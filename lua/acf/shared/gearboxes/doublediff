-- Double Differential 

-- Weight
local GearDDSW = 80
local GearDDMW = 240
local GearDDLW = 600

-- Torque Rating
local GearDDST = 240
local GearDDMT = 850 
local GearDDLT = 4600

-- general description
local DDDesc = "\n\nA Double Differential transmission allows for a multitude of radii aswell as a neutral steer."

-- Inline

ACF_DefineGearbox( "DoubleDiff-T-S", {
	name = "Double Differential, Small",
	desc = "A light duty regenerative steering transmission."..DDDesc,
	model = "models/engines/transaxial_s.mdl",
	category = "Regenerative Steering",
	weight = GearDDSW,
	switch = 0.2,
	maxtq = GearDDST,
	gears = 1,
	doublediff = true,
	tank = true,
	geartable = {
		[ 0 ] = 0,
		[ 1 ] = 1,
		[ -1 ] = 1
	}
} )

ACF_DefineGearbox( "DoubleDiff-T-M", {
	name = "Double Differential, Medium",
	desc = "A medium regenerative steering transmission."..DDDesc,
	model = "models/engines/transaxial_m.mdl",
	category = "Regenerative Steering",
	weight = GearDDMW,
	switch = 0.35,
	maxtq = GearDDMT,
	gears = 1,
	doublediff = true,
	tank = true,
	geartable = {
		[ 0 ] = 0,
		[ 1 ] = 1,
		[ -1 ] = 1
	}
} )

ACF_DefineGearbox( "DoubleDiff-T-L", {
	name = "Double Differential, Large",
	desc = "A heavy regenerative steering transmission."..DDDesc,
	model = "models/engines/transaxial_l.mdl",
	category = "Regenerative Steering",
	weight = GearDDLW,
	switch = 0.5,
	maxtq = GearDDLT,
	gears = 1,
	doublediff = true,
	tank = true,
	geartable = {
		[ 0 ] = 0,
		[ 1 ] = 1,
		[ -1 ] = 1
	}
} )


