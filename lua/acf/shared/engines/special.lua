
-- Special engines

ACF_DefineEngine( "1.9L-I4", {
	name = "1.9L I4 Petrol",
	desc = "Supercharged racing 4 cylinder, most of the power in the high revs.",
	model = "models/engines/inline4s.mdl",
	sound = "acf_engines/i4_special.wav",
	category = "Special",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	requiresfuel = true,
	weight = 150,
	torque = 176,
	flywheelmass = 0.06,
	idlerpm = 950,
	peakminrpm = 5200,
	peakmaxrpm = 8500,
	limitrpm = 9000
} )

ACF_DefineEngine( "2.9-V8", {
	name = "2.9L V8 Petrol",
	desc = "Racing V8, very high revving and loud",
	model = "models/engines/v8s.mdl",
	sound = "acf_engines/v8_special.wav",
	category = "Special",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	requiresfuel = true,
	weight = 180,
	torque = 200,
	flywheelmass = 0.075,
	idlerpm = 1000,
	peakminrpm = 5500,
	peakmaxrpm = 9000,
	limitrpm = 10000
} )

ACF_DefineEngine( "3.8-I6", {
	name = "3.8L I6 Petrol",
	desc = "Large racing straight six, powerful and high revving, but lacking in torque.",
	model = "models/engines/inline6m.mdl",
	sound = "acf_engines/l6_special.wav",
	category = "Special",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	requiresfuel = true,
	weight = 180,
	torque = 224,
	flywheelmass = 0.1,
	idlerpm = 1100,
	peakminrpm = 5200,
	peakmaxrpm = 8500,
	limitrpm = 9000
} )

ACF_DefineEngine( "7.2-V8", {
	name = "7.2L V8 Petrol",
	desc = "Very high revving, glorious v8 of ear rapetasticalness.",
	model = "models/engines/v8m.mdl",
	sound = "acf_engines/v8_special2.wav",
	category = "Special",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	requiresfuel = true,
	weight = 400,
	torque = 340,
	flywheelmass = 0.15,
	idlerpm = 1000,
	peakminrpm = 5000,
	peakmaxrpm = 8000,
	limitrpm = 8500
} )

ACF_DefineEngine( "13.0-V12", {
	name = "13.0L V12 Petrol",
	desc = "Thirsty gasoline v12, good torque and power for medium applications.",
	model = "models/engines/v12m.mdl",
	sound = "acf_engines/v12_special.wav",
	category = "Special",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 520,
	torque = 600,
	flywheelmass = 1,
	idlerpm = 700,
	peakminrpm = 2500,
	peakmaxrpm = 4000,
	limitrpm = 4250
} )
