
-- Radial engines

ACF_DefineEngine( "3.8-R7", {
	name = "3.8L R7 Petrol",
	desc = "A tiny, old worn-out radial.",
	model = "models/engines/radial7s.mdl",
	sound = "acf_engines/r7_petrolsmall.wav",
	category = "Radial",
	fuel = "Petrol",
	enginetype = "Radial",
	weight = 120,
	torque = 200,
	flywheelmass = 0.15,
	idlerpm = 700,
	peakminrpm = 2800,
	peakmaxrpm = 4500,
	limitrpm = 5000
} )

ACF_DefineEngine( "11.0-R7", {
	name = "11.0 R7 Petrol",
	desc = "Mid range radial, thirsty and smooth",
	model = "models/engines/radial7m.mdl",
	sound = "acf_engines/r7_petrolmedium.wav",
	category = "Radial",
	fuel = "Petrol",
	enginetype = "Radial",
	weight = 300,
	torque = 440,
	flywheelmass = 0.35,
	idlerpm = 600,
	peakminrpm = 2200,
	peakmaxrpm = 3700,
	limitrpm = 4000
} )

ACF_DefineEngine( "24.0-R7", {
	name = "24.0L R7 Petrol",
	desc = "The beast of Radials, this monster was destined for fighter aircraft.",
	model = "models/engines/radial7l.mdl",
	sound = "acf_engines/r7_petrollarge.wav",
	category = "Radial",
	fuel = "Petrol",
	enginetype = "Radial",
	weight = 800,
	torque = 1280,
	flywheelmass = 3,
	idlerpm = 750,
	peakminrpm = 1900,
	peakmaxrpm = 3000,
	limitrpm = 3300
} )
