-- ================================================
-- CLIENT - CHICKEN SYSTEM (EGG COLLECTION)
-- Multi-Farm v0.3.0
-- ================================================

local function DebugPrint(...)
    if Config and Config.Debug then
        print('^3[Multi-Farm Chicken]^0', ...)
    end
end

local isCollecting = false
local resourceName = GetCurrentResourceName()

-- ================================================
-- START EGG COLLECTION
-- ================================================
local function StartEggCollection(chickenEntity, chickenId)
    if not chickenId then
        DebugPrint('^1chickenId is nil!^0')
        lib.notify({
            title = 'Multi-Farm',
            description = '\u{274C} Fehler: Hühner-ID fehlt!',
            type = 'error'
        })
        return
    end
    
    if isCollecting then
        lib.notify({
            title = 'Multi-Farm',
            description = '\u{274C} Du sammelst bereits!',
            type = 'error'
        })
        return
    end
    
    if not chickenEntity or not DoesEntityExist(chickenEntity) then
        lib.notify({
            title = 'Multi-Farm',
            description = '\u{274C} Huhn nicht gefunden!',
            type = 'error'
        })
        return
    end
    
    DebugPrint('^3Starting egg collection for chicken ' .. tostring(chickenId) .. '^0')
    
    isCollecting = true
    
    local ped = PlayerPedId()
    local chickenCoords = GetEntityCoords(chickenEntity)
    local chickenHeading = GetEntityHeading(chickenEntity)
    
    -- Calculate position next to chicken
    local offset = vector3(
        chickenCoords.x + math.cos(math.rad(chickenHeading + 90)) * 0.5,
        chickenCoords.y + math.sin(math.rad(chickenHeading + 90)) * 0.5,
        chickenCoords.z
    )
    
    -- Walk to chicken
    TaskGoToCoordAnyMeans(ped, offset.x, offset.y, offset.z, 1.0, 0, 0, 786603, 0xbf800000)
    
    local timeout = 0
    while #(GetEntityCoords(ped) - offset) > 1.5 and timeout < 5000 do
        Wait(100)
        timeout = timeout + 100
    end
    
    -- Turn player towards chicken
    SetEntityHeading(ped, chickenHeading + 90)
    
    -- Load animation
    if Config.EggCollection.Animation then
        lib.requestAnimDict(Config.EggCollection.Animation.dict)
        TaskPlayAnim(ped, Config.EggCollection.Animation.dict, Config.EggCollection.Animation.name, 8.0, -8.0, -1, 1, 0, false, false, false)
    end
    
    -- Progress Bar
    local success = lib.progressCircle({
        duration = Config.EggCollection.ProgressDuration,
        label = Config.EggCollection.ProgressLabel,
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
        DebugPrint('^3Egg collection cancelled^0')
        isCollecting = false
        return
    end
    
    -- Server Callback
    lib.callback('multifarm:collectEggs', false, function(success, message)
        if success then
            DebugPrint('^2Egg collection successful!^0')
            
            lib.notify({
                title = 'Multi-Farm',
                description = message or '\u{2705} Eier gesammelt!',
                type = 'success',
                icon = 'egg'
            })
        else
            DebugPrint('^1Egg collection failed: ' .. tostring(message) .. '^0')
            
            lib.notify({
                title = 'Multi-Farm',
                description = message or '\u{274C} Sammeln fehlgeschlagen!',
                type = 'error'
            })
        end
        
        isCollecting = false
    end, chickenId)
end

-- ================================================
-- EVENT: Start Egg Collection
-- ================================================

RegisterNetEvent('multifarm:collectEggs', function(chickenEntity, chickenId)
    DebugPrint('^3multifarm:collectEggs event received - chickenId: ' .. tostring(chickenId) .. '^0')
    StartEggCollection(chickenEntity, chickenId)
end)

-- ================================================
-- CLEANUP
-- ================================================

AddEventHandler('onResourceStop', function(resName)
    if resName ~= resourceName then return end
    
    if isCollecting then
        ClearPedTasks(PlayerPedId())
    end
end)

DebugPrint('^2Chicken collection system loaded^0')
