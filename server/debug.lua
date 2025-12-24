-- ================================================
-- DEBUG COMMANDS - HM Holy Cow v0.2.1 (FIXED)
-- Only active when Config.Debug = true
-- NOW WITH ACE PERMISSIONS!
-- ================================================

if not Config or not Config.Debug then
    return
end

-- ================================================
-- HELPER: Check ACE Permission
-- ================================================
local function HasPermission(source)
    if source == 0 then return true end -- Console always has permission
    
    local permission = Config.Permissions.DebugCommands or 'holycow.admin'
    return IsPlayerAceAllowed(source, permission)
end

-- ================================================
-- CHECK BRIDGE LOADING
-- ================================================
RegisterCommand('holycow_checkbridge', function(source, args)
    if not HasPermission(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Holy Cow',
            description = '\u{274C} Keine Berechtigung!',
            type = 'error'
        })
        return
    end
    
    print('^3[Holy Cow Debug] Checking Bridge...^0')
    print('^3  Framework table exists: ' .. tostring(Framework ~= nil) .. '^0')
    print('^3  Inventory table exists: ' .. tostring(Inventory ~= nil) .. '^0')
    
    if Framework then
        print('^3  Framework.Name: ' .. tostring(Framework.GetFrameworkName and Framework.GetFrameworkName()) .. '^0')
        print('^3  Framework.GetPlayerIdentifier: ' .. tostring(Framework.GetPlayerIdentifier ~= nil) .. '^0')
    end
    
    if Inventory then
        print('^3  Inventory.HasItem: ' .. tostring(Inventory.HasItem ~= nil) .. '^0')
        print('^3  Inventory.AddItem: ' .. tostring(Inventory.AddItem ~= nil) .. '^0')
        print('^3  Inventory.RemoveItem: ' .. tostring(Inventory.RemoveItem ~= nil) .. '^0')
    else
        print('^1  ERROR: Inventory is NIL!^0')
    end
end, false)

-- ================================================
-- GIVE MILKING ITEMS
-- ================================================
RegisterCommand('holycow_giveitems', function(source, args)
    if not HasPermission(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Holy Cow',
            description = '\u{274C} Keine Berechtigung!',
            type = 'error'
        })
        return
    end
    
    local amount = tonumber(args[1]) or 1
    
    -- Give bucket
    Inventory.AddItem(source, 'milk_bucket', amount)
    
    -- Give stool
    Inventory.AddItem(source, 'milk_stool', 1)
    
    print('^2[Holy Cow Debug] Gave ' .. amount .. ' milk_bucket and 1 milk_stool to player ' .. source .. '^0')
    
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Holy Cow',
        description = '\u{2705} Items gegeben!',
        type = 'success'
    })
end, false)

-- ================================================
-- CHECK COW COOLDOWN STATUS
-- ================================================
RegisterCommand('holycow_cooldownstatus', function(source, args)
    if not HasPermission(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Holy Cow',
            description = '\u{274C} Keine Berechtigung!',
            type = 'error'
        })
        return
    end
    
    local cowId = tonumber(args[1])
    
    if not cowId then
        print('^1Usage: /holycow_cooldownstatus [cowId]^0')
        return
    end
    
    local cow = MySQL.single.await('SELECT id, last_milked, total_milk_produced FROM holycow_owned WHERE id = ?', {cowId})
    
    if not cow then
        print('^1Cow #' .. cowId .. ' not found in database!^0')
        return
    end
    
    print('^3[Holy Cow Debug] Cooldown Status for Cow #' .. cowId .. ':^0')
    print('^3  last_milked: ' .. tostring(cow.last_milked) .. ' (type: ' .. type(cow.last_milked) .. ')^0')
    print('^3  total_milk_produced: ' .. tostring(cow.total_milk_produced) .. '^0')
    
    if cow.last_milked and cow.last_milked ~= '' then
        -- Parse DATETIME
        local year, month, day, hour, min, sec = cow.last_milked:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
        
        if year then
            local lastMilked = os.time({
                year = tonumber(year),
                month = tonumber(month),
                day = tonumber(day),
                hour = tonumber(hour),
                min = tonumber(min),
                sec = tonumber(sec)
            })
            
            local now = os.time()
            local cooldownSeconds = Config.Milking.CooldownMinutes * 60
            local elapsedSeconds = now - lastMilked
            local remainingSeconds = cooldownSeconds - elapsedSeconds
            
            print('^3  Elapsed: ' .. elapsedSeconds .. ' seconds (' .. math.floor(elapsedSeconds/60) .. ' minutes)^0')
            print('^3  Required: ' .. (Config.Milking.CooldownMinutes * 60) .. ' seconds (' .. Config.Milking.CooldownMinutes .. ' minutes)^0')
            
            if remainingSeconds > 0 then
                print('^1  Status: ON COOLDOWN (remaining: ' .. remainingSeconds .. ' seconds / ' .. math.floor(remainingSeconds/60) .. ' minutes)^0')
            else
                print('^2  Status: READY TO MILK (cooldown expired ' .. math.abs(remainingSeconds) .. ' seconds ago)^0')
            end
        else
            print('^1  ERROR: Could not parse DATETIME!^0')
        end
    else
        print('^2  Status: NEVER MILKED (ready to milk)^0')
    end
end, false)

-- ================================================
-- RESET COW COOLDOWN
-- ================================================
RegisterCommand('holycow_resetcooldown', function(source, args)
    if not HasPermission(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Holy Cow',
            description = '\u{274C} Keine Berechtigung!',
            type = 'error'
        })
        return
    end
    
    local cowId = tonumber(args[1])
    
    if not cowId then
        print('^1Usage: /holycow_resetcooldown [cowId]^0')
        return
    end
    
    MySQL.update('UPDATE holycow_owned SET last_milked = NULL WHERE id = ?', {cowId}, function(affectedRows)
        print('^2[Holy Cow Debug] Reset cooldown for cow ' .. cowId .. ' (affected: ' .. affectedRows .. ')^0')
    end)
end, false)

-- ================================================
-- CHECK ITEMS
-- ================================================
RegisterCommand('holycow_checkitems', function(source, args)
    if not HasPermission(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Holy Cow',
            description = '\u{274C} Keine Berechtigung!',
            type = 'error'
        })
        return
    end
    
    local hasBucket = Inventory.HasItem(source, 'milk_bucket', 1) and exports.ox_inventory:Search(source, 'count', 'milk_bucket') or 0
    local hasStool = Inventory.HasItem(source, 'milk_stool', 1) and exports.ox_inventory:Search(source, 'count', 'milk_stool') or 0
    local hasMilk = exports.ox_inventory:Search(source, 'count', 'raw_milk') or 0
    
    print('^3[Holy Cow Debug] Player ' .. source .. ' items:^0')
    print('^3  milk_bucket: ' .. hasBucket .. '^0')
    print('^3  milk_stool: ' .. hasStool .. '^0')
    print('^3  raw_milk: ' .. hasMilk .. '^0')
end, false)

-- ================================================
-- TEST BRIDGE
-- ================================================
RegisterCommand('holycow_testbridge', function(source, args)
    if not HasPermission(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Holy Cow',
            description = '\u{274C} Keine Berechtigung!',
            type = 'error'
        })
        return
    end
    
    print('^3[Holy Cow Debug] Testing Bridge...^0')
    
    -- Test Framework
    local identifier = Framework.GetPlayerIdentifier(source)
    print('^3  Framework.GetPlayerIdentifier: ' .. tostring(identifier) .. '^0')
    
    -- Test Inventory
    local testHas = Inventory.HasItem(source, 'milk_bucket', 1)
    print('^3  Inventory.HasItem (milk_bucket): ' .. tostring(testHas) .. '^0')
end, false)

print('^2[Holy Cow] Debug commands loaded (with ACE permissions)^0')