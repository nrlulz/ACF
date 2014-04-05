
-- V12 engines

-- Petrol

ACF_DefineEngine( "4.6-V12", {
	name = "4.6L V12 Petrol",
	desc = "An elderly racecar engine; low on torque, but plenty of power",
	model = "models/engines/v12s.mdl",
	sound = "acf_engines/v12_petrolsmall.wav",
	category = "V12",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 188,
	torque = 235,
	flywheelmass = 0.2,
	idlerpm = 1000,
	peakminrpm = 4500,
	peakmaxrpm = 7500,
	limitrpm = 8000
} )

ACF_DefineEngine( "7.0-V12", {
	name = "7.0L V12 Petrol",
	desc = "A high end V12; primarily found in very expensive cars",
	model = "models/engines/v12m.mdl",
	sound = "acf_engines/v12_petrolmedium.wav",
	category = "V12",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 360,
	torque = 420,
	flywheelmass = 0.45,
	idlerpm = 800,
	peakminrpm = 3600,
	peakmaxrpm = 6000,
	limitrpm = 7500
} )

ACF_DefineEngine( "23.0-V12", {
	name = "23.0 V12 Petrol",
	desc = "A large, thirsty gasoline V12, found in early cold war tanks",
	model = "models/engines/v12l.mdl",
	sound = "acf_engines/v12_petrollarge.wav",
	category = "V12",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 1350,
	torque = 1925,
	flywheelmass = 5,
	idlerpm = 600,
	peakminrpm = 1500,
	peakmaxrpm = 3000,
	limitrpm = 3250
} )

-- Diesel

ACF_DefineEngine( "4.0-V12", {
	name = "4.0L V12 Diesel",
	desc = "Reliable truck-duty diesel; a lot of smooth torque",
	model = "models/engines/v12s.mdl",
	sound = "acf_engines/v12_dieselsmall.wav",
	category = "V12",
	fuel = "Diesel",
	enginetype = "GenericDiesel",
	weight = 305,
	torque = 375,
	flywheelmass = 0.475,
	idlerpm = 650,
	peakminrpm = 1200,
	peakmaxrpm = 3800,
	limitrpm = 4000
} )

ACF_DefineEngine( "9.2-V12", {
	name = "9.2L V12 Diesel",
	desc = "High torque light-tank V12, used mainly for vehicles that require balls",
	model = "models/engines/v12m.mdl",
	sound = "acf_engines/v12_dieselmedium.wav",
	category = "V12",
	fuel = "Diesel",
	enginetype = "GenericDiesel",
	weight = 600,
	torque = 750,
	flywheelmass = 2.5,
	idlerpm = 675,
	peakminrpm = 1100,
	peakmaxrpm = 3300,
	limitrpm = 3500
} )

ACF_DefineEngine( "21.0-V12", {
	name = "21.0 V12 Diesel",
	desc = "AVDS-1790-2 tank engine; massively powerful, but enormous and heavy",
	model = "models/engines/v12l.mdl",
	sound = "acf_engines/v12_diesellarge.wav",
	category = "V12",
	fuel = "Diesel",
	enginetype = "GenericDiesel",
	weight = 1800,
	torque = 3560,
	flywheelmass = 7,
	idlerpm = 400,
	peakminrpm = 500,
	peakmaxrpm = 1500,
	limitrpm = 2500
} )
