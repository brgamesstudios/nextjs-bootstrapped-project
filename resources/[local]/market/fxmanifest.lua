fx_version 'cerulean'
lua54 'yes'

game 'gta5'

name 'market-ui'

description 'Lightweight market UI with NUI'

author 'cursor-gpt'

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/style.css',
  'html/app.js',
  'html/reset.css',
  'html/images/*.svg'
}

shared_scripts {
  'shared/config.lua'
}

client_scripts {
  'shared/config.lua',
  'client/client.lua'
}

server_scripts {
  'shared/config.lua',
  'server/server.lua'
}

dependencies {
  'qb-core'
}