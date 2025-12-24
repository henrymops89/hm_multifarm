-- ================================================
-- INVENTORY BRIDGE - UNIVERSAL
-- Supports: ox_inventory, qb-inventory, ps-inventory
-- Auto-detects OR uses Config.Inventory setting
-- ================================================

Inventory = {}

local InventorySystem = nil

-- ================================================
-- WAIT FOR CONFIG
-- ================================================
CreateThread(function()
    while not Config do
        Wait(50)
    end
    
    -- ================================================
    -- CHECK CONFIG PREFERENCE
    -- ================================================
    if Config.Inventory and Config.Inventory ~= 'auto' then
        -- Use config setting
        InventorySystem = Config.Inventory
        print('^2[Multi-Farm Bridge] Using config inventory: ' .. InventorySystem .. '^0')
    else
        -- Auto-detect
        print('^3[Multi-Farm Bridge] Auto-detecting inventory system...^0')
        
        if GetResourceState('ox_inventory') == 'started' then
            InventorySystem = 'ox_inventory'
            print('^2[Multi-Farm Bridge] Detected: ox_inventory^0')
        elseif GetResourceState('qb-inventory') == 'started' then
            InventorySystem = 'qb-inventory'
            print('^2[Multi-Farm Bridge] Detected: qb-inventory^0')
        elseif GetResourceState('ps-inventory') == 'started' then
            InventorySystem = 'ps-inventory'
            print('^2[Multi-Farm Bridge] Detected: ps-inventory (QB-compatible)^0')
        else
            InventorySystem = 'ox_inventory' -- Default fallback
            print('^3[Multi-Farm Bridge] No inventory detected, defaulting to ox_inventory^0')
        end
    end
    
    print('^2[Multi-Farm Bridge] Inventory bridge ready: ' .. InventorySystem .. '^0')
end)

-- ================================================
-- HELPER: Wait for system to be set
-- ================================================
local function WaitForInventorySystem()
    while not InventorySystem do
        Wait(10)
    end
end

-- ================================================
-- SERVER-SIDE FUNCTIONS
-- ================================================
if IsDuplicityVersion() then
    print('^3[Multi-Farm Bridge] Loading SERVER inventory functions...^0')
    
    -- ================================================
    -- HAS ITEM
    -- ================================================
    function Inventory.HasItem(source, item, amount)
        WaitForInventorySystem()
        amount = amount or 1
        
        if InventorySystem == 'ox_inventory' then
            local count = exports.ox_inventory:Search(source, 'count', item)
            return count >= amount
            
        elseif InventorySystem == 'qb-inventory' or InventorySystem == 'ps-inventory' then
            local Player = exports['qb-core']:GetPlayer(source)
            if not Player then return false end
            
            local itemData = Player.Functions.GetItemByName(item)
            if not itemData then return false end
            
            return itemData.amount >= amount
        end
        
        return false
    end
    
    -- ================================================
    -- ADD ITEM
    -- ================================================
    function Inventory.AddItem(source, item, amount, metadata)
        WaitForInventorySystem()
        amount = amount or 1
        metadata = metadata or {}
        
        if InventorySystem == 'ox_inventory' then
            return exports.ox_inventory:AddItem(source, item, amount, metadata)
            
        elseif InventorySystem == 'qb-inventory' or InventorySystem == 'ps-inventory' then
            local Player = exports['qb-core']:GetPlayer(source)
            if not Player then return false end
            
            -- QB uses 'info' instead of 'metadata'
            local success = Player.Functions.AddItem(item, amount, false, metadata)
            
            if success then
                TriggerClientEvent('inventory:client:ItemBox', source, exports['qb-core']:GetItems()[item], 'add', amount)
            end
            
            return success
        end
        
        return false
    end
    
    -- ================================================
    -- REMOVE ITEM
    -- ================================================
    function Inventory.RemoveItem(source, item, amount, metadata)
        WaitForInventorySystem()
        amount = amount or 1
        metadata = metadata or {}
        
        if InventorySystem == 'ox_inventory' then
            return exports.ox_inventory:RemoveItem(source, item, amount, metadata)
            
        elseif InventorySystem == 'qb-inventory' or InventorySystem == 'ps-inventory' then
            local Player = exports['qb-core']:GetPlayer(source)
            if not Player then return false end
            
            local success = Player.Functions.RemoveItem(item, amount, false, metadata)
            
            if success then
                TriggerClientEvent('inventory:client:ItemBox', source, exports['qb-core']:GetItems()[item], 'remove', amount)
            end
            
            return success
        end
        
        return false
    end
    
    -- ================================================
    -- CAN CARRY ITEM
    -- ================================================
    function Inventory.CanCarryItem(source, item, amount)
        WaitForInventorySystem()
        amount = amount or 1
        
        if InventorySystem == 'ox_inventory' then
            return exports.ox_inventory:CanCarryItem(source, item, amount)
            
        elseif InventorySystem == 'qb-inventory' or InventorySystem == 'ps-inventory' then
            local Player = exports['qb-core']:GetPlayer(source)
            if not Player then return false end
            
            -- QB doesn't have direct CanCarryItem, we check if AddItem would work
            -- This is a simplified check
            return true -- QB handles this internally in AddItem
        end
        
        return false
    end
    
    print('^2[Multi-Farm Bridge] SERVER inventory functions loaded^0')
    
-- ================================================
-- CLIENT-SIDE FUNCTIONS
-- ================================================
else
    print('^3[Multi-Farm Bridge] Loading CLIENT inventory functions...^0')
    
    -- ================================================
    -- GET ITEM COUNT (Client-side check)
    -- ================================================
    function Inventory.GetItemCount(item)
        WaitForInventorySystem()
        
        if InventorySystem == 'ox_inventory' then
            return exports.ox_inventory:Search('count', item)
            
        elseif InventorySystem == 'qb-inventory' or InventorySystem == 'ps-inventory' then
            local Player = exports['qb-core']:GetPlayerData()
            if not Player or not Player.items then return 0 end
            
            local count = 0
            for _, itemData in pairs(Player.items) do
                if itemData.name == item then
                    count = count + (itemData.amount or 1)
                end
            end
            
            return count
        end
        
        return 0
    end
    
    print('^2[Multi-Farm Bridge] CLIENT inventory functions loaded^0')
end

-- ================================================
-- EXPORT INVENTORY SYSTEM NAME
-- ================================================
function Inventory.GetSystem()
    WaitForInventorySystem()
    return InventorySystem
end