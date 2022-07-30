fx_version 'cerulean'
use_fxv2_oal 'yes'
game 'gta5'
lua54 'yes'

name 'JLRP-Hud'
author 'Mahan Moulaei'
discord 'Mahan#8183'
description 'JolbakLifeRP Hud'

version '0.0'

shared_scripts {
	'@JLRP-Framework/imports.lua',
    '@JLRP-Framework/shared/locale.lua',
    'locales/en.lua',
    'config.lua'
}

client_script 'client.lua'
server_script 'server.lua'

ui_page 'html/index.html'

files {
	'html/*',
	'html/index.html',
	'html/styles.css',
	'html/responsive.css',
	'html/app.js',
}
