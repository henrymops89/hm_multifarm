fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'HM Scripts'
description 'HM Holy Cow v0.1.0 - Farm Management System (Foundation)'
version '0.1.0'

dependencies {
    'ox_lib',
    'ox_target',
    'oxmysql'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'bridge/framework.lua',
    'client/main.lua',
    'client/npc.lua',
    'client/ui.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/framework.lua',
    'server/database.lua',
    'server/main.lua',
    'server/shop.lua'
}

ui_page 'html/shop.html'

files {
    'html/shop.html'
}
