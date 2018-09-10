
-- Special engines

ACF_DefineEngine( "0.9L-I2", {
	name = "0.9L I2 Petrol",
	desc = "Turbocharged inline twin engine that delivers surprising pep for its size.",
	model = "models/engines/inline2s.mdl",
	sound = "acf_extra/vehiclefx/engines/ponyengine.wav",
	category = "Special",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	requiresfuel = true,
	weight = 60,
	torque = 116,
	flywheelmass = 0.085,
	idlerpm = 750,
	peakminrpm = 3125,
	peakmaxrpm = 5100,
	limitrpm = 6000
} )

ACF_DefineEngine( "1.0L-I4", {
	name = "1.0L I4 Petrol",
	desc = "Tiny I4 designed for racing bikes. Doesn't pack much torque, but revs ludicrously high.",
	model = "models/engines/inline4s.mdl",
	sound = "acf_extra/vehiclefx/engines/l4/mini_onhigh.wav",
	pitch = 0.75,
	category = "Special",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	requiresfuel = true,
	weight = 78,
	torque = 68,
	flywheelmass = 0.031,
	idlerpm = 1200,
	peakminrpm = 7500,
	peakmaxrpm = 11500,
	limitrpm = 12000
} )

ACF_DefineEngine( "1.8L-V4", {
	name = "1.8L V4 Petrol",
	desc = "Naturally aspirated rally-tuned V4 with enlarged bore and stroke.",
	model = "models/engines/v4s.mdl",
	sound = "acf_extra/vehiclefx/engines/l4/elan_onlow.WAV",
	category = "Special",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	requiresfuel = true,
	weight = 92,
	torque = 124.8,
	flywheelmass = 0.04,
	idlerpm = 900,
	peakminrpm = 4600,
	peakmaxrpm = 7000,
	limitrpm = 7500
} )

ACF_DefineEngine( "2.4L-V6", {
	name = "2.4L V6 Petrol",
	desc = "Although the cast iron engine block is fairly weighty, this tiny v6 makes up for it with impressive power.  The unique V angle allows uncharacteristically high RPM for a V6.",
	model = "models/engines/v6small.mdl",
	sound = "acf_extra/vehiclefx/engines/l6/capri_onmid.WAV",
	category = "Special",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	requiresfuel = true,
	weight = 134,
	torque = 172,
	flywheelmass = 0.075,
	idlerpm = 950,
	peakminrpm = 4500,
	peakmaxrpm = 7100,
	limitrpm = 8000
} )

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

ACF_DefineEngine( "2.6L-Wankel", {
	name = "2.6L Rotary",
	desc = "4 rotor racing Wankel, high revving and high strung.",
	model = "models/engines/wankel_4_med.mdl",
	sound = "acf_engines/wankel_large.wav",
	category = "Special",
	fuel = "Petrol",
	enginetype = "Wankel",
	requiresfuel = true,
	weight = 260,
	torque = 250,
	flywheelmass = 0.11,
	idlerpm = 1200,
	peakminrpm = 4500,
	peakmaxrpm = 9000,
	limitrpm = 9500
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

ACF_DefineEngine( "5.3-V10", {
	name = "5.3L V10 Special",
	desc = "Extreme performance v10",
	model = "models/engines/v10sml.mdl",
	sound = "acf_engines/v10_special.wav",
	category = "Special",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 300,
	torque = 320,
	requiresfuel = true,
	flywheelmass = 0.15,
	idlerpm = 1100,
	peakminrpm = 5750,
	peakmaxrpm = 8000,
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

ACF_DefineEngine( "3.0-V12", {
	name = "3.0L V12 Petrol",
	desc = "A purpose-built racing v12, not known for longevity.",
	model = "models/engines/v12s.mdl",
	sound = "acf_extra/vehiclefx/engines/v12/gtb4_onmid.WAV",
	pitch = 0.85,
	category = "Special",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	requiresfuel = true,
	weight = 175,
	torque = 248,
	flywheelmass = 0.1,
	idlerpm = 1200,
	peakminrpm = 6875,
	peakmaxrpm = 11000,
	limitrpm = 12500
} )

ACF_DefineEngine( "8.0-V8", {
	name = "8.0L V8 Diesel",
	desc = "Sturdy truck engine with high torque",
	model = "models/engines/v8m.mdl",
	sound = "acf_extra/vehiclefx/engines/gnomefather/porschediesel.wav",
	category = "Special",
	fuel = "Diesel",
	enginetype = "GenericDiesel",
	requiresfuel = true	
	weight = 550,
	torque = 850,
	flywheelmass = 1.6,
	idlerpm = 600,
	peakminrpm = 750,
	peakmaxrpm = 2700,
	limitrpm = 3000
} )
