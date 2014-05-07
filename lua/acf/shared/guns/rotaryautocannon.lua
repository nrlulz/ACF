--define the class
ACF_defineGunClass("RAC", {
	spread = 0.48,
	name = "Rotary Autocannon",
	desc = "Rotary Autocannons sacrifice weight, bulk and accuracy over classic Autocannons to get the highest rate of fire possible.",
	muzzleflash = "50cal_muzzleflash_noscale",
	rofmod = 0.07,
	sound = "weapons/ACF_Gun/rac_fire2.wav",
	soundDistance = " ",
	soundNormal = " "
} )

--add a gun to the class
ACF_defineGun("20mmRAC", { --id
	name = "20mm Rotary Autocannon",
	desc = "The 20mm is the lighter of the pair, with decent penetration, but still able to chew up armor or put up a big flak screen.  Mounted on ground attack aircraft and occasionally APCs, to be used against aircraft.",
	model = "models/rotarycannon/rotarycannon_20mm.mdl",
	gunclass = "RAC",
	caliber = 2.0,
	weight = 1260,
	year = 1965,
	magsize = 25,
	magreload = 1.5,
	round = {
		maxlength = 28,
		propweight = 0.12
	}
} )

ACF_defineGun("30mmRAC", {
	name = "30mm Rotary Autocannon",
	desc = "The 30mm is the bane of ground-attack aircraft, able to tear up thin armor without giving one single fuck.  Also seen in the skies above dead T-72s.",
	model = "models/rotarycannon/rotarycannon_30mm.mdl",
	gunclass = "RAC",
	caliber = 3.0,
	weight = 3680,
	year = 1975,
	magsize = 25,
	magreload = 1.5,
	round = {
		maxlength = 39,
		propweight = 0.350
	}
} )
