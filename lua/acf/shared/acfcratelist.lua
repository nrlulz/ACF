AddCSLuaFile( "acf/shared/acfcratelist.lua" )

local AmmoTable = {}  --Start ammo containers listing

local AmmoSmall = {}
	AmmoSmall.id = "AmmoSmall"
	AmmoSmall.ent = "acf_ammo"
	AmmoSmall.type = "Ammo"
	AmmoSmall.name = "Small Ammo Crate"
	AmmoSmall.desc = "Small ammo crate\n"
	AmmoSmall.model = "models/ammocrate_small.mdl"
	AmmoSmall.weight = 10
	AmmoSmall.volume = 2790
AmmoTable["AmmoSmall"] = AmmoSmall

local AmmoMedCube = {}
	AmmoMedCube.id = "AmmoMedCube"
	AmmoMedCube.ent = "acf_ammo"
	AmmoMedCube.type = "Ammo"
	AmmoMedCube.name = "Medium cubic ammo crate"
	AmmoMedCube.desc = "Medium cubic ammo crate\n"
	AmmoMedCube.model = "models/ammocrate_medium_small.mdl"
	AmmoMedCube.weight = 80
	AmmoMedCube.volume = 20682
AmmoTable["AmmoMedCube"] = AmmoMedCube
	
local AmmoMedium = {}
	AmmoMedium.id = "AmmoMedium"
	AmmoMedium.ent = "acf_ammo"
	AmmoMedium.type = "Ammo"
	AmmoMedium.name = "Medium Ammo Crate"
	AmmoMedium.desc = "Medium ammo crate\n"
	AmmoMedium.model = "models/ammocrate_medium.mdl"
	AmmoMedium.weight = 150
	AmmoMedium.volume = 40221
AmmoTable["AmmoMedium"] = AmmoMedium
	
local AmmoLarge = {}
	AmmoLarge.id = "AmmoLarge"
	AmmoLarge.ent = "acf_ammo"
	AmmoLarge.type = "Ammo"
	AmmoLarge.name = "Large Ammo Crate"
	AmmoLarge.desc = "Large ammo crate\n"
	AmmoLarge.model = "models/ammocrate_large.mdl"
	AmmoLarge.weight = 1000
	AmmoLarge.volume = 156499
AmmoTable["AmmoLarge"] = AmmoLarge

local Ammo1x1x8 = {}
	Ammo1x1x8.id = "Ammo1x1x8"
	Ammo1x1x8.ent = "acf_ammo"
	Ammo1x1x8.type = "Ammo"
	Ammo1x1x8.name = "Modular Ammo Crate"
	Ammo1x1x8.desc = "Modular Ammo Crate 1x1x8 Size\n"
	Ammo1x1x8.model = "models/ammocrates/ammo_1x1x8.mdl"
	Ammo1x1x8.weight = 40
	Ammo1x1x8.volume = 15681
AmmoTable["Ammo1x1x8"] = Ammo1x1x8

local Ammo1x1x6 = {}
	Ammo1x1x6.id = "Ammo1x1x6"
	Ammo1x1x6.ent = "acf_ammo"
	Ammo1x1x6.type = "Ammo"
	Ammo1x1x6.name = "Modular Ammo Crate"
	Ammo1x1x6.desc = "Modular Ammo Crate 1x1x6 Size\n"
	Ammo1x1x6.model = "models/ammocrates/ammo_1x1x6.mdl"
	Ammo1x1x6.weight = 30
	Ammo1x1x6.volume = 11750
AmmoTable["Ammo1x1x6"] = Ammo1x1x6

local Ammo1x1x4 = {}
	Ammo1x1x4.id = "Ammo1x1x4"
	Ammo1x1x4.ent = "acf_ammo"
	Ammo1x1x4.type = "Ammo"
	Ammo1x1x4.name = "Modular Ammo Crate"
	Ammo1x1x4.desc = "Modular Ammo Crate 1x1x4 Size\n"
	Ammo1x1x4.model = "models/ammocrates/ammo_1x1x4.mdl"
	Ammo1x1x4.weight = 20
	Ammo1x1x4.volume = 8019
AmmoTable["Ammo1x1x4"] = Ammo1x1x4

local Ammo1x1x2 = {}
	Ammo1x1x2.id = "Ammo1x1x2"
	Ammo1x1x2.ent = "acf_ammo"
	Ammo1x1x2.type = "Ammo"
	Ammo1x1x2.name = "Modular Ammo Crate"
	Ammo1x1x2.desc = "Modular Ammo Crate 1x1x2 Size\n"
	Ammo1x1x2.model = "models/ammocrates/ammo_1x1x2.mdl"
	Ammo1x1x2.weight = 10
	Ammo1x1x2.volume = 4031
AmmoTable["Ammo1x1x2"] = Ammo1x1x2

local Ammo2x2x1 = {}
	Ammo2x2x1.id = "Ammo2x2x1"
	Ammo2x2x1.ent = "acf_ammo"
	Ammo2x2x1.type = "Ammo"
	Ammo2x2x1.name = "Modular Ammo Crate"
	Ammo2x2x1.desc = "Modular Ammo Crate 2x2x1 Size\n"
	Ammo2x2x1.model = "models/ammocrates/ammocrate_2x2x1.mdl"
	Ammo2x2x1.weight = 20
	Ammo2x2x1.volume = 4076
AmmoTable["Ammo2x2x1"] = Ammo2x2x1

local Ammo2x2x2 = {}
	Ammo2x2x2.id = "Ammo2x2x2"
	Ammo2x2x2.ent = "acf_ammo"
	Ammo2x2x2.type = "Ammo"
	Ammo2x2x2.name = "Modular Ammo Crate"
	Ammo2x2x2.desc = "Modular Ammo Crate 2x2x2 Size\n"
	Ammo2x2x2.model = "models/ammocrates/ammocrate_2x2x2.mdl"
	Ammo2x2x2.weight = 40
	Ammo2x2x2.volume = 10936
AmmoTable["Ammo2x2x2"] = Ammo2x2x2

local Ammo2x2x4 = {}
	Ammo2x2x4.id = "Ammo2x2x4"
	Ammo2x2x4.ent = "acf_ammo"
	Ammo2x2x4.type = "Ammo"
	Ammo2x2x4.name = "Modular Ammo Crate"
	Ammo2x2x4.desc = "Modular Ammo Crate 2x2x4 Size\n"
	Ammo2x2x4.model = "models/ammocrates/ammocrate_2x2x4.mdl"
	Ammo2x2x4.weight = 80
	Ammo2x2x4.volume = 22193
AmmoTable["Ammo2x2x4"] = Ammo2x2x4

local Ammo2x2x6 = {}
	Ammo2x2x6.id = "Ammo2x2x6"
	Ammo2x2x6.ent = "acf_ammo"
	Ammo2x2x6.type = "Ammo"
	Ammo2x2x6.name = "Modular Ammo Crate"
	Ammo2x2x6.desc = "Modular Ammo Crate 2x2x6 Size\n"
	Ammo2x2x6.model = "models/ammocrates/ammo_2x2x6.mdl"
	Ammo2x2x6.weight = 120
	Ammo2x2x6.volume = 40290
AmmoTable["Ammo2x2x6"] = Ammo2x2x6

local Ammo2x2x8 = {}
	Ammo2x2x8.id = "Ammo2x2x8"
	Ammo2x2x8.ent = "acf_ammo"
	Ammo2x2x8.type = "Ammo"
	Ammo2x2x8.name = "Modular Ammo Crate"
	Ammo2x2x8.desc = "Modular Ammo Crate 2x2x8 Size\n"
	Ammo2x2x8.model = "models/ammocrates/ammo_2x2x8.mdl"
	Ammo2x2x8.weight = 160
	Ammo2x2x8.volume = 54174
AmmoTable["Ammo2x2x8"] = Ammo2x2x8

local Ammo2x3x1 = {}
	Ammo2x3x1.id = "Ammo2x3x1"
	Ammo2x3x1.ent = "acf_ammo"
	Ammo2x3x1.type = "Ammo"
	Ammo2x3x1.name = "Modular Ammo Crate"
	Ammo2x3x1.desc = "Modular Ammo Crate 2x3x1 Size\n"
	Ammo2x3x1.model = "models/ammocrates/ammocrate_2x3x1.mdl"
	Ammo2x3x1.weight = 30
	Ammo2x3x1.volume = 6193
AmmoTable["Ammo2x3x1"] = Ammo2x3x1

local Ammo2x3x2 = {}
	Ammo2x3x2.id = "Ammo2x3x2"
	Ammo2x3x2.ent = "acf_ammo"
	Ammo2x3x2.type = "Ammo"
	Ammo2x3x2.name = "Modular Ammo Crate"
	Ammo2x3x2.desc = "Modular Ammo Crate 2x3x2 Size\n"
	Ammo2x3x2.model = "models/ammocrates/ammocrate_2x3x2.mdl"
	Ammo2x3x2.weight = 60
	Ammo2x3x2.volume = 14938
AmmoTable["Ammo2x3x2"] = Ammo2x3x2

local Ammo2x3x4 = {}
	Ammo2x3x4.id = "Ammo2x3x4"
	Ammo2x3x4.ent = "acf_ammo"
	Ammo2x3x4.type = "Ammo"
	Ammo2x3x4.name = "Modular Ammo Crate"
	Ammo2x3x4.desc = "Modular Ammo Crate 2x3x4 Size\n"
	Ammo2x3x4.model = "models/ammocrates/ammocrate_2x3x4.mdl"
	Ammo2x3x4.weight = 120
	Ammo2x3x4.volume = 33731
AmmoTable["Ammo2x3x4"] = Ammo2x3x4

local Ammo2x4x1 = {}
	Ammo2x4x1.id = "Ammo2x4x1"
	Ammo2x4x1.ent = "acf_ammo"
	Ammo2x4x1.type = "Ammo"
	Ammo2x4x1.name = "Modular Ammo Crate"
	Ammo2x4x1.desc = "Modular Ammo Crate 2x4x1 Size\n"
	Ammo2x4x1.model = "models/ammocrates/ammocrate_2x4x1.mdl"
	Ammo2x4x1.weight = 40
	Ammo2x4x1.volume = 8521
AmmoTable["Ammo2x4x1"] = Ammo2x4x1

local Ammo2x4x2 = {}
	Ammo2x4x2.id = "Ammo2x4x2"
	Ammo2x4x2.ent = "acf_ammo"
	Ammo2x4x2.type = "Ammo"
	Ammo2x4x2.name = "Modular Ammo Crate"
	Ammo2x4x2.desc = "Modular Ammo Crate 2x4x2 Size\n"
	Ammo2x4x2.model = "models/ammocrates/ammocrate_2x4x2.mdl"
	Ammo2x4x2.weight = 80
	Ammo2x4x2.volume = 22193
AmmoTable["Ammo2x4x2"] = Ammo2x4x2

local Ammo2x4x4 = {}
	Ammo2x4x4.id = "Ammo2x4x4"
	Ammo2x4x4.ent = "acf_ammo"
	Ammo2x4x4.type = "Ammo"
	Ammo2x4x4.name = "Modular Ammo Crate"
	Ammo2x4x4.desc = "Modular Ammo Crate 2x4x4 Size\n"
	Ammo2x4x4.model = "models/ammocrates/ammocrate_2x4x4.mdl"
	Ammo2x4x4.weight = 160
	Ammo2x4x4.volume = 46285
AmmoTable["Ammo2x4x4"] = Ammo2x4x4

local Ammo2x4x6 = {}
	Ammo2x4x6.id = "Ammo2x4x6"
	Ammo2x4x6.ent = "acf_ammo"
	Ammo2x4x6.type = "Ammo"
	Ammo2x4x6.name = "Modular Ammo Crate"
	Ammo2x4x6.desc = "Modular Ammo Crate 2x4x6 Size\n"
	Ammo2x4x6.model = "models/ammocrates/ammocrate_2x4x6.mdl"
	Ammo2x4x6.weight = 240
	Ammo2x4x6.volume = 68746
AmmoTable["Ammo2x4x6"] = Ammo2x4x6

local Ammo2x4x8 = {}
	Ammo2x4x8.id = "Ammo2x4x8"
	Ammo2x4x8.ent = "acf_ammo"
	Ammo2x4x8.type = "Ammo"
	Ammo2x4x8.name = "Modular Ammo Crate"
	Ammo2x4x8.desc = "Modular Ammo Crate 2x4x8 Size\n"
	Ammo2x4x8.model = "models/ammocrates/ammocrate_2x4x8.mdl"
	Ammo2x4x8.weight = 320
	Ammo2x4x8.volume = 90547
AmmoTable["Ammo2x4x8"] = Ammo2x4x8

local Ammo3x4x1 = {}
	Ammo3x4x1.id = "Ammo3x4x1"
	Ammo3x4x1.ent = "acf_ammo"
	Ammo3x4x1.type = "Ammo"
	Ammo3x4x1.name = "Modular Ammo Crate"
	Ammo3x4x1.desc = "Modular Ammo Crate 3x4x1 Size\n"
	Ammo3x4x1.model = "models/ammocrates/ammocrate_3x4x1.mdl"
	Ammo3x4x1.weight = 60
	Ammo3x4x1.volume = 13462
AmmoTable["Ammo3x4x1"] = Ammo3x4x1

local Ammo3x4x2 = {}
	Ammo3x4x2.id = "Ammo3x4x2"
	Ammo3x4x2.ent = "acf_ammo"
	Ammo3x4x2.type = "Ammo"
	Ammo3x4x2.name = "Modular Ammo Crate"
	Ammo3x4x2.desc = "Modular Ammo Crate 3x4x2 Size\n"
	Ammo3x4x2.model = "models/ammocrates/ammocrate_3x4x2.mdl"
	Ammo3x4x2.weight = 120
	Ammo3x4x2.volume = 35121
AmmoTable["Ammo3x4x2"] = Ammo3x4x2

local Ammo3x4x4 = {}
	Ammo3x4x4.id = "Ammo3x4x4"
	Ammo3x4x4.ent = "acf_ammo"
	Ammo3x4x4.type = "Ammo"
	Ammo3x4x4.name = "Modular Ammo Crate"
	Ammo3x4x4.desc = "Modular Ammo Crate 3x4x4 Size\n"
	Ammo3x4x4.model = "models/ammocrates/ammocrate_3x4x4.mdl"
	Ammo3x4x4.weight = 240
	Ammo3x4x4.volume = 73379
AmmoTable["Ammo3x4x4"] = Ammo3x4x4

local Ammo3x4x6 = {}
	Ammo3x4x6.id = "Ammo3x4x6"
	Ammo3x4x6.ent = "acf_ammo"
	Ammo3x4x6.type = "Ammo"
	Ammo3x4x6.name = "Modular Ammo Crate"
	Ammo3x4x6.desc = "Modular Ammo Crate 3x4x6 Size\n"
	Ammo3x4x6.model = "models/ammocrates/ammocrate_3x4x6.mdl"
	Ammo3x4x6.weight = 360
	Ammo3x4x6.volume = 108989
AmmoTable["Ammo3x4x6"] = Ammo3x4x6

local Ammo3x4x8 = {}
	Ammo3x4x8.id = "Ammo3x4x8"
	Ammo3x4x8.ent = "acf_ammo"
	Ammo3x4x8.type = "Ammo"
	Ammo3x4x8.name = "Modular Ammo Crate"
	Ammo3x4x8.desc = "Modular Ammo Crate 3x4x8 Size\n"
	Ammo3x4x8.model = "models/ammocrates/ammocrate_3x4x8.mdl"
	Ammo3x4x8.weight = 480
	Ammo3x4x8.volume = 149086
AmmoTable["Ammo3x4x8"] = Ammo3x4x8

local Ammo4x4x1 = {}
	Ammo4x4x1.id = "Ammo4x4x1"
	Ammo4x4x1.ent = "acf_ammo"
	Ammo4x4x1.type = "Ammo"
	Ammo4x4x1.name = "Modular Ammo Crate"
	Ammo4x4x1.desc = "Modular Ammo Crate 4x4x1 Size\n"
	Ammo4x4x1.model = "models/ammocrates/ammo_4x4x1.mdl"
	Ammo4x4x1.weight = 80
	Ammo4x4x1.volume = 26710
AmmoTable["Ammo4x4x1"] = Ammo4x4x1

local Ammo4x4x2 = {}
	Ammo4x4x2.id = "Ammo4x4x2"
	Ammo4x4x2.ent = "acf_ammo"
	Ammo4x4x2.type = "Ammo"
	Ammo4x4x2.name = "Modular Ammo Crate"
	Ammo4x4x2.desc = "Modular Ammo Crate 4x4x2 Size\n"
	Ammo4x4x2.model = "models/ammocrates/ammocrate_4x4x2.mdl"
	Ammo4x4x2.weight = 160
	Ammo4x4x2.volume = 49254
AmmoTable["Ammo4x4x2"] = Ammo4x4x2

local Ammo4x4x4 = {}
	Ammo4x4x4.id = "Ammo4x4x4"
	Ammo4x4x4.ent = "acf_ammo"
	Ammo4x4x4.type = "Ammo"
	Ammo4x4x4.name = "Modular Ammo Crate"
	Ammo4x4x4.desc = "Modular Ammo Crate 4x4x4 Size\n"
	Ammo4x4x4.model = "models/ammocrates/ammocrate_4x4x4.mdl"
	Ammo4x4x4.weight = 320
	Ammo4x4x4.volume = 106693
AmmoTable["Ammo4x4x4"] = Ammo4x4x4

local Ammo4x4x6 = {}
	Ammo4x4x6.id = "Ammo4x4x6"
	Ammo4x4x6.ent = "acf_ammo"
	Ammo4x4x6.type = "Ammo"
	Ammo4x4x6.name = "Modular Ammo Crate"
	Ammo4x4x6.desc = "Modular Ammo Crate 4x4x6 Size\n"
	Ammo4x4x6.model = "models/ammocrates/ammocrate_4x4x6.mdl"
	Ammo4x4x6.weight = 480
	Ammo4x4x6.volume = 158722
AmmoTable["Ammo4x4x6"] = Ammo4x4x6

local Ammo4x4x8 = {}
	Ammo4x4x8.id = "Ammo4x4x8"
	Ammo4x4x8.ent = "acf_ammo"
	Ammo4x4x8.type = "Ammo"
	Ammo4x4x8.name = "Modular Ammo Crate"
	Ammo4x4x8.desc = "Modular Ammo Crate 4x4x8 Size\n"
	Ammo4x4x8.model = "models/ammocrates/ammocrate_4x4x8.mdl"
	Ammo4x4x8.weight = 640
	Ammo4x4x8.volume = 208689
AmmoTable["Ammo4x4x8"] = Ammo4x4x8

local Ammo4x6x8 = {}
	Ammo4x6x8.id = "Ammo4x6x8"
	Ammo4x6x8.ent = "acf_ammo"
	Ammo4x6x8.type = "Ammo"
	Ammo4x6x8.name = "Modular Ammo Crate"
	Ammo4x6x8.desc = "Modular Ammo Crate 4x6x8 Size\n"
	Ammo4x6x8.model = "models/ammocrates/ammo_4x6x8.mdl"
	Ammo4x6x8.weight = 800
	Ammo4x6x8.volume = 304089
AmmoTable["Ammo4x6x8"] = Ammo4x6x8

local Ammo4x6x6 = {}
	Ammo4x6x6.id = "Ammo4x6x6"
	Ammo4x6x6.ent = "acf_ammo"
	Ammo4x6x6.type = "Ammo"
	Ammo4x6x6.name = "Modular Ammo Crate"
	Ammo4x6x6.desc = "Modular Ammo Crate 4x6x6 Size\n"
	Ammo4x6x6.model = "models/ammocrates/ammo_4x6x6.mdl"
	Ammo4x6x6.weight = 720
	Ammo4x6x6.volume = 230947
AmmoTable["Ammo4x6x6"] = Ammo4x6x6

local Ammo4x8x8 = {}
	Ammo4x8x8.id = "Ammo4x8x8"
	Ammo4x8x8.ent = "acf_ammo"
	Ammo4x8x8.type = "Ammo"
	Ammo4x8x8.name = "Modular Ammo Crate"
	Ammo4x8x8.desc = "Modular Ammo Crate 4x8x8 Size\n"
	Ammo4x8x8.model = "models/ammocrates/ammo_4x8x8.mdl"
	Ammo4x8x8.weight = 960
	Ammo4x8x8.volume = 396813
AmmoTable["Ammo4x8x8"] = Ammo4x8x8
	
list.Set( "ACFEnts", "Ammo", AmmoTable )	--end ammo containers listing
