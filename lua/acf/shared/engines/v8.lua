
-- V8 engines

-- Petrol

ACF_DefineEngine( "5.7-V8", {
	name = "5.7L V8 Petrol",
	desc = "Car sized petrol engine, good power and mid range torque",
	model = "models/engines/v8s.mdl",
	sound = "acf_engines/v8_petrolsmall.wav",
	category = "V8",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 260,
	torque = 320,
	flywheelmass = 0.15,
	idlerpm = 800,
	peakminrpm = 3000,
	peakmaxrpm = 5000,
	limitrpm = 6500
} )

ACF_DefineEngine( "9.0-V8", {
	name = "9.0L V8 Petrol",
	desc = "Thirsty, giant V8, for medium applications",
	model = "models/engines/v8m.mdl",
	sound = "acf_engines/v8_petrolmedium.wav",
	category = "V8",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 400,
	torque = 460,
	flywheelmass = 0.25,
	idlerpm = 700,
	peakminrpm = 3100,
	peakmaxrpm = 5000,
	limitrpm = 5500
} )

ACF_DefineEngine( "18.0-V8", {
	name = "18.0L V8 Petrol",
	desc = "American gasoline tank V8, good overall power and torque and fairly lightweight",
	model = "models/engines/v8l.mdl",
	sound = "acf_engines/v8_petrollarge.wav",
	category = "V8",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 850,
	torque = 1458,
	flywheelmass = 2.8,
	idlerpm = 600,
	peakminrpm = 2000,
	peakmaxrpm = 3300,
	limitrpm = 3800
} )

-- Diesel

ACF_DefineEngine( "4.5-V8", {
	name = "4.5L V8 Diesel",
	desc = "Light duty diesel v8, good for light vehicles that require a lot of torque",
	model = "models/engines/v8s.mdl",
	sound = "acf_engines/v8_dieselsmall.wav",
	category = "V8",
	fuel = "Diesel",
	enginetype = "GenericDiesel",
	weight = 320,
	torque = 380,
	flywheelmass = 0.75,
	idlerpm = 800,
	peakminrpm = 1000,
	peakmaxrpm = 3000,
	limitrpm = 5000
} )

ACF_DefineEngine( "7.8-V8", {
	name = "7.8L V8 Diesel",
	desc = "Redneck chariot material. Truck duty V8 diesel, has a good, wide powerband",
	model = "models/engines/v8m.mdl",
	sound = "acf_engines/v8_dieselmedium2.wav",
	category = "V8",
	fuel = "Diesel",
	enginetype = "GenericDiesel",
	weight = 550,
	torque = 689,
	flywheelmass = 1.5,
	idlerpm = 650,
	peakminrpm = 1000,
	peakmaxrpm = 3000,
	limitrpm = 4000
} )

ACF_DefineEngine( "19.0-V8", {
	name = "19.0L V8 Diesel",
	desc = "Heavy duty diesel V8, used in heavy construction equipment and tanks",
	model = "models/engines/v8l.mdl",
	sound = "acf_engines/v8_diesellarge.wav",
	category = "V8",
	fuel = "Diesel",
	enginetype = "GenericDiesel",
	weight = 1500,
	torque = 2300,
	flywheelmass = 4.5,
	idlerpm = 500,
	peakminrpm = 600,
	peakmaxrpm = 1800,
	limitrpm = 2500
} )
