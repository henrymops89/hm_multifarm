-- ================================================
-- QB-CORE ITEMS - MULTIFARM
-- Add to: qb-core/shared/items.lua
-- ================================================

-- ════════════════════════════════════════════════
-- KÜHE / COWS
-- ════════════════════════════════════════════════

['milk_bucket'] = {
    name = 'milk_bucket',
    label = 'Melkeimer',
    weight = 500,
    type = 'item',
    image = 'milk_bucket.png',
    unique = false,
    useable = false,
    shouldClose = true,
    combinable = nil,
    description = 'Ein Eimer zum Melken von Kühen'
},

['milk_stool'] = {
    name = 'milk_stool',
    label = 'Melkschemel',
    weight = 2000,
    type = 'item',
    image = 'milk_stool.png',
    unique = false,
    useable = false,
    shouldClose = true,
    combinable = nil,
    description = 'Ein kleiner Schemel zum Melken'
},

['raw_milk'] = {
    name = 'raw_milk',
    label = 'Rohmilch',
    weight = 1000,
    type = 'item',
    image = 'raw_milk.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Frische Rohmilch direkt von der Kuh'
},

['cow_feed'] = {
    name = 'cow_feed',
    label = 'Kuhfutter',
    weight = 500,
    type = 'item',
    image = 'cow_feed.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Nahrhaftes Futter für Kühe'
},

-- ════════════════════════════════════════════════
-- HÜHNER / CHICKENS
-- ════════════════════════════════════════════════

['egg'] = {
    name = 'egg',
    label = 'Hühnerei',
    weight = 50,
    type = 'item',
    image = 'egg.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Ein frisches Hühnerei'
},

['chicken_feed'] = {
    name = 'chicken_feed',
    label = 'Hühnerfutter',
    weight = 200,
    type = 'item',
    image = 'chicken_feed.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Körnerfutter für Hühner'
},

['feather'] = {
    name = 'feather',
    label = 'Feder',
    weight = 10,
    type = 'item',
    image = 'feather.png',
    unique = false,
    useable = false,
    shouldClose = true,
    combinable = nil,
    description = 'Eine weiche Hühnerfeder'
},

-- ════════════════════════════════════════════════
-- SCHWEINE / PIGS
-- ════════════════════════════════════════════════

['pork'] = {
    name = 'pork',
    label = 'Schweinefleisch',
    weight = 2000,
    type = 'item',
    image = 'pork.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Frisches Schweinefleisch'
},

['bacon'] = {
    name = 'bacon',
    label = 'Speck',
    weight = 500,
    type = 'item',
    image = 'bacon.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Knuspriger Speck'
},

['pig_feed'] = {
    name = 'pig_feed',
    label = 'Schweinefutter',
    weight = 300,
    type = 'item',
    image = 'pig_feed.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Nahrhaftes Futter für Schweine'
},

-- ════════════════════════════════════════════════
-- VERARBEITET / PROCESSED
-- ════════════════════════════════════════════════

['milk'] = {
    name = 'milk',
    label = 'Milch',
    weight = 1000,
    type = 'item',
    image = 'milk.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Pasteurisierte Milch'
},

['cheese'] = {
    name = 'cheese',
    label = 'Käse',
    weight = 500,
    type = 'item',
    image = 'cheese.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Leckerer Käse aus Milch'
},

['butter'] = {
    name = 'butter',
    label = 'Butter',
    weight = 250,
    type = 'item',
    image = 'butter.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Frische Butter'
},

['omelette'] = {
    name = 'omelette',
    label = 'Omelette',
    weight = 200,
    type = 'item',
    image = 'omelette.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Ein köstliches Omelette'
},

-- ================================================
-- NOTES:
-- ================================================
--
-- 1. Add these to qb-core/shared/items.lua
-- 2. Make sure images exist in qb-inventory/html/images/
-- 3. Restart qb-core and qb-inventory
-- 4. Test with /giveitem [id] [item] [amount]
--
-- Image names needed:
-- - milk_bucket.png
-- - milk_stool.png
-- - raw_milk.png
-- - cow_feed.png
-- - egg.png
-- - chicken_feed.png
-- - feather.png
-- - pork.png
-- - bacon.png
-- - pig_feed.png
-- - milk.png
-- - cheese.png
-- - butter.png
-- - omelette.png
--
-- You can use placeholder images or create custom ones!
--
-- ================================================