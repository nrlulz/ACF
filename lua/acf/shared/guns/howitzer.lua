--define the class
ACF_defineGunClass("HW", {
	spread = 0.12,
	name = "Howitzer",
	desc = "Howitzers are limited to rather mediocre muzzle velocities, but can fire extremely heavy projectiles with large usefull payload capacities.",
	muzzleflash = "120mm_muzzleflash_noscale",
	rofmod = 1.3,
	sound = "weapons/ACF_Gun/howitzer_new2.wav",
	soundDistance = "Howitzer.Fire",
	soundNormal = " "
} )

--add a gun to the class
ACF_defineGun("75mmHW", { --id
	name = "75mm Howitzer",
	desc = "Often found being towed by large smelly animals, the 75mm has a high rate of fire, and is surprisingly lethal against light armor.  Great for a sustained barrage against someone you really don't like.",
	model = "models/howitzer/howitzer_75mm.mdl",
	gunclass = "HW",
	caliber = 7.5,
	weight = 530,
	year = 1900,
	round = {
		maxlength = 60,
		propweight = 1.8
	}
} )
	
ACF_defineGun("105mmHW", {
	name = "105mm Howitzer",
	desc = "The 105 lobs a big shell far, and its HEAT rounds can be extremely effective against even heavier armor.",
	model = "models/howitzer/howitzer_105mm.mdl",
	gunclass = "HW",
	caliber = 10.5,
	weight = 1810,
	year = 1900,
	round = {
		maxlength = 84,
		propweight = 2.9
	}
} )

ACF_defineGun("122mmHW", {
	name = "122mm Howitzer",
	desc = "The 122mm bridges the gap between the 105 and the 155, providing a lethal round with a big splash radius.",
	model = "models/howitzer/howitzer_122mm.mdl",
	gunclass = "HW",
	caliber = 12.2,
	weight = 3520,
	year = 1900,
	round = {
		maxlength = 104,
		propweight = 6
	}
} )
	
ACF_defineGun("155mmHW", {
	name = "155mm Howitzer",
	desc = "The 155 is a classic heavy artillery round, with good reason.  A versatile weapon, it's found on most modern SPGs.",
	model = "models/howitzer/howitzer_155mm.mdl",
	gunclass = "HW",
	caliber = 15.5,
	weight = 5340,
	year = 1900,
	round = {
		maxlength = 124,
		propweight = 13.5
	}
} )
	
ACF_defineGun("203mmHW", {
	name = "203mm Howitzer",
	desc = "An 8-inch deck gun, found on siege artillery and cruisers.",
	model = "models/howitzer/howitzer_203mm.mdl",
	gunclass = "HW",
	caliber = 20.3,
	weight = 10280,
	year = 1900,
	round = {
		maxlength = 162.4,
		propweight = 28.5
	}
} )

--[[
ACF_defineGun("240mmHW", {
	name = "240mm Howitzer",
	desc = "A 9.4-inch deck gun, found on heavy siege artillery and cruisers.",
	model = "models/howitzer/howitzer_240mm.mdl",
	gunclass = "HW",
	caliber = 24.0,
	weight = 12980,
	year = 1900,
	round = {
		maxlength = 192.0,
		propweight = 33.7
	}
} )

ACF_defineGun("290mmHW", {
	name = "290mm Howitzer",
	desc = " Mother of all howitzers. This 12in beast can be found on battleships. It WILL fuck your day up... when it reloads.",
	model = "models/howitzer/howitzer_406mm.mdl",
	gunclass = "HW",
	caliber = 29,
	weight = 24960,
	year = 1900,
	round = {
		maxlength = 325,
		propweight = 57.0
	}
} )
]]--	