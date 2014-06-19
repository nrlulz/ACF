
--definition for the fuel tank that shows on menu
ACF_DefineFuelTank( "Basic_FuelTank", {
	name = "High Grade Fuel Tank",
	desc = "A fuel tank containing high grade fuel. Guaranteed to improve engine performance by "..((ACF.TorqueBoost-1)*100).."%.",
	category = "High Grade"
} )

--definitions for the possible tank sizes selectable from the basic tank.
ACF_DefineFuelTankSize( "Tank_1x1x1", { --ID used in code
	name = "1x1x1", --human readable name
	desc = "Seriously consider walking.",
	model = "models/fueltank/fueltank_1x1x1.mdl",
	dims = { 11, 11, 10.6 } --physical dimensions of prop in gmod units, used for capacity calcs in gui
} )

ACF_DefineFuelTankSize( "Tank_1x1x2", {
	name = "1x1x2",
	desc = "Will keep a kart running all day.",
	model = "models/fueltank/fueltank_1x1x2.mdl",
	dims = { 10.9, 11, 20.3 }
} )

ACF_DefineFuelTankSize( "Tank_1x1x4", {
	name = "1x1x4",
	desc = "Dinghy",
	model = "models/fueltank/fueltank_1x1x4.mdl",
	dims = { 11, 11, 40.4 }
} )

ACF_DefineFuelTankSize( "Tank_1x2x1", {
	name = "1x2x1",
	desc = "Will keep a kart running all day.",
	model = "models/fueltank/fueltank_1x2x1.mdl",
	dims = { 21.3, 11, 10.6 }
} )

ACF_DefineFuelTankSize( "Tank_1x2x2", {
	name = "1x2x2",
	desc = "Dinghy",
	model = "models/fueltank/fueltank_1x2x2.mdl",
	dims = { 21.3, 11, 20.4 }
} )

ACF_DefineFuelTankSize( "Tank_1x2x4", {
	name = "1x2x4",
	desc = "Outboard motor.",
	model = "models/fueltank/fueltank_1x2x4.mdl",
	dims = { 21.3, 11, 40.4 }
} )

ACF_DefineFuelTankSize( "Tank_1x4x1", {
	name = "1x4x1",
	desc = "Dinghy",
	model = "models/fueltank/fueltank_1x4x1.mdl",
	dims = { 41, 11, 10.3 }
} )

ACF_DefineFuelTankSize( "Tank_1x4x2", {
	name = "1x4x2",
	desc = "Clown car.",
	model = "models/fueltank/fueltank_1x4x2.mdl",
	dims = { 41, 11, 20.6 }
} )

ACF_DefineFuelTankSize( "Tank_1x4x4", {
	name = "1x4x4",
	desc = "",
	model = "models/fueltank/fueltank_1x4x4.mdl",
	dims = { 41.1, 11, 40.4 }
} )

ACF_DefineFuelTankSize( "Tank_1x6x1", {
	name = "1x6x1",
	desc = "Lawn tractors.",
	model = "models/fueltank/fueltank_1x6x1.mdl",
	dims = { 61.2, 11, 10.4 }
} )

ACF_DefineFuelTankSize( "Tank_1x6x2", {
	name = "1x6x2",
	desc = "",
	model = "models/fueltank/fueltank_1x6x2.mdl",
	dims = { 61.2, 11, 20.5 }
} )

ACF_DefineFuelTankSize( "Tank_1x6x4", {
	name = "1x6x4",
	desc = "",
	model = "models/fueltank/fueltank_1x6x4.mdl",
	dims = { 61.2, 11, 40.3 }
} )

ACF_DefineFuelTankSize( "Tank_1x8x1", {
	name = "1x8x1",
	desc = "Clown car.",
	model = "models/fueltank/fueltank_1x8x1.mdl",
	dims = { 81.1, 11, 10.4 }
} )

ACF_DefineFuelTankSize( "Tank_1x8x2", {
	name = "1x8x2",
	desc = "",
	model = "models/fueltank/fueltank_1x8x2.mdl",
	dims = { 81.1, 11, 20.8 }
} )

ACF_DefineFuelTankSize( "Tank_1x8x4", {
	name = "1x8x4",
	desc = "",
	model = "models/fueltank/fueltank_1x8x4.mdl",
	dims = { 81.1, 11, 40.4 }
} )

ACF_DefineFuelTankSize( "Tank_2x2x1", {
	name = "2x2x1",
	desc = "Dinghy",
	model = "models/fueltank/fueltank_2x2x1.mdl",
	dims = { 21.6, 21.7, 11.6 }
} )

ACF_DefineFuelTankSize( "Tank_2x2x2", {
	name = "2x2x2",
	desc = "Clown car.",
	model = "models/fueltank/fueltank_2x2x2.mdl",
	dims = { 21.6, 21.8, 21.3 }
} )

ACF_DefineFuelTankSize( "Tank_2x2x4", {
	name = "2x2x4",
	desc = "Mini Cooper.",
	model = "models/fueltank/fueltank_2x2x4.mdl",
	dims = { 21.6, 21.6, 41.8 }
} )

ACF_DefineFuelTankSize( "Tank_2x4x1", {
	name = "2x4x1",
	desc = "",
	model = "models/fueltank/fueltank_2x4x1.mdl",
	dims = { 41.7, 21.7, 11.6 }
} )

ACF_DefineFuelTankSize( "Tank_2x4x2", {
	name = "2x4x2",
	desc = "Mini Cooper.",
	model = "models/fueltank/fueltank_2x4x2.mdl",
	dims = { 41.7, 21.6, 21.6 }
} )

ACF_DefineFuelTankSize( "Tank_2x4x4", {
	name = "2x4x4",
	desc = "Land boat.",
	model = "models/fueltank/fueltank_2x4x4.mdl",
	dims = { 41.7, 21.7, 41.8 }
} )

ACF_DefineFuelTankSize( "Tank_2x6x1", {
	name = "2x6x1",
	desc = "",
	model = "models/fueltank/fueltank_2x6x1.mdl",
	dims = { 61.4, 21.6, 11.6 }
} )

ACF_DefineFuelTankSize( "Tank_2x6x2", {
	name = "2x6x2",
	desc = "Compact car.",
	model = "models/fueltank/fueltank_2x6x2.mdl",
	dims = { 61.5, 21.5, 21.6 }
} )

ACF_DefineFuelTankSize( "Tank_2x6x4", {
	name = "2x6x4",
	desc = "Sedan.",
	model = "models/fueltank/fueltank_2x6x4.mdl",
	dims = { 61.5, 21.7, 41.8 }
} )

ACF_DefineFuelTankSize( "Tank_2x8x1", {
	name = "2x8x1",
	desc = "",
	model = "models/fueltank/fueltank_2x8x1.mdl",
	dims = { 81.6, 21.7, 11.6 }
} )

ACF_DefineFuelTankSize( "Tank_2x8x2", {
	name = "2x8x2",
	desc = "Truck.",
	model = "models/fueltank/fueltank_2x8x2.mdl",
	dims = { 81.6, 21.4, 21.6 }
} )

ACF_DefineFuelTankSize( "Tank_2x8x4", {
	name = "2x8x4",
	desc = "",
	model = "models/fueltank/fueltank_2x8x4.mdl",
	dims = { 81.6, 21.6, 41.8 }
} )

ACF_DefineFuelTankSize( "Tank_4x4x1", {
	name = "4x4x1",
	desc = "Sedan.",
	model = "models/fueltank/fueltank_4x4x1.mdl",
	dims = { 42.7, 43, 11.7 }
} )

ACF_DefineFuelTankSize( "Tank_4x4x2", {
	name = "4x4x2",
	desc = "Land boat.",
	model = "models/fueltank/fueltank_4x4x2.mdl",
	dims = { 42.7, 43.1, 21.4 }
} )

ACF_DefineFuelTankSize( "Tank_4x4x4", {
	name = "4x4x4",
	desc = "Popular with arsonists.",
	model = "models/fueltank/fueltank_4x4x4.mdl",
	dims = { 42.7, 42.6, 41.3 }
} )

ACF_DefineFuelTankSize( "Tank_4x6x1", {
	name = "4x6x1",
	desc = "",
	model = "models/fueltank/fueltank_4x6x1.mdl",
	dims = { 62.5, 43, 11.7 }
} )

ACF_DefineFuelTankSize( "Tank_4x6x2", {
	name = "4x6x2",
	desc = "",
	model = "models/fueltank/fueltank_4x6x2.mdl",
	dims = { 62.5, 43, 21.4 }
} )

ACF_DefineFuelTankSize( "Tank_4x6x4", {
	name = "4x6x4",
	desc = "Trees are gay anyway.",
	model = "models/fueltank/fueltank_4x6x4.mdl",
	dims = { 62.5, 43, 41.3 }
} )

ACF_DefineFuelTankSize( "Tank_4x8x1", {
	name = "4x8x1",
	desc = "",
	model = "models/fueltank/fueltank_4x8x1.mdl",
	dims = { 82.2, 43, 11.7 }
} )

ACF_DefineFuelTankSize( "Tank_4x8x2", {
	name = "4x8x2",
	desc = "",
	model = "models/fueltank/fueltank_4x8x2.mdl",
	dims = { 82.2, 43, 21.7 }
} )

ACF_DefineFuelTankSize( "Tank_4x8x4", {
	name = "4x8x4",
	desc = "\'MURRICA  FUCKYEAH!",
	model = "models/fueltank/fueltank_4x8x4.mdl",
	dims = { 82.2, 42.9, 41 }
} )

ACF_DefineFuelTankSize( "Tank_6x6x1", {
	name = "6x6x1",
	desc = "",
	model = "models/fueltank/fueltank_6x6x1.mdl",
	dims = { 64.1, 64, 11.6 }
} )

ACF_DefineFuelTankSize( "Tank_6x6x2", {
	name = "6x6x2",
	desc = "",
	model = "models/fueltank/fueltank_6x6x2.mdl",
	dims = { 64.1, 64, 21.8 }
} )

ACF_DefineFuelTankSize( "Tank_6x6x4", {
	name = "6x6x4",
	desc = "May contain Mesozoic ghosts.",
	model = "models/fueltank/fueltank_6x6x4.mdl",
	dims = { 64.1, 64, 41.3 }
} )

ACF_DefineFuelTankSize( "Tank_6x8x1", {
	name = "6x8x1",
	desc = "",
	model = "models/fueltank/fueltank_6x8x1.mdl",
	dims = { 83.4, 64, 11.2 }
} )

ACF_DefineFuelTankSize( "Tank_6x8x2", {
	name = "6x8x2",
	desc = "Certified 100% dinosaur juice.",
	model = "models/fueltank/fueltank_6x8x2.mdl",
	dims = { 83.4, 64, 20.9 }
} )

ACF_DefineFuelTankSize( "Tank_6x8x4", {
	name = "6x8x4",
	desc = "Will last you a while.",
	model = "models/fueltank/fueltank_6x8x4.mdl",
	dims = { 83.4, 64, 40.7 }
} )

ACF_DefineFuelTankSize( "Tank_8x8x1", {
	name = "8x8x1",
	desc = "",
	model = "models/fueltank/fueltank_8x8x1.mdl",
	dims = { 83.4, 83.1, 11.3 }
} )

ACF_DefineFuelTankSize( "Tank_8x8x2", {
	name = "8x8x2",
	desc = "What's global warming?",
	model = "models/fueltank/fueltank_8x8x2.mdl",
	dims = { 83.4, 83.1, 21 }
} )

ACF_DefineFuelTankSize( "Tank_8x8x4", {
	name = "8x8x4",
	desc = "Tank Tank.",
	model = "models/fueltank/fueltank_8x8x4.mdl",
	dims = { 83.5, 83.1, 40.8 }
} )

ACF_DefineFuelTankSize( "Fuel_Drum", {
	name = "Fuel Drum",
	desc = "Tends to explode when shot.",
	model = "models/props_c17/oildrum001_explosive.mdl",
	dims = { 29, 29, 45.6 }
} )

ACF_DefineFuelTankSize( "Jerry_Can", {
	name = "Jerry Can",
	desc = "Handy portable fuel container.",
	model = "models/props_junk/gascan001a.mdl",
	dims = { 8.6, 20.2, 30.2 },
	nolinks = true
} )

ACF_DefineFuelTankSize( "Transport_Tank", {
	name = "Transport Tank",
	desc = "Disappointingly non-explosive.",
	model = "models/props_wasteland/horizontalcoolingtank04.mdl",
	dims = { 316.4, 97.3, 121.8 },
	explosive = false,
	nolinks = true
} )

ACF_DefineFuelTankSize( "Storage_Tank", {
	name = "Storage Tank",
	desc = "Disappointingly non-explosive.",
	model = "models/props_wasteland/coolingtank02.mdl",
	dims = { 112.8, 101.5, 411.4 },
	explosive = false,
	nolinks = true
} )
