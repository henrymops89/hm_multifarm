-- ================================================
-- CLIENT - NPC SPAWNING (INSTANT)
-- Works with instant target bridge!
-- ================================================

local spawnedNPCs = {}
local npcBlips = {}

local function DebugPrint(...)
    if Config and Config.Debug then
        print('^3[Multi-Farm NPC]^0', ...)
    else
        print('^3[Multi-Farm NPC]^0', ...) -- Always print during debug phase
    end
end

-- ================================================
-- WAIT FOR TARGET (SHORT TIMEOUT)
-- ================================================
local function WaitForTarget()
    DebugPrint('Checking Target bridge...')
    
    if not Target then
        print('^1[Multi-Farm NPC] ERROR: Target global not found!^0')
        return false
    end
    
    if not Target.IsReady then
        print('^1[Multi-Farm NPC] ERROR: Target.IsReady function not found!^0')
        return false
    end
    
    -- Target should be ready immediately now!
    local attempts = 0
    while not Target.IsReady() and attempts < 20 do -- Only 2 seconds max
        Wait(100)
        attempts = attempts + 1
    end
    
    if not Target.IsReady() then
        print('^1[Multi-Farm NPC] ERROR: Target bridge not ready after 2 seconds!^0')
        print('^1[Multi-Farm NPC] Target object exists: ' .. tostring(Target ~= nil) .. '^0')
        print('^1[Multi-Farm NPC] Target.IsReady exists: ' .. tostring(Target.IsReady ~= nil) .. '^0')
        if Target.IsReady then
            print('^1[Multi-Farm NPC] Target.IsReady() returns: ' .. tostring(Target.IsReady()) .. '^0')
        end
        return false
    end
    
    DebugPrint('Target bridge ready: ' .. Target.GetSystem())
    return true
end

-- ================================================
-- CREATE SHOP NPC
-- ================================================
local function CreateShopNPC(animalType)
    DebugPrint('Starting CreateShopNPC for: ' .. animalType)
    
    -- Wait for Config
    local configAttempts = 0
    while not Config or not Config.NPCs or not Config.NPCs[animalType] do
        Wait(100)
        configAttempts = configAttempts + 1
        
        if configAttempts > 50 then
            print('^1[Multi-Farm NPC] Config timeout for ' .. animalType .. '^0')
            return
        end
    end
    
    local npcConfig = Config.NPCs[animalType]
    
    if not npcConfig.Enabled then
        DebugPrint(animalType .. ' NPC disabled in config')
        return
    end
    
    DebugPrint('Creating ' .. animalType .. ' NPC...')
    
    -- Load model
    local modelHash = GetHashKey(npcConfig.Model)
    RequestModel(modelHash)
    
    local attempts = 0
    while not HasModelLoaded(modelHash) and attempts < 100 do
        Wait(100)
        attempts = attempts + 1
    end
    
    if not HasModelLoaded(modelHash) then
        print('^1[Multi-Farm NPC] Failed to load model: ' .. npcConfig.Model .. '^0')
        return
    end
    
    DebugPrint('Model loaded: ' .. npcConfig.Model)
    
    -- Create NPC
    local npc = CreatePed(4, modelHash, npcConfig.Coords.x, npcConfig.Coords.y, npcConfig.Coords.z, npcConfig.Coords.w, false, true)
    
    if not DoesEntityExist(npc) then
        print('^1[Multi-Farm NPC] Failed to create NPC entity!^0')
        return
    end
    
    DebugPrint('NPC entity created with handle: ' .. npc)
    
    -- Setup NPC
    SetEntityAsMissionEntity(npc, true, true)
    SetPedFleeAttributes(npc, 0, false)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    
    -- Scenario
    if npcConfig.Scenario then
        TaskStartScenarioInPlace(npc, npcConfig.Scenario, 0, true)
    end
    
    DebugPrint(animalType .. ' NPC setup complete')
    
    -- Store NPC
    spawnedNPCs[animalType] = npc
    
    -- Create Blip
    if npcConfig.Blip and npcConfig.Blip.Enabled then
        local npcBlip = AddBlipForCoord(npcConfig.Coords.x, npcConfig.Coords.y, npcConfig.Coords.z)
        
        SetBlipSprite(npcBlip, npcConfig.Blip.Sprite)
        SetBlipColour(npcBlip, npcConfig.Blip.Color)
        SetBlipScale(npcBlip, npcConfig.Blip.Scale)
        SetBlipAsShortRange(npcBlip, true)
        
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(npcConfig.Blip.Name)
        EndTextCommandSetBlipName(npcBlip)
        
        npcBlips[animalType] = npcBlip
        
        DebugPrint('Blip created for ' .. animalType)
    end
    
    -- ================================================
    -- ADD TARGET
    -- ================================================
    if not npcConfig.Target then
        DebugPrint('No target config for ' .. animalType)
        return
    end
    
    DebugPrint('Preparing to add target to ' .. animalType .. ' NPC...')
    
    if not WaitForTarget() then
        print('^1[Multi-Farm NPC] Target bridge not ready, skipping target for ' .. animalType .. '^0')
        print('^1[Multi-Farm NPC] NPC will be visible but not interactable!^0')
        return
    end
    
    DebugPrint('Target bridge confirmed ready, adding target...')
    
    local targetOptions = {
        {
            name = 'multifarm_shop_' .. animalType,
            label = npcConfig.Target.Label,
            icon = npcConfig.Target.Icon,
            distance = npcConfig.Target.Distance,
            onSelect = function()
                DebugPrint('Target clicked for ' .. animalType)
                TriggerEvent('multifarm:openShop', animalType)
            end
        }
    }
    
    DebugPrint('Calling Target.AddLocalEntity...')
    
    local success = Target.AddLocalEntity(npc, targetOptions)
    
    if success then
        DebugPrint('✅ Target added successfully to ' .. animalType .. ' NPC!')
    else
        print('^1[Multi-Farm NPC] ❌ Failed to add target to ' .. animalType .. ' NPC!^0')
    end
end

-- ================================================
-- CLEANUP
-- ================================================
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    DebugPrint('Cleaning up NPCs...')
    
    for animalType, npc in pairs(spawnedNPCs) do
        if DoesEntityExist(npc) then
            DeleteEntity(npc)
        end
    end
    
    for animalType, blip in pairs(npcBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
end)

-- ================================================
-- INITIALIZE
-- ================================================
CreateThread(function()
    print('^2[Multi-Farm NPC] ============================================^0')
    print('^2[Multi-Farm NPC] NPC Spawner Starting...^0')
    print('^2[Multi-Farm NPC] ============================================^0')
    
    -- Wait for game ready
    local gameReady = 0
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(100)
        gameReady = gameReady + 1
        if gameReady > 100 then
            print('^1[Multi-Farm NPC] Player not active after 10 seconds!^0')
            break
        end
    end
    
    DebugPrint('Player is active')
    
    -- Small delay to let everything initialize
    Wait(1000)
    
    DebugPrint('Starting NPC spawn sequence...')
    
    -- Spawn NPCs
    CreateShopNPC('cow')
    Wait(500)
    
    CreateShopNPC('chicken')
    Wait(500)
    
    CreateShopNPC('pig')
    
    print('^2[Multi-Farm NPC] ============================================^0')
    print('^2[Multi-Farm NPC] NPC Spawning Complete!^0')
    print('^2[Multi-Farm NPC] Spawned NPCs: ' .. #spawnedNPCs .. '/3^0')
    print('^2[Multi-Farm NPC] ============================================^0')
end)