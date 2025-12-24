fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'HM Scripts'
description 'Multi-Farm v0.3.0 - Kühe, Hühner, Schweine'
version '0.3.0'

dependencies {
    'ox_lib',
    'ox_target',
    'oxmysql'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'bridge/framework.lua',
    'bridge/inventory.lua',
    '@lation_ui/init.lua'
}

client_scripts {
    'bridge/target.lua', 
    'client/main.lua',
    'client/npc.lua',
    'client/ui.lua',
    'client/milking.lua',
    'client/chicken.lua',
    'client/pig.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/main.lua',
    'server/shop.lua',
    'server/milking.lua',
    'server/chicken.lua',
    'server/pig.lua',
    'server/debug.lua'
}
