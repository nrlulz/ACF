
--fuel tanks based on ammocrate models

--definition for the fuel tank that shows on menu
ACF_DefineFuelTank( "Basic_FuelTank", {
	name = "High Grade Fuel Tank",
	desc = "A fuel tank containing high grade fuel. Garunteed to improve engine performance by "..((ACF.TorqueBoost-1)*100).."%.",
	category = "High Grade"
} )

--definitions for the possible tank sizes selectable from the basic tank.
ACF_DefineFuelTankSize( "Crate_Micro", { --ID used in code
	name = "Micro", --human readable name
	desc = "Seriously consider walking.",
	model = "models/ammocrate_small.mdl",
	dims = { 23, 8.4, 14.5 } --physical dimensions of prop in gmod units, used for capacity calcs in gui
} )

ACF_DefineFuelTankSize( "Crate_Med", {
	name = "Medium",
	desc = "Small car.",
	model = "models/ammocrate_medium_small.mdl",
	dims = { 26.9, 28.8, 26.7 }
} )

ACF_DefineFuelTankSize( "Crate_Large", {
	name = "Large",
	desc = "Gas guzzler.",
	model = "models/ammocrate_medium.mdl",
	dims = { 52.3, 28.8, 26.7 }
} )

ACF_DefineFuelTankSize( "Crate_Huge", {
	name = "Huge",
	desc = "Dafuq you need all this fuel for!?",
	model = "models/ammocrate_large.mdl",
	dims = { 53.2, 56, 52.6 }
} )

ACF_DefineFuelTankSize( "Crate_2x2x1", {
	name = "2x2x1",
	desc = "Will keep a kart running all day.",
	model = "models/ammocrates/ammocrate_2x2x1.mdl",
	dims = { 23, 8.5, 20.9 }
} )

ACF_DefineFuelTankSize( "Crate_2x2x2", {
	name = "2x2x2",
	desc = "Dinghy.",
	model = "models/ammocrates/ammocrate_2x2x2.mdl",
	dims = { 20.5, 24.8, 21.5 }
} )

ACF_DefineFuelTankSize( "Crate_2x2x4", {
	name = "2x2x4",
	desc = "Mini Cooper.",
	model = "models/ammocrates/ammocrate_2x2x4.mdl",
	dims = { 23.4, 45.5, 20.9 }
} )

ACF_DefineFuelTankSize( "Crate_2x3x1", {
	name = "2x3x1",
	desc = "Lawn tractors.",
	model = "models/ammocrates/ammocrate_2x3x1.mdl",
	dims = { 34.9, 8.5, 20.9 }
} )

ACF_DefineFuelTankSize( "Crate_2x3x2", {
	name = "2x3x2",
	desc = "Clown cars.",
	model = "models/ammocrates/ammocrate_2x3x2.mdl",
	dims = { 34.9, 20.5, 20.9 }
} )

ACF_DefineFuelTankSize( "Crate_2x3x4", {
	name = "2x3x4",
	desc = "Sedan.",
	model = "models/ammocrates/ammocrate_2x3x4.mdl",
	dims = { 35.2, 46.7, 20.5 }
} )

ACF_DefineFuelTankSize( "Crate_2x4x1", {
	name = "2x4x1",
	desc = "Outboard motor.",
	model = "models/ammocrates/ammocrate_2x4x1.mdl",
	dims = { 48, 8.5, 20.9 }
} )

ACF_DefineFuelTankSize( "Crate_2x4x2", {
	name = "2x4x2",
	desc = "Mini Cooper.",
	model = "models/ammocrates/ammocrate_2x4x2.mdl",
	dims = { 45.5, 23.4, 20.9 }
} )

ACF_DefineFuelTankSize( "Crate_2x4x4", {
	name = "2x4x4",
	desc = "Land boat.",
	model = "models/ammocrates/ammocrate_2x4x4.mdl",
	dims = { 48.3, 46.7, 20.5 }
} )

ACF_DefineFuelTankSize( "Crate_2x4x6", {
	name = "2x4x6",
	desc = "Lots.",
	model = "models/ammocrates/ammocrate_2x4x6.mdl",
	dims = { 48.3, 69.4, 20.5 }
} )

ACF_DefineFuelTankSize( "Crate_2x4x8", {
	name = "2x4x8",
	desc = "Lots.",
	model = "models/ammocrates/ammocrate_2x4x8.mdl",
	dims = { 48.3, 91.4, 20.5 }
} )

ACF_DefineFuelTankSize( "Crate_3x4x1", {
	name = "3x4x1",
	desc = "large outboard motor.",
	model = "models/ammocrates/ammocrate_3x4x1.mdl",
	dims = { 48, 8.5, 33 }
} )

ACF_DefineFuelTankSize( "Crate_3x4x2", {
	name = "3x4x2",
	desc = "Sedan.",
	model = "models/ammocrates/ammocrate_3x4x2.mdl",
	dims = { 45.5, 23.4, 33 }
} )

ACF_DefineFuelTankSize( "Crate_3x4x4", {
	name = "3x4x4",
	desc = "Certified 100% dinosaur juice.",
	model = "models/ammocrates/ammocrate_3x4x4.mdl",
	dims = { 48.3, 46.7, 32.5 }
} )

ACF_DefineFuelTankSize( "Crate_3x4x6", {
	name = "3x4x6",
	desc = "Molotovs for everybody!",
	model = "models/ammocrates/ammocrate_3x4x6.mdl",
	dims = { 48.3, 69.4, 32.5 }
} )

ACF_DefineFuelTankSize( "Crate_3x4x8", {
	name = "3x4x8",
	desc = "What's global warming?",
	model = "models/ammocrates/ammocrate_3x4x8.mdl",
	dims = { 50.2, 91.4, 32.5 }
} )

ACF_DefineFuelTankSize( "Crate_4x4x2", {
	name = "4x4x2",
	desc = "Land boat.",
	model = "models/ammocrates/ammocrate_4x4x2.mdl",
	dims = { 46.3, 23.4, 45.5 }
} )

ACF_DefineFuelTankSize( "Crate_4x4x4", {
	name = "4x4x4",
	desc = "Popular with arsonists.",
	model = "models/ammocrates/ammocrate_4x4x4.mdl",
	dims = { 50.2, 46.7, 45.5 }
} )

ACF_DefineFuelTankSize( "Crate_4x4x6", {
	name = "4x4x6",
	desc = "Trees are gay anyway.",
	model = "models/ammocrates/ammocrate_4x4x6.mdl",
	dims = { 50.2, 69.5, 45.5 }
} )

ACF_DefineFuelTankSize( "Crate_4x4x8", {
	name = "4x4x8",
	desc = "\'MURRICA  FUCKYEAH!",
	model = "models/ammocrates/ammocrate_4x4x8.mdl",
	dims = { 50.2, 91.4, 45.5 }
} )

ACF_DefineFuelTankSize( "Fuel_Drum", {
	name = "Fuel Drum",
	desc = "Tends to explode when shot.",
	model = "models/props_c17/oildrum001_explosive.mdl",
	dims = { 29, 29, 45.6 }
} )

ACF_DefineFuelTankSize( "Transport_Tank", {
	name = "Transport Tank",
	desc = "Tends to explode violently.",
	model = "models/props_wasteland/horizontalcoolingtank04.mdl",
	dims = { 316.4, 97.3, 121.8 }
} )

ACF_DefineFuelTankSize( "Storage_Tank", {
	name = "Storage Tank",
	desc = "Tends to explode very violently.",
	model = "models/props_wasteland/coolingtank02.mdl",
	dims = { 112.8, 101.5, 411.4 }
} )

ACF_DefineFuelTankSize( "Crate_1x1x2", {
	name = "1x1x2",
	desc = "Will keep a kart running all day.",
	model = "models/ammocrates/ammo_1x1x2.mdl",
	dims = { 14.4, 22.9, 12.2 }
} )

ACF_DefineFuelTankSize( "Crate_1x1x4", {
	name = "1x1x4",
	desc = "Outboard motor.",
	model = "models/ammocrates/ammo_1x1x4.mdl",
	dims = { 14.4, 45.5, 12.2 }
} )

ACF_DefineFuelTankSize( "Crate_1x1x6", {
	name = "1x1x6",
	desc = "Dinghy.",
	model = "models/ammocrates/ammo_1x1x6.mdl",
	dims = { 14.4, 66.9, 12.2 }
} )

ACF_DefineFuelTankSize( "Crate_1x1x8", {
	name = "1x1x8",
	desc = "Clown car.",
	model = "models/ammocrates/ammo_1x1x8.mdl",
	dims = { 14.4, 89.6, 12.1 }
} )

ACF_DefineFuelTankSize( "Crate_2x2x6", {
	name = "2x2x6",
	desc = "Compact car.",
	model = "models/ammocrates/ammo_2x2x6.mdl",
	dims = { 25.9, 68.3, 22.8 }
} )

ACF_DefineFuelTankSize( "Crate_2x2x8", {
	name = "2x2x8",
	desc = "Truck.",
	model = "models/ammocrates/ammo_2x2x8.mdl",
	dims = { 25.9, 91.3, 22.9 }
} )

ACF_DefineFuelTankSize( "Crate_4x4x1", {
	name = "4x4x1",
	desc = "Land boat.",
	model = "models/ammocrates/ammo_4x4x1.mdl",
	dims = { 48.3, 46.2, 12 }
} )

ACF_DefineFuelTankSize( "Crate_4x6x6", {
	name = "4x6x6",
	desc = "May contain Mesozoic ghosts.",
	model = "models/ammocrates/ammo_4x6x6.mdl",
	dims = { 73.3, 69.4, 45.4 }
} )

ACF_DefineFuelTankSize( "Crate_4x6x8", {
	name = "4x6x8",
	desc = "Will last you a while.",
	model = "models/ammocrates/ammo_4x6x8.mdl",
	dims = { 73.3, 91.4, 45.4 }
} )

ACF_DefineFuelTankSize( "Crate_4x8x8", {
	name = "4x8x8",
	desc = "Tank Tank.",
	model = "models/ammocrates/ammo_4x8x8.mdl",
	dims = { 95.2, 91.4, 45.6 }
} )
