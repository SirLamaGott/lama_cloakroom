fx_version 'cerulean'
games {'gta5'}
lua54 'yes'

author 'SirLamaGott'
description 'Lama - Umkleide'
version '0.2.1'

shared_script 'config.lua'
shared_script '@es_extended/imports.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'config.lua',
    'server/main.lua'
}
client_scripts {
    '@es_extended/locale.lua',
    'config.lua',
    'client/main.lua'
}

dependencies {
	'es_extended',
    'oxmysql'  
} 

escrow_ignore {
  'config.lua',
  'client/main.lua',
  'server/main.lua',
  'locales/*.lua'
}