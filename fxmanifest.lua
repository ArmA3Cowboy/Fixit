fx_version 'cerulean'
game 'gta5'

author 'Cowboy'
name 'Fixit'
description 'NPC Vehicle Repair System'
version '1.0.0'

shared_script '@ND_Core/init.lua'

client_scripts {
    'config.lua',
    'client/main.lua'
}

server_scripts {
    'config.lua',
    'server/main.lua'
}
