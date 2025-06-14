fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Whiskeysim'
description 'ESC/TCS Control System for Dynamic Framework'
version '1.0'

shared_script 'config.lua'

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}