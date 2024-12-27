fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
game 'gta5'

description 'Mechanic script'
author 'RijayJH'
version '0.0.1'

ui_page 'web/index.html'

client_scripts {
    'client/**/*',
    'preview/menus/main.lua',
    'preview/zones.lua',
    'preview/**/*'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/**/*'
}

shared_scripts {
    'shared/**/*',
    '@ox_lib/init.lua'
}

files {
    'client/**/*.lua',
    'web/**/*',
    'carcols_gen9.meta',
    'carmodcols_gen9.meta',
}

data_file 'CARCOLS_GEN9_FILE' 'carcols_gen9.meta'
data_file 'CARMODCOLS_GEN9_FILE' 'carmodcols_gen9.meta'

lua54 'yes'