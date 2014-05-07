--define the class
ACF_defineGunClass("C", {
	spread = 0.08,
	name = "Cannon",
	desc = "High velocity guns that can fire very powerful ammunition, but are rather slow to reload.",
	muzzleflash = "120mm_muzzleflash_noscale",
	rofmod = 1.5,
	sound = "weapons/ACF_Gun/cannon_new.wav",
	soundDistance = "Cannon.Fire",
	soundNormal = " "
} )

--add a gun to the class
ACF_defineGun("37mmC", { --id
    name = "37mm Cannon",
    desc = "A light and fairly weak cannon with good accuracy.",
	model = "models/tankgun/tankgun_37mm.mdl",
	gunclass = "C",
	caliber = 3.7,
	weight = 350,
	year = 1919,
	rofmod = 1.4,
	sound = "weapons/ACF_Gun/ac_fire4.wav",
	round = {
		maxlength = 45,
		propweight = 1.125
	}
} )

ACF_defineGun("50mmC", {
	name = "50mm Cannon",
	desc = "The 50mm is surprisingly fast-firing, with good effectiveness against light armor, but a pea-shooter compared to its bigger cousins",
	model = "models/tankgun/tankgun_50mm.mdl",
	gunclass = "C",
	caliber = 5.0,
	weight = 665,
	year = 1935,
	sound = "weapons/ACF_Gun/ac_fire4.wav",
	round = {
		maxlength = 63,
		propweight = 2.1
	}
} )
	
ACF_defineGun("75mmC", {
	name = "75mm Cannon",
	desc = "The 75mm is still rather respectable in rate of fire, but has only modest payload.  Often found on the Eastern Front, and on cold war light tanks.",
	model = "models/tankgun/tankgun_75mm.mdl",
	gunclass = "C",
	caliber = 7.5,
	weight = 1420,
	year = 1942,
	round = {
		maxlength = 78,
		propweight = 3.8
	}
} )
	
ACF_defineGun("100mmC", {
	name = "100mm Cannon",
	desc = "The 100mm was a benchmark for the early cold war period, and has great muzzle velocity and hitting power, while still boasting a respectable, if small, payload.",
	model = "models/tankgun/tankgun_100mm.mdl",
	gunclass = "C",
	caliber = 10.0,
	weight = 2750,
	year = 1944,
	round = {
		maxlength = 93,
		propweight = 9.5
	}
} )
	
ACF_defineGun("120mmC", {
	name = "120mm Cannon",
	desc = "Often found in MBTs, the 120mm shreds lighter armor with utter impunity, and is formidable against even the big boys.",
	model = "models/tankgun/tankgun_120mm.mdl",
	gunclass = "C",
	caliber = 12.0,
	weight = 5200,
	year = 1955,
	round = {
		maxlength = 110,
		propweight = 18
	}
} )
	
ACF_defineGun("140mmC", {
	ent = "acf_gun",
	type = "Guns",
	name = "140mm Cannon",
	desc = "The 140mm fires a massive shell with enormous penetrative capability, but has a glacial reload speed and a very hefty weight.",
	model = "models/tankgun/tankgun_140mm.mdl",
	gunclass = "C",
	caliber = 14.0,
	weight = 8180,
	year = 1990,
	round = {
		maxlength = 127,
		propweight = 28
	}
} )

--[[
ACF_defineGun("170mmC", {
	name = "170mm Cannon",
	desc = "The 170mm fires a gigantic shell with ginormous penetrative capability, but has a glacial reload speed and an extremely hefty weight.",
	model = "models/tankgun/tankgun_170mm.mdl",
	gunclass = "C",
	caliber = 17.0,
	weight = 12350,
	year = 1990,
	round = {
		maxlength = 154,
		propweight = 34
	}
} )
]]--	
