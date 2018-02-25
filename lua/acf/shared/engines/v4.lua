--V4 Engines

ACF_DefineEngine( "1.9L-V4", {
	name = "1.9L V4 Diesel",
	desc = "Torquey little lunchbox for those smaller vehicles that don't agree with petrol powerbands",
	model = "models/engines/v4s.mdl",
	sound = "acf_engines/i4_diesel2.wav",
	category = "V4",
	fuel = "Diesel",
	enginetype = "GenericDiesel",
	weight = 110,
	torque = 165,
	flywheelmass = 0.3,
	idlerpm = 650,
	peakminrpm = 950,
	peakmaxrpm = 3000,
	limitrpm = 4000
} )

ACF_DefineEngine( "3.3L-V4", {
	name = "3.3L V4 Diesel",
	desc = "Compact cube of git for moderate utility applications",
	model = "models/engines/v4m.mdl",
	sound = "acf_engines/i4_dieselmedium.wav",
	category = "V4",
	fuel = "Diesel",
	enginetype = "GenericDiesel",
	weight = 275,
	torque = 340,
	flywheelmass = 1.05,
	idlerpm = 600,
	peakminrpm = 1050,
	peakmaxrpm = 3100,
	limitrpm = 3900
} )