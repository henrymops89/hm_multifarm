-- ================================================
-- TARGET BRIDGE - UNIVERSAL (CLIENT-SIDE)
-- Supports: ox_target, qb-target
-- IMMEDIATE INITIALIZATION - No config wait!
-- ================================================

Target = {}

local TargetSystem = nil
local isReady = false

print('^3[Multi-Farm Target] Bridge initializing IMMEDIATELY...^0')

-- ================================================
-- AUTO-DETECT TARGET SYSTEM (NO CONFIG WAIT!)
-- ================================================
if GetResourceState('ox_target') == 'started' then
    TargetSystem = 'ox_target'
    print('^2[Multi-Farm Target] Detected: ox_target^0')
elseif GetResourceState('qb-target') == 'started' then
    TargetSystem = 'qb-target'
    print('^2[Multi-Farm Target] Detected: qb-target^0')
else
    TargetSystem = 'ox_target' -- Default fallback
    print('^3[Multi-Farm Target] No target system detected, defaulting to ox_target^0')
end

isReady = true
print('^2[Multi-Farm Target] Bridge ready immediately: ' .. TargetSystem .. '^0')

-- ================================================
-- OPTIONAL: Check config later and override if needed
-- ================================================
CreateThread(function()
    Wait(1000) -- Give config time to load
    
    if Config and Config.Target and Config.Target ~= 'auto' then
        local oldSystem = TargetSystem
        TargetSystem = Config.Target
        print('^3[Multi-Farm Target] Config override: ' .. oldSystem .. ' -> ' .. TargetSystem .. '^0')
    end
end)

-- ================================================
-- ADD TARGET TO ENTITY
-- ================================================
function Target.AddLocalEntity(entity, options)
    print('^3[Multi-Farm Target] AddLocalEntity called^0')
    print('^3[Multi-Farm Target] isReady: ' .. tostring(isReady) .. '^0')
    print('^3[Multi-Farm Target] System: ' .. tostring(TargetSystem) .. '^0')
    
    if not DoesEntityExist(entity) then
        print('^1[Multi-Farm Target] Entity does not exist!^0')
        return false
    end
    
    print('^3[Multi-Farm Target] Entity exists, handle: ' .. entity .. '^0')
    
    if TargetSystem == 'ox_target' then
        print('^3[Multi-Farm Target] Using ox_target^0')
        
        local success, err = pcall(function()
            exports.ox_target:addLocalEntity(entity, options)
        end)
        
        if not success then
            print('^1[Multi-Farm Target] ox_target error: ' .. tostring(err) .. '^0')
            return false
        end
        
        print('^2[Multi-Farm Target] ox_target added successfully!^0')
        return true
        
    elseif TargetSystem == 'qb-target' then
        print('^3[Multi-Farm Target] Using qb-target^0')
        
        -- Convert ox_target format to qb-target format
        local qbOptions = {}
        
        for _, option in ipairs(options) do
            print('^3[Multi-Farm Target] Converting option: ' .. tostring(option.label) .. '^0')
            
            table.insert(qbOptions, {
                type = "client",
                event = option.event,
                icon = option.icon or 'fas fa-hand',
                label = option.label,
                action = option.onSelect,
                canInteract = function(entity)
                    if option.canInteract then
                        return option.canInteract(entity)
                    end
                    return true
                end
            })
        end
        
        print('^3[Multi-Farm Target] Converted ' .. #qbOptions .. ' options^0')
        
        local success, err = pcall(function()
            exports['qb-target']:AddTargetEntity(entity, {
                options = qbOptions,
                distance = options[1].distance or 2.5
            })
        end)
        
        if not success then
            print('^1[Multi-Farm Target] qb-target error: ' .. tostring(err) .. '^0')
            return false
        end
        
        print('^2[Multi-Farm Target] qb-target added successfully!^0')
        return true
    end
    
    print('^1[Multi-Farm Target] Unknown target system!^0')
    return false
end

-- ================================================
-- ADD TARGET TO MODEL
-- ================================================
function Target.AddModel(models, options)
    if type(models) ~= 'table' then
        models = {models}
    end
    
    if TargetSystem == 'ox_target' then
        local success, err = pcall(function()
            exports.ox_target:addModel(models, options)
        end)
        
        if not success then
            print('^1[Multi-Farm Target] ox_target addModel error: ' .. tostring(err) .. '^0')
        end
        
        return success
        
    elseif TargetSystem == 'qb-target' then
        -- Convert options
        local qbOptions = {}
        
        for _, option in ipairs(options) do
            table.insert(qbOptions, {
                type = "client",
                event = option.event,
                icon = option.icon or 'fas fa-hand',
                label = option.label,
                action = option.onSelect,
            })
        end
        
        local success, err = pcall(function()
            exports['qb-target']:AddTargetModel(models, {
                options = qbOptions,
                distance = options[1].distance or 2.5
            })
        end)
        
        if not success then
            print('^1[Multi-Farm Target] qb-target addModel error: ' .. tostring(err) .. '^0')
        end
        
        return success
    end
    
    return false
end

-- ================================================
-- REMOVE TARGET FROM ENTITY
-- ================================================
function Target.RemoveLocalEntity(entity, optionNames)
    if not DoesEntityExist(entity) then
        return false
    end
    
    if TargetSystem == 'ox_target' then
        pcall(function()
            exports.ox_target:removeLocalEntity(entity, optionNames)
        end)
        return true
        
    elseif TargetSystem == 'qb-target' then
        pcall(function()
            exports['qb-target']:RemoveTargetEntity(entity)
        end)
        return true
    end
    
    return false
end

-- ================================================
-- REMOVE TARGET FROM MODEL
-- ================================================
function Target.RemoveModel(models, optionNames)
    if type(models) ~= 'table' then
        models = {models}
    end
    
    if TargetSystem == 'ox_target' then
        pcall(function()
            exports.ox_target:removeModel(models, optionNames)
        end)
        return true
        
    elseif TargetSystem == 'qb-target' then
        pcall(function()
            exports['qb-target']:RemoveTargetModel(models)
        end)
        return true
    end
    
    return false
end

-- ================================================
-- ADD TARGET ZONE
-- ================================================
function Target.AddBoxZone(name, coords, size, options)
    if TargetSystem == 'ox_target' then
        pcall(function()
            exports.ox_target:addBoxZone({
                coords = coords,
                size = size,
                rotation = options.rotation or 0,
                debug = options.debug or false,
                options = options.options
            })
        end)
        return true
        
    elseif TargetSystem == 'qb-target' then
        pcall(function()
            exports['qb-target']:AddBoxZone(name, coords, size.x, size.y, {
                name = name,
                heading = options.rotation or 0,
                debugPoly = options.debug or false,
                minZ = coords.z - (size.z / 2),
                maxZ = coords.z + (size.z / 2),
            }, {
                options = options.options,
                distance = options.distance or 2.5
            })
        end)
        return true
    end
    
    return false
end

-- ================================================
-- REMOVE TARGET ZONE
-- ================================================
function Target.RemoveZone(name)
    if TargetSystem == 'ox_target' then
        pcall(function()
            exports.ox_target:removeZone(name)
        end)
        return true
        
    elseif TargetSystem == 'qb-target' then
        pcall(function()
            exports['qb-target']:RemoveZone(name)
        end)
        return true
    end
    
    return false
end

-- ================================================
-- GET ACTIVE SYSTEM
-- ================================================
function Target.GetSystem()
    return TargetSystem
end

-- ================================================
-- CHECK IF READY
-- ================================================
function Target.IsReady()
    return isReady
end

print('^2[Multi-Farm Target] All functions registered^0')
print('^2[Multi-Farm Target] Ready to use! System: ' .. TargetSystem .. '^0')