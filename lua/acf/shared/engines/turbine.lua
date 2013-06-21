
-- Gas turbines

ACF_DefineEngine( "Turbine-Small-Trans", {
	name = "Gas Turbine, Small, Transaxial",
	desc = "A small gas turbine, high power and a very wide powerband\n\nTurbines are powerful but suffer from poor throttle response.  Outputs to the side instead of rear.",
	model = "models/engines/turbine_s.mdl",
	sound = "acf_engines/turbine_small.wav",
	category = "Turbine",
	weight = 200,
	torque = 320,
	flywheelmass = 1,
	idlerpm = 2000,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 10000,
	iselec = true,
	istrans = true,
	elecpower = 110,
	flywheeloverride = 6000
} )

ACF_DefineEngine( "Turbine-Medium-Trans", {
	name = "Gas Turbine, Medium, Transaxial",
	desc = "A medium gas turbine, moderate power but a very wide powerband\n\nTurbines are powerful but suffer from poor throttle response.  Outputs to the side instead of rear.",
	model = "models/engines/turbine_m.mdl",
	sound = "acf_engines/turbine_medium.wav",
	category = "Turbine",
	weight = 400,
	torque = 480,
	flywheelmass = 2,
	idlerpm = 2000,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 12000,
	iselec = true,
	istrans = true,
	elecpower = 200,
	flywheeloverride = 6000
} )

ACF_DefineEngine( "Turbine-Large-Trans", {
	name = "Gas Turbine, Large, Transaxial",
	desc = "A large gas turbine, powerful with a wide powerband\n\nTurbines are powerful but suffer from poor throttle response.  Outputs to the side instead of rear.",
	model = "models/engines/turbine_l.mdl",
	sound = "acf_engines/turbine_large.wav",
	category = "Turbine",
	weight = 1000,
	torque = 1200,
	flywheelmass = 4,
	idlerpm = 2000,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 13500,
	iselec = true,
	istrans = true,
	elecpower = 560,
	flywheeloverride = 6000
} )

ACF_DefineEngine( "Turbine-Small", {
	name = "Gas Turbine, Small",
	desc = "A small gas turbine, high power and a very wide powerband\n\nTurbines are powerful but suffer from poor throttle response.",
	model = "models/engines/gasturbine_s.mdl",
	sound = "acf_engines/turbine_small.wav",
	category = "Turbine",
	weight = 200,
	torque = 320,
	flywheelmass = 1,
	idlerpm = 2000,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 10000,
	iselec = true,
	elecpower = 110,
	flywheeloverride = 6000
} )

ACF_DefineEngine( "Turbine-Medium", {
	name = "Gas Turbine, Medium",
	desc = "A medium gas turbine, moderate power but a very wide powerband\n\nTurbines are powerful but suffer from poor throttle response.",
	model = "models/engines/gasturbine_m.mdl",
	sound = "acf_engines/turbine_medium.wav",
	category = "Turbine",
	weight = 400,
	torque = 480,
	flywheelmass = 2,
	idlerpm = 2000,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 12000,
	iselec = true,
	elecpower = 200,
	flywheeloverride = 6000
} )

ACF_DefineEngine( "Turbine-Large", {
	name = "Gas Turbine, Large",
	desc = "A large gas turbine, powerful with a wide powerband\n\nTurbines are powerful but suffer from poor throttle response.",
	model = "models/engines/gasturbine_l.mdl",
	sound = "acf_engines/turbine_large.wav",
	category = "Turbine",
	weight = 1000,
	torque = 1200,
	flywheelmass = 4,
	idlerpm = 2000,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 13500,
	iselec = true,
	elecpower = 560,
	flywheeloverride = 6000
} )
