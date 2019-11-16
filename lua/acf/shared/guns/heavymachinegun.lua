--define the class
ACF_defineGunClass("HMG", {
	spread = 0.4,
	name = "Heavy Machinegun",
	desc = "Designed as autocannons for aircraft, HMGs are rapid firing, lightweight, and compact but sacrifice accuracy, magazine size, and reload times.  They excel at strafing and dogfighting.\nBecause of their long reload times and high rate of fire, it is best to aim BEFORE pushing the almighty fire switch.",
	muzzleflash = "50cal_muzzleflash_noscale",
	rofmod = 0.14,
	sound = "weapons/ACF_Gun/mg_fire3.wav",
	soundDistance = " ",
	soundNormal = " ",
	longbarrel = {
		index = 2, 
		submodel = 4, 
		newpos = "muzzle2"
	}
} )

--add a gun to the class

ACF_defineGun("13mmHMG", {
	name = "13mm Heavy Machinegun",
	desc = "The lightest of the HMGs, the 13mm has a rapid fire rate but suffers from poor payload size.  Often used to strafe ground troops or annoy low-flying aircraft.",
	model = "models/machinegun/machinegun_20mm.mdl",
	gunclass = "HMG",
	caliber = 1.3,
	weight = 90,
	year = 1935,
	rofmod = 3.3, 
	magsize = 35,
	magreload = 6,
	round = {
		maxlength = 22,
		propweight = 0.09
	}
} )

ACF_defineGun("20mmHMG", {
	name = "20mm Heavy Machinegun",
	desc = "The 20mm has a rapid fire rate but suffers from poor payload size.  Often used to strafe ground troops or annoy low-flying aircraft.",
	model = "models/machinegun/machinegun_20mm_compact.mdl",
	gunclass = "HMG",
	caliber = 2.0,
	weight = 160,
	year = 1935,
	rofmod = 1.9, --at 1.5, 675rpm; at 2.0, 480rpm
	magsize = 30,
	magreload = 6,
	round = {
		maxlength = 30,
		propweight = 0.12
	}
} )

ACF_defineGun("30mmHMG", {
	name = "30mm Heavy Machinegun",
	desc = "30mm shell chucker, light and compact. Your average cold war dogfight go-to.",
	model = "models/machinegun/machinegun_30mm_compact.mdl",
	gunclass = "HMG",
	caliber = 3.0,
	weight = 480,
	year = 1941,
	rofmod = 1.1, --at 1.05, 495rpm; 
	magsize = 25,
	magreload = 6,
	round = {
		maxlength = 37,
		propweight = 0.35
	}
} )

ACF_defineGun("40mmHMG", {
	name = "40mm Heavy Machinegun",
	desc = "The heaviest of the heavy machineguns.  Massively powerful with a killer reload and hefty ammunition requirements, it can pop even relatively heavy targets with ease.",
	model = "models/machinegun/machinegun_40mm_compact.mdl",
	gunclass = "HMG",
	caliber = 4.0,
	weight = 780,
	year = 1955,
	rofmod = 0.95, --at 0.75, 455rpm
	magsize = 20,
	magreload = 8,
	round = {
		maxlength = 42,
		propweight = 0.9
	}
} )
	
