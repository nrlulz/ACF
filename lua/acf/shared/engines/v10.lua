--V10s

ACF_DefineEngine( "4.3-V10", {
	name = "4.3L V10 Petrol",
	desc = "Small-block V-10 gasoline engine, great for powering a hot rod lincoln",
	model = "models/engines/v10sml.mdl",
	sound = "acf_engines/v10_petrolsmall.wav",
	category = "V10",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 160,
	torque = 300,
	flywheelmass = 0.2,
	idlerpm = 900,
	peakminrpm = 3500,
	peakmaxrpm = 5800,
	limitrpm = 6250
} )

ACF_DefineEngine( "8.0-V10", {
	name = "8.0L V10 Petrol",
	desc = "Beefy 10-cylinder gas engine, gets 9 kids to soccer practice",
	model = "models/engines/v10med.mdl",
	sound = "acf_engines/v10_petrolmedium.wav",
	category = "V10",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 300,
	torque = 520,
	flywheelmass = 0.5,
	idlerpm = 750,
	peakminrpm = 3400,
	peakmaxrpm = 5500,
	limitrpm = 6500
} )

ACF_DefineEngine( "22.0-V10", {
	name = "22.0L V10 Multifuel",
	desc = "Heavy multifuel V-10, gearbox-shredding torque but very heavy.",
	model = "models/engines/v10big.mdl",
	sound = "acf_engines/v10_diesellarge.wav",
	category = "V10",
	fuel = "Any",
	enginetype = "GenericDiesel",
	weight = 1400,
	torque = 2750,
	flywheelmass = 5,
	idlerpm = 425,
	peakminrpm = 600,
	peakmaxrpm = 1800,
	limitrpm = 2500
} )
