fx_version 'cerulean'
game 'gta5'

name 'TSA-ebikerentals'
author 'TyronSmiteApril'
description 'TSA E-Bike Rental'
version '3.2.1'

client_scripts {
    'config.lua',
    'client/main.lua'
}

server_scripts {
    'config.lua',
    'server/main.lua',
    'server/sv_version_check.lua'
}

dependencies {
    'qb-core',
    'qb-target'
}

optional_dependencies {
    'ox-target'
}
