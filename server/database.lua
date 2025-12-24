-- ================================================
-- SERVER - DATABASE HANDLER (MULTI-FARM)
-- Multi-Farm v0.3.0
-- ================================================

-- Local Debug Print
local function DebugPrint(...)
    if Config and Config.Debug then
        print('^3[Multi-Farm DB]^0', ...)
    end
end

-- ================================================
-- ZOMBIE SLOT CLEANUP
-- ================================================
function CleanupZombieSlots()
    DebugPrint('^3Checking for zombie slots...^0')
    
    local result = MySQL.query.await([[
        UPDATE multifarm_slots 
        SET is_occupied = 0, occupied_by = NULL 
        WHERE is_occupied = 1 
        AND occupied_by NOT IN (SELECT id FROM multifarm_owned)
    ]])
    
    if result and result.affectedRows > 0 then
        DebugPrint('^2Cleaned up ' .. result.affectedRows .. ' zombie slots^0')
        return result.affectedRows
    else
        DebugPrint('^2No zombie slots found^0')
        return 0
    end
end

-- ================================================
-- LOAD SLOTS
-- ================================================
function LoadSlotsFromDatabase()
    local slots = MySQL.query.await('SELECT * FROM multifarm_slots ORDER BY animal_type, slot_number')
    
    if slots then
        if Config then
            Config.Slots = slots
        end
        DebugPrint('^2Loaded ' .. #slots .. ' slots from database^0')
        return true
    else
        DebugPrint('^1Failed to load slots!^0')
        return false
    end
end

-- ================================================
-- GET FREE SLOTS (by animal type)
-- ================================================
function GetFreeSlots(animalType)
    local query = 'SELECT * FROM multifarm_slots WHERE is_occupied = 0'
    
    if animalType then
        query = query .. ' AND animal_type = ?'
    end
    
    query = query .. ' ORDER BY slot_number'
    
    local result
    if animalType then
        result = MySQL.query.await(query, {animalType})
    else
        result = MySQL.query.await(query)
    end
    
    return result or {}
end

-- ================================================
-- GET PLAYER ANIMALS
-- ================================================
function GetPlayerAnimals(identifier, animalType)
    local query = [[
        SELECT mo.*, ms.slot_number, ms.animal_type, ms.pos_x, ms.pos_y, ms.pos_z, ms.heading
        FROM multifarm_owned mo
        JOIN multifarm_slots ms ON mo.slot_id = ms.id
        WHERE mo.owner = ?
    ]]
    
    local params = {identifier}
    
    if animalType then
        query = query .. ' AND mo.animal_type = ?'
        table.insert(params, animalType)
    end
    
    local result = MySQL.query.await(query, params)
    
    return result or {}
end

-- ================================================
-- CHECK IF SLOT IS FREE
-- ================================================
function IsSlotFree(slotId)
    local result = MySQL.single.await('SELECT is_occupied FROM multifarm_slots WHERE id = ?', {slotId})
    if not result then 
        DebugPrint('^1IsSlotFree: No result for slot ' .. slotId .. '^0')
        return false 
    end
    
    local occupied = result.is_occupied
    local isFree = false
    
    if type(occupied) == 'boolean' then
        isFree = not occupied
    else
        isFree = (occupied == 0)
    end
    
    DebugPrint('^3IsSlotFree: Slot ' .. slotId .. ' occupied=' .. tostring(occupied) .. ' -> free=' .. tostring(isFree) .. '^0')
    
    return isFree
end

-- ================================================
-- PURCHASE ANIMAL
-- ================================================
function PurchaseAnimal(identifier, animalType, breedId, slotId, customName)
    DebugPrint('^3=== PURCHASE ANIMAL DEBUG ===^0')
    DebugPrint('^3Identifier: ' .. identifier .. '^0')
    DebugPrint('^3AnimalType: ' .. animalType .. '^0')
    DebugPrint('^3BreedID: ' .. breedId .. '^0')
    DebugPrint('^3SlotID: ' .. slotId .. '^0')
    
    -- 1. Check if slot is free
    local isFree = IsSlotFree(slotId)
    DebugPrint('^3Slot ' .. slotId .. ' is free? ' .. tostring(isFree) .. '^0')
    
    if not isFree then
        DebugPrint('^1Slot ' .. slotId .. ' is OCCUPIED!^0')
        
        -- Check if a zombie slot
        local animalInfo = MySQL.single.await('SELECT * FROM multifarm_owned WHERE slot_id = ?', {slotId})
        if animalInfo then
            DebugPrint('^3Animal exists: ID=' .. animalInfo.id .. ', Owner=' .. animalInfo.owner .. '^0')
            return false, 'already_owned'
        else
            DebugPrint('^1NO ANIMAL FOUND! Auto-fixing...^0')
            MySQL.update.await('UPDATE multifarm_slots SET is_occupied = 0, occupied_by = NULL WHERE id = ?', {slotId})
            DebugPrint('^2Slot ' .. slotId .. ' fixed and set to FREE!^0')
            return false, 'slot_was_inconsistent_now_fixed'
        end
    end
    
    -- 2. Insert animal
    local animalId = MySQL.insert.await([[
        INSERT INTO multifarm_owned (owner, animal_type, breed_id, slot_id, custom_name, stage, age_days, purchased_at)
        VALUES (?, ?, ?, ?, ?, 1, 0, NOW())
    ]], {
        identifier,
        animalType,
        breedId,
        slotId,
        customName or (animalType .. ' #' .. slotId)
    })
    
    if not animalId then
        DebugPrint('^1Failed to insert animal into database!^0')
        return false, 'database_error'
    end
    
    -- 3. Update slot status
    MySQL.update.await('UPDATE multifarm_slots SET is_occupied = 1, occupied_by = ? WHERE id = ?', {animalId, slotId})
    
    DebugPrint('^2Player ' .. identifier .. ' purchased ' .. animalType .. ' (ID: ' .. animalId .. ') at slot ' .. slotId .. '^0')
    
    return true, animalId
end

-- ================================================
-- DELETE ANIMAL
-- ================================================
function DeleteAnimal(animalId)
    local animal = MySQL.single.await('SELECT slot_id FROM multifarm_owned WHERE id = ?', {animalId})
    
    if not animal then
        DebugPrint('^1Animal ' .. animalId .. ' not found!^0')
        return false
    end
    
    -- Free slot FIRST
    MySQL.update.await('UPDATE multifarm_slots SET is_occupied = 0, occupied_by = NULL WHERE id = ?', {animal.slot_id})
    
    -- Delete animal
    MySQL.query.await('DELETE FROM multifarm_owned WHERE id = ?', {animalId})
    
    DebugPrint('^3Animal ' .. animalId .. ' deleted and slot freed^0')
    return true
end

-- ================================================
-- INITIALIZATION
-- ================================================
CreateThread(function()
    Wait(2000)
    
    DebugPrint('^3Initializing database...^0')
    
    -- 1. Cleanup zombie slots
    local zombiesFixed = CleanupZombieSlots()
    if zombiesFixed > 0 then
        DebugPrint('^2Auto-repaired ' .. zombiesFixed .. ' inconsistent slots^0')
    end
    
    -- 2. Load slots
    local success = LoadSlotsFromDatabase()
    
    if success then
        local freeCows = GetFreeSlots('cow')
        local freeChickens = GetFreeSlots('chicken')
        local freePigs = GetFreeSlots('pig')
        
        DebugPrint('^2Database ready!^0')
        DebugPrint('^2  Cow slots: ' .. #freeCows .. '/10^0')
        DebugPrint('^2  Chicken slots: ' .. #freeChickens .. '/10^0')
        DebugPrint('^2  Pig slots: ' .. #freePigs .. '/10^0')
    else
        DebugPrint('^1Database initialization FAILED!^0')
    end
end)

-- ================================================
-- EXPORTS
-- ================================================
exports('GetPlayerAnimals', GetPlayerAnimals)
exports('GetFreeSlots', GetFreeSlots)
exports('PurchaseAnimal', PurchaseAnimal)
exports('DeleteAnimal', DeleteAnimal)
exports('CleanupZombieSlots', CleanupZombieSlots)
