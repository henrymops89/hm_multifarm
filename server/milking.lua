-- ================================================
-- SERVER - MILKING SYSTEM (Multi-Farm v2)
-- HM Multi-Farm v0.2.0
-- Uses: multifarm_owned table with animal_type
-- ================================================

-- Local Debug Print
local function DebugPrint(...)
    if Config and Config.Debug then
        print('^3[Multi-Farm Milking]^0', ...)
    end
end

-- ================================================
-- FALLBACK: Inventory Bridge (if not loaded)
-- ================================================
if not Inventory then
    DebugPrint('^1Inventory not found! Creating fallback...^0')
    
    Inventory = {}
    
    function Inventory.HasItem(source, item, amount)
        amount = amount or 1
        local count = exports.ox_inventory:Search(source, 'count', item)
        return count >= amount
    end
    
    function Inventory.RemoveItem(source, item, amount)
        amount = amount or 1
        return exports.ox_inventory:RemoveItem(source, item, amount)
    end
    
    function Inventory.AddItem(source, item, amount, metadata)
        amount = amount or 1
        return exports.ox_inventory:AddItem(source, item, amount, metadata)
    end
    
    DebugPrint('^2Inventory fallback created!^0')
else
    DebugPrint('^2Inventory loaded from bridge^0')
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
    
    local valueType = type(lastCollected)
    DebugPrint('^3ParseLastCollected: type=' .. valueType .. ', value=' .. tostring(lastCollected) .. '^0')
    
    -- Case 1: Already a number (Unix timestamp)
    if valueType == 'number' then
        DebugPrint('^3last_collected is a number: ' .. lastCollected .. '^0')
        if lastCollected > 4102444800 then
            return math.floor(lastCollected / 1000)
        else
            return lastCollected
        end
    end
    
    -- Case 2: String (DATETIME format)
    if valueType == 'string' then
        DebugPrint('^3last_collected is a string: ' .. lastCollected .. '^0')
        
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
            DebugPrint('^3Parsed DATETIME to timestamp: ' .. timestamp .. '^0')
            return timestamp
        else
            DebugPrint('^1Failed to parse DATETIME string!^0')
            return nil
        end
    end
    
    DebugPrint('^1Unknown type for last_collected!^0')
    return nil
end

-- ================================================
-- CHECK: Can animal be collected from?
-- ================================================
local function CanCollect(animalId, animalType)
    DebugPrint('^3CanCollect: Checking ' .. animalType .. ' #' .. tostring(animalId) .. '^0')
    
    local animal = MySQL.single.await('SELECT last_collected FROM multifarm_owned WHERE id = ? AND animal_type = ?', {animalId, animalType})
    
    if not animal then
        DebugPrint('^1' .. animalType .. ' #' .. tostring(animalId) .. ' not found in database!^0')
        return false, 'Tier nicht gefunden!'
    end
    
    DebugPrint('^3last_collected raw value: ' .. tostring(animal.last_collected) .. ' (type: ' .. type(animal.last_collected) .. ')^0')
    
    local lastCollectedTimestamp = ParseLastCollected(animal.last_collected)
    
    if not lastCollectedTimestamp then
        DebugPrint('^2Never collected before - OK to collect^0')
        return true, nil
    end
    
    local now = os.time()
    local cooldownSeconds = Config.Milking.CooldownMinutes * 60
    local elapsedSeconds = now - lastCollectedTimestamp
    
    DebugPrint('^3Cooldown check:^0')
    DebugPrint('^3  Now: ' .. now .. ' (' .. os.date('%Y-%m-%d %H:%M:%S', now) .. ')^0')
    DebugPrint('^3  Last collected: ' .. lastCollectedTimestamp .. ' (' .. os.date('%Y-%m-%d %H:%M:%S', lastCollectedTimestamp) .. ')^0')
    DebugPrint('^3  Elapsed: ' .. tostring(elapsedSeconds) .. ' seconds (' .. math.floor(elapsedSeconds/60) .. ' minutes)^0')
    DebugPrint('^3  Required: ' .. tostring(cooldownSeconds) .. ' seconds (' .. Config.Milking.CooldownMinutes .. ' minutes)^0')
    
    if elapsedSeconds < cooldownSeconds then
        local remainingSeconds = cooldownSeconds - elapsedSeconds
        local timeString = FormatTime(remainingSeconds)
        DebugPrint('^3Cooldown active! Remaining: ' .. tostring(remainingSeconds) .. ' seconds (' .. timeString .. ')^0')
        return false, string.format(Config.Milking.Notifications.cooldown, timeString)
    end
    
    DebugPrint('^2Cooldown expired - OK to collect^0')
    return true, nil
end

-- ================================================
-- MILK COW
-- ================================================
local function MilkCow(source, cowId)
    DebugPrint('^3=== MilkCow called for cow ' .. tostring(cowId) .. ' ===^0')
    
    local identifier = Framework.GetPlayerIdentifier(source)
    
    if not identifier then
        DebugPrint('^1Could not get identifier for source ' .. tostring(source) .. '^0')
        return false, Config.Milking.Notifications.error
    end
    
    DebugPrint('^3Player ' .. tostring(identifier) .. ' attempting to milk cow ' .. tostring(cowId) .. '^0')
    
    -- 1. Check if cow belongs to player (with slot info)
    DebugPrint('^3Checking cow ownership...^0')
    local cow = MySQL.single.await([[
        SELECT o.*, s.pos_x, s.pos_y, s.pos_z, s.heading 
        FROM multifarm_owned o
        JOIN multifarm_slots s ON o.slot_id = s.id
        WHERE o.id = ? AND o.owner = ? AND o.animal_type = ?
    ]], {cowId, identifier, 'cow'})
    
    if not cow then
        DebugPrint('^1Cow ' .. tostring(cowId) .. ' not owned by ' .. tostring(identifier) .. '^0')
        return false, '\u{274C} Das ist nicht deine Kuh!'
    end
    
    DebugPrint('^2Cow ownership verified^0')
    
    -- 2. Check cooldown
    DebugPrint('^3Checking cooldown...^0')
    local canMilk, cooldownMsg = CanCollect(cowId, 'cow')
    if not canMilk then
        DebugPrint('^3Cow ' .. tostring(cowId) .. ' is on cooldown: ' .. tostring(cooldownMsg) .. '^0')
        return false, cooldownMsg
    end
    
    DebugPrint('^2Cooldown check passed^0')
    
    -- 3. Check items
    if Config.Milking.RequireItems then
        DebugPrint('^3Checking items...^0')
        
        local hasBucket = Inventory.HasItem(source, Config.Milking.RequiredItems.bucket, 1)
        local hasStool = Inventory.HasItem(source, Config.Milking.RequiredItems.stool, 1)
        
        DebugPrint('^3Has bucket: ' .. tostring(hasBucket) .. '^0')
        DebugPrint('^3Has stool: ' .. tostring(hasStool) .. '^0')
        
        if not hasBucket then
            DebugPrint('^1Player ' .. tostring(identifier) .. ' missing bucket^0')
            return false, Config.Milking.Notifications.no_items_bucket
        end
        
        if not hasStool then
            DebugPrint('^1Player ' .. tostring(identifier) .. ' missing stool^0')
            return false, Config.Milking.Notifications.no_items_stool
        end
        
        DebugPrint('^2Item check passed^0')
        
        if Config.Milking.RemoveItemsAfterUse then
            Inventory.RemoveItem(source, Config.Milking.RequiredItems.bucket, 1)
            Inventory.RemoveItem(source, Config.Milking.RequiredItems.stool, 1)
        end
    else
        DebugPrint('^3Item check skipped (RequireItems = false)^0')
    end
    
    -- 4. Give milk
    DebugPrint('^3Adding milk to inventory...^0')
    
    local success = Inventory.AddItem(source, Config.Milking.Output.item, Config.Milking.Output.amount)
    
    DebugPrint('^3AddItem result: ' .. tostring(success) .. '^0')
    
    if not success then
        DebugPrint('^1Failed to give milk to player ' .. tostring(identifier) .. '^0')
        return false, '\u{274C} Inventar voll!'
    end
    
    -- 5. Set cooldown
    DebugPrint('^3Setting cooldown...^0')
    
    local currentDateTime = os.date('%Y-%m-%d %H:%M:%S')
    DebugPrint('^3Current datetime: ' .. currentDateTime .. '^0')
    
    local affectedRows = MySQL.update.await([[
        UPDATE multifarm_owned 
        SET last_collected = ?, 
            total_produced = total_produced + ?
        WHERE id = ? AND animal_type = ?
    ]], {currentDateTime, Config.Milking.Output.amount, cowId, 'cow'})
    
    DebugPrint('^3Database UPDATE executed. Affected rows: ' .. tostring(affectedRows) .. '^0')
    
    if affectedRows and affectedRows > 0 then
        DebugPrint('^2Cooldown set successfully for cow ' .. tostring(cowId) .. ' (datetime: ' .. currentDateTime .. ')^0')
    else
        DebugPrint('^1WARNING: Database UPDATE may have failed! Affected rows: ' .. tostring(affectedRows) .. '^0')
    end
    
    DebugPrint('^2Player ' .. tostring(identifier) .. ' successfully milked cow ' .. tostring(cowId) .. '^0')
    
    local successMsg = string.format(
        Config.Milking.Notifications.success, 
        Config.Milking.Output.amount, 
        Config.Milking.Output.label
    )
    
    DebugPrint('^2Success message: ' .. successMsg .. '^0')
    
    return true, successMsg
end

-- ================================================
-- GET COOLDOWN INFO
-- ================================================
local function GetCooldown(animalId, animalType)
    local animal = MySQL.single.await('SELECT last_collected FROM multifarm_owned WHERE id = ? AND animal_type = ?', {animalId, animalType})
    
    if not animal then
        return {
            canCollect = true,
            cooldownActive = false,
            remainingSeconds = 0,
            remainingFormatted = 'Bereit'
        }
    end
    
    local lastCollectedTimestamp = ParseLastCollected(animal.last_collected)
    
    if not lastCollectedTimestamp then
        return {
            canCollect = true,
            cooldownActive = false,
            remainingSeconds = 0,
            remainingFormatted = 'Bereit'
        }
    end
    
    local canCollect, cooldownMsg = CanCollect(animalId, animalType)
    
    if canCollect then
        return {
            canCollect = true,
            cooldownActive = false,
            remainingSeconds = 0,
            remainingFormatted = 'Bereit'
        }
    else
        local now = os.time()
        local cooldownSeconds = Config.Milking.CooldownMinutes * 60
        local elapsed = now - lastCollectedTimestamp
        local remaining = cooldownSeconds - elapsed
        
        return {
            canCollect = false,
            cooldownActive = true,
            remainingSeconds = remaining,
            remainingFormatted = FormatTime(remaining)
        }
    end
end

-- ================================================
-- GET ANIMAL WITH SLOT INFO
-- ================================================
local function GetAnimalWithSlot(animalId, animalType)
    return MySQL.single.await([[
        SELECT o.*, s.pos_x, s.pos_y, s.pos_z, s.heading, s.slot_number
        FROM multifarm_owned o
        JOIN multifarm_slots s ON o.slot_id = s.id
        WHERE o.id = ? AND o.animal_type = ?
    ]], {animalId, animalType})
end

-- ================================================
-- GET PLAYER'S ANIMALS WITH SLOTS
-- ================================================
local function GetPlayerAnimals(identifier, animalType)
    return MySQL.query.await([[
        SELECT o.*, s.pos_x, s.pos_y, s.pos_z, s.heading, s.slot_number
        FROM multifarm_owned o
        JOIN multifarm_slots s ON o.slot_id = s.id
        WHERE o.owner = ? AND o.animal_type = ?
        ORDER BY s.slot_number ASC
    ]], {identifier, animalType})
end

-- ================================================
-- CALLBACKS
-- ================================================

-- Callback: Milk cow
lib.callback.register('multifarm:milkCow', function(source, cowId)
    DebugPrint('^3Callback received: source=' .. tostring(source) .. ', cowId=' .. tostring(cowId) .. '^0')
    
    if not cowId then
        DebugPrint('^1Invalid cowId: nil^0')
        return false, '\u{274C} Ungültige Kuh-ID!'
    end
    
    if not source then
        DebugPrint('^1Invalid source: nil^0')
        return false, '\u{274C} Ungültiger Spieler!'
    end
    
    local success, result, message = pcall(function()
        return MilkCow(source, cowId)
    end)
    
    if not success then
        DebugPrint('^1MilkCow error: ' .. tostring(result) .. '^0')
        return false, '\u{274C} Server-Fehler: ' .. tostring(result)
    end
    
    DebugPrint('^3MilkCow returned: success=' .. tostring(result) .. ', message=' .. tostring(message) .. '^0')
    
    return result, message
end)

-- Callback: Get cooldown info
lib.callback.register('multifarm:getCowCooldown', function(source, cowId)
    return GetCooldown(cowId, 'cow')
end)

-- Callback: Get player's animals with slot info
lib.callback.register('multifarm:getPlayerAnimals', function(source, animalType)
    local identifier = Framework.GetPlayerIdentifier(source)
    if not identifier then
        return {}
    end
    return GetPlayerAnimals(identifier, animalType)
end)

-- ================================================
-- EXPORTS
-- ================================================

exports('MilkCow', MilkCow)
exports('CanCollect', CanCollect)
exports('GetCooldown', GetCooldown)
exports('GetAnimalWithSlot', GetAnimalWithSlot)
exports('GetPlayerAnimals', GetPlayerAnimals)

DebugPrint('^2Milking system loaded (Multi-Farm v2 - uses multifarm_owned table)^0')