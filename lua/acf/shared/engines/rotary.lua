
-- Wankel engines

ACF_DefineEngine( "900cc-R", {
	name = "900cc Rotary",
	desc = "Small rotary engine, very high strung and suited for yard use.",
	model = "models/engines/wankelsmall.mdl",
	sound = "acf_engines/wankel_small.wav",
	category = "Rotary",
	fuel = "Petrol",
	enginetype = "Wankel",
	weight = 50,
	torque = 78,
	flywheelmass = 0.06,
	idlerpm = 950,
	peakminrpm = 4500,
	peakmaxrpm = 9000,
	limitrpm = 9200
} )

ACF_DefineEngine( "1.3L-R", {
	name = "1.3L Rotary",
	desc = "Medium Wankel for general use. Wankels have a somewhat wide powerband, but very high strung.",
	model = "models/engines/wankelmed.mdl",
	sound = "acf_engines/wankel_medium.wav",
	category = "Rotary",
	fuel = "Petrol",
	enginetype = "Wankel",
	weight = 140,
	torque = 124,
	flywheelmass = 0.06,
	idlerpm = 950,
	peakminrpm = 4100,
	peakmaxrpm = 8500,
	limitrpm = 9000
} )

ACF_DefineEngine( "2.0L-R", {
	name = "2.0L Rotary",
	desc = "High performance rotary engine.",
	model = "models/engines/wankellarge.mdl",
	sound = "acf_engines/wankel_large.wav",
	category = "Rotary",
	fuel = "Petrol",
	enginetype = "Wankel",
	weight = 200,
	torque = 188,
	flywheelmass = 0.1,
	idlerpm = 950,
	peakminrpm = 4100,
	peakmaxrpm = 8500,
	limitrpm = 9500
} )
