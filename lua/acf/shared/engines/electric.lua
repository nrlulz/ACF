
-- Electric motors

ACF_DefineEngine( "Electric-Small", {
	name = "Electric motor, Small",
	desc = "A small electric motor, loads of torque, but low power\n\nElectric motors provide huge amounts of torque, but are very heavy",
	model = "models/engines/emotorsmall.mdl",
	sound = "acf_engines/electric_small.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	weight = 250,
	torque = 320,
	flywheelmass = 0.25,
	idlerpm = 10,
	peakminrpm = 10,
	peakmaxrpm = 10,
	limitrpm = 10000,
	iselec = true,
	elecpower = 78,
	flywheeloverride = 5000
} )

ACF_DefineEngine( "Electric-Medium", {
	name = "Electric motor, Medium",
	desc = "A medium electric motor, loads of torque, but low power\n\nElectric motors provide huge amounts of torque, but are very heavy",
	model = "models/engines/emotormed.mdl",
	sound = "acf_engines/electric_medium.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	weight = 850,
	torque = 960,
	flywheelmass = 1.2,
	idlerpm = 10,
	peakminrpm = 10,
	peakmaxrpm = 10,
	limitrpm = 7000,
	iselec = true,
	elecpower = 160,
	flywheeloverride = 8000
} )

ACF_DefineEngine( "Electric-Large", {
	name = "Electric motor, Large",
	desc = "A huge electric motor, loads of torque, but low power\n\nElectric motors provide huge amounts of torque, but are very heavy",
	model = "models/engines/emotorlarge.mdl",
	sound = "acf_engines/electric_large.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	weight = 1900,
	torque = 2400,
	flywheelmass = 8,
	idlerpm = 10,
	peakminrpm = 10,
	peakmaxrpm = 10,
	limitrpm = 4500,
	iselec = true,
	elecpower = 272,
	flywheeloverride = 6000
} )

ACF_DefineEngine( "Electric-Small-NoBatt", {
	name = "Electric motor, Small, Standalone",
	desc = "A small electric motor, loads of torque, but low power\n\nElectric motors provide huge amounts of torque, but are very heavy.\n\nStandalone electric motors don't have integrated batteries, saving on weight and volume, but require you to supply your own batteries.",
	model = "models/engines/emotorsmall2.mdl",
	sound = "acf_engines/electric_small.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	requiresfuel = true,
	weight = 125, --250
	torque = 320,
	flywheelmass = 0.25,
	idlerpm = 10,
	peakminrpm = 10,
	peakmaxrpm = 10,
	limitrpm = 10000,
	iselec = true,
	elecpower = 78,
	flywheeloverride = 5000
} )

ACF_DefineEngine( "Electric-Medium-NoBatt", {
	name = "Electric motor, Medium, Standalone",
	desc = "A medium electric motor, loads of torque, but low power\n\nElectric motors provide huge amounts of torque, but are very heavy.\n\nStandalone electric motors don't have integrated batteries, saving on weight and volume, but require you to supply your own batteries.",
	model = "models/engines/emotormed2.mdl",
	sound = "acf_engines/electric_medium.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	requiresfuel = true,
	weight = 575, --800
	torque = 960,
	flywheelmass = 1.2,
	idlerpm = 10,
	peakminrpm = 10,
	peakmaxrpm = 10,
	limitrpm = 7000,
	iselec = true,
	elecpower = 160,
	flywheeloverride = 8000
} )

ACF_DefineEngine( "Electric-Large-NoBatt", {
	name = "Electric motor, Large, Standalone",
	desc = "A huge electric motor, loads of torque, but low power\n\nElectric motors provide huge amounts of torque, but are very heavy.\n\nStandalone electric motors don't have integrated batteries, saving on weight and volume, but require you to supply your own batteries.",
	model = "models/engines/emotorlarge2.mdl",
	sound = "acf_engines/electric_large.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	requiresfuel = true,
	weight = 1500, --1900
	torque = 2400,
	flywheelmass = 8,
	idlerpm = 10,
	peakminrpm = 10,
	peakmaxrpm = 10,
	limitrpm = 4500,
	iselec = true,
	elecpower = 272,
	flywheeloverride = 6000
} )
