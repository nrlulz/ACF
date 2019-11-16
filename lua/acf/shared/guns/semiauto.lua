--define the class
ACF_defineGunClass("SA", {
	spread = 0.1,
	name = "Semiautomatic Cannon",
	desc = "Semiautomatic cannons offer better payloads than autocannons and less weight at the cost of rate of fire.",
	muzzleflash = "30mm_muzzleflash_noscale",
	rofmod = 0.36,
	sound = "acf_extra/tankfx/gnomefather/25mm1.wav",
	soundDistance = " ",
	soundNormal = " "
} )

--add a gun to the class
ACF_defineGun("25mmSA", { --id
	name = "25mm Semiautomatic Cannon",
	desc = "The 25mm semiauto can quickly put five rounds downrange, being lethal, yet light.",
	model = "models/autocannon/semiautocannon_25mm.mdl",
	gunclass = "SA",
	caliber = 2.5,
	weight = 200,
	year = 1935,
	rofmod = 0.7,
	magsize = 5,
	magreload = 2,
	round = {
		maxlength = 39,
		propweight = 0.5
	}
} )
	
ACF_defineGun("37mmSA", {
	name = "37mm Semiautomatic Cannon",
	desc = "The 37mm is surprisingly powerful, its five-round clips boasting a respectable payload and a high muzzle velocity.",
	model = "models/autocannon/semiautocannon_37mm.mdl",
	gunclass = "SA",
	caliber = 3.7,
	weight = 540,
	year = 1940,
	rofmod = 0.7,
	magsize = 5,
	magreload = 3.5,
	round = {
		maxlength = 42,
		propweight = 1.125
	}
} )

ACF_defineGun("45mmSA", {
	name = "45mm Semiautomatic Cannon",
	desc = "The 45mm can easily shred light armor, with a respectable rate of fire, but its armor penetration pales in comparison to regular cannons.",
	model = "models/autocannon/semiautocannon_45mm.mdl",
	gunclass = "SA",
	caliber = 4.5,
	weight = 870,
	year = 1965,
	rofmod = 0.72,
	magsize = 5,
	magreload = 4,
	round = {
		maxlength = 52,
		propweight = 1.8
	}
} )

ACF_defineGun("57mmSA", {
	name = "57mm Semiautomatic Cannon",
	desc = "The 57mm is a respectable light armament, offering considerable penetration and moderate fire rate.",
	model = "models/autocannon/semiautocannon_57mm.mdl",
	gunclass = "SA",
	caliber = 5.7,
	weight = 1560,
	year = 1965,
	rofmod = 0.8,
	magsize = 5,
	magreload = 4.5,
	round = {
		maxlength = 62,
		propweight = 2
	}
} )

ACF_defineGun("76mmSA", {
	name = "76mm Semiautomatic Cannon",
	desc = "The 76mm semiauto is a fearsome weapon, able to put 5 76mm rounds downrange in 8 seconds.",
	model = "models/autocannon/semiautocannon_76mm.mdl",
	gunclass = "SA",
	caliber = 7.62,
	weight = 2990,
	year = 1984,
	rofmod = 0.85,
	magsize = 5,
	magreload = 5,
	round = {
		maxlength = 70,
		propweight = 4.75
	}
} )
