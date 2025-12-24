-- ================================================
-- SERVER - PIG SYSTEM (FEEDING & COLLECTION)
-- Multi-Farm v0.3.0
-- ================================================

local function DebugPrint(...)
    if Config and Config.Debug then
        print('^3[Multi-Farm Pig]^0', ...)
    end
end

-- ================================================
-- HELPER: Format Time
-- ================================================
local function FormatTime(seconds)
    if seconds < 60 then
        return string.format('%d Sekunden', seconds)
    elseif seconds < 3600 then
        local mins = math.floor(seconds / 60)
        return string.format('%d Minuten', mins)
    else
        local hours = math.floor(seconds / 3600)
        local mins = math.floor((seconds % 3600) / 60)
        return string.format('%d Stunden %d Minuten', hours, mins)
    end
end

-- ================================================
-- HELPER: Parse last_collected to timestamp
-- ================================================
local function ParseLastCollected(lastCollected)
    if not lastCollected then
        return nil
    end
    
    local lastCollectedType = type(lastCollected)
    
    if lastCollectedType == 'number' then
        if lastCollected > 4102444800 then
            return math.floor(lastCollected / 1000)
        else
            return lastCollected
        end
    end
    
    if lastCollectedType == 'string' then
        if lastCollected == '' then
            return nil
        end
        
        local year, month, day, hour, min, sec = lastCollected:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
        
        if year then
            local timestamp = os.time({
                year = tonumber(year),
                month = tonumber(month),
                day = tonumber(day),
                hour = tonumber(hour),
                min = tonumber(min),
                sec = tonumber(sec)
            })
            return timestamp
        end
    end
    
    return nil
end

-- ================================================
-- CHECK: Can feed pig?
-- ================================================
local function CanFeedPig(pigId)
    DebugPrint('^3CanFeedPig: Checking pig ' .. tostring(pigId) .. '^0')
    
    local pig = MySQL.single.await('SELECT last_collected FROM multifarm_owned WHERE id = ? AND animal_type = ?', {pigId, 'pig'})
    
    if not pig then
        DebugPrint('^1Pig ' .. tostring(pigId) .. ' not found!^0')
        return false, 'Schwein nicht gefunden!'
    end
    
    local lastCollectedTimestamp = ParseLastCollected(pig.last_collected)
    
    if not lastCollectedTimestamp then
        DebugPrint('^2Never fed before - OK to feed^0')
        return true, nil
    end
    
    local now = os.time()
    local cooldownSeconds = Config.PigFeeding.CooldownMinutes * 60
    local elapsedSeconds = now - lastCollectedTimestamp
    
    DebugPrint('^3Cooldown check: Elapsed=' .. elapsedSeconds .. 's, Required=' .. cooldownSeconds .. 's^0')
    
    if elapsedSeconds < cooldownSeconds then
        local remainingSeconds = cooldownSeconds - elapsedSeconds
        local timeString = FormatTime(remainingSeconds)
        return false, string.format(Config.PigFeeding.Notifications.cooldown, timeString)
    end
    
    return true, nil
end

-- ================================================
-- FEED PIG
-- ================================================
local function FeedPig(source, pigId)
    DebugPrint('^3=== FeedPig called for pig ' .. tostring(pigId) .. ' ===^0')
    
    local identifier = Framework.GetPlayerIdentifier(source)
    
    if not identifier then
        DebugPrint('^1Could not get identifier for source ' .. tostring(source) .. '^0')
        return false, Config.PigFeeding.Notifications.error
    end
    
    -- 1. Check if pig belongs to player
    local pig = MySQL.single.await('SELECT * FROM multifarm_owned WHERE id = ? AND owner = ? AND animal_type = ?', {pigId, identifier, 'pig'})
    
    if not pig then
        DebugPrint('^1Pig ' .. tostring(pigId) .. ' not owned by ' .. tostring(identifier) .. '^0')
        return false, '\u{274C} Das ist nicht dein Schwein!'
    end
    
    -- 2. Check cooldown
    local canFeed, cooldownMsg = CanFeedPig(pigId)
    if not canFeed then
        return false, cooldownMsg
    end
    
    -- 3. Check for feed
    if Config.PigFeeding.RequireItems then
        local hasFeed = Inventory.HasItem(source, Config.PigFeeding.RequiredItems.feed, 1)
        
        if not hasFeed then
            DebugPrint('^1Player ' .. tostring(identifier) .. ' missing pig feed^0')
            return false, Config.PigFeeding.Notifications.no_feed
        end
        
        -- Remove feed
        if Config.PigFeeding.RemoveItemsAfterUse then
            Inventory.RemoveItem(source, Config.PigFeeding.RequiredItems.feed, 1)
        end
    end
    
    -- 4. Calculate pork amount based on breed
    local breed = Config.GetAnimalType('pig', pig.breed_id)
    local porkAmount = breed and breed.stats.pork_base or Config.PigFeeding.Output.amount
    
    -- 5. Give pork
    local success = Inventory.AddItem(source, Config.PigFeeding.Output.item, porkAmount)
    
    if not success then
        -- Refund feed if inventory full
        if Config.PigFeeding.RequireItems and Config.PigFeeding.RemoveItemsAfterUse then
            Inventory.AddItem(source, Config.PigFeeding.RequiredItems.feed, 1)
        end
        return false, '\u{274C} Inventar voll!'
    end
    
    -- 6. Set cooldown
    local currentDateTime = os.date('%Y-%m-%d %H:%M:%S')
    
    MySQL.update.await([[
        UPDATE multifarm_owned 
        SET last_collected = ?, 
            total_produced = total_produced + ?
        WHERE id = ?
    ]], {currentDateTime, porkAmount, pigId})
    
    DebugPrint('^2Player ' .. identifier .. ' fed pig ' .. pigId .. ' and got ' .. porkAmount .. ' pork^0')
    
    local successMsg = string.format(
        Config.PigFeeding.Notifications.success, 
        porkAmount, 
        Config.PigFeeding.Output.label
    )
    
    return true, successMsg
end

-- ================================================
-- CALLBACKS
-- ================================================

lib.callback.register('multifarm:feedPig', function(source, pigId)
    DebugPrint('^3Callback received: source=' .. tostring(source) .. ', pigId=' .. tostring(pigId) .. '^0')
    
    if not pigId then
        return false, '\u{274C} Ungültige Schweine-ID!'
    end
    
    local success, result, message = pcall(function()
        return FeedPig(source, pigId)
    end)
    
    if not success then
        DebugPrint('^1FeedPig error: ' .. tostring(result) .. '^0')
        return false, '\u{274C} Server-Fehler: ' .. tostring(result)
    end
    
    return result, message
end)

-- ================================================
-- EXPORTS
-- ================================================

exports('FeedPig', FeedPig)
exports('CanFeedPig', CanFeedPig)

DebugPrint('^2Pig system loaded^0')
