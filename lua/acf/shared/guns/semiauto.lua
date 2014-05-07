--define the class
ACF_defineGunClass("SA", {
	spread = 0.08,
	name = "Semiautomatic Cannon",
	desc = "Semiautomatic cannons offer better payloads than autocannons and less weight at the cost of rate of fire.",
	muzzleflash = "30mm_muzzleflash_noscale",
	rofmod = 0.5,
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
	rofmod = 1,
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
	weight = 480,
	year = 1940,
	rofmod = 1,
	magsize = 5,
	magreload = 3.5,
	round = {
		maxlength = 45,
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
	rofmod = 1,
	magsize = 5,
	magreload = 4,
	round = {
		maxlength = 52,
		propweight = 1.8
	}
} )

ACF_defineGun("57mmSA", {
	name = "57mm Semiautomatic Cannon",
	desc = "The 57mm offers the closest thing to a tank cannon, but still lacking in power.",
	model = "models/autocannon/semiautocannon_57mm.mdl",
	gunclass = "SA",
	caliber = 5.7,
	weight = 1560,
	year = 1965,
	rofmod = 1,
	magsize = 5,
	magreload = 4.5,
	round = {
		maxlength = 62,
		propweight = 2
	}
} )
