--define the class
ACF_defineGunClass("SL", {
	spread = 0.32,
	name = "Smoke Launcher",
	desc = "Smoke launcher to block an attacker's line of sight.",
	muzzleflash = "40mm_muzzleflash_noscale",
	rofmod = 60,
	sound = "weapons/ACF_Gun/mortar_new.wav",
	soundDistance = "Mortar.Fire",
	soundNormal = " "
} )

--add a gun to the class
ACF_defineGun("40mmSL", { --id
	name = "40mm Smoke Launcher",
	desc = "",
	model = "models/launcher/40mmgl.mdl",
	gunclass = "SL",
	caliber = 4.0,
	weight = 55,
	year = 1941,
	round = {
		maxlength = 15,
		propweight = 0.00005 
	}
} )
