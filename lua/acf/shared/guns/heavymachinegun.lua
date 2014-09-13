--define the class
ACF_defineGunClass("HMG", {
	spread = 0.32,
	name = "Heavy Machinegun",
	desc = "Heavy machineguns are lightweight and compact, but suffer from poor accuracy.",
	muzzleflash = "50cal_muzzleflash_noscale",
	rofmod = 0.29,
	sound = "weapons/ACF_Gun/mg_fire3.wav",
	soundDistance = " ",
	soundNormal = " "
} )

--add a gun to the class
ACF_defineGun("20mmHMG", { --id
	name = "20mm Heavy Machinegun",
	desc = "The lightest of the HMGs, the 20mm has a modest fire rate but suffers from poor payload size.  Often used to strafe ground troops or annoy low-flying aircraft.",
	model = "models/machinegun/machinegun_20mm_compact.mdl",
	gunclass = "HMG",
	caliber = 2.0,
	weight = 60,
	year = 1935,
	rofmod = 2.85,
	magsize = 75,
	magreload = 5,
	round = {
		maxlength = 21,
		propweight = 0.045
	}
} )

ACF_defineGun("30mmHMG", {
	name = "30mm Heavy Machinegun",
	desc = "30mm shell chucker, light and compact. Best used in aircraft, it lobs a solid amount of lead out a respectable distance.",
	model = "models/machinegun/machinegun_30mm_compact.mdl",
	gunclass = "HMG",
	caliber = 3.0,
	weight = 240,
	year = 1941,
	rofmod = 1.44,
	magsize = 50,
	magreload = 7,
	round = {
		maxlength = 28,
		propweight = 0.13
	}
} )

ACF_defineGun("40mmHMG", {
	name = "40mm Heavy Machinegun",
	desc = "The heaviest of the heavy machineguns, this one boasts a useful payload, but suffers severely in ballistic performance",
	model = "models/machinegun/machinegun_40mm_compact.mdl",
	gunclass = "HMG",
	caliber = 4.0,
	weight = 960,
	year = 1935,
	magsize = 30,
	magreload = 10,
	round = {
		maxlength = 28,
		propweight = 0.30
	}
} )
	