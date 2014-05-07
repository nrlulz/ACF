--define the class
ACF_defineGunClass("GL", {
	spread = 0.32,
	name = "Grenade Launcher",
	desc = "Grenade Launchers can fire shells with relatively large payloads at a fast rate, but with very limited velocities and poor accuracy.",
	muzzleflash = "40mm_muzzleflash_noscale",
	rofmod = 1,
	sound = "weapons/grenade_launcher1.wav",
	soundDistance = " ",
	soundNormal = " "
} )

--add a gun to the class
ACF_defineGun("40mmGL", { --id
	name = "40mm Grenade Machine Gun",
	desc = "The 40mm chews up infantry but is about as useful as tits on a nun for fighting armor.  Often found on 4x4s rolling through the third world.",
	model = "models/launcher/40mmgl.mdl",
	gunclass = "GL",
	caliber = 4.0,
	weight = 55,
	year = 1970,
	round = {
		maxlength = 7.5,
		propweight = 0.01
	}
} )
