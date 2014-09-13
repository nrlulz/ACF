--define the class
ACF_defineGunClass("MG", {
	spread = 0.16,
	name = "Machinegun",
	desc = "Machineguns are light guns that fire equally light bullets at a fast rate.",
	muzzleflash = "50cal_muzzleflash_noscale",
	rofmod = 0.9,
	sound = "weapons/ACF_Gun/mg_fire4.wav",
	soundNormal = "weapons/ACF_Gun/mg_fire4.wav",
	soundDistance = "",
} )

--add a gun to the class
ACF_defineGun("7.62mmMG", { --id
	name = "7.62mm Machinegun",
	desc = "The 7.62mm is effective against infantry, but its usefulness against armor is laughable at best.",
	model = "models/machinegun/machinegun_762mm.mdl",
	gunclass = "MG",
	caliber = 0.762,
	weight = 15,
	year = 1930,
	rofmod = 2,
	round = {
		maxlength = 13,
		propweight = 0.04
	}
} )

ACF_defineGun("12.7mmMG", {
	name = "12.7mm Machinegun",
	desc = "The 12.7mm MG is still light, finding its way into a lot of mountings, including on top of tanks.",
	model = "models/machinegun/machinegun_127mm.mdl",
	gunclass = "MG",
	caliber = 1.27,
	weight = 30,
	year = 1910,
	round = {
		maxlength = 15.8,
		propweight = 0.03
	}
} )
	
ACF_defineGun("14.5mmMG", {
	name = "14.5mm Machinegun",
	desc = "The 14.5mm MG trades its smaller stablemates' rate of fire for more armor penetration and damage.",
	model = "models/machinegun/machinegun_145mm.mdl",
	gunclass = "MG",
	caliber = 1.45,
	weight = 45,
	year = 1932,
	round = {
		maxlength = 19.5,
		propweight = 0.04
	}
} )
	
ACF_defineGun("20mmMG", {
	name = "20mm Machinegun",
	desc = "The 20mm MG is practically a cannon in its own right; the weight and recoil made it difficult to mount on light land vehicles, though it was adapted for use on both aircraft and ships.",
	model = "models/machinegun/machinegun_20mm.mdl",
	gunclass = "MG",
	caliber = 2.0,
	weight = 95,
	year = 1935,
	rofmod = 0.55,
	round = {
		maxlength = 22,
		propweight = 0.09
	}
} )
