-- ================================================
-- CLIENT - PIG SYSTEM (FEEDING)
-- Multi-Farm v0.3.0
-- ================================================

local function DebugPrint(...)
    if Config and Config.Debug then
        print('^3[Multi-Farm Pig]^0', ...)
    end
end

local isFeeding = false
local resourceName = GetCurrentResourceName()

-- ================================================
-- START FEEDING
-- ================================================
local function StartFeeding(pigEntity, pigId)
    if not pigId then
        DebugPrint('^1pigId is nil!^0')
        lib.notify({
            title = 'Multi-Farm',
            description = '\u{274C} Fehler: Schweine-ID fehlt!',
            type = 'error'
        })
        return
    end
    
    if isFeeding then
        lib.notify({
            title = 'Multi-Farm',
            description = '\u{274C} Du fütterst bereits!',
            type = 'error'
        })
        return
    end
    
    if not pigEntity or not DoesEntityExist(pigEntity) then
        lib.notify({
            title = 'Multi-Farm',
            description = '\u{274C} Schwein nicht gefunden!',
            type = 'error'
        })
        return
    end
    
    DebugPrint('^3Starting feeding for pig ' .. tostring(pigId) .. '^0')
    
    isFeeding = true
    
    local ped = PlayerPedId()
    local pigCoords = GetEntityCoords(pigEntity)
    local pigHeading = GetEntityHeading(pigEntity)
    
    -- Calculate position next to pig
    local offset = vector3(
        pigCoords.x + math.cos(math.rad(pigHeading + 90)) * 1.0,
        pigCoords.y + math.sin(math.rad(pigHeading + 90)) * 1.0,
        pigCoords.z
    )
    
    -- Walk to pig
    TaskGoToCoordAnyMeans(ped, offset.x, offset.y, offset.z, 1.0, 0, 0, 786603, 0xbf800000)
    
    local timeout = 0
    while #(GetEntityCoords(ped) - offset) > 1.5 and timeout < 5000 do
        Wait(100)
        timeout = timeout + 100
    end
    
    -- Turn player towards pig
    SetEntityHeading(ped, pigHeading + 90)
    
    -- Load animation
    if Config.PigFeeding.Animation then
        lib.requestAnimDict(Config.PigFeeding.Animation.dict)
        TaskPlayAnim(ped, Config.PigFeeding.Animation.dict, Config.PigFeeding.Animation.name, 8.0, -8.0, -1, 1, 0, false, false, false)
    end
    
    -- Progress Bar
    local success = lib.progressCircle({
        duration = Config.PigFeeding.ProgressDuration,
        label = Config.PigFeeding.ProgressLabel,
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
        DebugPrint('^3Feeding cancelled^0')
        isFeeding = false
        return
    end
    
    -- Server Callback
    lib.callback('multifarm:feedPig', false, function(success, message)
        if success then
            DebugPrint('^2Feeding successful!^0')
            
            lib.notify({
                title = 'Multi-Farm',
                description = message or '\u{2705} Schwein gefüttert!',
                type = 'success',
                icon = 'wheat-awn'
            })
        else
            DebugPrint('^1Feeding failed: ' .. tostring(message) .. '^0')
            
            lib.notify({
                title = 'Multi-Farm',
                description = message or '\u{274C} Füttern fehlgeschlagen!',
                type = 'error'
            })
        end
        
        isFeeding = false
    end, pigId)
end

-- ================================================
-- EVENT: Start Feeding
-- ================================================

RegisterNetEvent('multifarm:feedPig', function(pigEntity, pigId)
    DebugPrint('^3multifarm:feedPig event received - pigId: ' .. tostring(pigId) .. '^0')
    StartFeeding(pigEntity, pigId)
end)

-- ================================================
-- CLEANUP
-- ================================================

AddEventHandler('onResourceStop', function(resName)
    if resName ~= resourceName then return end
    
    if isFeeding then
        ClearPedTasks(PlayerPedId())
    end
end)

DebugPrint('^2Pig feeding system loaded^0')
