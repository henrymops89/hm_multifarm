-- ================================================
-- SERVER - SHOP LOGIC (MULTI-FARM)
-- Handles purchases for Cows, Chickens, and Pigs
-- ================================================

local function DebugPrint(...)
    if Config and Config.Debug then
        print('^3[Multi-Farm Shop]^0', ...)
    end
end

-- ================================================
-- CALLBACK: Get Shop Data (by animal type)
-- ================================================
lib.callback.register('multifarm:getShopData', function(source, animalType)
    local freeSlots = GetFreeSlots(animalType)
    
    DebugPrint('^3Player ' .. source .. ' opened ' .. animalType .. ' shop^0')
    
    local animalTypes
    local farmName
    
    if animalType == 'cow' then
        animalTypes = Config.CowTypes
        farmName = 'Kuh-Farm'
    elseif animalType == 'chicken' then
        animalTypes = Config.ChickenTypes
        farmName = 'Hühner-Farm'
    elseif animalType == 'pig' then
        animalTypes = Config.PigTypes
        farmName = 'Schweine-Farm'
    else
        return nil
    end
    
    return {
        animalTypes = animalTypes,
        freeSlots = freeSlots,
        totalSlots = 10,  -- 10 per animal type
        farmName = farmName,
        animalType = animalType
    }
end)

-- ================================================
-- CALLBACK: Purchase Animal
-- ================================================
lib.callback.register('multifarm:purchaseAnimal', function(source, data)
    local src = source
    local animalType = data.animalType  -- 'cow', 'chicken', 'pig'
    local breedId = data.breedId
    local slotId = data.slotId
    local customName = data.customName
    
    DebugPrint('^3Purchase request: Player=' .. src .. ', Type=' .. animalType .. ', Breed=' .. breedId .. ', Slot=' .. slotId .. '^0')
    
    -- 1. Get Player Identifier
    local identifier = Framework.GetPlayerIdentifier(src)
    
    if not identifier then
        DebugPrint('^1Could not get identifier for source ' .. src .. '^0')
        return false, 'no_identifier'
    end
    
    -- 2. Get Breed Info
    local breed = Config.GetAnimalType(animalType, breedId)
    if not breed then
        DebugPrint('^1Invalid breed: ' .. breedId .. '^0')
        return false, 'invalid_breed'
    end
    
    -- 3. Check Money
    local playerMoney = Framework.GetMoney(src, Config.Economy.Currency)
    
    if playerMoney < breed.price then
        DebugPrint('^1Player ' .. identifier .. ' has insufficient funds: ' .. playerMoney .. ' < ' .. breed.price .. '^0')
        
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Multi-Farm',
            description = Config.Notifications.Error.no_money,
            type = 'error'
        })
        return false, 'no_money'
    end
    
    -- 4. Purchase Animal
    local success, animalId = PurchaseAnimal(identifier, animalType, breedId, slotId, customName)
    
    if not success then
        local errorMsg = Config.Notifications.Error[animalId] or Config.Notifications.Error.database_error
        
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Multi-Farm',
            description = errorMsg,
            type = 'error'
        })
        
        DebugPrint('^1Purchase failed: ' .. animalId .. '^0')
        return false, animalId
    end
    
    -- 5. Remove Money
    Framework.RemoveMoney(src, breed.price, Config.Economy.Currency)
    
    -- 6. Success Notification
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Multi-Farm',
        description = Config.Notifications.Success.animal_purchased,
        type = 'success'
    })
    
    DebugPrint('^2✅ PURCHASE SUCCESS: Player=' .. identifier .. ', Animal=' .. breed.name .. ', Price=$' .. breed.price .. ', ID=' .. animalId .. '^0')
    
    -- 7. Return Slot Info for spawning
    local slotData = Config.GetSlotById(slotId)
    
    return true, {
        animalId = animalId,
        animalType = animalType,
        breedId = breedId,
        slot = slotData,
        animalName = customName or (breed.name .. ' #' .. slotId)
    }
end)

-- ================================================
-- CALLBACK: Get My Animals (by type or all)
-- ================================================
lib.callback.register('multifarm:getMyAnimals', function(source, animalType)
    local identifier = Framework.GetPlayerIdentifier(source)
    if not identifier then
        DebugPrint('^1Could not get identifier for source ' .. source .. '^0')
        return {}
    end
    
    local animals = GetPlayerAnimals(identifier, animalType)
    
    if animalType then
        DebugPrint('^3Player ' .. identifier .. ' has ' .. #animals .. ' ' .. animalType .. 's^0')
    else
        DebugPrint('^3Player ' .. identifier .. ' has ' .. #animals .. ' total animals^0')
    end
    
    return animals
end)
