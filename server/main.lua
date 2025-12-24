-- ================================================
-- SERVER - MAIN (MULTI-FARM)
-- Multi-Farm v0.3.0
-- ================================================

-- Startup Banner
CreateThread(function()
    while not Config do
        Wait(100)
    end
    
    Wait(1000)
    
    print('^2===========================================^0')
    print('^2                                           ^0')
    print('^2    🐄🐔🐷 MULTI-FARM v0.3.0 🐷🐔🐄      ^0')
    print('^2    Farm Management System                ^0')
    print('^2    Kühe • Hühner • Schweine              ^0')
    print('^2                                           ^0')
    print('^2===========================================^0')
    
    -- Check Database
    if Config.Database.Enabled then
        print('^3Checking database connection...^0')
        Wait(2000)
        
        local cowSlots = GetFreeSlots('cow')
        local chickenSlots = GetFreeSlots('chicken')
        local pigSlots = GetFreeSlots('pig')
        
        if cowSlots and chickenSlots and pigSlots then
            print('^2✅ Database connected successfully!^0')
            print('^3📊 Free slots:^0')
            print('^3   🐄 Kühe: ' .. #cowSlots .. '/10^0')
            print('^3   🐔 Hühner: ' .. #chickenSlots .. '/10^0')
            print('^3   🐷 Schweine: ' .. #pigSlots .. '/10^0')
        else
            print('^1❌ Database connection FAILED!^0')
            print('^1Please check your MySQL configuration!^0')
        end
    end
    
    -- Check Framework
    local framework = Framework.GetFrameworkName()
    print('^3🔧 Framework detected: ^2' .. framework .. '^0')
end)

-- ================================================
-- DEBUG COMMANDS
-- ================================================

CreateThread(function()
    while not Config do
        Wait(100)
    end
    
    if not Config.Debug then return end
    
    -- List all animals
    RegisterCommand('multifarm_list', function(source)
        local result = MySQL.query.await('SELECT * FROM multifarm_owned')
        
        print('^3========================================^0')
        print('^3🐄🐔🐷 ALL ANIMALS IN DATABASE^0')
        print('^3========================================^0')
        
        if result and #result > 0 then
            for _, animal in ipairs(result) do
                print(string.format('^2%s #%d: Owner=%s, Breed=%s, Slot=%d, Name=%s^0', 
                    animal.animal_type:upper(), animal.id, animal.owner, animal.breed_id, animal.slot_id, animal.custom_name or 'N/A'))
            end
            print('^3Total: ' .. #result .. ' animals^0')
        else
            print('^1No animals in database^0')
        end
        
        print('^3========================================^0')
    end, true)
    
    -- Show free slots
    RegisterCommand('multifarm_slots', function(source)
        local cowSlots = GetFreeSlots('cow')
        local chickenSlots = GetFreeSlots('chicken')
        local pigSlots = GetFreeSlots('pig')
        
        print('^3========================================^0')
        print('^3📍 SLOT STATUS^0')
        print('^3========================================^0')
        print('^2🐄 Kühe: ' .. #cowSlots .. '/10 frei^0')
        print('^2🐔 Hühner: ' .. #chickenSlots .. '/10 frei^0')
        print('^2🐷 Schweine: ' .. #pigSlots .. '/10 frei^0')
        print('^3========================================^0')
    end, true)
    
    -- Delete ALL animals (CAUTION!)
    RegisterCommand('multifarm_reset', function(source)
        MySQL.query.await('DELETE FROM multifarm_owned')
        MySQL.query.await('UPDATE multifarm_slots SET is_occupied = 0, occupied_by = NULL')
        
        print('^1⚠️ ALL ANIMALS DELETED! Database reset.^0')
        
        LoadSlotsFromDatabase()
    end, true)
    
    -- Manual zombie cleanup
    RegisterCommand('multifarm_cleanup', function(source)
        local fixed = CleanupZombieSlots()
        print('^2🧹 Cleanup complete! Fixed ' .. fixed .. ' zombie slots.^0')
    end, true)
    
    print('^2[Multi-Farm] Debug commands registered^0')
end)
