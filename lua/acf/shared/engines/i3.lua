
-- Inline 3 engines

-- Petrol

ACF_DefineEngine( "1.2-I3", {
	name = "1.2L I3 Petrol",
	desc = "Tiny microcar engine, efficient but weak",
	model = "models/engines/inline3s.mdl",
	sound = "acf_engines/i4_petrolsmall2.wav",
	category = "I3",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 40,
	torque = 95,
	flywheelmass = 0.05,
	idlerpm = 1100,
	peakminrpm = 3300,
	peakmaxrpm = 5400,
	limitrpm = 6000
} )

ACF_DefineEngine( "3.4-I3", {
	name = "3.4L I3 Petrol",
	desc = "Short block engine for light utility use",
	model = "models/engines/inline3m.mdl",
	sound = "acf_engines/i4_petrolmedium2.wav",
	category = "I3",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 170,
	torque = 195,
	flywheelmass = 0.2,
	idlerpm = 900,
	peakminrpm = 3500,
	peakmaxrpm = 6600,
	limitrpm = 6800
} )

ACF_DefineEngine( "13.5-I3", {
	name = "13.5L I3 Petrol",
	desc = "Short block light tank engine, likes sideways mountings",
	model = "models/engines/inline3b.mdl",
	sound = "acf_engines/i4_petrollarge.wav",
	category = "I3",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 500,
	torque = 700,
	flywheelmass = 4,
	idlerpm = 500,
	peakminrpm = 1900,
	peakmaxrpm = 3500,
	limitrpm = 3900
} )

-- Diesel

ACF_DefineEngine( "1.1-I3", {
	name = "1.1L I3 Diesel",
	desc = "ATV grade 3-banger, enormous rev band but a choppy idle, great for light utility work",
	model = "models/engines/inline3s.mdl",
	sound = "acf_engines/i4_diesel2.wav",
	category = "I3",
	fuel = "Diesel",
	enginetype = "GenericDiesel",
	weight = 65,
	torque = 150,
	flywheelmass = 0.2,
	idlerpm = 550,
	peakminrpm = 800,
	peakmaxrpm = 2500,
	limitrpm = 3000
} )

ACF_DefineEngine( "2.8-I3", {
	name = "2.8L I3 Diesel",
	desc = "Medium utility grade I3 diesel, for tractors",
	model = "models/engines/inline3m.mdl",
	sound = "acf_engines/i4_dieselmedium.wav",
	category = "I3",
	fuel = "Diesel",
	enginetype = "GenericDiesel",
	weight = 200,
	torque = 290,
	flywheelmass = 1,
	idlerpm = 600,
	peakminrpm = 1200,
	peakmaxrpm = 3600,
	limitrpm = 3800
} )

ACF_DefineEngine( "11.0-I3", {
	name = "11.0L I3 Diesel",
	desc = "Light tank duty engine, compact yet grunts hard",
	model = "models/engines/inline3b.mdl",
	sound = "acf_engines/i4_diesellarge.wav",
	category = "I3",
	fuel = "Diesel",
	enginetype = "GenericDiesel",
	weight = 650,
	torque = 1100,
	flywheelmass = 5,
	idlerpm = 550,
	peakminrpm = 650,
	peakmaxrpm = 1800,
	limitrpm = 2000
} )