-- ================================================
-- MULTI-FARM v0.3.0 - OX_INVENTORY ITEMS
-- Add these items to your ox_inventory/data/items.lua
-- ================================================

-- ================================================
-- KUH-PRODUKTE & WERKZEUGE
-- ================================================

['milk_bucket'] = {
    label = 'Melkeimer',
    weight = 500,
    stack = true,
    close = true,
    description = 'Ein Eimer zum Melken von Kühen',
    client = {
        image = 'milk_bucket.png',
    }
},

['milk_stool'] = {
    label = 'Melkschemel',
    weight = 1000,
    stack = false,
    close = true,
    description = 'Ein Schemel zum Sitzen beim Melken',
    client = {
        image = 'milk_stool.png',
    }
},

['raw_milk'] = {
    label = 'Rohmilch',
    weight = 100,
    stack = true,
    close = true,
    description = 'Frische Rohmilch von einer Kuh',
    client = {
        image = 'raw_milk.png',
    }
},

-- ================================================
-- HÜHNER-PRODUKTE
-- ================================================

['eggs'] = {
    label = 'Eier',
    weight = 50,
    stack = true,
    close = true,
    description = 'Frische Eier von glücklichen Hühnern',
    client = {
        image = 'eggs.png',
    }
},

-- ================================================
-- SCHWEINE-PRODUKTE & FUTTER
-- ================================================

['pig_feed'] = {
    label = 'Schweinefutter',
    weight = 200,
    stack = true,
    close = true,
    description = 'Nährstoffreiches Futter für Schweine',
    client = {
        image = 'pig_feed.png',
    }
},

['pork'] = {
    label = 'Schweinefleisch',
    weight = 300,
    stack = true,
    close = true,
    description = 'Hochwertiges Schweinefleisch',
    client = {
        image = 'pork.png',
    }
},

-- ================================================
-- OPTIONAL: VERARBEITETE PRODUKTE (für spätere Updates)
-- ================================================

['milk'] = {
    label = 'Milch',
    weight = 100,
    stack = true,
    close = true,
    description = 'Pasteurisierte Milch',
    client = {
        image = 'milk.png',
    }
},

['cheese'] = {
    label = 'Käse',
    weight = 200,
    stack = true,
    close = true,
    description = 'Handgemachter Käse',
    client = {
        image = 'cheese.png',
    }
},

['butter'] = {
    label = 'Butter',
    weight = 150,
    stack = true,
    close = true,
    description = 'Frische Butter',
    client = {
        image = 'butter.png',
    }
},

['bacon'] = {
    label = 'Speck',
    weight = 150,
    stack = true,
    close = true,
    description = 'Knuspriger Speck',
    client = {
        image = 'bacon.png',
    }
},

['omelet'] = {
    label = 'Omelett',
    weight = 100,
    stack = true,
    close = true,
    description = 'Frisches Omelett',
    client = {
        image = 'omelet.png',
    }
},

-- ================================================
-- BILDER BENÖTIGT (place in ox_inventory/web/images/)
-- ================================================
-- KÜHE:
--   - milk_bucket.png
--   - milk_stool.png
--   - raw_milk.png
--
-- HÜHNER:
--   - eggs.png
--
-- SCHWEINE:
--   - pig_feed.png
--   - pork.png
--
-- OPTIONAL:
--   - milk.png, cheese.png, butter.png
--   - bacon.png, omelet.png
-- ================================================
