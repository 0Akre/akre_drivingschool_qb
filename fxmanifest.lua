fx_version 'adamant'
game 'gta5'

author 'Akre'
version '1.0'
lua54 'yes'

shared_scripts {
    'config.lua',
}

client_script {
    'client/main.lua',
}

server_scripts {
    'server/server.lua',
}

ui_page {'html/index.html'}

files {
    'html/index.html',
    'html/script.js',
    'html/style.css',
}