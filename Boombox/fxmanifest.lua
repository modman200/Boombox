fx_version 'cerulean'

lua54 'yes'
game 'gta5'
author 'Modman'
description 'Modman'

-- Client --
client_scripts {
	'client/*.lua'
	
	}
	
	-- Server --
server_scripts {
	'server/*.lua',
	'@oxmysql/lib/MySQL.lua'
}

data_file 'CARCOLS_FILE' 'carcols.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'client/weapons.meta'

shared_scripts {
	'@ox_lib/init.lua',
--	'[criminal]/criminal-config/*.lua',
--	'[jobs]/jobs-config/*.lua',
	'config/*.lua'
}


files {
	'data/**/carcols.meta',
	'data/**/carvariations.meta',
	'data/**/handling.meta',
	'data/**/vehiclelayouts.meta',
	'data/**/vehicles.meta',
	'visualsettings.dat',
	'stream/**/**/*.ytyp'


}

data_file 'VEHICLE_LAYOUTS_FILE'	'data/**/vehiclelayouts.meta'
data_file 'HANDLING_FILE'			'data/**/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'data/**/vehicles.meta'
data_file 'CARCOLS_FILE'			'data/**/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE'	'data/**/carvariations.meta'

data_file 'DLC_ITYP_REQUEST' 'stream/props/bzz/icecream/bzzz_food_icecream_pack.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/props/bzz/dessert/bzzz_food_dessert_a.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/props/bzz/torch/bzzz_prop_torch_fire001.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/props/bzz/bzzz_food_xmas22.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/props/bzz/bzzz_animal_fish002.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/props/bzz/bzzz_food_skewerpack.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/props/bzz/prop_monster_can_01.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/props/bzz/bzzz_plant_coca_c.ytyp'

