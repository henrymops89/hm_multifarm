-- ================================================
-- SERVER - CHICKEN SYSTEM (EGG COLLECTION)
-- Multi-Farm v0.3.0
-- ================================================

local function DebugPrint(...)
    if Config and Config.Debug then
        print('^3[Multi-Farm Chicken]^0', ...)
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
-- CHECK: Can collect eggs?
-- ================================================
local function CanCollectEggs(chickenId)
    DebugPrint('^3CanCollectEggs: Checking chicken ' .. tostring(chickenId) .. '^0')
    
    local chicken = MySQL.single.await('SELECT last_collected FROM multifarm_owned WHERE id = ? AND animal_type = ?', {chickenId, 'chicken'})
    
    if not chicken then
        DebugPrint('^1Chicken ' .. tostring(chickenId) .. ' not found!^0')
        return false, 'Huhn nicht gefunden!'
    end
    
    local lastCollectedTimestamp = ParseLastCollected(chicken.last_collected)
    
    if not lastCollectedTimestamp then
        DebugPrint('^2Never collected before - OK to collect^0')
        return true, nil
    end
    
    local now = os.time()
    local cooldownSeconds = Config.EggCollection.CooldownMinutes * 60
    local elapsedSeconds = now - lastCollectedTimestamp
    
    DebugPrint('^3Cooldown check: Elapsed=' .. elapsedSeconds .. 's, Required=' .. cooldownSeconds .. 's^0')
    
    if elapsedSeconds < cooldownSeconds then
        local remainingSeconds = cooldownSeconds - elapsedSeconds
        local timeString = FormatTime(remainingSeconds)
        return false, string.format(Config.EggCollection.Notifications.cooldown, timeString)
    end
    
    return true, nil
end

-- ================================================
-- COLLECT EGGS
-- ================================================
local function CollectEggs(source, chickenId)
    DebugPrint('^3=== CollectEggs called for chicken ' .. tostring(chickenId) .. ' ===^0')
    
    local identifier = Framework.GetPlayerIdentifier(source)
    
    if not identifier then
        DebugPrint('^1Could not get identifier for source ' .. tostring(source) .. '^0')
        return false, Config.EggCollection.Notifications.error
    end
    
    -- 1. Check if chicken belongs to player
    local chicken = MySQL.single.await('SELECT * FROM multifarm_owned WHERE id = ? AND owner = ? AND animal_type = ?', {chickenId, identifier, 'chicken'})
    
    if not chicken then
        DebugPrint('^1Chicken ' .. tostring(chickenId) .. ' not owned by ' .. tostring(identifier) .. '^0')
        return false, '\u{274C} Das ist nicht dein Huhn!'
    end
    
    -- 2. Check cooldown
    local canCollect, cooldownMsg = CanCollectEggs(chickenId)
    if not canCollect then
        return false, cooldownMsg
    end
    
    -- 3. Calculate egg amount based on breed
    local breed = Config.GetAnimalType('chicken', chicken.breed_id)
    local eggAmount = breed and breed.stats.egg_base or Config.EggCollection.Output.amount
    
    -- 4. Give eggs
    local success = Inventory.AddItem(source, Config.EggCollection.Output.item, eggAmount)
    
    if not success then
        return false, '\u{274C} Inventar voll!'
    end
    
    -- 5. Set cooldown
    local currentDateTime = os.date('%Y-%m-%d %H:%M:%S')
    
    MySQL.update.await([[
        UPDATE multifarm_owned 
        SET last_collected = ?, 
            total_produced = total_produced + ?
        WHERE id = ?
    ]], {currentDateTime, eggAmount, chickenId})
    
    DebugPrint('^2Player ' .. identifier .. ' collected ' .. eggAmount .. ' eggs from chicken ' .. chickenId .. '^0')
    
    local successMsg = string.format(
        Config.EggCollection.Notifications.success, 
        eggAmount, 
        Config.EggCollection.Output.label
    )
    
    return true, successMsg
end

-- ================================================
-- CALLBACKS
-- ================================================

lib.callback.register('multifarm:collectEggs', function(source, chickenId)
    DebugPrint('^3Callback received: source=' .. tostring(source) .. ', chickenId=' .. tostring(chickenId) .. '^0')
    
    if not chickenId then
        return false, '\u{274C} Ungültige Hühner-ID!'
    end
    
    local success, result, message = pcall(function()
        return CollectEggs(source, chickenId)
    end)
    
    if not success then
        DebugPrint('^1CollectEggs error: ' .. tostring(result) .. '^0')
        return false, '\u{274C} Server-Fehler: ' .. tostring(result)
    end
    
    return result, message
end)

-- ================================================
-- EXPORTS
-- ================================================

exports('CollectEggs', CollectEggs)
exports('CanCollectEggs', CanCollectEggs)

DebugPrint('^2Chicken system loaded^0')
