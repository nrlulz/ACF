
-- Inline 5 engines

-- Petrol

ACF_DefineEngine( "2.3-I5", {
	name = "2.3L I5 Petrol",
	desc = "Sedan-grade 5-cylinder, solid and dependable",
	model = "models/engines/inline5s.mdl",
	sound = "acf_engines/i5_petrolsmall.wav",
	category = "I5",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 100,
	torque = 125,
	flywheelmass = 0.12,
	idlerpm = 900,
	peakminrpm = 3600,
	peakmaxrpm = 5900,
	limitrpm = 7000
} )

ACF_DefineEngine( "3.9-I5", {
	name = "3.9L I5 Petrol",
	desc = "Truck sized inline 5, strong with a good balance of revs and torques",
	model = "models/engines/inline5m.mdl",
	sound = "acf_engines/i5_petrolmedium.wav",
	category = "I5",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 250,
	torque = 275,
	flywheelmass = 0.25,
	idlerpm = 700,
	peakminrpm = 3700,
	peakmaxrpm = 6000,
	limitrpm = 6500
} )

-- Diesel

ACF_DefineEngine( "2.9-I5", {
	name = "2.9L I5 Diesel",
	desc = "Aging fuel-injected diesel, low in horsepower but very forgiving and durable",
	model = "models/engines/inline5s.mdl",
	sound = "acf_engines/i5_dieselsmall2.wav",
	category = "I5",
	fuel = "Diesel",
	enginetype = "GenericDiesel",
	weight = 130,
	torque = 180,
	flywheelmass = 0.5,
	idlerpm = 500,
	peakminrpm = 900,
	peakmaxrpm = 2800,
	limitrpm = 4200
} )

ACF_DefineEngine( "4.1-I5", {
	name = "4.1L I5 Diesel",
	desc = "Heavier duty diesel, found in things that work hard",
	model = "models/engines/inline5m.mdl",
	sound = "acf_engines/i5_dieselmedium.wav",
	category = "I5",
	fuel = "Diesel",
	enginetype = "GenericDiesel",
	weight = 400,
	torque = 440,
	flywheelmass = 1.5,
	idlerpm = 650,
	peakminrpm = 1000,
	peakmaxrpm = 3200,
	limitrpm = 3800
} )
