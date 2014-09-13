
-- Single-cylinder engines

ACF_DefineEngine( "0.25-I1", {
	name = "250cc Single",
	desc = "Tiny bike engine",
	model = "models/engines/1cylsml.mdl",
	sound = "acf_engines/i1_small.wav",
	category = "Single",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 15,
	torque = 20,
	flywheelmass = 0.005,
	idlerpm = 1200,
	peakminrpm = 4000,
	peakmaxrpm = 6500,
	limitrpm = 7500
} )

ACF_DefineEngine( "0.5-I1", {
	name = "500cc Single",
	desc = "Large single cylinder bike engine",
	model = "models/engines/1cylmed.mdl",
	sound = "acf_engines/i1_medium.wav",
	category = "Single",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 20,
	torque = 40,
	flywheelmass = 0.005,
	idlerpm = 900,
	peakminrpm = 4300,
	peakmaxrpm = 7000,
	limitrpm = 8000
} )

ACF_DefineEngine( "1.3-I1", {
	name = "1300cc Single",
	desc = "Ridiculously large single cylinder engine, seriously what the fuck",
	model = "models/engines/1cylbig.mdl",
	sound = "acf_engines/i1_large.wav",
	category = "Single",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 50,
	torque = 90,
	flywheelmass = 0.1,
	idlerpm = 600,
	peakminrpm = 3600,
	peakmaxrpm = 6000,
	limitrpm = 6700
} )
