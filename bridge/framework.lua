Framework = {}
local frameworkLoaded = false

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION (läuft asynchron)
-- ═══════════════════════════════════════════════════════════════

CreateThread(function()
    -- Warte bis Config verfügbar ist
    while not Config do
        Wait(50)
    end
    
    print('^3[Holy Cow Bridge] Starting framework detection...^0')
    
    -- Auto-detect framework if set to 'auto'
    if Config.Framework == 'auto' then
        print('^3[Holy Cow Bridge] Checking for frameworks...^0')
        print('^3[Holy Cow Bridge] qbx_core: ' .. GetResourceState('qbx_core') .. '^0')
        print('^3[Holy Cow Bridge] qb-core: ' .. GetResourceState('qb-core') .. '^0')
        print('^3[Holy Cow Bridge] es_extended: ' .. GetResourceState('es_extended') .. '^0')
        
        if GetResourceState('qbx_core') == 'started' then
            Config.Framework = 'qbox'
        elseif GetResourceState('qb-core') == 'started' then
            Config.Framework = 'qbcore'
        elseif GetResourceState('es_extended') == 'started' then
            Config.Framework = 'esx'
        else
            print('^1[Holy Cow Bridge] ERROR: No supported framework detected! Using standalone mode.^0')
            Config.Framework = 'standalone'
        end
    end

    print('^2[Holy Cow Bridge] Framework detected: ' .. Config.Framework .. '^0')
    frameworkLoaded = true
end)

-- Helper: Warte auf Framework-Init
local function WaitForFramework()
    while not frameworkLoaded do
        Wait(10)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- SERVER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

if IsDuplicityVersion() then -- Server
    
    Framework.GetPlayer = function(source)
        WaitForFramework()
        
        print('^3[Holy Cow Bridge] GetPlayer called for source: ' .. source .. ', Framework: ' .. Config.Framework .. '^0')
        
        local player = nil
        
        if Config.Framework == 'qbox' then
            local success, result = pcall(function()
                return exports.qbx_core:GetPlayer(source)
            end)
            if success then
                player = result
                print('^2[Holy Cow Bridge] QBox player found^0')
            else
                print('^1[Holy Cow Bridge] QBox GetPlayer failed: ' .. tostring(result) .. '^0')
            end
            
        elseif Config.Framework == 'qbcore' then
            local success, QBCore = pcall(function()
                return exports['qb-core']:GetCoreObject()
            end)
            if success and QBCore then
                player = QBCore.Functions.GetPlayer(source)
                print('^2[Holy Cow Bridge] QBCore player found^0')
            else
                print('^1[Holy Cow Bridge] QBCore GetCoreObject failed^0')
            end
            
        elseif Config.Framework == 'esx' then
            local success, ESX = pcall(function()
                return exports['es_extended']:getSharedObject()
            end)
            if success and ESX then
                player = ESX.GetPlayerFromId(source)
                print('^2[Holy Cow Bridge] ESX player found^0')
            else
                print('^1[Holy Cow Bridge] ESX getSharedObject failed^0')
            end
        end
        
        if not player then
            print('^1[Holy Cow Bridge] Player object is NIL for source ' .. source .. '^0')
        end
        
        return player
    end
    
    Framework.GetPlayerIdentifier = function(source)
        WaitForFramework()
        
        print('^3[Holy Cow Bridge] GetPlayerIdentifier for source: ' .. source .. '^0')
        
        local player = Framework.GetPlayer(source)
        
        if not player then
            print('^1[Holy Cow Bridge] No player found, trying license fallback...^0')
            -- Fallback: License
            local identifiers = GetPlayerIdentifiers(source)
            for _, id in pairs(identifiers) do
                if string.match(id, 'license:') then
                    local license = string.gsub(id, 'license:', '')
                    print('^2[Holy Cow Bridge] Using license fallback: ' .. license .. '^0')
                    return license
                end
            end
            print('^1[Holy Cow Bridge] No license found either!^0')
            return nil
        end
        
        local identifier = nil
        
        if Config.Framework == 'qbox' or Config.Framework == 'qbcore' then
            identifier = player.PlayerData and player.PlayerData.citizenid
            print('^3[Holy Cow Bridge] QB CitizenID: ' .. tostring(identifier) .. '^0')
        elseif Config.Framework == 'esx' then
            identifier = player.identifier
            print('^3[Holy Cow Bridge] ESX Identifier: ' .. tostring(identifier) .. '^0')
        end
        
        if not identifier then
            print('^1[Holy Cow Bridge] Identifier is NIL!^0')
        end
        
        return identifier
    end
    
    Framework.GetMoney = function(source, moneyType)
        WaitForFramework()
        local player = Framework.GetPlayer(source)
        if not player then return 0 end
        
        moneyType = moneyType or 'cash'
        
        if Config.Framework == 'qbox' or Config.Framework == 'qbcore' then
            return player.PlayerData.money[moneyType] or 0
        elseif Config.Framework == 'esx' then
            if moneyType == 'cash' then
                return player.getMoney()
            elseif moneyType == 'bank' then
                return player.getAccount('bank').money
            end
        end
        
        return 0
    end
    
    Framework.RemoveMoney = function(source, amount, moneyType)
        WaitForFramework()
        local player = Framework.GetPlayer(source)
        if not player then return false end
        
        moneyType = moneyType or 'cash'
        
        if Config.Framework == 'qbox' or Config.Framework == 'qbcore' then
            player.Functions.RemoveMoney(moneyType, amount)
            return true
        elseif Config.Framework == 'esx' then
            if moneyType == 'cash' then
                player.removeMoney(amount)
            elseif moneyType == 'bank' then
                player.removeAccountMoney('bank', amount)
            end
            return true
        end
        
        return false
    end
    
    Framework.AddMoney = function(source, amount, moneyType)
        WaitForFramework()
        local player = Framework.GetPlayer(source)
        if not player then return false end
        
        moneyType = moneyType or 'cash'
        
        if Config.Framework == 'qbox' or Config.Framework == 'qbcore' then
            player.Functions.AddMoney(moneyType, amount)
            return true
        elseif Config.Framework == 'esx' then
            if moneyType == 'cash' then
                player.addMoney(amount)
            elseif moneyType == 'bank' then
                player.addAccountMoney('bank', amount)
            end
            return true
        end
        
        return false
    end
    
else -- Client
    
    Framework.GetPlayerData = function()
        WaitForFramework()
        
        if Config.Framework == 'qbox' then
            return exports.qbx_core:GetPlayerData()
        elseif Config.Framework == 'qbcore' then
            local QBCore = exports['qb-core']:GetCoreObject()
            return QBCore.Functions.GetPlayerData()
        elseif Config.Framework == 'esx' then
            local ESX = exports['es_extended']:getSharedObject()
            return ESX.GetPlayerData()
        end
        
        return {}
    end
    
    Framework.Notify = function(message, type, duration)
        lib.notify({
            title = 'Holy Cow Farm',
            description = message,
            type = type or 'info',
            duration = duration or 5000,
            position = 'top'
        })
    end
    
end

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

Framework.GetFrameworkName = function()
    WaitForFramework()
    return Config.Framework or 'unknown'
end

return Framework