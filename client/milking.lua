-- ================================================
-- CLIENT - MILKING SYSTEM (FIXED)
-- HM Multi-Farm v0.2.1
-- FIX: Dynamic resource name instead of hardcoded
-- ================================================

-- Local Debug Print
local function DebugPrint(...)
    if Config and Config.Debug then
        print('^3[Multi-Farm Milking]^0', ...)
    end
end

local isMilking = false
local resourceName = GetCurrentResourceName() -- DYNAMIC!

-- ================================================
-- START MILKING PROCESS
-- ================================================
local function StartMilking(cowEntity, cowId)
    -- Validate parameters
    if not cowId then
        DebugPrint('^1cowId is nil!^0')
        lib.notify({
            title = 'Multi-Farm Farm',
            description = '\u{274C} Fehler: Kuh-ID fehlt!',
            type = 'error'
        })
        return
    end
    
    if isMilking then
        DebugPrint('^3Already milking!^0')
        lib.notify({
            title = 'Multi-Farm Farm',
            description = '\u{274C} Du melkst bereits!',
            type = 'error'
        })
        return
    end
    
    if not cowEntity or not DoesEntityExist(cowEntity) then
        DebugPrint('^1Cow entity does not exist!^0')
        lib.notify({
            title = 'Multi-Farm Farm',
            description = '\u{274C} Kuh nicht gefunden!',
            type = 'error'
        })
        return
    end
    
    DebugPrint('^3Starting milking process for cow ' .. tostring(cowId) .. '^0')
    
    isMilking = true
    
    local ped = PlayerPedId()
    local cowCoords = GetEntityCoords(cowEntity)
    local cowHeading = GetEntityHeading(cowEntity)
    
    -- Calculate position next to cow
    local offset = vector3(
        cowCoords.x + math.cos(math.rad(cowHeading + 90)) * 0.8,
        cowCoords.y + math.sin(math.rad(cowHeading + 90)) * 0.8,
        cowCoords.z
    )
    
    -- Walk to cow
    TaskGoToCoordAnyMeans(ped, offset.x, offset.y, offset.z, 1.0, 0, 0, 786603, 0xbf800000)
    
    local timeout = 0
    while #(GetEntityCoords(ped) - offset) > 1.5 and timeout < 5000 do
        Wait(100)
        timeout = timeout + 100
    end
    
    -- Turn player towards cow
    SetEntityHeading(ped, cowHeading + 90)
    
    -- Load animation
    if Config.Milking.Animation then
        lib.requestAnimDict(Config.Milking.Animation.dict)
        
        -- Start animation
        TaskPlayAnim(ped, Config.Milking.Animation.dict, Config.Milking.Animation.name, 8.0, -8.0, -1, 1, 0, false, false, false)
    end
    
    -- Progress Bar
    local success = lib.progressCircle({
        duration = Config.Milking.ProgressDuration,
        label = Config.Milking.ProgressLabel,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = false
        }
    })
    
    -- Stop animation
    ClearPedTasks(ped)
    
    if not success then
        DebugPrint('^3Milking cancelled^0')
        isMilking = false
        return
    end
    
    -- Server Callback: Milk
    lib.callback('multifarm:milkCow', false, function(success, message)
        if success then
            DebugPrint('^2Milking successful!^0')
            
            lib.notify({
                title = 'Multi-Farm Farm',
                description = message or '\u{2705} Erfolgreich gemolken!',
                type = 'success',
                icon = 'droplet'
            })
        else
            DebugPrint('^1Milking failed: ' .. tostring(message) .. '^0')
            
            lib.notify({
                title = 'Multi-Farm Farm',
                description = message or '\u{274C} Melken fehlgeschlagen!',
                type = 'error'
            })
        end
        
        isMilking = false
    end, cowId)
end

-- ================================================
-- EVENT: Start Milking
-- ================================================

RegisterNetEvent('multifarm:startMilking', function(cowEntity, cowId)
    DebugPrint('^3multifarm:startMilking event received - cowEntity: ' .. tostring(cowEntity) .. ', cowId: ' .. tostring(cowId) .. '^0')
    StartMilking(cowEntity, cowId)
end)

-- ================================================
-- CLEANUP
-- ================================================

AddEventHandler('onResourceStop', function(resName)
    if resName ~= resourceName then return end
    
    -- Stop animation if active
    if isMilking then
        ClearPedTasks(PlayerPedId())
    end
end)

-- ================================================
-- DEBUG COMMANDS
-- ================================================

if Config.Debug then
    -- Fix ox_target for all spawned cows
    RegisterCommand('fixtargets', function()
        DebugPrint('^3Running fixtargets command...^0')
        
        -- Use dynamic resource name!
        local cows = exports[resourceName]:GetAllSpawnedCows()
        local count = 0
        
        if not cows then
            print('^1No cows found!^0')
            lib.notify({
                title = 'Multi-Farm Farm',
                description = '\u{274C} Keine Kühe gefunden!',
                type = 'error'
            })
            return
        end
        
        for cowId, entity in pairs(cows) do
            if DoesEntityExist(entity) then
                DebugPrint('^3Adding ox_target to cow ' .. tostring(cowId) .. ' (entity: ' .. tostring(entity) .. ')^0')
                
                exports.ox_target:addLocalEntity(entity, {
                    {
                        name = 'multifarm_milk_' .. tostring(cowId),
                        label = Config.Milking.Target.Label,
                        icon = Config.Milking.Target.Icon,
                        distance = Config.Milking.Target.Distance,
                        onSelect = function()
                            DebugPrint('^3ox_target manually triggered for cow ' .. tostring(cowId) .. '^0')
                            TriggerEvent('multifarm:startMilking', entity, cowId)
                        end
                    }
                })
                count = count + 1
                print('^2Added ox_target to cow ' .. tostring(cowId) .. '^0')
            else
                print('^1Cow ' .. tostring(cowId) .. ' entity does not exist!^0')
            end
        end
        
        local message = string.format('\u{2705} Added targets to %d cows!', count)
        print('^2' .. message .. '^0')
        lib.notify({
            title = 'Multi-Farm Farm',
            description = message,
            type = 'success'
        })
    end, false)
    
    -- Reset milking state
    RegisterCommand('resetmilk', function()
        isMilking = false
        ClearPedTasks(PlayerPedId())
        print('^2Milking state reset!^0')
    end, false)
    
    -- Check targets
    RegisterCommand('multifarm_check_targets', function()
        local spawnedCows = exports[resourceName]:GetAllSpawnedCows()
        
        if not spawnedCows then
            print('^1No spawned cows found!^0')
            return
        end
        
        print('^3========================================^0')
        print('^3Checking ox_target on cows:^0')
        
        for cowId, entity in pairs(spawnedCows) do
            if DoesEntityExist(entity) then
                print('^2\u{2705} Cow #' .. cowId .. ' - Entity exists: ' .. entity .. '^0')
            else
                print('^1\u{274C} Cow #' .. cowId .. ' - Entity does NOT exist!^0')
            end
        end
        
        print('^3========================================^0')
    end)
    
    -- Add target manually
    RegisterCommand('multifarm_add_target_manual', function(source, args)
        local cowId = tonumber(args[1])
        if not cowId then
            print('^1Usage: /multifarm_add_target_manual [cowId]^0')
            return
        end
        
        local cowEntity = exports[resourceName]:GetSpawnedCow(cowId)
        
        if not cowEntity or not DoesEntityExist(cowEntity) then
            print('^1Cow #' .. cowId .. ' not found!^0')
            return
        end
        
        exports.ox_target:addLocalEntity(cowEntity, {
            {
                name = 'multifarm_milk_' .. cowId,
                label = Config.Milking.Target.Label,
                icon = Config.Milking.Target.Icon,
                distance = Config.Milking.Target.Distance,
                onSelect = function()
                    TriggerEvent('multifarm:startMilking', cowEntity, cowId)
                end
            }
        })
        
        print('^2\u{2705} Manually added ox_target to cow #' .. cowId .. '^0')
    end)
end

DebugPrint('^2Milking system loaded^0')