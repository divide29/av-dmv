fx_version 'cerulean'
game 'gta5'

author 'avellon'
description 'This resource adds a better performing DMV system to roleplay servers.'
version '1.0.0'

shared_scripts {
	'@qb-core/shared/locale.lua',
	'config.lua',
	'configuration/locales/en.lua',
	'configuration/locales/*.lua',
	'configuration/routes.lua',
	'configuration/theoryQuestions.lua',
}

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
	'client/main.lua'
}
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

files {
	'assets/main.html',
	'assets/main.css',
	'assets/main.js',
	'assets/js/feather.min.js',
}

escrow_ignore {
	'configuration/locales/*.lua',
	'configuration/*.lua',
	'config.lua'
}

ui_page 'assets/main.html'

lua54 'yes'
