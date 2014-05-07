--define the class
ACF_defineGunClass("SC", {
	spread = 0.24,
	name = "Short-Barrel Cannon",
	desc = "Short cannons trade muzzle velocity and accuracy for lighter weight and smaller size, with more penetration than howitzers and lighter than cannons.",
	muzzleflash = "120mm_muzzleflash_noscale",
	rofmod = 1.3,
	sound = "weapons/ACF_Gun/cannon_new.wav",
	soundDistance = "Cannon.Fire",
	soundNormal = " "
} )

--add a gun to the class
ACF_defineGun("37mmSC", {
	name = "37mm Short Cannon",
	desc = "Quick-firing and light, but penetration is laughable.  You're better off throwing rocks.",
	model = "models/tankgun/tankgun_short_37mm.mdl",
	gunclass = "SC",
	caliber = 3.7,
	weight = 200,
	rofmod = 1.4,
	year = 1915,
	sound = "weapons/ACF_Gun/ac_fire4.wav",
	round = {
		maxlength = 45,
		propweight = 0.29
	}
} )

ACF_defineGun("50mmSC", {
	name = "50mm Short Cannon",
	desc = "The 50mm is a quick-firing pea-shooter, good for scouts, and common on old interwar tanks.",
	model = "models/tankgun/tankgun_short_50mm.mdl",
	gunclass = "SC",
	caliber = 5.0,
	weight = 330,
	year = 1915,
	sound = "weapons/ACF_Gun/ac_fire4.wav",
	round = {
		maxlength = 63,
		propweight = 0.6,
	}
} )

ACF_defineGun("75mmSC", {
	name = "75mm Short Cannon",
	desc = "The 75mm is common WW2 medium tank armament, and still useful in many other applications.",
	model = "models/tankgun/tankgun_short_75mm.mdl",
	gunclass = "SC",
	caliber = 7.5,
	weight = 750,
	year = 1936,
	round = {
		maxlength = 76,
		propweight = 2
	}
} )

ACF_defineGun("100mmSC", {
	name = "100mm Short Cannon",
	desc = "The 100mm is an effective infantry-support or antitank weapon, with a lot of uses and surprising lethality.",
	model = "models/tankgun/tankgun_short_100mm.mdl",
	gunclass = "SC",
	caliber = 10.0,
	weight = 1750,
	year = 1940,
	round = {
		maxlength = 93,
		propweight = 4.5
	}
} )

ACF_defineGun("120mmSC", {
	name = "120mm Short Cannon",
	desc = "The 120mm is a formidable yet lightweight weapon, with excellent performance against larger vehicles.",
	model = "models/tankgun/tankgun_short_120mm.mdl",
	gunclass = "SC",
	caliber = 12.0,
	weight = 4200,
	year = 1944,
	round = {
		maxlength = 110,
		propweight = 8.5
	}
} )

ACF_defineGun("140mmSC", {
	name = "140mm Short Cannon",
	desc = "A specialized weapon, developed from dark magic and anti-heavy tank hatred.  Deal with it.",
	model = "models/tankgun/tankgun_short_140mm.mdl",
	gunclass = "SC",
	caliber = 14.0,
	weight = 7040,
	year = 1999,
	round = {
		maxlength = 127,
		propweight = 12.8
	}
} )
