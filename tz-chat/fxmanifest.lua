fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'TZ Scripts'
description 'StreetKings-inspired compact roleplay chat'
version '1.0.0'

ui_page 'web/index.html'

shared_script 'config.lua'

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'web/index.html',
    'web/style.css',
    'web/app.js'
}
