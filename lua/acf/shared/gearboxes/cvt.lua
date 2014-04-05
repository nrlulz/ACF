
-- CVT (continuously variable transmission)

-- Weight
local GearCVTSW = 65
local GearCVTMW = 180
local GearCVTLW = 500
local StWB = 0.75 --straight weight bonus mulitplier

-- Torque Rating
local GearCVTST = 175
local GearCVTMT = 650 
local GearCVTLT = 6000
local StTB = 1.25 --straight torque bonus multiplier

-- general description
local CVTDesc = "\n\nA CVT will adjust the ratio its first gear to keep an engine within a target rpm range, allowing constant peak performance. However, this comes at the cost of increased weight and limited torque ratings."

-- Inline

ACF_DefineGearbox( "CVT-L-S", {
	name = "CVT, Inline, Small",
	desc = "A light duty inline CVT."..CVTDesc,
	model = "models/engines/linear_s.mdl",
	category = "CVT",
	weight = GearCVTSW,
	switch = 0.15,
	maxtq = GearCVTST,
	gears = 2,
	cvt = true,
	geartable = {
		[-3] = 3000, --target min rpm
        [-2] = 5000, --target max rpm
		[-1] = 1, --final drive
		[ 0 ] = 0,
		[ 1 ] = 0,
		[ 2 ] = -0.1
	}
} )

ACF_DefineGearbox( "CVT-L-M", {
	name = "CVT, Inline, Medium",
	desc = "A medium inline CVT."..CVTDesc,
	model = "models/engines/linear_m.mdl",
	category = "CVT",
	weight = GearCVTMW,
	switch = 0.2,
	maxtq = GearCVTMT,
	gears = 2,
	cvt = true,
	geartable = {
		[-3] = 3000, --target min rpm
        [-2] = 5000, --target max rpm
		[-1] = 1, --final drive
		[ 0 ] = 0,
		[ 1 ] = 0,
		[ 2 ] = -0.1
	}
} )

ACF_DefineGearbox( "CVT-L-L", {
	name = "CVT, Inline, Large",
	desc = "A massive inline CVT designed for high torque applications."..CVTDesc,
	model = "models/engines/linear_l.mdl",
	category = "CVT",
	weight = GearCVTLW,
	switch = 0.3,
	maxtq = GearCVTLT,
	gears = 2,
	cvt = true,
	geartable = {
		[-3] = 3000, --target min rpm
        [-2] = 5000, --target max rpm
		[-1] = 1, --final drive
		[ 0 ] = 0,
		[ 1 ] = 0,
		[ 2 ] = -0.1
	}
} )

-- Inline Dual Clutch

ACF_DefineGearbox( "CVT-LD-S", {
	name = "CVT, Inline, Small, Dual Clutch",
	desc = "A light duty inline CVT. The dual clutch allows you to apply power and brake each side independently."..CVTDesc,
	model = "models/engines/linear_s.mdl",
	category = "CVT",
	weight = GearCVTSW,
	switch = 0.15,
	maxtq = GearCVTST,
	gears = 2,
	doubleclutch = true,
	cvt = true,
	geartable = {
		[-3] = 3000, --target min rpm
        [-2] = 5000, --target max rpm
		[-1] = 1, --final drive
		[ 0 ] = 0,
		[ 1 ] = 0,
		[ 2 ] = -0.1
	}
} )

ACF_DefineGearbox( "CVT-LD-M", {
	name = "CVT, Inline, Medium, Dual Clutch",
	desc = "A medium inline CVT. The dual clutch allows you to apply power and brake each side independently."..CVTDesc,
	model = "models/engines/linear_m.mdl",
	category = "CVT",
	weight = GearCVTMW,
	switch = 0.2,
	maxtq = GearCVTMT,
	gears = 2,
	doubleclutch = true,
	cvt = true,
	geartable = {
		[-3] = 3000, --target min rpm
        [-2] = 5000, --target max rpm
		[-1] = 1, --final drive
		[ 0 ] = 0,
		[ 1 ] = 0,
		[ 2 ] = -0.1
	}
} )

ACF_DefineGearbox( "CVT-LD-L", {
	name = "CVT, Inline, Large, Dual Clutch",
	desc = "A massive inline CVT designed for high torque applications. The dual clutch allows you to apply power and brake each side independently."..CVTDesc,
	model = "models/engines/linear_l.mdl",
	category = "CVT",
	weight = GearCVTLW,
	switch = 0.3,
	maxtq = GearCVTLT,
	gears = 2,
	doubleclutch = true,
	cvt = true,
	geartable = {
		[-3] = 3000, --target min rpm
        [-2] = 5000, --target max rpm
		[-1] = 1, --final drive
		[ 0 ] = 0,
		[ 1 ] = 0,
		[ 2 ] = -0.1
	}
} )

-- Transaxial

ACF_DefineGearbox( "CVT-T-S", {
	name = "CVT, Transaxial, Small",
	desc = "A light duty CVT."..CVTDesc,
	model = "models/engines/transaxial_s.mdl",
	category = "CVT",
	weight = GearCVTSW,
	switch = 0.15,
	maxtq = GearCVTST,
	gears = 2,
	cvt = true,
	geartable = {
		[-3] = 3000, --target min rpm
        [-2] = 5000, --target max rpm
		[-1] = 1, --final drive
		[ 0 ] = 0,
		[ 1 ] = 0,
		[ 2 ] = -0.1
	}
} )

ACF_DefineGearbox( "CVT-T-M", {
	name = "CVT, Transaxial, Medium",
	desc = "A medium CVT."..CVTDesc,
	model = "models/engines/transaxial_m.mdl",
	category = "CVT",
	weight = GearCVTMW,
	switch = 0.2,
	maxtq = GearCVTMT,
	gears = 2,
	cvt = true,
	geartable = {
		[-3] = 3000, --target min rpm
        [-2] = 5000, --target max rpm
		[-1] = 1, --final drive
		[ 0 ] = 0,
		[ 1 ] = 0,
		[ 2 ] = -0.1
	}
} )

ACF_DefineGearbox( "CVT-T-L", {
	name = "CVT, Transaxial, Large",
	desc = "A massive CVT designed for high torque applications."..CVTDesc,
	model = "models/engines/transaxial_l.mdl",
	category = "CVT",
	weight = GearCVTLW,
	switch = 0.3,
	maxtq = GearCVTLT,
	gears = 2,
	cvt = true,
	geartable = {
		[-3] = 3000, --target min rpm
        [-2] = 5000, --target max rpm
		[-1] = 1, --final drive
		[ 0 ] = 0,
		[ 1 ] = 0,
		[ 2 ] = -0.1
	}
} )

-- Transaxial Dual Clutch

ACF_DefineGearbox( "CVT-TD-S", {
	name = "CVT, Transaxial, Small, Dual Clutch",
	desc = "A light duty CVT. The dual clutch allows you to apply power and brake each side independently."..CVTDesc,
	model = "models/engines/transaxial_s.mdl",
	category = "CVT",
	weight = GearCVTSW,
	switch = 0.15,
	maxtq = GearCVTST,
	gears = 2,
	doubleclutch = true,
	cvt = true,
	geartable = {
		[-3] = 3000, --target min rpm
        [-2] = 5000, --target max rpm
		[-1] = 1, --final drive
		[ 0 ] = 0,
		[ 1 ] = 0,
		[ 2 ] = -0.1
	}
} )

ACF_DefineGearbox( "CVT-TD-M", {
	name = "CVT, Transaxial, Medium, Dual Clutch",
	desc = "A medium CVT. The dual clutch allows you to apply power and brake each side independently."..CVTDesc,
	model = "models/engines/transaxial_m.mdl",
	category = "CVT",
	weight = GearCVTMW,
	switch = 0.2,
	maxtq = GearCVTMT,
	gears = 2,
	doubleclutch = true,
	cvt = true,
	geartable = {
		[-3] = 3000, --target min rpm
        [-2] = 5000, --target max rpm
		[-1] = 1, --final drive
		[ 0 ] = 0,
		[ 1 ] = 0,
		[ 2 ] = -0.1
	}
} )

ACF_DefineGearbox( "CVT-TD-L", {
	name = "CVT, Transaxial, Large, Dual Clutch",
	desc = "A massive CVT designed for high torque applications. The dual clutch allows you to apply power and brake each side independently."..CVTDesc,
	model = "models/engines/transaxial_l.mdl",
	category = "CVT",
	weight = GearCVTLW,
	switch = 0.3,
	maxtq = GearCVTLT,
	gears = 2,
	doubleclutch = true,
	cvt = true,
	geartable = {
		[-3] = 3000, --target min rpm
        [-2] = 5000, --target max rpm
		[-1] = 1, --final drive
		[ 0 ] = 0,
		[ 1 ] = 0,
		[ 2 ] = -0.1
	}
} )

-- Straight-through gearboxes

ACF_DefineGearbox( "CVT-ST-S", {
	name = "CVT, Straight, Small",
	desc = "A light duty straight-through CVT."..CVTDesc,
	model = "models/engines/t5small.mdl",
	category = "CVT",
	weight = math.floor(GearCVTSW * StWB),
	switch = 0.15,
	maxtq = math.floor(GearCVTST * StTB),
	gears = 2,
	cvt = true,
	geartable = {
		[-3] = 3000, --target min rpm
        [-2] = 5000, --target max rpm
		[-1] = 1, --final drive
		[ 0 ] = 0,
		[ 1 ] = 0,
		[ 2 ] = -0.1
	}
} )

ACF_DefineGearbox( "CVT-ST-M", {
	name = "CVT, Straight, Medium",
	desc = "A medium straight-through CVT."..CVTDesc,
	model = "models/engines/t5med.mdl",
	category = "CVT",
	weight = math.floor(GearCVTMW * StWB),
	switch = 0.2,
	maxtq = math.floor(GearCVTMT * StTB),
	gears = 2,
	cvt = true,
	geartable = {
		[-3] = 3000, --target min rpm
        [-2] = 5000, --target max rpm
		[-1] = 1, --final drive
		[ 0 ] = 0,
		[ 1 ] = 0,
		[ 2 ] = -0.1
	}
} )

ACF_DefineGearbox( "CVT-ST-L", {
	name = "CVT, Straight, Large",
	desc = "A massive straight-through CVT designed for high torque applications."..CVTDesc,
	model = "models/engines/t5large.mdl",
	category = "CVT",
	weight = math.floor(GearCVTLW * StWB),
	switch = 0.3,
	maxtq = math.floor(GearCVTLT * StTB),
	gears = 2,
	cvt = true,
	geartable = {
		[-3] = 3000, --target min rpm
        [-2] = 5000, --target max rpm
		[-1] = 1, --final drive
		[ 0 ] = 0,
		[ 1 ] = 0,
		[ 2 ] = -0.1
	}
} )
