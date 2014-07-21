--define the class
ACF_defineGunClass("AL", {
	spread = 0.08,
	name = "Autoloader",
	desc = "A cannon with attached autoloading mechanism.  While it allows for several quick shots, the mechanism adds considerable bulk, weight, and magazine reload time.",
	muzzleflash = "120mm_muzzleflash_noscale",
	rofmod = 0.8,
	sound = "weapons/ACF_Gun/autoloader.wav",
	soundDistance = "Cannon.Fire",
	soundNormal = " "
} )

--add a gun to the class
ACF_defineGun("75mmAL", { --id
	name = "75mm Autoloading Cannon",
	desc = "A quick-firing 75mm gun, pops off a number of rounds in relatively short order.",
	model = "models/tankgun/tankgun_al_75mm.mdl",
	gunclass = "AL",
	caliber = 7.5,
	weight = 2125,
	year = 1946,
	rofmod = 0.8,
	magsize = 8,
	magreload = 15,
	round = {
		maxlength = 78,
		propweight = 3.8
	}
} )

ACF_defineGun("100mmAL", {
	name = "100mm Autoloading Cannon",
	desc = "The 100mm is good for rapidly hitting medium armor, then running like your ass is on fire to reload.",
	model = "models/tankgun/tankgun_al_100mm.mdl",
	gunclass = "AL",
	caliber = 10.0,
	weight = 3750,
	year = 1956,
	rofmod = 0.8,
	magsize = 6,
	magreload = 21,
	round = {
		maxlength = 93,
		propweight = 9.5
	}
} )

ACF_defineGun("120mmAL", {
	name = "120mm Autoloading Cannon",
	desc = "The 120mm autoloader can do serious damage before reloading, but the reload time is killer.",
	model = "models/tankgun/tankgun_al_120mm.mdl",
	gunclass = "AL",
	caliber = 12.0,
	weight = 6200,
	year = 1956,
	rofmod = 0.8,
	magsize = 4,
	magreload = 27,
	round = {
		maxlength = 110,
		propweight = 18
	}
} )

ACF_defineGun("140mmAL", {
	name = "140mm Autoloading Cannon",
	desc = "The 140mm can shred a medium tank's armor with one magazine, and even function as shoot & scoot artillery, with its useful HE payload.",
	model = "models/tankgun/tankgun_al_140mm.mdl",
	gunclass = "AL",
	caliber = 14.0,
	weight = 9180,
	year = 1970,
	rofmod = 0.8,
	magsize = 4,
	magreload = 35,
	round = {
		maxlength = 127,
		propweight = 28
	}
} )
		
--[[
ACF_defineGun("170mmAL", {
	name = "170mm Autoloading Cannon",
	desc = "The 170mm can shred an average 40ton tank's armor with one magazine.",
	model = "models/tankgun/tankgun_al_170mm.mdl",
	gunclass = "AL",
	caliber = 17.0,
	weight = 13350,
	year = 1970,
	rofmod = 0.8,
	magsize = 4,
	magreload = 40,
	round = {
		maxlength = 154,
		propweight = 34
	}
} )
]]--

