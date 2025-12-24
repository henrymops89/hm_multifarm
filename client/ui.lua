-- ================================================
-- CLIENT - UI HANDLER (MULTI-FARM)
-- Supports ox_lib Menu for Cows, Chickens, and Pigs
-- ================================================

local function DebugPrint(...)
    if Config and Config.Debug then
        print('^3[Multi-Farm UI]^0', ...)
    end
end

local uiOpen = false
local shopData = nil

-- ================================================
-- LOAD SHOP DATA
-- ================================================

local function LoadShopData(animalType, callback)
    lib.callback('multifarm:getShopData', false, function(data)
        if not data then
            DebugPrint('^1Failed to load shop data!^0')
            lib.notify({
                title = 'Multi-Farm',
                description = 'Fehler beim Laden des Shops!',
                type = 'error'
            })
            return
        end
        
        shopData = data
        callback(data)
    end, animalType)
end

-- ================================================
-- OPEN SHOP (OX_LIB)
-- ================================================

local function OpenShop(animalType)
    if uiOpen then
        DebugPrint('^3Shop already open^0')
        return
    end
    
    DebugPrint('^3Opening ' .. animalType .. ' shop...^0')
    uiOpen = true
    
    LoadShopData(animalType, function(data)
        local animalOptions = {}
        
        -- Rarity-Info
        local rarityInfo = {
            common = { emoji = '⚪', name = 'Gewöhnlich', color = '#10b981' },
            uncommon = { emoji = '🟢', name = 'Ungewöhnlich', color = '#3b82f6' },
            rare = { emoji = '🔵', name = 'Selten', color = '#6366f1' },
            epic = { emoji = '🟣', name = 'Episch', color = '#9333ea' },
            legendary = { emoji = '🟡', name = 'Legendär', color = '#eab308' }
        }
        
        for _, animal in ipairs(data.animalTypes) do
            local rarity = rarityInfo[animal.rarity] or rarityInfo.common
            
            local description = animal.description
            
            if Config.UI.ShowStats and animal.stats then
                local statKey = animalType == 'cow' and 'milk_base' or animalType == 'chicken' and 'egg_base' or 'pork_base'
                description = description .. string.format(
                    '\n\n📊 **Stats:**\n❤️ Gesundheit: %d | ⚡ Wachstum: %.1fx | 🎯 Produktion: %d',
                    animal.stats.base_health,
                    animal.stats.growth_speed,
                    animal.stats[statKey]
                )
            end
            
            local option = {
                title = animal.icon .. ' ' .. animal.name,
                description = description,
                icon = animalType == 'cow' and 'cow' or animalType == 'chicken' and 'egg' or 'bacon',
                iconColor = rarity.color,
                onSelect = function()
                    OpenSlotSelection(animalType, animal, data.freeSlots)
                end
            }
            
            if Config.UI.OxLib and Config.UI.OxLib.ShowMetadata then
                option.metadata = {
                    { label = 'Preis', value = '$' .. animal.price },
                    { label = 'Seltenheit', value = rarity.emoji .. ' ' .. rarity.name }
                }
            end
            
            table.insert(animalOptions, option)
        end
        
        if Config.UI.OxLib and Config.UI.OxLib.ShowSeparators then
            table.insert(animalOptions, {
                title = '━━━━━━━━━━━━━━━━━━━━━━',
                disabled = true
            })
        end
        
        table.insert(animalOptions, {
            title = '📊 Verfügbare Slots: ' .. #data.freeSlots .. '/' .. data.totalSlots,
            description = 'Freie Plätze für neue Tiere',
            icon = 'location-dot',
            disabled = true
        })
        
        -- Emoji für Tierart
        local emoji = animalType == 'cow' and '🐄' or animalType == 'chicken' and '🐔' or '🐷'
        
        lib.registerContext({
            id = 'multifarm_shop_' .. animalType,
            title = emoji .. ' ' .. data.farmName,
            onExit = function()
                uiOpen = false
                DebugPrint('^3Shop closed^0')
            end,
            options = animalOptions
        })
        
        lib.showContext('multifarm_shop_' .. animalType)
    end)
end

-- ================================================
-- SLOT SELECTION
-- ================================================

function OpenSlotSelection(animalType, animal, freeSlots)
    if #freeSlots == 0 then
        lib.notify({
            title = 'Multi-Farm',
            description = '❌ Keine freien Ställe verfügbar!',
            type = 'error'
        })
        uiOpen = false
        return
    end
    
    local slotOptions = {}
    
    for i, slot in ipairs(freeSlots) do
        local slotDesc = 'Freier Platz für dein Tier'
        
        if Config.UI.OxLib and Config.UI.OxLib.ShowSlotCoords then
            slotDesc = string.format('Position: %.0f, %.0f, %.0f', slot.pos_x, slot.pos_y, slot.pos_z)
        end
        
        local slotOption = {
            title = string.format('Stall #%d', slot.slot_number),
            description = slotDesc,
            icon = 'location-dot',
            iconColor = '#3b82f6',
            onSelect = function()
                OpenNameInput(animalType, animal, slot)
            end
        }
        
        if Config.UI.OxLib and Config.UI.OxLib.ShowMetadata then
            slotOption.metadata = {
                { label = 'Stall', value = '#' .. slot.slot_number },
                { label = 'Status', value = '✅ Frei' }
            }
        end
        
        table.insert(slotOptions, slotOption)
    end
    
    if Config.UI.OxLib and Config.UI.OxLib.ShowSeparators then
        table.insert(slotOptions, {
            title = '━━━━━━━━━━━━━━━━━━━━━━',
            disabled = true
        })
    end
    
    table.insert(slotOptions, {
        title = 'Zurück zum Shop',
        description = 'Anderes Tier wählen',
        icon = 'arrow-left',
        iconColor = '#3b82f6',
        onSelect = function()
            lib.hideContext()
            uiOpen = false
            Wait(200)
            OpenShop(animalType)
            DebugPrint('^2Returned to shop^0')
        end
    })
    
    local menuTitle = string.format('%s %s - $%d', animal.icon, animal.name, animal.price)
    
    lib.registerContext({
        id = 'multifarm_slots_' .. animalType,
        title = menuTitle,
        onExit = function()
            uiOpen = false
        end,
        options = slotOptions
    })
    
    lib.showContext('multifarm_slots_' .. animalType)
end

-- ================================================
-- NAME INPUT
-- ================================================

function OpenNameInput(animalType, animal, slot)
    local emoji = animalType == 'cow' and '🐄' or animalType == 'chicken' and '🐔' or '🐷'
    
    local input = lib.inputDialog(emoji .. ' Tier benennen', {
        {
            type = 'input',
            label = 'Name für dein Tier',
            description = 'Optional - leer lassen für Standard-Namen',
            placeholder = 'z.B. Berta',
            maxLength = 20
        }
    })
    
    if not input then
        uiOpen = true
        OpenSlotSelection(animalType, animal, shopData.freeSlots)
        return
    end
    
    local customName = input[1] and input[1] ~= '' and input[1] or nil
    
    -- Kaufbestätigung
    local rarityInfo = {
        common = { emoji = '⚪', name = 'Gewöhnlich' },
        uncommon = { emoji = '🟢', name = 'Ungewöhnlich' },
        rare = { emoji = '🔵', name = 'Selten' },
        epic = { emoji = '🟣', name = 'Episch' },
        legendary = { emoji = '🟡', name = 'Legendär' }
    }
    
    local rarity = rarityInfo[animal.rarity] or rarityInfo.common
    
    local confirmContent = string.format([[
╔═══════════════════════════════╗
║     %s KAUFBESTÄTIGUNG        ║
╚═══════════════════════════════╝

%s **Tier:**
   %s %s
   %s %s

💰 **Preis:**
   $%s

📍 **Slot:**
   Slot #%d

📝 **Name:**
   %s

━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ Bist du sicher?
]],
        emoji,
        emoji,
        animal.icon, animal.name,
        rarity.emoji, rarity.name,
        animal.price,
        slot.slot_number,
        customName or (emoji .. ' Tier #' .. slot.slot_number)
    )
    
    local confirm = lib.alertDialog({
        header = emoji .. ' Kauf bestätigen',
        content = confirmContent,
        centered = true,
        cancel = true,
        labels = {
            confirm = '✅ Kaufen ($' .. animal.price .. ')',
            cancel = '❌ Abbrechen'
        }
    })
    
    if confirm == 'confirm' then
        PurchaseAnimal(animalType, animal.id, slot.id, customName)
    else
        uiOpen = true
        OpenSlotSelection(animalType, animal, shopData.freeSlots)
    end
end

-- ================================================
-- PURCHASE ANIMAL
-- ================================================

function PurchaseAnimal(animalType, breedId, slotId, customName)
    lib.callback('multifarm:purchaseAnimal', false, function(success, result)
        if success then
            DebugPrint('^2Purchase successful!^0')
            
            TriggerEvent('multifarm:animalPurchased', result)
            
            lib.notify({
                title = 'Multi-Farm',
                description = '✅ Tier erfolgreich gekauft!',
                type = 'success'
            })
            
            uiOpen = false
        else
            DebugPrint('^1Purchase failed: ' .. result .. '^0')
            
            local errorMsg = Config.Notifications.Error[result] or Config.Notifications.Error.database_error
            
            lib.notify({
                title = 'Multi-Farm',
                description = errorMsg,
                type = 'error'
            })
            
            Wait(500)
            OpenShop(animalType)
        end
    end, {
        animalType = animalType,
        breedId = breedId,
        slotId = slotId,
        customName = customName
    })
end

-- ================================================
-- EVENT: Open Shop
-- ================================================

RegisterNetEvent('multifarm:openShop', function(animalType)
    while not Config do
        Wait(100)
    end
    
    OpenShop(animalType)
end)

-- ================================================
-- DEBUG COMMANDS
-- ================================================

if Config.Debug then
    RegisterCommand('multifarm_cow_shop', function()
        TriggerEvent('multifarm:openShop', 'cow')
    end)
    
    RegisterCommand('multifarm_chicken_shop', function()
        TriggerEvent('multifarm:openShop', 'chicken')
    end)
    
    RegisterCommand('multifarm_pig_shop', function()
        TriggerEvent('multifarm:openShop', 'pig')
    end)
end
