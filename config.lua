-- ================================================
-- HM HOLY COW v0.3.0 - MULTI-FARM CONFIGURATION
-- Farm Management System - Kühe, Hühner, Schweine
-- ================================================

Config = {}

-- Debug Mode
Config.Debug = false

-- ================================================
-- FRAMEWORK
-- ================================================
Config.Framework = 'auto' -- 'qbox', 'qbcore', 'esx', or 'auto'
Config.Inventory = 'auto'  -- 'ox', 'qb-inventory', 'ps-inventory'
Config.Target = 'auto' -- 'ox_target', 'qb-target'
-- ================================================
-- DATABASE
-- ================================================
Config.Database = {
    Enabled = true,
    Resource = 'oxmysql'
}

-- ================================================
-- FARM LOCATION
-- ================================================
Config.Farm = {
    Name = 'Multi-Farm Grapeseed',
    Blip = {
        Enabled = true,
        Coords = vector3(2447.24, 4784.11, 34.18),
        Sprite = 273,
        Color = 2,
        Scale = 0.8,
        Name = '\u{1F404} Multi-Farm'
    }
}

-- ================================================
-- SHOP NPCs (3 NPCS!)
-- ================================================
Config.NPCs = {
    -- 🐄 KUH-FARMER
cow = {
    Enabled = true,
    Model = 'a_m_m_farmer_01',
    Coords = vector4(2440.5, 4783.2, 34.3, 120.0),
    Scenario = 'WORLD_HUMAN_CLIPBOARD',
    Target = {
        Label = '\u{1F404} Kühe kaufen',
        Icon = 'fa-solid fa-cow',
        Distance = 2.5
    },  
    Blip = {
        Enabled = true,
        Sprite = 273,
        Color = 5,
        Scale = 0.7,
        Name = '🐄 Kuh-Shop'
    }
},
    
    -- 🐔 HÜHNER-ZÜCHTER
    chicken = {
        Enabled = true,
        Model = 'a_m_m_hillbilly_01',
        Coords = vector4(2302.5088, 4949.5698, 41.4801, 120.0),
        Scenario = 'WORLD_HUMAN_CLIPBOARD',
        Target = {
            Label = '\u{1F414} Hühner kaufen',
            Icon = 'fa-solid fa-egg',
            Distance = 2.5
        },
    Blip = {
            Enabled = true,
            Sprite = 274,          -- Blip-Icon (anpassen!)
            Color = 46,            -- Orange
            Scale = 0.7,
            Name = '🐔 Hühner-Shop'
        },
    },
    
    -- 🐷 SCHWEINE-ZÜCHTER
    pig = {
        Enabled = true,
        Model = 'a_m_m_farmer_01',
        Coords = vector4(2366.2463, 5055.6899, 46.4690, 180.0),
        Scenario = 'WORLD_HUMAN_CLIPBOARD',
        Target = {
            Label = '\u{1F437} Schweine kaufen',
            Icon = 'fa-solid fa-bacon',
            Distance = 2.5
        },
     Blip = {
            Enabled = true,
            Sprite = 275,          -- Blip-Icon (anpassen!)
            Color = 8,             -- Pink
            Scale = 0.7,
            Name = '🐷 Schweine-Shop'
        },
    }
}

-- ================================================
-- COW TYPES (5 Breeds - BLEIBT WIE ES IST)
-- ================================================
Config.CowTypes = {
    {
        id = 'holstein',
        name = 'Holstein-Friesian',
        description = 'Standard Milchkuh - zuverlässig und produktiv',
        price = 500,
        rarity = 'common',
        icon = '\u{1F404}',
        model = 'a_c_cow',
        scenario = 'WORLD_COW_GRAZING',
        stats = {
            base_health = 100,
            growth_speed = 1.0,
            max_age = 30,
            milk_base = 3
        }
    },
    {
        id = 'jersey',
        name = 'Jersey Premium',
        description = 'Hochwertige Rasse - 50% schnelleres Wachstum!',
        price = 1200,
        rarity = 'rare',
        icon = '\u{2B50}',
        model = 'a_c_cow',
        scenario = 'WORLD_COW_GRAZING',
        stats = {
            base_health = 100,
            growth_speed = 1.5,
            max_age = 25,
            milk_base = 5
        }
    },
    {
        id = 'angus',
        name = 'Black Angus',
        description = 'Robuste Fleischrasse - höchste Gesundheit',
        price = 900,
        rarity = 'uncommon',
        icon = '\u{1F402}',
        model = 'a_c_cow',
        scenario = 'WORLD_COW_GRAZING',
        stats = {
            base_health = 120,
            growth_speed = 0.9,
            max_age = 35,
            milk_base = 2
        }
    },
    {
        id = 'swiss_brown',
        name = 'Schweizer Braunvieh',
        description = 'Alpenrind - perfekt für Käse!',
        price = 1500,
        rarity = 'rare',
        icon = '\u{1F3D4}',
        model = 'a_c_cow',
        scenario = 'WORLD_COW_GRAZING',
        stats = {
            base_health = 110,
            growth_speed = 1.2,
            max_age = 28,
            milk_base = 4
        }
    },
    {
        id = 'simmental',
        name = 'Simmental Elite',
        description = 'Elite-Rasse - beste Milchproduktion!',
        price = 1800,
        rarity = 'epic',
        icon = '\u{1F451}',
        model = 'a_c_cow',
        scenario = 'WORLD_COW_GRAZING',
        stats = {
            base_health = 105,
            growth_speed = 1.3,
            max_age = 32,
            milk_base = 6
        }
    }
}

-- ================================================
-- CHICKEN TYPES (3 Breeds - NEU!)
-- ================================================
Config.ChickenTypes = {
    {
        id = 'chicken_basic',
        name = 'Legehennen',
        description = 'Standard Hühner - zuverlässige Eierproduktion',
        price = 150,
        rarity = 'common',
        icon = '\u{1F414}',
        model = 'a_c_hen',
        scenario = 'WORLD_HEN_PECKING',
        stats = {
            base_health = 50,
            growth_speed = 1.5,
            max_age = 20,
            egg_base = 2
        }
    },
    {
        id = 'chicken_premium',
        name = 'Premium-Huhn',
        description = 'Hochwertige Rasse - doppelte Eierproduktion!',
        price = 400,
        rarity = 'rare',
        icon = '\u{1F413}',
        model = 'a_c_hen',
        scenario = 'WORLD_HEN_PECKING',
        stats = {
            base_health = 60,
            growth_speed = 1.8,
            max_age = 18,
            egg_base = 4
        }
    },
    {
        id = 'chicken_gold',
        name = 'Gold-Huhn',
        description = 'Elite-Rasse - beste Eierqualität!',
        price = 800,
        rarity = 'epic',
        icon = '\u{1F947}',
        model = 'a_c_hen',
        scenario = 'WORLD_HEN_PECKING',
        stats = {
            base_health = 70,
            growth_speed = 2.0,
            max_age = 15,
            egg_base = 6
        }
    }
}

-- ================================================
-- PIG TYPES (3 Breeds - NEU!)
-- ================================================
Config.PigTypes = {
    {
        id = 'pig_basic',
        name = 'Hausschwein',
        description = 'Standard Mastschwein - solide Fleischproduktion',
        price = 600,
        rarity = 'common',
        icon = '\u{1F437}',
        model = 'a_c_pig',
        scenario = 'WORLD_PIG_GRAZING',
        stats = {
            base_health = 150,
            growth_speed = 0.8,
            max_age = 25,
            pork_base = 2
        }
    },
    {
        id = 'pig_premium',
        name = 'Mastschwein',
        description = 'Hochwertige Rasse - doppelte Fleischausbeute!',
        price = 1200,
        rarity = 'rare',
        icon = '\u{1F416}',
        model = 'a_c_pig',
        scenario = 'WORLD_PIG_GRAZING',
        stats = {
            base_health = 180,
            growth_speed = 1.0,
            max_age = 22,
            pork_base = 4
        }
    },
    {
        id = 'pig_elite',
        name = 'Premium-Schwein',
        description = 'Elite-Rasse - beste Fleischqualität!',
        price = 2000,
        rarity = 'epic',
        icon = '\u{1F451}',
        model = 'a_c_pig',
        scenario = 'WORLD_PIG_GRAZING',
        stats = {
            base_health = 200,
            growth_speed = 1.2,
            max_age = 20,
            pork_base = 6
        }
    }
}

-- ================================================
-- SLOTS (loaded from database)
-- ================================================
Config.Slots = {} -- Auto-filled on server start

-- ================================================
-- UI SETTINGS
-- ================================================
Config.UI = {
    Type = 'ox_lib',
    ShowRarity = true,
    ShowStats = false,
    Theme = 'light',
    Currency = '$',
    OxLib = {
        ShowMetadata = true,
        ShowSeparators = true,
        ShowSlotCoords = true
    }
}

-- ================================================
-- ANIMAL BLIPS
-- ================================================
Config.AnimalBlips = {
    Enabled = true,
    Sprite = 141,
    Scale = 0.6,
    
    -- Farben nach Tierart
    Color = {
        -- Kühe
        holstein = 0,
        jersey = 46,
        angus = 1,
        swiss_brown = 26,
        simmental = 5,
        
        -- Hühner
        chicken_basic = 7,
        chicken_premium = 46,
        chicken_gold = 46,
        
        -- Schweine
        pig_basic = 27,
        pig_premium = 45,
        pig_elite = 83,
        
        default = 2
    },
    ShowName = true
}

-- ================================================
-- NOTIFICATIONS
-- ================================================
Config.Notifications = {
    Success = {
        animal_purchased = '\u{2705} Tier erfolgreich gekauft!',
        animal_spawned = '\u{2705} Dein Tier wurde gespawnt!',
    },
    Error = {
        no_money = '\u{274C} Nicht genug Geld!',
        no_slots = '\u{274C} Keine freien Slots verfügbar!',
        already_owned = '\u{26A0} Dieser Slot ist bereits belegt!',
        database_error = '\u{274C} Datenbankfehler!',
        invalid_slot = '\u{274C} Ungültiger Slot!',
        slot_was_inconsistent_now_fixed = '\u{26A0} Slot wurde repariert!',
    },
    Info = {
        welcome = '\u{1F404} Willkommen auf der Multi-Farm!',
        select_slot = '\u{1F50D} Wähle einen freien Slot',
        shop_opened = '\u{1F6AA} Shop geöffnet',
    }
}

-- ================================================
-- PERMISSIONS
-- ================================================
Config.Permissions = {
    MaxAnimals = 30,  -- Max gesamt (10 Kühe + 10 Hühner + 10 Schweine)
    MaxCows = 10,
    MaxChickens = 10,
    MaxPigs = 10,
    RequireJob = false,
    RequireGang = false,
    DebugCommands = 'holycow.admin'
}

-- ================================================
-- MILKING SYSTEM (KÜHE)
-- ================================================
Config.Milking = {
    Enabled = true,
    RequireItems = true,
    RequiredItems = {
        bucket = 'milk_bucket',
        stool = 'milk_stool'
    },
    RemoveItemsAfterUse = false,
    Output = {
        item = 'raw_milk',
        amount = 1,
        label = 'Rohmilch'
    },
    CooldownMinutes = 15,
    ProgressDuration = 10000,
    ProgressLabel = 'Kuh melken...',
    Animation = {
        dict = 'amb@world_human_gardener_plant@male@base',
        name = 'base',
    },
    Target = {
        Label = '\u{1F95B} Kuh melken',
        Icon = 'fa-solid fa-droplet',
        Distance = 2.5
    },
    Notifications = {
        success = '\u{2705} Erfolgreich gemolken! +%d %s',
        cooldown = '\u{23F0} Cooldown aktiv! Noch %s',
        missing_items = '\u{274C} Du brauchst: %s',
        no_items_bucket = '\u{1FAA3} Melkeimer fehlt!',
        no_items_stool = '\u{1FA91} Melkschemel fehlt!',
        error = '\u{274C} Etwas ist schiefgelaufen!'
    }
}

-- ================================================
-- EGG COLLECTION SYSTEM (HÜHNER)
-- ================================================
Config.EggCollection = {
    Enabled = true,
    RequireItems = false,  -- Keine Items nötig!
    Output = {
        item = 'eggs',
        amount = 1,
        label = 'Eier'
    },
    CooldownMinutes = 10,
    ProgressDuration = 5000,
    ProgressLabel = 'Eier sammeln...',
    Animation = {
        dict = 'amb@world_human_gardener_plant@male@base',
        name = 'base',
    },
    Target = {
        Label = '\u{1F95A} Eier sammeln',
        Icon = 'fa-solid fa-egg',
        Distance = 2.5
    },
    Notifications = {
        success = '\u{2705} Eier gesammelt! +%d %s',
        cooldown = '\u{23F0} Cooldown aktiv! Noch %s',
        error = '\u{274C} Etwas ist schiefgelaufen!'
    }
}

-- ================================================
-- PIG FEEDING SYSTEM (SCHWEINE)
-- ================================================
Config.PigFeeding = {
    Enabled = true,
    RequireItems = true,  -- Futter benötigt!
    RequiredItems = {
        feed = 'pig_feed'
    },
    RemoveItemsAfterUse = true,  -- Futter wird verbraucht!
    Output = {
        item = 'pork',
        amount = 1,
        label = 'Schweinefleisch'
    },
    CooldownMinutes = 20,
    ProgressDuration = 8000,
    ProgressLabel = 'Schwein füttern...',
    Animation = {
        dict = 'amb@world_human_gardener_plant@male@base',
        name = 'base',
    },
    Target = {
        Label = '\u{1F33D} Schwein füttern',
        Icon = 'fa-solid fa-wheat-awn',
        Distance = 2.5
    },
    Notifications = {
        success = '\u{2705} Schwein gefüttert! +%d %s',
        cooldown = '\u{23F0} Cooldown aktiv! Noch %s',
        no_feed = '\u{1F33D} Schweinefutter fehlt!',
        error = '\u{274C} Etwas ist schiefgelaufen!'
    }
}

-- ================================================
-- ECONOMY
-- ================================================
Config.Economy = {
    Currency = 'cash',
    SellPercentage = 0.5
}

-- ================================================
-- HELPER FUNCTIONS
-- ================================================

function Config.GetAnimalType(animalType, id)
    local types = {
        cow = Config.CowTypes,
        chicken = Config.ChickenTypes,
        pig = Config.PigTypes
    }
    
    local typeList = types[animalType]
    if not typeList then return nil end
    
    for _, animal in ipairs(typeList) do
        if animal.id == id then
            return animal
        end
    end
    return nil
end

function Config.GetSlotById(slotId)
    for _, slot in ipairs(Config.Slots) do
        if slot.id == slotId then
            return slot
        end
    end
    return nil
end

-- ================================================
-- DEBUG PRINT
-- ================================================

function DebugPrint(...)
    if Config.Debug then
        print('^3[Multi-Farm]^0', ...)
    end
end
