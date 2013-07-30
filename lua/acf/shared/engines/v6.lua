
-- V6 engines

ACF_DefineEngine( "3.6-V6", {
	name = "3.6L V6 Petrol",
	desc = "Meaty Car sized V6, lots of torque\n\nV6s are more torquey than the Boxer and Inline 6s but suffer in power",
	model = "models/engines/v6small.mdl",
	sound = "acf_engines/v6_petrolsmall.wav",
	category = "V6",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 190,
	torque = 228,
	flywheelmass = 0.25,
	idlerpm = 700,
	peakminrpm = 2200,
	peakmaxrpm = 3500,
	limitrpm = 5000
} )

ACF_DefineEngine( "6.2-V6", {
	name = "6.2L V6 Petrol",
	desc = "Heavy duty v6, throatier than an LA whore, but loaded with torque\n\nV6s are more torquey than the Boxer and Inline 6s but suffer in power",
	model = "models/engines/v6med.mdl",
	sound = "acf_engines/v6_petrolmedium.wav",
	category = "V6",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 360,
	torque = 420,
	flywheelmass = 0.45,
	idlerpm = 800,
	peakminrpm = 2200,
	peakmaxrpm = 3600,
	limitrpm = 5000
} )

ACF_DefineEngine( "12.0-V6", {
	name = "12.0L V6 Petrol",
	desc = "Fuck duty V6, guts ripped from god himself diluted in salt and shaped into an engine.\n\nV6s are more torquey than the Boxer and Inline 6s but suffer in power",
	model = "models/engines/v6large.mdl",
	sound = "acf_engines/v6_petrollarge.wav",
	category = "V6",
	fuel = "Petrol",
	enginetype = "GenericPetrol",
	weight = 800,
	torque = 1120,
	flywheelmass = 4,
	idlerpm = 600,
	peakminrpm = 1750,
	peakmaxrpm = 2950,
	limitrpm = 3500
} )
