fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Base FiveM Script'
version '1.0.0'

-- Client scripts
client_scripts {
    'client/main.lua',
    'client/events.lua'
}

-- Server scripts
server_scripts {
    'server/main.lua',
    'server/events.lua'
}

-- Shared scripts
shared_scripts {
    'shared/config.lua',
    'shared/utils.lua'
}

-- Dependencies
dependencies {
    'es_extended' -- Optional: Remove if not using ESX
}

-- Files
files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

-- UI pages
ui_page 'html/index.html'