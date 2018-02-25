
-- V10 engines

-- Petrol

ACF_DefineEngine( "4.3-V10", {
	name = "4.3L V10 Petrol",
	desc = "Small-block V10; great for powering a hot rod Lincoln",
	model = "models/engines/v10sml.mdl",
	sound = "acf_engines/v10_petrolsmall.wav",
	category = "V10",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 160,
	torque = 288,
	flywheelmass = 0.2,
	idlerpm = 900,
	peakminrpm = 3500,
	peakmaxrpm = 5800,
	limitrpm = 6250
} )

ACF_DefineEngine( "8.0-V10", {
	name = "8.0L V10 Petrol",
	desc = "Beefy 10-cylinder; gets 9 kids to soccer practice",
	model = "models/engines/v10med.mdl",
	sound = "acf_engines/v10_petrolmedium.wav",
	category = "V10",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 300,
	torque = 490,
	flywheelmass = 0.5,
	idlerpm = 750,
	peakminrpm = 3400,
	peakmaxrpm = 5500,
	limitrpm = 6500
} )

-- Diesel

ACF_DefineEngine( "22.0-V10", {
	name = "22.0L V10 Multifuel",
	desc = "Heavy multifuel V10, gearbox-shredding torque but very heavy.",
	model = "models/engines/v10big.mdl",
	sound = "acf_engines/v10_diesellarge.wav",
	category = "V10",
	fuel = "Multifuel",
	enginetype = "GenericDiesel",
	weight = 1600,
	torque = 2605,
	flywheelmass = 5,
	idlerpm = 525,
	peakminrpm = 750,
	peakmaxrpm = 1900,
	limitrpm = 2500
} )
