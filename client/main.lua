-- ================================================
-- CLIENT - MAIN (MULTI-FARM)
-- Spawns Cows, Chickens, and Pigs
-- ================================================

local function DebugPrint(...)
    if Config and Config.Debug then
        print('^3[Multi-Farm]^0', ...)
    end
end

local spawnedAnimals = {} -- {animalId = {entity = ped, blip = blip, type = 'cow'/'chicken'/'pig'}}

-- ================================================
-- ADD OX_TARGET
-- ================================================
local function AddAnimalTarget(entity, animalId, animalType)
    if not entity or not DoesEntityExist(entity) then
        return
    end
    
    local timeout = 0
    while not IsEntityVisible(entity) and timeout < 5000 do
        Wait(100)
        timeout = timeout + 100
    end
    
    if not DoesEntityExist(entity) then
        return
    end
    
    local targetConfig
    local eventName
    
    if animalType == 'cow' then
        targetConfig = Config.Milking.Target
        eventName = 'multifarm:startMilking'
    elseif animalType == 'chicken' then
        targetConfig = Config.EggCollection.Target
        eventName = 'multifarm:collectEggs'
    elseif animalType == 'pig' then
        targetConfig = Config.PigFeeding.Target
        eventName = 'multifarm:feedPig'
    else
        return
    end
    
    exports.ox_target:addLocalEntity(entity, {
        {
            name = 'multifarm_' .. animalType .. '_' .. tostring(animalId),
            label = targetConfig.Label,
            icon = targetConfig.Icon,
            distance = targetConfig.Distance,
            onSelect = function()
                DebugPrint('^3ox_target triggered for ' .. animalType .. ' ' .. tostring(animalId) .. '^0')
                TriggerEvent(eventName, entity, animalId)
            end
        }
    })
    
    DebugPrint('^2✅ ox_target added to ' .. animalType .. ' #' .. tostring(animalId) .. '^0')
end

-- ================================================
-- SPAWN ANIMAL
-- ================================================
function SpawnAnimal(animalId, animalType, breedId, slot, customName)
    local breed = Config.GetAnimalType(animalType, breedId)
    if not breed then
        DebugPrint('^1Unknown breed: ' .. breedId .. '^0')
        return nil
    end
    
    local model = GetHashKey(breed.model)
    
    -- Load Model
    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 5000 do
        Wait(100)
        timeout = timeout + 100
    end
    
    if not HasModelLoaded(model) then
        DebugPrint('^1Failed to load model: ' .. breed.model .. '^0')
        return nil
    end
    
    -- Spawn Entity
    local animal = CreatePed(28, model, slot.pos_x, slot.pos_y, slot.pos_z, slot.heading, false, false)
    
    if DoesEntityExist(animal) then
        -- Configure Ped
        SetEntityAsMissionEntity(animal, true, true)
        SetPedFleeAttributes(animal, 0, false)
        SetBlockingOfNonTemporaryEvents(animal, true)
        SetEntityInvincible(animal, true)
        SetPedCanRagdoll(animal, false)
        
        -- Start Scenario
        if breed.scenario then
            TaskStartScenarioInPlace(animal, breed.scenario, 0, true)
        end
        
        -- CREATE BLIP
        local blip = nil
        if Config.AnimalBlips and Config.AnimalBlips.Enabled then
            blip = AddBlipForEntity(animal)
            
            SetBlipSprite(blip, Config.AnimalBlips.Sprite)
            SetBlipScale(blip, Config.AnimalBlips.Scale)
            
            local blipColor = Config.AnimalBlips.Color[breedId] or Config.AnimalBlips.Color.default
            SetBlipColour(blip, blipColor)
            
            SetBlipAsShortRange(blip, true)
            
            if Config.AnimalBlips.ShowName then
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(customName or (breed.name .. ' #' .. animalId))
                EndTextCommandSetBlipName(blip)
            end
        end
        
        -- Store Reference
        spawnedAnimals[animalId] = {
            entity = animal,
            blip = blip,
            type = animalType,
            name = customName
        }
        
        DebugPrint('^2✅ Spawned ' .. animalType .. ' #' .. animalId .. ' (' .. breed.name .. ')^0')
        
        -- Notification
        lib.notify({
            title = 'Multi-Farm',
            description = 'Dein Tier wurde gespawnt!',
            type = 'success'
        })
        
        -- ADD OX_TARGET
        CreateThread(function()
            AddAnimalTarget(animal, animalId, animalType)
        end)
        
        return animal
    else
        DebugPrint('^1Failed to spawn ' .. animalType .. ' entity!^0')
        return nil
    end
end

-- ================================================
-- LOAD MY ANIMALS
-- ================================================
function LoadMyAnimals(animalType)
    DebugPrint('^3Loading player animals (' .. (animalType or 'all') .. ')...^0')
    
    lib.callback('multifarm:getMyAnimals', false, function(animals)
        if not animals or #animals == 0 then
            DebugPrint('^3No animals owned^0')
            return
        end
        
        DebugPrint('^2Loading ' .. #animals .. ' owned animals...^0')
        
        for _, animal in ipairs(animals) do
            SpawnAnimal(animal.id, animal.animal_type, animal.breed_id, {
                pos_x = animal.pos_x,
                pos_y = animal.pos_y,
                pos_z = animal.pos_z,
                heading = animal.heading,
                slot_number = animal.slot_number
            }, animal.custom_name)
        end
    end, animalType)
end

-- ================================================
-- INITIALIZATION
-- ================================================

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(1000)
    end
    
    Wait(5000)
    
    DebugPrint('^3Player spawned - loading animals...^0')
    LoadMyAnimals() -- Load all animals
end)

-- Framework spawn events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    LoadMyAnimals()
end)

RegisterNetEvent('esx:playerLoaded', function()
    Wait(2000)
    LoadMyAnimals()
end)

-- Event: New animal purchased
RegisterNetEvent('multifarm:animalPurchased', function(data)
    DebugPrint('^2Animal purchased: ' .. data.animalType .. ' ID=' .. data.animalId .. '^0')
    SpawnAnimal(data.animalId, data.animalType, data.breedId, data.slot, data.animalName)
end)

-- ================================================
-- CLEANUP
-- ================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    local count = 0
    for _ in pairs(spawnedAnimals) do count = count + 1 end
    
    DebugPrint('^3Cleaning up ' .. count .. ' spawned animals...^0')
    
    for animalId, data in pairs(spawnedAnimals) do
        if data.entity and DoesEntityExist(data.entity) then
            DeleteEntity(data.entity)
        end
        if data.blip and DoesBlipExist(data.blip) then
            RemoveBlip(data.blip)
        end
    end
    
    spawnedAnimals = {}
end)

-- ================================================
-- EXPORTS
-- ================================================

exports('GetSpawnedAnimal', function(animalId)
    local data = spawnedAnimals[animalId]
    return data and data.entity or nil
end)

exports('GetAllSpawnedAnimals', function(animalType)
    local entities = {}
    for id, data in pairs(spawnedAnimals) do
        if not animalType or data.type == animalType then
            entities[id] = data.entity
        end
    end
    return entities
end)
