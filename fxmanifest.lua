fx_version 'cerulean'
games { 'rdr3', 'gta5' }

author 'Domas Scripts'
description 'Influencer codes for your FiveM server'
version '1.0.0'

server_scripts {'server/*.lua'}
client_scripts {'client/*.lua'}
shared_script 'config.lua'

escrow_ignore {
    'server/*.lua',
    'client/*.lua',
    'config.lua'
}