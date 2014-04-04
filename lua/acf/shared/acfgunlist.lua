AddCSLuaFile( "acf/shared/acfgunlist.lua" )


-- local Exemple = {}  --That name is just a variable name and doesn't have much meaning
	-- Exemple.id = "7.62mmEx" --This is how we reference that gun everywhere
	-- Exemple.ent = "acf_gun" --This is the entity the menu has to spawn to use that gun
	-- Exemple.type = "Guns" --Another reference for the spawn menu
	-- Exemple.desc = "Exemple" --Spawn menu text
	-- Exemple.model = "models/error.mdl" --The model of that particular gun
	-- Exemple.caliber = 99 --The gun caliber in mm
	-- Exemple.gunclass = "MG" --A gun class code that determines a few attributes, the tables for that are lower in this file
	-- Exemple.weight = 99 --Weight, duh
		-- Exemple.round = {} --The table that defines that gun ammo
		-- Exemple.round.id = "7.62mmEX" --Ammo ID, if you actually want to fire it it has to be the same as the gun ID, first line in the table
		-- Exemple.round.emptyweight = 0.01 --Minimum ammo weight
		-- Exemple.round.maxweight = 0.05 --Max ammo weight
		-- Exemple.round.propweight = 0.010 --Max propellant weight
--Exemple["7.62mmEx"] = Exemple --Reference the gun table we defined into the gun listing


local GunTable = {}

local MG762mm = {}
	MG762mm.id = "7.62mmMG"
	MG762mm.ent = "acf_gun"
	MG762mm.type = "Guns"
	MG762mm.name = "7.62mm Machinegun"
	MG762mm.desc = "Machineguns are light guns that fire equally light bullets at a fast rate.  The 7.62mm is effective against infantry, but its usefulness against armor is laughable at best"
	MG762mm.model = "models/machinegun/machinegun_127mm.mdl"
	MG762mm.caliber = 0.762
	MG762mm.gunclass = "MG"
	MG762mm.weight = 15
	MG762mm.year = 1930
	MG762mm.rofmod = 2

		MG762mm.round = {}
		MG762mm.round.id = "7.62mmMG"
		MG762mm.round.maxlength = 13
		MG762mm.round.propweight = 0.04
	if ( CLIENT ) then
		MG762mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		MG762mm.guiupdate = function() return end
	end
GunTable["7.62mmMG"] = MG762mm

local MG12mm = {}
	MG12mm.id = "12.7mmMG"
	MG12mm.ent = "acf_gun"
	MG12mm.type = "Guns"
	MG12mm.name = "12.7mm Machinegun"
	MG12mm.desc = "Machineguns are light guns that fire equally light bullets at a fast rate.  The 12.7mm MG is still light, finding its way into a lot of mountings, including on top of tanks"
	MG12mm.model = "models/machinegun/machinegun_127mm.mdl"
	MG12mm.caliber = 1.27
	MG12mm.gunclass = "MG"
	MG12mm.weight = 30
	MG12mm.year = 1910

		MG12mm.round = {}
		MG12mm.round.id = "12.7mmMG"
		MG12mm.round.maxlength = 15.8
		MG12mm.round.propweight = 0.03
	if ( CLIENT ) then
		MG12mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		MG12mm.guiupdate = function() return end
	end
GunTable["12.7mmMG"] = MG12mm
	
local MG14mm = {}
	MG14mm.id = "14.5mmMG"
	MG14mm.ent = "acf_gun"
	MG14mm.type = "Guns"
	MG14mm.name = "14.5mm Machinegun"
	MG14mm.desc = "Machineguns are light guns that fire equally light bullets at a fast rate. The 14.5mm MG trades its smaller stablemates' rate of fire for more armor penetration and damage"
	MG14mm.model = "models/machinegun/machinegun_145mm.mdl"
	MG14mm.caliber = 1.45
	MG14mm.gunclass = "MG"
	MG14mm.weight = 45
	MG14mm.year = 1932
		MG14mm.round = {}
		MG14mm.round.id = "14.5mmMG"
		MG14mm.round.maxlength = 19.5
		MG14mm.round.propweight = 0.04
	if ( CLIENT ) then
		MG14mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		MG14mm.guiupdate = function() return end
	end
GunTable["14.5mmMG"] = MG14mm
	
local HMG20mm = {}
	HMG20mm.id = "20mmHMG"
	HMG20mm.ent = "acf_gun"
	HMG20mm.type = "Guns"
	HMG20mm.name = "20mm Heavy Machinegun"
	HMG20mm.desc = "The lightest of the HMGs, the 20mm fires at a high rate, but with poor accuracy and little damage.  Often used to strafe ground troops or annoy low-flying aircraft."
	HMG20mm.model = "models/machinegun/machinegun_20mm_compact.mdl"
	HMG20mm.caliber = 2.0
	HMG20mm.gunclass = "HMG"
	HMG20mm.weight = 60
	HMG20mm.year = 1935
	HMG20mm.rofmod = 1.7
		HMG20mm.round = {}
		HMG20mm.round.id = "20mmHMG"
		HMG20mm.round.maxlength = 12.5
		HMG20mm.round.propweight = 0.05
	HMG20mm.magsize = 120
	HMG20mm.magreload = 5
	if ( CLIENT ) then
		HMG20mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		HMG20mm.guiupdate = function() return end
	end
GunTable["20mmHMG"] = HMG20mm

	
	local HMG30mm = {}
	HMG30mm.id = "30mmHMG"
	HMG30mm.ent = "acf_gun"
	HMG30mm.type = "Guns"
	HMG30mm.name = "30mm Heavy Machinegun"
	HMG30mm.desc = "30mm shell chucker, light and compact, however suffers in accuracy and ballistics. Best used in aircraft, it lobs a solid amount of lead out a respectable distance."
	HMG30mm.model = "models/machinegun/machinegun_30mm_compact.mdl"
	HMG30mm.caliber = 3.0
	HMG30mm.gunclass = "HMG"
	HMG30mm.weight = 240
	HMG30mm.year = 1941
		HMG30mm.round = {}
		HMG30mm.round.id = "30mmHMG"
		HMG30mm.round.maxlength = 21.75
		HMG30mm.round.propweight = 0.13
	HMG30mm.magsize = 50
	HMG30mm.magreload = 7
	if ( CLIENT ) then
		HMG30mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		HMG30mm.guiupdate = function() return end
	end
GunTable["30mmHMG"] = HMG30mm

local HMG40mm = {}
	HMG40mm.id = "40mmHMG"
	HMG40mm.ent = "acf_gun"
	HMG40mm.type = "Guns"
	HMG40mm.name = "40mm Heavy Machinegun"
	HMG40mm.desc = "The heaviest of the heavy machineguns, this one boasts a useful payload, but suffers severely in ballistic performance"
	HMG40mm.model = "models/machinegun/machinegun_40mm_compact.mdl"
	HMG40mm.caliber = 4.0
	HMG40mm.gunclass = "HMG"
	HMG40mm.weight = 960
	HMG40mm.year = 1935
		HMG40mm.round = {}
		HMG40mm.round.id = "40mmHMG"
		HMG40mm.round.maxlength = 28
		HMG40mm.round.propweight = 0.30
	HMG40mm.magsize = 30
	HMG40mm.magreload = 10
	if ( CLIENT ) then
		HMG40mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		HMG40mm.guiupdate = function() return end
	end
GunTable["40mmHMG"] = HMG40mm
	
local AC20mm = {}
	AC20mm.id = "20mmAC"
	AC20mm.ent = "acf_gun"
	AC20mm.type = "Guns"
	AC20mm.name = "20mm Autocannon"
	AC20mm.desc = "Autocannons have a rather high weight and bulk for the ammo they fire, but they can fire it extremely fast.  The 20mm AC is the smallest of the familly; having a good rate of fire but a tiny shell, it's still infinitely more effective than the 20mm when firing AP"
	AC20mm.model = "models/autocannon/autocannon_20mm.mdl"
	AC20mm.caliber = 2.0
	AC20mm.gunclass = "AC"
	AC20mm.weight = 360
	AC20mm.year = 1930
		AC20mm.round = {}
		AC20mm.round.id = "20mmAC"
		AC20mm.round.maxlength = 28
		AC20mm.round.propweight = 0.12
	AC20mm.rofmod = 2
	AC20mm.magsize = 100
	AC20mm.magreload = 3
	if ( CLIENT ) then
		AC20mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		AC20mm.guiupdate = function() return end
	end
GunTable["20mmAC"] = AC20mm
	
local AC30mm = {}
	AC30mm.id = "30mmAC"
	AC30mm.ent = "acf_gun"
	AC30mm.type = "Guns"
	AC30mm.name = "30mm Autocannon"
	AC30mm.desc = "Autocannons have a rather high weight and bulk for the ammo they fire, but they can fire it extremely fast.  The 30mm AC can fire shells with sufficient space for a small payload, and has modest anti-armor capability"
	AC30mm.model = "models/autocannon/autocannon_30mm.mdl"
	AC30mm.caliber = 3.0
	AC30mm.gunclass = "AC"
	AC30mm.weight = 960
	AC30mm.year = 1935
		AC30mm.round = {}
		AC30mm.round.id = "30mmAC"
		AC30mm.round.maxlength = 39
		AC30mm.round.propweight = 0.350
	AC30mm.rofmod = 1
	AC30mm.magsize = 75
	AC30mm.magreload = 3
	if ( CLIENT ) then
		AC30mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		AC30mm.guiupdate = function() return end
	end
GunTable["30mmAC"] = AC30mm
	
local AC40mm = {}
	AC40mm.id = "40mmAC"
	AC40mm.ent = "acf_gun"
	AC40mm.type = "Guns"
	AC40mm.name = "40mm Autocannon"
	AC40mm.desc = "Autocannons have a rather high weight and bulk for the ammo they fire, but they can fire it extremely fast.  The 40mm AC can fire shells with sufficient space for a useful payload, and can get decent penetration with proper rounds"
	AC40mm.model = "models/autocannon/autocannon_40mm.mdl"
	AC40mm.caliber = 4.0
	AC40mm.gunclass = "AC"
	AC40mm.weight = 1500
	AC40mm.year = 1940
		AC40mm.round = {}
		AC40mm.round.id = "40mmAC"
		AC40mm.round.maxlength = 45
		AC40mm.round.propweight = 0.9
	AC40mm.rofmod = 0.92
	AC40mm.magsize = 30
	AC40mm.magreload = 3
	if ( CLIENT ) then
		AC40mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		AC40mm.guiupdate = function() return end
	end
GunTable["40mmAC"] = AC40mm
	
local AC50mm = {}
	AC50mm.id = "50mmAC"
	AC50mm.ent = "acf_gun"
	AC50mm.type = "Guns"
	AC50mm.name = "50mm Autocannon"
	AC50mm.desc = "Autocannons have a rather high weight and bulk for the ammo they fire, but they can fire it extremely fast.  The 50mm AC fires shells comparable with the 50mm Cannon, making it capable of destroying light armour quite quickly"
	AC50mm.model = "models/autocannon/autocannon_50mm.mdl"
	AC50mm.caliber = 5.0
	AC50mm.gunclass = "AC"
	AC50mm.weight = 2130
	AC50mm.year = 1965
		AC50mm.round = {}
		AC50mm.round.id = "50mmAC"
		AC50mm.round.maxlength = 52
		AC50mm.round.propweight = 1.2
	AC50mm.rofmod = 0.9
	AC50mm.magsize = 20
	AC50mm.magreload = 3
	if ( CLIENT ) then
		AC50mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		AC50mm.guiupdate = function() return end
	end
GunTable["50mmAC"] = AC50mm

--Semi auto cannons
local SA25mm = {}
	SA25mm.id = "25mmSA"
	SA25mm.ent = "acf_gun"
	SA25mm.type = "Guns"
	SA25mm.name = "25mm Semiautomatic Cannon"
	SA25mm.desc = "Semiautomatic cannons offer better payloads than autocannons and less weight at the cost of rate of fire.  The 25mm semiauto can quickly put five rounds downrange, being lethal, yet light."
	SA25mm.model = "models/autocannon/semiautocannon_25mm.mdl"
	SA25mm.caliber = 2.5
	SA25mm.gunclass = "SA"
	SA25mm.weight = 200
	SA25mm.year = 1935
		SA25mm.round = {}
		SA25mm.round.id = "25mmSA"
		SA25mm.round.maxlength = 39
		SA25mm.round.propweight = 0.5
	SA25mm.rofmod = 1
	SA25mm.magsize = 5
	SA25mm.magreload = 2
	if ( CLIENT ) then
		SA25mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		SA25mm.guiupdate = function() return end
	end
GunTable["25mmSA"] = SA25mm
	
local SA37mm = {}
	SA37mm.id = "37mmSA"
	SA37mm.ent = "acf_gun"
	SA37mm.type = "Guns"
	SA37mm.name = "37mm Semiautomatic Cannon"
	SA37mm.desc = "Semiautomatic cannons offer better payloads than autocannons and less weight at the cost of rate of fire.  The 37mm is surprisingly powerful, its five-round clips boasting a respectable payload and a high muzzle velocity."
	SA37mm.model = "models/autocannon/semiautocannon_37mm.mdl"
	SA37mm.caliber = 3.7
	SA37mm.gunclass = "SA"
	SA37mm.weight = 480
	SA37mm.year = 1940
		SA37mm.round = {}
		SA37mm.round.id = "37mmSA"
		SA37mm.round.maxlength = 45
		SA37mm.round.propweight = 1.125
	SA37mm.rofmod = 1
	SA37mm.magsize = 5
	SA37mm.magreload = 3.5
	if ( CLIENT ) then
		SA37mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		SA37mm.guiupdate = function() return end
	end
GunTable["37mmSA"] = SA37mm
	
local SA45mm = {}
	SA45mm.id = "45mmSA"
	SA45mm.ent = "acf_gun"
	SA45mm.type = "Guns"
	SA45mm.name = "45mm Semiautomatic Cannon"
	SA45mm.desc = "Semiautomatic cannons offer better payloads than autocannons and less weight at the cost of rate of fire.  The 45mm can easily shred light armor, with a respectable rate of fire, but its armor penetration pales in comparison to regular cannons."
	SA45mm.model = "models/autocannon/semiautocannon_45mm.mdl"
	SA45mm.caliber = 4.5
	SA45mm.gunclass = "SA"
	SA45mm.weight = 870
	SA45mm.year = 1965
		SA45mm.round = {}
		SA45mm.round.id = "45mmSA"
		SA45mm.round.maxlength = 52
		SA45mm.round.propweight = 1.8
	SA45mm.rofmod = 1
	SA45mm.magsize = 5
	SA45mm.magreload = 4
	if ( CLIENT ) then
		SA45mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		SA45mm.guiupdate = function() return end
	end
GunTable["45mmSA"] = SA45mm

local SA57mm = {}
	SA57mm.id = "57mmSA"
	SA57mm.ent = "acf_gun"
	SA57mm.type = "Guns"
	SA57mm.name = "57mm Semiautomatic Cannon"
	SA57mm.desc = "Semiautomatic cannons offer better payloads than autocannons and less weight at the cost of rate of fire. The 57mm offers the closest thing to a tank cannon, but still lacking in power."
	SA57mm.model = "models/autocannon/semiautocannon_57mm.mdl"
	SA57mm.caliber = 5.7
	SA57mm.gunclass = "SA"
	SA57mm.weight = 1560
	SA57mm.year = 1965
		SA57mm.round = {}
		SA57mm.round.id = "57mmSA"
		SA57mm.round.maxlength = 62
		SA57mm.round.propweight = 2
	SA57mm.rofmod = 1
	SA57mm.magsize = 5
	SA57mm.magreload = 4.5
	if ( CLIENT ) then
		SA57mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		SA57mm.guiupdate = function() return end
	end
GunTable["57mmSA"] = SA57mm

--12.7mmRAC--
--[[
local RAC127mm = {}
	RAC127mm.id = "12.7mmRAC"
	RAC127mm.ent = "acf_gun"
	RAC127mm.type = "Guns"
	RAC127mm.name = "12.7mm Rotary Autocannon"
	RAC127mm.desc = "Small RAC for light combat vehicles, won't do much against heavier targets, but should chew up light vehicles."
	RAC127mm.model = "models/rotarycannon/rotarycannon_127mm.mdl"
	RAC127mm.caliber = 1.27
	RAC127mm.gunclass = "RAC"
	RAC127mm.weight = 760
	RAC127mm.year = 1965
		RAC127mm.round = {}
		RAC127mm.round.id = "12.7mmRAC"
		RAC127mm.round.maxlength = 17
		RAC127mm.round.propweight = 0.076
	RAC127mm.magsize = 25
	RAC127mm.magreload = 1.5
	RAC127mm.rofmod = 1.1
	if ( CLIENT ) then
		RAC127mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		RAC127mm.guiupdate = function() return end
	end
GunTable["12.7mmRAC"] = RAC127mm
]]--	

local RAC20mm = {}
	RAC20mm.id = "20mmRAC"
	RAC20mm.ent = "acf_gun"
	RAC20mm.type = "Guns"
	RAC20mm.name = "20mm Rotary Autocannon"
	RAC20mm.desc = "Rotary Autocannons sacrifice weight, bulk and accuracy over classic Autocannons to get the highest rate of fire possible.  The 20mm is the lighter of the pair, with decent penetration, but still able to chew up armor or put up a big flak screen.  Mounted on ground attack aircraft and occasionally APCs, to be used against aircraft."
	RAC20mm.model = "models/rotarycannon/rotarycannon_20mm.mdl"
	RAC20mm.caliber = 2.0
	RAC20mm.gunclass = "RAC"
	RAC20mm.weight = 1260
	RAC20mm.year = 1965
		RAC20mm.round = {}
		RAC20mm.round.id = "20mmRAC"
		RAC20mm.round.maxlength = 28
		RAC20mm.round.propweight = 0.12
	RAC20mm.magsize = 25
	RAC20mm.magreload = 1.5
	if ( CLIENT ) then
		RAC20mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		RAC20mm.guiupdate = function() return end
	end
GunTable["20mmRAC"] = RAC20mm

local RAC30mm = {}
	RAC30mm.id = "30mmRAC"
	RAC30mm.ent = "acf_gun"
	RAC30mm.type = "Guns"
	RAC30mm.name = "30mm Rotary Autocannon"
	RAC30mm.desc = "Rotary Autocannons sacrifice weight, bulk and accuracy over classic Autocannons to get the highest rate of fire possible.  The 30mm is the bane of ground-attack aircraft, able to tear up thin armor without giving one single fuck.  Seen in the skies above dead T-72s."
	RAC30mm.model = "models/rotarycannon/rotarycannon_30mm.mdl"
	RAC30mm.caliber = 3.0
	RAC30mm.gunclass = "RAC"
	RAC30mm.weight = 3680
	RAC30mm.year = 1975
		RAC30mm.round = {}
		RAC30mm.round.id = "30mmRAC"
		RAC30mm.round.maxlength = 39
		RAC30mm.round.propweight = 0.350
	RAC30mm.magsize = 25
	RAC30mm.magreload = 1.5
	if ( CLIENT ) then
		RAC30mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		RAC30mm.guiupdate = function() return end
	end
GunTable["30mmRAC"] = RAC30mm
--Autoloaders

local AL100mm = {}
	AL100mm.id = "100mmAL"
	AL100mm.ent = "acf_gun"
	AL100mm.type = "Guns"
	AL100mm.name = "100mm Autoloading Cannon"
	AL100mm.desc = "Fast firing, high velocity gun, however bulky and heavy.  The 100mm is good for rapidly hitting medium armor, then running like your ass is on fire to reload"
	AL100mm.model = "models/tankgun/tankgun_al_100mm.mdl"
	AL100mm.caliber = 10.0
	AL100mm.gunclass = "AL"
	AL100mm.weight = 3750
	AL100mm.year = 1956
	-- new stuff
	AL100mm.rofmod = 0.8
	AL100mm.magsize = 6
	AL100mm.magreload = 18
	--
		AL100mm.round = {}
		AL100mm.round.id = "100mmAL"
		AL100mm.round.maxlength = 93
		AL100mm.round.propweight = 9.5
	if ( CLIENT ) then
		AL100mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		AL100mm.guiupdate = function() return end
	end
GunTable["100mmAL"] = AL100mm

local AL120mm = {}
	AL120mm.id = "120mmAL"
	AL120mm.ent = "acf_gun"
	AL120mm.type = "Guns"
	AL120mm.name = "120mm Autoloading Cannon"
	AL120mm.desc = "Fast firing, high velocity gun, however bulky and heavy.  The 120mm autoloader can do serious damage before reloading, but the reload time is killer."
	AL120mm.model = "models/tankgun/tankgun_al_120mm.mdl"
	AL120mm.caliber = 12.0
	AL120mm.gunclass = "AL"
	AL120mm.weight = 6200
	AL120mm.year = 1956
	-- new stuff
	AL120mm.rofmod = 0.8
	AL120mm.magsize = 4
	AL120mm.magreload = 27
	--
		AL120mm.round = {}
		AL120mm.round.id = "120mmAL"
		AL120mm.round.maxlength = 110
		AL120mm.round.propweight = 18
	if ( CLIENT ) then
		AL120mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		AL120mm.guiupdate = function() return end
	end
GunTable["120mmAL"] = AL120mm	

local AL140mm = {}
	AL140mm.id = "140mmAL"
	AL140mm.ent = "acf_gun"
	AL140mm.type = "Guns"
	AL140mm.name = "140mm Autoloading Cannon"
	AL140mm.desc = "Fast firing, high velocity gun, however bulky and heavy.  The 140mm can shred a medium tank's armor with one magazine, and even function as shoot & scoot artillery, with its useful HE payload."
	AL140mm.model = "models/tankgun/tankgun_al_140mm.mdl"
	AL140mm.caliber = 14.0
	AL140mm.gunclass = "AL"
	AL140mm.weight = 9180
	AL140mm.year = 1970
	-- new stuff
	AL140mm.rofmod = 0.8
	AL140mm.magsize = 4
	AL140mm.magreload = 35
	--
		AL140mm.round = {}
		AL140mm.round.id = "140mmAL"
		AL140mm.round.maxlength = 127
		AL140mm.round.propweight = 28
	if ( CLIENT ) then
		AL140mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		AL140mm.guiupdate = function() return end
	end
GunTable["140mmAL"] = AL140mm	
--[[
--170mmAL--
local AL170mm = {}
	AL170mm.id = "170mmAL"
	AL170mm.ent = "acf_gun"
	AL170mm.type = "Guns"
	AL170mm.name = "170mm Autoloading Cannon"
	AL170mm.desc = "Fast firing, high velocity gun, however bulky, heavy and slow to reload.  The 170mm can shred an average 40ton tank's armor with one magazine."
	AL170mm.model = "models/tankgun/tankgun_al_170mm.mdl"
	AL170mm.caliber = 17.0
	AL170mm.gunclass = "AL"
	AL170mm.weight = 13350
	AL170mm.year = 1970
	-- new stuff
	AL170mm.rofmod = 0.8
	AL170mm.magsize = 4
	AL170mm.magreload = 40
	--
		AL170mm.round = {}
		AL170mm.round.id = "170mmAL"
		AL170mm.round.maxlength = 154
		AL170mm.round.propweight = 34
	if ( CLIENT ) then
		AL170mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		AL170mm.guiupdate = function() return end
	end
GunTable["170mmAL"] = AL170mm	
]]--

local AL75mm = {}
	AL75mm.id = "75mmAL"
	AL75mm.ent = "acf_gun"
	AL75mm.type = "Guns"
	AL75mm.name = "75mm Autoloading Cannon"
	AL75mm.desc = "Fast firing, high velocity gun, however bulky and heavy.  A quick-firing 75mm gun, pops off a number of rounds in relatively short order."
	AL75mm.model = "models/tankgun/tankgun_al_75mm.mdl"
	AL75mm.caliber = 7.5
	AL75mm.gunclass = "AL"
	AL75mm.weight = 2420
	AL75mm.year = 1946
	-- new stuff
	AL75mm.rofmod = 0.8
	AL75mm.magsize = 6
	AL75mm.magreload = 14
	--
		AL75mm.round = {}
		AL75mm.round.id = "75mmAL"
		AL75mm.round.maxlength = 78
		AL75mm.round.propweight = 3.8
	if ( CLIENT ) then
		AL75mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		AL75mm.guiupdate = function() return end
	end
GunTable["75mmAL"] = AL75mm

local Gun37mm = {}
        Gun37mm.id = "37mmC"
        Gun37mm.ent = "acf_gun"
        Gun37mm.type = "Guns"
        Gun37mm.name = "37mm Tank Gun"
        Gun37mm.desc = "High velocity guns that can fire very powerful ammunition, but are rather slow to reload.  A light and fairly weak cannon with good accuracy."
        Gun37mm.model = "models/tankgun/tankgun_37mm.mdl"
        Gun37mm.caliber = 3.7
        Gun37mm.gunclass = "C"
        Gun37mm.weight = 350
        Gun37mm.year = 1919
        Gun37mm.rofmod = 1.4
        Gun37mm.sound = "weapons/ACF_Gun/ac_fire4.wav"
                Gun37mm.round = {}
                Gun37mm.round.id = "37mmC"
                Gun37mm.round.maxlength = 45
                Gun37mm.round.propweight = 1.125
        if ( CLIENT ) then
                Gun37mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
                Gun37mm.guiupdate = function() return end
        end
GunTable["37mmC"] = Gun37mm

local Gun50mm = {}
	Gun50mm.id = "50mmC"
	Gun50mm.ent = "acf_gun"
	Gun50mm.type = "Guns"
	Gun50mm.name = "50mm Cannon"
	Gun50mm.desc = "High velocity guns that can fire very powerful ammunition, but are rather slow to reload.  The 50mm is surprisingly fast-firing, with good effectiveness against light armor, but a pea-shooter compared to its bigger cousins"
	Gun50mm.model = "models/tankgun/tankgun_50mm.mdl"
	Gun50mm.caliber = 5.0
	Gun50mm.gunclass = "C"
	Gun50mm.weight = 665
	Gun50mm.year = 1935
	Gun50mm.sound = "weapons/ACF_Gun/ac_fire4.wav"
		Gun50mm.round = {}
		Gun50mm.round.id = "50mmC"
		Gun50mm.round.maxlength = 63
		Gun50mm.round.propweight = 2.1
	if ( CLIENT ) then
		Gun50mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		Gun50mm.guiupdate = function() return end
	end
GunTable["50mmC"] = Gun50mm
	
local Gun75mm = {}
	Gun75mm.id = "75mmC"
	Gun75mm.ent = "acf_gun"
	Gun75mm.type = "Guns"
	Gun75mm.name = "75mm Cannon"
	Gun75mm.desc = "High velocity guns that can fire very powerful ammunition, but are rather slow to reload.  The 75mm is still rather respectable in rate of fire, but has only modest payload.  Often found on the Eastern Front, and on cold war light tanks."
	Gun75mm.model = "models/tankgun/tankgun_75mm.mdl"
	Gun75mm.caliber = 7.5
	Gun75mm.gunclass = "C"
	Gun75mm.weight = 1420
	Gun75mm.year = 1942
		Gun75mm.round = {}
		Gun75mm.round.id = "75mmC"
		Gun75mm.round.maxlength = 78
		Gun75mm.round.propweight = 3.8
	if ( CLIENT ) then
		Gun75mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		Gun75mm.guiupdate = function() return end
	end
GunTable["75mmC"] = Gun75mm
	
local Gun100mm = {}
	Gun100mm.id = "100mmC"
	Gun100mm.ent = "acf_gun"
	Gun100mm.type = "Guns"
	Gun100mm.name = "100mm Cannon"
	Gun100mm.desc = "High velocity guns that can fire very powerful ammunition, but are rather slow to reload.  The 100mm was a benchmark for the early cold war period, and has great muzzle velocity and hitting power, while still boasting a respectable, if small, payload."
	Gun100mm.model = "models/tankgun/tankgun_100mm.mdl"
	Gun100mm.caliber = 10.0
	Gun100mm.gunclass = "C"
	Gun100mm.weight = 2750
	Gun100mm.year = 1944
		Gun100mm.round = {}
		Gun100mm.round.id = "100mmC"
		Gun100mm.round.maxlength = 93
		Gun100mm.round.propweight = 9.5
	if ( CLIENT ) then
		Gun100mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		Gun100mm.guiupdate = function() return end
	end
GunTable["100mmC"] = Gun100mm
	
local Gun120mm = {}
	Gun120mm.id = "120mmC"
	Gun120mm.ent = "acf_gun"
	Gun120mm.type = "Guns"
	Gun120mm.name = "120mm Cannon"
	Gun120mm.desc = "High velocity guns that can fire very powerful ammunition, but are rather slow to reload.  Often found in MBTs, the 120mm shreds lighter armor with utter impunity, and is formidable against even the big boys."
	Gun120mm.model = "models/tankgun/tankgun_120mm.mdl"
	Gun120mm.caliber = 12.0
	Gun120mm.gunclass = "C"
	Gun120mm.weight = 5200
	Gun120mm.year = 1955
		Gun120mm.round = {}
		Gun120mm.round.id = "120mmC"
		Gun120mm.round.maxlength = 110
		Gun120mm.round.propweight = 18
	if ( CLIENT ) then
		Gun120mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		Gun120mm.guiupdate = function() return end
	end
GunTable["120mmC"] = Gun120mm	
	
local Gun140mm = {}
	Gun140mm.id = "140mmC"
	Gun140mm.ent = "acf_gun"
	Gun140mm.type = "Guns"
	Gun140mm.name = "140mm Cannon"
	Gun140mm.desc = "High velocity guns that can fire very powerful ammunition, but are rather slow to reload. The 140mm fires a massive shell with enormous penetrative capability, but has a glacial reload speed and a very hefty weight."
	Gun140mm.model = "models/tankgun/tankgun_140mm.mdl"
	Gun140mm.caliber = 14.0
	Gun140mm.gunclass = "C"
	Gun140mm.weight = 8180
	Gun140mm.year = 1990
		Gun140mm.round = {}
		Gun140mm.round.id = "140mmC"
		Gun140mm.round.maxlength = 127
		Gun140mm.round.propweight = 28
	if ( CLIENT ) then
		Gun140mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		Gun140mm.guiupdate = function() return end
	end
GunTable["140mmC"] = Gun140mm

--[[
--170mmC--
local Gun170mm = {}
	Gun170mm.id = "170mmC"
	Gun170mm.ent = "acf_gun"
	Gun170mm.type = "Guns"
	Gun170mm.name = "170mm Cannon"
	Gun170mm.desc = "High velocity guns that can fire very powerful ammunition, but are rather slow to reload. The 170mm fires a gigantic shell with ginormous penetrative capability, but has a glacial reload speed and an extremely hefty weight."
	Gun170mm.model = "models/tankgun/tankgun_170mm.mdl"
	Gun170mm.caliber = 17.0
	Gun170mm.gunclass = "C"
	Gun170mm.weight = 12350
	Gun170mm.year = 1990
		Gun170mm.round = {}
		Gun170mm.round.id = "170mmC"
		Gun170mm.round.maxlength = 154
		Gun170mm.round.propweight = 34
	if ( CLIENT ) then
		Gun170mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		Gun170mm.guiupdate = function() return end
	end
GunTable["170mmC"] = Gun170mm
]]--	

local How75mm = {}
	How75mm.id = "75mmHW"
	How75mm.ent = "acf_gun"
	How75mm.type = "Guns"
	How75mm.name = "75mm Howitzer"
	How75mm.desc = "Howitzers are limited to rather mediocre muzzle velocities, but can fire extremely heavy projectiles with large usefull payload capacities.  Often found being towed by large smelly animals, the 75mm has a high rate of fire, and is surprisingly lethal against light armor.  Great for a sustained barrage against someone you really don't like."
	How75mm.model = "models/howitzer/howitzer_75mm.mdl"
	How75mm.caliber = 7.5
	How75mm.gunclass = "HW"
	How75mm.weight = 530
	How75mm.year = 1900
		How75mm.round = {}
		How75mm.round.id = "75mmHW"
		How75mm.round.maxlength = 60
		How75mm.round.propweight = 1.8
	if ( CLIENT ) then
		How75mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		How75mm.guiupdate = function() return end
	end
GunTable["75mmHW"] = How75mm
	
local How105mm = {}
	How105mm.id = "105mmHW"
	How105mm.ent = "acf_gun"
	How105mm.type = "Guns"
	How105mm.name = "105mm Howitzer"
	How105mm.desc = "Howitzers are limited to rather mediocre muzzle velocities, but can fire extremely heavy projectiles with large usefull payload capacities.  The 105 lobs a big shell far, and its HEAT rounds can be extremely effective against even heavier armor."
	How105mm.model = "models/howitzer/howitzer_105mm.mdl"
	How105mm.caliber = 10.5
	How105mm.gunclass = "HW"
	How105mm.weight = 1810
	How105mm.year = 1900
		How105mm.round = {}
		How105mm.round.id = "105mmHW"
		How105mm.round.maxlength = 84
		How105mm.round.propweight = 2.9
	if ( CLIENT ) then
		How105mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		How105mm.guiupdate = function() return end
	end
GunTable["105mmHW"] = How105mm

local How122mm = {}
	How122mm.id = "122mmHW"
	How122mm.ent = "acf_gun"
	How122mm.type = "Guns"
	How122mm.name = "122mm Howitzer"
	How122mm.desc = "Howitzers are limited to rather mediocre muzzle velocities, but can fire extremely heavy projectiles with large usefull payload capacities.  The 122mm bridges the gap between the 105 and the 155, providing a lethal round with a big splash radius."
	How122mm.model = "models/howitzer/howitzer_122mm.mdl"
	How122mm.caliber = 12.2
	How122mm.gunclass = "HW"
	How122mm.weight = 3520
	How122mm.year = 1900
		How122mm.round = {}
		How122mm.round.id = "122mmHW"
		How122mm.round.maxlength = 104
		How122mm.round.propweight = 6
	if ( CLIENT ) then
		How122mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		How122mm.guiupdate = function() return end
	end
GunTable["122mmHW"] = How122mm
	
local How155mm = {}
	How155mm.id = "155mmHW"
	How155mm.ent = "acf_gun"
	How155mm.type = "Guns"
	How155mm.name = "155mm Howitzer"
	How155mm.desc = "Howitzers are limited to rather mediocre muzzle velocities, but can fire extremely heavy projectiles with large usefull payload capacities.  The 155 is a classic heavy artillery round, with good reason.  A versatile weapon, it's found on most modern SPGs."
	How155mm.model = "models/howitzer/howitzer_155mm.mdl"
	How155mm.caliber = 15.5
	How155mm.gunclass = "HW"
	How155mm.weight = 5340
	How155mm.year = 1900
		How155mm.round = {}
		How155mm.round.id = "155mmHW"
		How155mm.round.maxlength = 124
		How155mm.round.propweight = 13.5
	if ( CLIENT ) then
		How155mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		How155mm.guiupdate = function() return end
	end
GunTable["155mmHW"] = How155mm
	
local How203mm = {}
	How203mm.id = "203mmHW"
	How203mm.ent = "acf_gun"
	How203mm.type = "Guns"
	How203mm.name = "203mm Howitzer"
	How203mm.desc = "An 8-inch deck gun, found on siege artillery and cruisers."
	How203mm.model = "models/howitzer/howitzer_203mm.mdl"
	How203mm.caliber = 20.3
	How203mm.gunclass = "HW"
	How203mm.weight = 10280
	How203mm.year = 1900
		How203mm.round = {}
		How203mm.round.id = "203mmHW"
		How203mm.round.maxlength = 162.4
		How203mm.round.propweight = 28.5
	if ( CLIENT ) then
		How203mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		How203mm.guiupdate = function() return end
	end
GunTable["203mmHW"] = How203mm

--[[
--240mmHW--	
local How240mm = {}
	How240mm.id = "240mmHW"
	How240mm.ent = "acf_gun"
	How240mm.type = "Guns"
	How240mm.name = "240mm Howitzer"
	How240mm.desc = "An 9.4-inch deck gun, found on heavy siege artillery and cruisers."
	How240mm.model = "models/howitzer/howitzer_240mm.mdl"
	How240mm.caliber = 24.0
	How240mm.gunclass = "HW"
	How240mm.weight = 12980
	How240mm.year = 1900
		How240mm.round = {}
		How240mm.round.id = "240mmHW"
		How240mm.round.maxlength = 192.0
		How240mm.round.propweight = 33.7
	if ( CLIENT ) then
		How240mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		How240mm.guiupdate = function() return end
	end
GunTable["240mmHW"] = How240mm

--290mmHW--
local How290mm = {}
	How290mm.id = "290mmHW"
	How290mm.ent = "acf_gun"
	How290mm.type = "Guns"
	How290mm.name = "290mm Howitzer"
	How290mm.desc = " Mother of all howitzers. This 12in beast can be found on battleships. It WILL fuck your day up... when it reloads."
	How290mm.model = "models/howitzer/howitzer_406mm.mdl"
	How290mm.caliber = 29
	How290mm.gunclass = "HW"
	How290mm.weight = 24960
	How290mm.year = 1900
		How290mm.round = {}
		How290mm.round.id = "290mmHW"
		How290mm.round.maxlength = 325
		How290mm.round.propweight = 57.0
	if ( CLIENT ) then
		How290mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		How290mm.guiupdate = function() return end
	end
GunTable["290mmHW"] = How290mm
]]--	
--our new short guns--

local ShortGun37mm = {}
	ShortGun37mm.id = "37mmSC"
	ShortGun37mm.ent = "acf_gun"
	ShortGun37mm.type = "Guns"
	ShortGun37mm.name = "37mm Short Cannon"
	ShortGun37mm.desc = "Short cannons trade muzzle velocity and accuracy for lighter weight and smaller size, with more penetration than howitzers and lighter than cannons.  Quick-firing and light, but penetration is laughable.  You're better off throwing rocks."
	ShortGun37mm.model = "models/tankgun/tankgun_short_37mm.mdl"
	ShortGun37mm.caliber = 3.7
	ShortGun37mm.gunclass = "SC"
	ShortGun37mm.weight = 200
	ShortGun37mm.year = 1915
	ShortGun37mm.sound = "weapons/ACF_Gun/ac_fire4.wav"
		ShortGun37mm.round = {}
		ShortGun37mm.round.id = "37mmSC"
		ShortGun37mm.round.maxlength = 45
		ShortGun37mm.round.propweight = 0.29
	if ( CLIENT ) then
		ShortGun37mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		ShortGun37mm.guiupdate = function() return end
	end
GunTable["37mmSC"] = ShortGun37mm

local ShortGun50mm = {}
	ShortGun50mm.id = "50mmSC"
	ShortGun50mm.ent = "acf_gun"
	ShortGun50mm.type = "Guns"
	ShortGun50mm.name = "50mm Short Cannon"
	ShortGun50mm.desc = "Short cannons trade muzzle velocity and accuracy for lighter weight and smaller size, with more penetration than howitzers and lighter than cannons.  The 50mm is a quick-firing pea-shooter, good for scouts, and common on old interwar tanks."
	ShortGun50mm.model = "models/tankgun/tankgun_short_50mm.mdl"
	ShortGun50mm.caliber = 5.0
	ShortGun50mm.gunclass = "SC"
	ShortGun50mm.weight = 330
	ShortGun50mm.year = 1915
	ShortGun50mm.sound = "weapons/ACF_Gun/ac_fire4.wav"
		ShortGun50mm.round = {}
		ShortGun50mm.round.id = "50mmSC"
		ShortGun50mm.round.maxlength = 63
		ShortGun50mm.round.propweight = 0.6
	if ( CLIENT ) then
		ShortGun50mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		ShortGun50mm.guiupdate = function() return end
	end
GunTable["50mmSC"] = ShortGun50mm

local ShortGun75mm = {}
	ShortGun75mm.id = "75mmSC"
	ShortGun75mm.ent = "acf_gun"
	ShortGun75mm.type = "Guns"
	ShortGun75mm.name = "75mm Short Cannon"
	ShortGun75mm.desc = "Short cannons trade muzzle velocity and accuracy for lighter weight and smaller size, with more penetration than howitzers and lighter than cannons.  The 75mm is common WW2 medium tank armament, and still useful in many other applications."
	ShortGun75mm.model = "models/tankgun/tankgun_short_75mm.mdl"
	ShortGun75mm.caliber = 7.5
	ShortGun75mm.gunclass = "SC"
	ShortGun75mm.weight = 750
	ShortGun75mm.year = 1936
		ShortGun75mm.round = {}
		ShortGun75mm.round.id = "75mmSC"
		ShortGun75mm.round.maxlength = 76
		ShortGun75mm.round.propweight = 2
	if ( CLIENT ) then
		ShortGun75mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		ShortGun75mm.guiupdate = function() return end
	end
GunTable["75mmSC"] = ShortGun75mm

local ShortGun100mm = {}
	ShortGun100mm.id = "100mmSC"
	ShortGun100mm.ent = "acf_gun"
	ShortGun100mm.type = "Guns"
	ShortGun100mm.name = "100mm Short Cannon"
	ShortGun100mm.desc = "Short cannons trade muzzle velocity and accuracy for lighter weight and smaller size, with more penetration than howitzers and lighter than cannons.  The 100mm is an effective infantry-support or antitank weapon, with a lot of uses and surprising lethality."
	ShortGun100mm.model = "models/tankgun/tankgun_short_100mm.mdl"
	ShortGun100mm.caliber = 10.0
	ShortGun100mm.gunclass = "SC"
	ShortGun100mm.weight = 1750
	ShortGun100mm.year = 1940
		ShortGun100mm.round = {}
		ShortGun100mm.round.id = "100mmSC"
		ShortGun100mm.round.maxlength = 93
		ShortGun100mm.round.propweight = 4.5
	if ( CLIENT ) then
		ShortGun100mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		ShortGun100mm.guiupdate = function() return end
	end
GunTable["100mmSC"] = ShortGun100mm

local ShortGun120mm = {}
	ShortGun120mm.id = "120mmSC"
	ShortGun120mm.ent = "acf_gun"
	ShortGun120mm.type = "Guns"
	ShortGun120mm.name = "120mm Short Cannon"
	ShortGun120mm.desc = "Short cannons trade muzzle velocity and accuracy for lighter weight and smaller size, with more penetration than howitzers and lighter than cannons.  The 120mm is a formidable yet lightweight weapon, with excellent performance against larger vehicles."
	ShortGun120mm.model = "models/tankgun/tankgun_short_120mm.mdl"
	ShortGun120mm.caliber = 12.0
	ShortGun120mm.gunclass = "SC"
	ShortGun120mm.weight = 4200
	ShortGun120mm.year = 1944
		ShortGun120mm.round = {}
		ShortGun120mm.round.id = "120mmSC"
		ShortGun120mm.round.maxlength = 110
		ShortGun120mm.round.propweight = 8.5
	if ( CLIENT ) then
		ShortGun120mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		ShortGun120mm.guiupdate = function() return end
	end
GunTable["120mmSC"] = ShortGun120mm	

local ShortGun140mm = {}
	ShortGun140mm.id = "140mmSC"
	ShortGun140mm.ent = "acf_gun"
	ShortGun140mm.type = "Guns"
	ShortGun140mm.name = "140mm Short Cannon"
	ShortGun140mm.desc = "Short cannons trade muzzle velocity and accuracy for lighter weight and smaller size, with more penetration than howitzers and lighter than cannons.  A specialized weapon, developed from dark magic and anti-heavy tank hatred.  Deal with it."
	ShortGun140mm.model = "models/tankgun/tankgun_short_140mm.mdl"
	ShortGun140mm.caliber = 14.0
	ShortGun140mm.gunclass = "SC"
	ShortGun140mm.weight = 7040
	ShortGun140mm.year = 1999
		ShortGun140mm.round = {}
		ShortGun140mm.round.id = "140mmSC"
		ShortGun140mm.round.maxlength = 127
		ShortGun140mm.round.propweight = 12.8
	if ( CLIENT ) then
		ShortGun140mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		ShortGun140mm.guiupdate = function() return end
	end
GunTable["140mmSC"] = ShortGun140mm

local GL40mm = {}
	GL40mm.id = "40mmGL"
	GL40mm.ent = "acf_gun"
	GL40mm.type = "Guns"
	GL40mm.name = "40mm Grenade Machine Gun"
	GL40mm.desc = "Grenade Launchers can fire shells with relatively large payloads at a fast rate, but with very limited velocities and bad accuracy. The 40mm chews up infantry but is about as useful as tits on a nun for fighting armor.  Often found on 4x4s rolling through the third world."
	GL40mm.model = "models/launcher/40mmgl.mdl"
	GL40mm.caliber = 4.0
	GL40mm.gunclass = "GL"
	GL40mm.weight = 55
	GL40mm.year = 1970
		GL40mm.round = {}
		GL40mm.round.id = "40mmGL"
		GL40mm.round.maxlength = 7.5
		GL40mm.round.propweight = 0.01
	if ( CLIENT ) then
		GL40mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		GL40mm.guiupdate = function() return end
	end
GunTable["40mmGL"] = GL40mm

local MO60mm = {}
	MO60mm.id = "60mmM"
	MO60mm.ent = "acf_gun"
	MO60mm.type = "Guns"
	MO60mm.name = "60mm Mortar"
	MO60mm.desc = "Mortars are able to fire shells with usefull payloads from a light weight gun, at the price of limited velocities.  The 60mm is a common light infantry support weapon, with a high rate of fire but a puny payload."
	MO60mm.model = "models/mortar/mortar_60mm.mdl"
	MO60mm.caliber = 6.0
	MO60mm.gunclass = "MO"
	MO60mm.weight = 60
	MO60mm.year = 1930
		MO60mm.round = {}
		MO60mm.round.id = "60mmM"
		MO60mm.round.maxlength = 20
		MO60mm.round.propweight = 0.037 
	if ( CLIENT ) then
		MO60mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		MO60mm.guiupdate = function() return end
	end
GunTable["60mmM"] = MO60mm

local MO80mm = {}
	MO80mm.id = "80mmM"
	MO80mm.ent = "acf_gun"
	MO80mm.type = "Guns"
	MO80mm.name = "80mm Mortar"
	MO80mm.desc = "Mortars are able to fire shells with extremely high usefull payloads from a light weight gun, at the price of a low rate of fire and limited velocities.  The 80mm is a common infantry support weapon, with a good bit more boom than its little cousin."
	MO80mm.model = "models/mortar/mortar_80mm.mdl"
	MO80mm.caliber = 8.0
	MO80mm.gunclass = "MO"
	MO80mm.weight = 120
	MO80mm.year = 1930
		MO80mm.round = {}
		MO80mm.round.id = "80mmM"
		MO80mm.round.maxlength = 28
		MO80mm.round.propweight = 0.055 
	if ( CLIENT ) then
		MO80mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		MO80mm.guiupdate = function() return end
	end
GunTable["80mmM"] = MO80mm
	
local MO120mm = {}
	MO120mm.id = "120mmM"
	MO120mm.ent = "acf_gun"
	MO120mm.type = "Guns"
	MO120mm.name = "120mm Mortar"
	MO120mm.desc = "Mortars are able to fire shells with extremely high useful payloads from a light weight gun, at the price of a low rate of fire and extremely limited velocities.  The versatile 120 is sometimes vehicle-mounted to provide quick boomsplat to support the infantry.  Carries more boom in its boomsplat, has good HEAT performance, and is more accurate in high-angle firing."
	MO120mm.model = "models/mortar/mortar_120mm.mdl"
	MO120mm.caliber = 12.0
	MO120mm.gunclass = "MO"
	MO120mm.weight = 640
	MO120mm.year = 1935
		MO120mm.round = {}
		MO120mm.round.id = "120mmM"
		MO120mm.round.maxlength = 45
		MO120mm.round.propweight = 0.175 
	if ( CLIENT ) then
		MO120mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		MO120mm.guiupdate = function() return end
	end
GunTable["120mmM"] = MO120mm
	

--150mmM--
local MO150mm = {}
	MO150mm.id = "150mmM"
	MO150mm.ent = "acf_gun"
	MO150mm.type = "Guns"
	MO150mm.name = "150mm Mortar"
	MO150mm.desc = "Mortars are able to fire shells with extremely high useful payloads from a light weight gun, at the price of a low rate of fire and extremely limited velocities. The perfect balance between the 120mm and the 200mm. Can prove a worthy main gun weapon, as well as a mighty good mortar emplacement"
	MO150mm.model = "models/mortar/mortar_150mm.mdl"
	MO150mm.caliber = 15.0
	MO150mm.gunclass = "MO"
	MO150mm.weight = 1255
	MO150mm.year = 1945
		MO150mm.round = {}
		MO150mm.round.id = "150mmM"
		MO150mm.round.maxlength = 58
		MO150mm.round.propweight = 0.235 
	if ( CLIENT ) then
		MO150mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		MO150mm.guiupdate = function() return end
	end
GunTable["150mmM"] = MO150mm

local MO200mm = {}
	MO200mm.id = "200mmM"
	MO200mm.ent = "acf_gun"
	MO200mm.type = "Guns"
	MO200mm.name = "200mm Mortar"
	MO200mm.desc = "Mortars are able to fire shells with extremely high useful payloads from a light weight gun, at the price of a low rate of fire and extremely limited velocities. The 200mm is a beast, often used against fortifications.  Though enormously powerful, feel free to take a nap while it reloads"
	MO200mm.model = "models/mortar/mortar_200mm.mdl"
	MO200mm.caliber = 20.0
	MO200mm.gunclass = "MO"
	MO200mm.weight = 2850
	MO200mm.year = 1940
		MO200mm.round = {}
		MO200mm.round.id = "200mmM"
		MO200mm.round.maxlength = 80
		MO200mm.round.propweight = 0.330 
	if ( CLIENT ) then
		MO200mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		MO200mm.guiupdate = function() return end
	end
GunTable["200mmM"] = MO200mm

--[[280mmM--
local MO280mm = {}
	MO280mm.id = "280mmM"
	MO280mm.ent = "acf_gun"
	MO280mm.type = "Guns"
	MO280mm.name = "280mm Mortar"
	MO280mm.desc = "Mortars are able to fire shells with extremely high useful payloads from a light weight gun, at the price of a low rate of fire and extremely limited velocities. Massive payload, with a reload time to match. Found in rare WW2 siege artillery pieces. It's the perfect size for a jeep."
	MO280mm.model = "models/mortar/mortar_280mm.mdl"
	MO280mm.caliber = 28.0
	MO280mm.gunclass = "MO"
	MO280mm.weight = 9035
	MO280mm.year = 1945
		MO280mm.round = {}
		MO280mm.round.id = "280mmM"
		MO280mm.round.maxlength = 138
		MO280mm.round.propweight = 0.462 
	if ( CLIENT ) then
		MO280mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		MO280mm.guiupdate = function() return end
	end
GunTable["280mmM"] = MO280mm
]]--

local SL40mm = {}
	SL40mm.id = "40mmSL"
	SL40mm.ent = "acf_gun"
	SL40mm.type = "Guns"
	SL40mm.name = "40mm Smoke Launcher"
	SL40mm.desc = "Smoke launcher to block an attacker's line of sight"
	SL40mm.model = "models/launcher/40mmgl.mdl"
	SL40mm.caliber = 4.0
	SL40mm.gunclass = "SL"
	SL40mm.weight = 55
	SL40mm.year = 1941
	SL40mm.round = {}
	SL40mm.round.id = "40mmSL"
	SL40mm.round.maxlength = 15
	SL40mm.round.propweight = 0.00005 
		

	if ( CLIENT ) then
		SL40mm.guicreate = (function( Panel, Table ) ACFGunGUICreate( Table ) end or nil)
		SL40mm.guiupdate = function() return end
	end
GunTable["40mmSL"] = SL40mm
	
list.Set( "ACFEnts", "Guns", GunTable )

local GunClass = {}	--Start gun classes listing
-- sound is used for the loudass sounds, soundDistance uses a script for a distance shot, soundNormal is for machineguns so they're not superloud
-- weapon spread is now expressed in degrees as cone radius (therefore half of total spread).
local Machinegun = {}
	Machinegun.spread = 0.16
	Machinegun.name = "Machinegun"
	Machinegun.muzzleflash = "50cal_muzzleflash_noscale"
	Machinegun.rofmod = 0.9
	Machinegun.soundNormal = "weapons/ACF_Gun/mg_fire4.wav"
	Machinegun.sound = "weapons/ACF_Gun/mg_fire4.wav"
	Machinegun.soundDistance = " "
GunClass["MG"] = Machinegun	
	
local Autocannon = {}
	Autocannon.spread = 0.16
	Autocannon.name = "Autocannon"
	Autocannon.muzzleflash = "30mm_muzzleflash_noscale"
	Autocannon.rofmod = 0.35
	Autocannon.sound = "weapons/ACF_Gun/ac_fire4.wav"
	Autocannon.soundDistance = " "
	Autocannon.soundNormal = " "
	
GunClass["AC"] = Autocannon

local Semiautomatic = {}
	Semiautomatic.spread = 0.08
	Semiautomatic.name = "Semiautomatic Cannon"
	Semiautomatic.muzzleflash = "30mm_muzzleflash_noscale"
	Semiautomatic.rofmod = 0.5
	Semiautomatic.sound = "acf_extra/tankfx/gnomefather/25mm1.wav"
	Semiautomatic.soundDistance = " "
	Semiautomatic.soundNormal = " "
		
GunClass["SA"] = Semiautomatic

local HeavyMachinegun = {}
	HeavyMachinegun.spread = 0.32
	HeavyMachinegun.name = "Heavy Machinegun"
	HeavyMachinegun.muzzleflash = "50cal_muzzleflash_noscale"
	HeavyMachinegun.rofmod = 0.29
	HeavyMachinegun.sound = "weapons/ACF_Gun/mg_fire3.wav"
	HeavyMachinegun.soundDistance = " "
	HeavyMachinegun.soundNormal = " "
GunClass["HMG"] = HeavyMachinegun

local Gatling = {}
	Gatling.spread = 0.48
	Gatling.name = "Rotary Autocannon"
	Gatling.muzzleflash = "50cal_muzzleflash_noscale"
	Gatling.rofmod = 0.07
	Gatling.sound = "weapons/ACF_Gun/rac_fire2.wav"
	Gatling.soundDistance = " "
	Gatling.soundNormal = " "
GunClass["RAC"] = Gatling
	
local Cannon = {}
	Cannon.spread = 0.08
	Cannon.name = "Cannon"
	Cannon.muzzleflash = "120mm_muzzleflash_noscale"
	Cannon.rofmod = 1.5
	Cannon.sound = "weapons/ACF_Gun/cannon_new.wav"
	Cannon.soundDistance = "Cannon.Fire"
	Cannon.soundNormal = " "
GunClass["C"] = Cannon	

local ShortGun= {}
	ShortGun.spread = 0.24
	ShortGun.name = "Short-Barrel Cannon"
	ShortGun.muzzleflash = "120mm_muzzleflash_noscale"
	ShortGun.rofmod = 1.3
	ShortGun.sound = "weapons/ACF_Gun/cannon_new.wav"
	ShortGun.soundDistance = "Cannon.Fire"
	ShortGun.soundNormal = " "
GunClass["SC"] = ShortGun	

local  Autoloader= {}
	Autoloader.spread = 0.08
	Autoloader.name = "Autoloader"
	Autoloader.muzzleflash = "120mm_muzzleflash_noscale"
	Autoloader.rofmod = 0.8
	Autoloader.sound = "weapons/ACF_Gun/autoloader.wav"
	Autoloader.soundDistance = "Cannon.Fire"
	Autoloader.soundNormal = " "
GunClass["AL"] = Autoloader
	
local Howitzer = {}
	Howitzer.spread = 0.12
	Howitzer.name = "Howitzer"
	Howitzer.muzzleflash = "120mm_muzzleflash_noscale"
	Howitzer.rofmod = 1.3
	Howitzer.sound = "weapons/ACF_Gun/howitzer_new2.wav"
	Howitzer.soundDistance = "Howitzer.Fire"
	Howitzer.soundNormal = " "
GunClass["HW"] = Howitzer
	
local Mortar = {}
	Mortar.spread = 0.64
	Mortar.name = "Mortar"
	Mortar.muzzleflash = "40mm_muzzleflash_noscale"
	Mortar.rofmod = 2
	Mortar.sound = "weapons/ACF_Gun/mortar_new.wav"
	Mortar.soundDistance = "Mortar.Fire"
	Mortar.soundNormal = " "
GunClass["MO"] = Mortar	

local GLauncher = {}
	GLauncher.spread = 0.32
	GLauncher.name = "Grenade Launcher"
	GLauncher.muzzleflash = "40mm_muzzleflash_noscale"
	GLauncher.rofmod = 1
	GLauncher.sound = "weapons/grenade_launcher1.wav"
	GLauncher.soundDistance = " "
	GLauncher.soundNormal = " "
GunClass["GL"] = GLauncher	

local SmokeLauncher = {}
	SmokeLauncher.spread = 0.32
	SmokeLauncher.name = "Smoke Launcher"
	SmokeLauncher.muzzleflash = "40mm_muzzleflash_noscale"
	SmokeLauncher.rofmod =  60 --60
	SmokeLauncher.sound = "weapons/ACF_Gun/mortar_new.wav"
	SmokeLauncher.soundDistance = "Mortar.Fire"
	SmokeLauncher.soundNormal = " "
GunClass["SL"] = SmokeLauncher	

list.Set( "ACFClasses", "GunClass", GunClass )	--End gun classes listing

local AmmoTable = {}  --Start ammo containers listing

local AmmoSmall = {}
	AmmoSmall.id = "AmmoSmall"
	AmmoSmall.ent = "acf_ammo"
	AmmoSmall.type = "Ammo"
	AmmoSmall.name = "Small Ammo Crate"
	AmmoSmall.desc = "Small ammo crate\n"
	AmmoSmall.model = "models/ammocrate_small.mdl"
	AmmoSmall.weight = 10
AmmoTable["AmmoSmall"] = AmmoSmall

local AmmoMedCube = {}
	AmmoMedCube.id = "AmmoMedCube"
	AmmoMedCube.ent = "acf_ammo"
	AmmoMedCube.type = "Ammo"
	AmmoMedCube.name = "Medium cubic ammo crate"
	AmmoMedCube.desc = "Medium cubic ammo crate\n"
	AmmoMedCube.model = "models/ammocrate_medium_small.mdl"
	AmmoMedCube.weight = 80
AmmoTable["AmmoMedCube"] = AmmoMedCube
	
local AmmoMedium = {}
	AmmoMedium.id = "AmmoMedium"
	AmmoMedium.ent = "acf_ammo"
	AmmoMedium.type = "Ammo"
	AmmoMedium.name = "Medium Ammo Crate"
	AmmoMedium.desc = "Medium ammo crate\n"
	AmmoMedium.model = "models/ammocrate_medium.mdl"
	AmmoMedium.weight = 150
AmmoTable["AmmoMedium"] = AmmoMedium
	
local AmmoLarge = {}
	AmmoLarge.id = "AmmoLarge"
	AmmoLarge.ent = "acf_ammo"
	AmmoLarge.type = "Ammo"
	AmmoLarge.name = "Large Ammo Crate"
	AmmoLarge.desc = "Large ammo crate\n"
	AmmoLarge.model = "models/ammocrate_large.mdl"
	AmmoLarge.weight = 1000
AmmoTable["AmmoLarge"] = AmmoLarge

local Ammo1x1x8 = {}
	Ammo1x1x8.id = "Ammo1x1x8"
	Ammo1x1x8.ent = "acf_ammo"
	Ammo1x1x8.type = "Ammo"
	Ammo1x1x8.name = "Modular Ammo Crate"
	Ammo1x1x8.desc = "Modular Ammo Crate 1x1x8 Size\n"
	Ammo1x1x8.model = "models/ammocrates/ammo_1x1x8.mdl"
	Ammo1x1x8.weight = 40
AmmoTable["Ammo1x1x8"] = Ammo1x1x8

local Ammo1x1x6 = {}
	Ammo1x1x6.id = "Ammo1x1x6"
	Ammo1x1x6.ent = "acf_ammo"
	Ammo1x1x6.type = "Ammo"
	Ammo1x1x6.name = "Modular Ammo Crate"
	Ammo1x1x6.desc = "Modular Ammo Crate 1x1x6 Size\n"
	Ammo1x1x6.model = "models/ammocrates/ammo_1x1x6.mdl"
	Ammo1x1x6.weight = 30
AmmoTable["Ammo1x1x6"] = Ammo1x1x6

local Ammo1x1x4 = {}
	Ammo1x1x4.id = "Ammo1x1x4"
	Ammo1x1x4.ent = "acf_ammo"
	Ammo1x1x4.type = "Ammo"
	Ammo1x1x4.name = "Modular Ammo Crate"
	Ammo1x1x4.desc = "Modular Ammo Crate 1x1x4 Size\n"
	Ammo1x1x4.model = "models/ammocrates/ammo_1x1x4.mdl"
	Ammo1x1x4.weight = 20
AmmoTable["Ammo1x1x4"] = Ammo1x1x4

local Ammo1x1x2 = {}
	Ammo1x1x2.id = "Ammo1x1x2"
	Ammo1x1x2.ent = "acf_ammo"
	Ammo1x1x2.type = "Ammo"
	Ammo1x1x2.name = "Modular Ammo Crate"
	Ammo1x1x2.desc = "Modular Ammo Crate 1x1x2 Size\n"
	Ammo1x1x2.model = "models/ammocrates/ammo_1x1x2.mdl"
	Ammo1x1x2.weight = 10
AmmoTable["Ammo1x1x2"] = Ammo1x1x2

local Ammo2x2x1 = {}
	Ammo2x2x1.id = "Ammo2x2x1"
	Ammo2x2x1.ent = "acf_ammo"
	Ammo2x2x1.type = "Ammo"
	Ammo2x2x1.name = "Modular Ammo Crate"
	Ammo2x2x1.desc = "Modular Ammo Crate 2x2x1 Size\n"
	Ammo2x2x1.model = "models/ammocrates/ammocrate_2x2x1.mdl"
	Ammo2x2x1.weight = 20
AmmoTable["Ammo2x2x1"] = Ammo2x2x1

local Ammo2x2x2 = {}
	Ammo2x2x2.id = "Ammo2x2x2"
	Ammo2x2x2.ent = "acf_ammo"
	Ammo2x2x2.type = "Ammo"
	Ammo2x2x2.name = "Modular Ammo Crate"
	Ammo2x2x2.desc = "Modular Ammo Crate 2x2x2 Size\n"
	Ammo2x2x2.model = "models/ammocrates/ammocrate_2x2x2.mdl"
	Ammo2x2x2.weight = 40
AmmoTable["Ammo2x2x2"] = Ammo2x2x2

local Ammo2x2x4 = {}
	Ammo2x2x4.id = "Ammo2x2x4"
	Ammo2x2x4.ent = "acf_ammo"
	Ammo2x2x4.type = "Ammo"
	Ammo2x2x4.name = "Modular Ammo Crate"
	Ammo2x2x4.desc = "Modular Ammo Crate 2x2x4 Size\n"
	Ammo2x2x4.model = "models/ammocrates/ammocrate_2x2x4.mdl"
	Ammo2x2x4.weight = 80
AmmoTable["Ammo2x2x4"] = Ammo2x2x4

local Ammo2x2x6 = {}
	Ammo2x2x6.id = "Ammo2x2x6"
	Ammo2x2x6.ent = "acf_ammo"
	Ammo2x2x6.type = "Ammo"
	Ammo2x2x6.name = "Modular Ammo Crate"
	Ammo2x2x6.desc = "Modular Ammo Crate 2x2x6 Size\n"
	Ammo2x2x6.model = "models/ammocrates/ammo_2x2x6.mdl"
	Ammo2x2x6.weight = 120
AmmoTable["Ammo2x2x6"] = Ammo2x2x6

local Ammo2x2x8 = {}
	Ammo2x2x8.id = "Ammo2x2x8"
	Ammo2x2x8.ent = "acf_ammo"
	Ammo2x2x8.type = "Ammo"
	Ammo2x2x8.name = "Modular Ammo Crate"
	Ammo2x2x8.desc = "Modular Ammo Crate 2x2x8 Size\n"
	Ammo2x2x8.model = "models/ammocrates/ammo_2x2x8.mdl"
	Ammo2x2x8.weight = 160
AmmoTable["Ammo2x2x8"] = Ammo2x2x8

local Ammo2x3x1 = {}
	Ammo2x3x1.id = "Ammo2x3x1"
	Ammo2x3x1.ent = "acf_ammo"
	Ammo2x3x1.type = "Ammo"
	Ammo2x3x1.name = "Modular Ammo Crate"
	Ammo2x3x1.desc = "Modular Ammo Crate 2x3x1 Size\n"
	Ammo2x3x1.model = "models/ammocrates/ammocrate_2x3x1.mdl"
	Ammo2x3x1.weight = 30
AmmoTable["Ammo2x3x1"] = Ammo2x3x1

local Ammo2x3x2 = {}
	Ammo2x3x2.id = "Ammo2x3x2"
	Ammo2x3x2.ent = "acf_ammo"
	Ammo2x3x2.type = "Ammo"
	Ammo2x3x2.name = "Modular Ammo Crate"
	Ammo2x3x2.desc = "Modular Ammo Crate 2x3x2 Size\n"
	Ammo2x3x2.model = "models/ammocrates/ammocrate_2x3x2.mdl"
	Ammo2x3x2.weight = 60
AmmoTable["Ammo2x3x2"] = Ammo2x3x2

local Ammo2x3x4 = {}
	Ammo2x3x4.id = "Ammo2x3x4"
	Ammo2x3x4.ent = "acf_ammo"
	Ammo2x3x4.type = "Ammo"
	Ammo2x3x4.name = "Modular Ammo Crate"
	Ammo2x3x4.desc = "Modular Ammo Crate 2x3x4 Size\n"
	Ammo2x3x4.model = "models/ammocrates/ammocrate_2x3x4.mdl"
	Ammo2x3x4.weight = 120
AmmoTable["Ammo2x3x4"] = Ammo2x3x4

local Ammo2x4x1 = {}
	Ammo2x4x1.id = "Ammo2x4x1"
	Ammo2x4x1.ent = "acf_ammo"
	Ammo2x4x1.type = "Ammo"
	Ammo2x4x1.name = "Modular Ammo Crate"
	Ammo2x4x1.desc = "Modular Ammo Crate 2x4x1 Size\n"
	Ammo2x4x1.model = "models/ammocrates/ammocrate_2x4x1.mdl"
	Ammo2x4x1.weight = 40
AmmoTable["Ammo2x4x1"] = Ammo2x4x1

local Ammo2x4x2 = {}
	Ammo2x4x2.id = "Ammo2x4x2"
	Ammo2x4x2.ent = "acf_ammo"
	Ammo2x4x2.type = "Ammo"
	Ammo2x4x2.name = "Modular Ammo Crate"
	Ammo2x4x2.desc = "Modular Ammo Crate 2x4x2 Size\n"
	Ammo2x4x2.model = "models/ammocrates/ammocrate_2x4x2.mdl"
	Ammo2x4x2.weight = 80
AmmoTable["Ammo2x4x2"] = Ammo2x4x2

local Ammo2x4x4 = {}
	Ammo2x4x4.id = "Ammo2x4x4"
	Ammo2x4x4.ent = "acf_ammo"
	Ammo2x4x4.type = "Ammo"
	Ammo2x4x4.name = "Modular Ammo Crate"
	Ammo2x4x4.desc = "Modular Ammo Crate 2x4x4 Size\n"
	Ammo2x4x4.model = "models/ammocrates/ammocrate_2x4x4.mdl"
	Ammo2x4x4.weight = 160
AmmoTable["Ammo2x4x4"] = Ammo2x4x4

local Ammo2x4x6 = {}
	Ammo2x4x6.id = "Ammo2x4x6"
	Ammo2x4x6.ent = "acf_ammo"
	Ammo2x4x6.type = "Ammo"
	Ammo2x4x6.name = "Modular Ammo Crate"
	Ammo2x4x6.desc = "Modular Ammo Crate 2x4x6 Size\n"
	Ammo2x4x6.model = "models/ammocrates/ammocrate_2x4x6.mdl"
	Ammo2x4x6.weight = 240
AmmoTable["Ammo2x4x6"] = Ammo2x4x6

local Ammo2x4x8 = {}
	Ammo2x4x8.id = "Ammo2x4x8"
	Ammo2x4x8.ent = "acf_ammo"
	Ammo2x4x8.type = "Ammo"
	Ammo2x4x8.name = "Modular Ammo Crate"
	Ammo2x4x8.desc = "Modular Ammo Crate 2x4x8 Size\n"
	Ammo2x4x8.model = "models/ammocrates/ammocrate_2x4x8.mdl"
	Ammo2x4x8.weight = 320
AmmoTable["Ammo2x4x8"] = Ammo2x4x8

local Ammo3x4x1 = {}
	Ammo3x4x1.id = "Ammo3x4x1"
	Ammo3x4x1.ent = "acf_ammo"
	Ammo3x4x1.type = "Ammo"
	Ammo3x4x1.name = "Modular Ammo Crate"
	Ammo3x4x1.desc = "Modular Ammo Crate 3x4x1 Size\n"
	Ammo3x4x1.model = "models/ammocrates/ammocrate_3x4x1.mdl"
	Ammo3x4x1.weight = 60
AmmoTable["Ammo3x4x1"] = Ammo3x4x1

local Ammo3x4x2 = {}
	Ammo3x4x2.id = "Ammo3x4x2"
	Ammo3x4x2.ent = "acf_ammo"
	Ammo3x4x2.type = "Ammo"
	Ammo3x4x2.name = "Modular Ammo Crate"
	Ammo3x4x2.desc = "Modular Ammo Crate 3x4x2 Size\n"
	Ammo3x4x2.model = "models/ammocrates/ammocrate_3x4x2.mdl"
	Ammo3x4x2.weight = 120
AmmoTable["Ammo3x4x2"] = Ammo3x4x2

local Ammo3x4x4 = {}
	Ammo3x4x4.id = "Ammo3x4x4"
	Ammo3x4x4.ent = "acf_ammo"
	Ammo3x4x4.type = "Ammo"
	Ammo3x4x4.name = "Modular Ammo Crate"
	Ammo3x4x4.desc = "Modular Ammo Crate 3x4x4 Size\n"
	Ammo3x4x4.model = "models/ammocrates/ammocrate_3x4x4.mdl"
	Ammo3x4x4.weight = 240
AmmoTable["Ammo3x4x4"] = Ammo3x4x4

local Ammo3x4x6 = {}
	Ammo3x4x6.id = "Ammo3x4x6"
	Ammo3x4x6.ent = "acf_ammo"
	Ammo3x4x6.type = "Ammo"
	Ammo3x4x6.name = "Modular Ammo Crate"
	Ammo3x4x6.desc = "Modular Ammo Crate 3x4x6 Size\n"
	Ammo3x4x6.model = "models/ammocrates/ammocrate_3x4x6.mdl"
	Ammo3x4x6.weight = 360
AmmoTable["Ammo3x4x6"] = Ammo3x4x6

local Ammo3x4x8 = {}
	Ammo3x4x8.id = "Ammo3x4x8"
	Ammo3x4x8.ent = "acf_ammo"
	Ammo3x4x8.type = "Ammo"
	Ammo3x4x8.name = "Modular Ammo Crate"
	Ammo3x4x8.desc = "Modular Ammo Crate 3x4x8 Size\n"
	Ammo3x4x8.model = "models/ammocrates/ammocrate_3x4x8.mdl"
	Ammo3x4x8.weight = 480
AmmoTable["Ammo3x4x8"] = Ammo3x4x8

local Ammo4x4x1 = {}
	Ammo4x4x1.id = "Ammo4x4x1"
	Ammo4x4x1.ent = "acf_ammo"
	Ammo4x4x1.type = "Ammo"
	Ammo4x4x1.name = "Modular Ammo Crate"
	Ammo4x4x1.desc = "Modular Ammo Crate 4x4x1 Size\n"
	Ammo4x4x1.model = "models/ammocrates/ammo_4x4x1.mdl"
	Ammo4x4x1.weight = 80
AmmoTable["Ammo4x4x1"] = Ammo4x4x1

local Ammo4x4x2 = {}
	Ammo4x4x2.id = "Ammo4x4x2"
	Ammo4x4x2.ent = "acf_ammo"
	Ammo4x4x2.type = "Ammo"
	Ammo4x4x2.name = "Modular Ammo Crate"
	Ammo4x4x2.desc = "Modular Ammo Crate 4x4x2 Size\n"
	Ammo4x4x2.model = "models/ammocrates/ammocrate_4x4x2.mdl"
	Ammo4x4x2.weight = 160
AmmoTable["Ammo4x4x2"] = Ammo4x4x2

local Ammo4x4x4 = {}
	Ammo4x4x4.id = "Ammo4x4x4"
	Ammo4x4x4.ent = "acf_ammo"
	Ammo4x4x4.type = "Ammo"
	Ammo4x4x4.name = "Modular Ammo Crate"
	Ammo4x4x4.desc = "Modular Ammo Crate 4x4x4 Size\n"
	Ammo4x4x4.model = "models/ammocrates/ammocrate_4x4x4.mdl"
	Ammo4x4x4.weight = 320
AmmoTable["Ammo4x4x4"] = Ammo4x4x4

local Ammo4x4x6 = {}
	Ammo4x4x6.id = "Ammo4x4x6"
	Ammo4x4x6.ent = "acf_ammo"
	Ammo4x4x6.type = "Ammo"
	Ammo4x4x6.name = "Modular Ammo Crate"
	Ammo4x4x6.desc = "Modular Ammo Crate 4x4x6 Size\n"
	Ammo4x4x6.model = "models/ammocrates/ammocrate_4x4x6.mdl"
	Ammo4x4x6.weight = 480
AmmoTable["Ammo4x4x6"] = Ammo4x4x6

local Ammo4x4x8 = {}
	Ammo4x4x8.id = "Ammo4x4x8"
	Ammo4x4x8.ent = "acf_ammo"
	Ammo4x4x8.type = "Ammo"
	Ammo4x4x8.name = "Modular Ammo Crate"
	Ammo4x4x8.desc = "Modular Ammo Crate 4x4x8 Size\n"
	Ammo4x4x8.model = "models/ammocrates/ammocrate_4x4x8.mdl"
	Ammo4x4x8.weight = 640
AmmoTable["Ammo4x4x8"] = Ammo4x4x8


local Ammo4x6x8 = {}
	Ammo4x6x8.id = "Ammo4x6x8"
	Ammo4x6x8.ent = "acf_ammo"
	Ammo4x6x8.type = "Ammo"
	Ammo4x6x8.name = "Modular Ammo Crate"
	Ammo4x6x8.desc = "Modular Ammo Crate 4x6x8 Size\n"
	Ammo4x6x8.model = "models/ammocrates/ammo_4x6x8.mdl"
	Ammo4x6x8.weight = 800
AmmoTable["Ammo4x6x8"] = Ammo4x6x8


local Ammo4x6x6 = {}
	Ammo4x6x6.id = "Ammo4x6x6"
	Ammo4x6x6.ent = "acf_ammo"
	Ammo4x6x6.type = "Ammo"
	Ammo4x6x6.name = "Modular Ammo Crate"
	Ammo4x6x6.desc = "Modular Ammo Crate 4x6x6 Size\n"
	Ammo4x6x6.model = "models/ammocrates/ammo_4x6x6.mdl"
	Ammo4x6x6.weight = 720
AmmoTable["Ammo4x6x6"] = Ammo4x6x6


local Ammo4x8x8 = {}
	Ammo4x8x8.id = "Ammo4x8x8"
	Ammo4x8x8.ent = "acf_ammo"
	Ammo4x8x8.type = "Ammo"
	Ammo4x8x8.name = "Modular Ammo Crate"
	Ammo4x8x8.desc = "Modular Ammo Crate 4x8x8 Size\n"
	Ammo4x8x8.model = "models/ammocrates/ammo_4x8x8.mdl"
	Ammo4x8x8.weight = 960
AmmoTable["Ammo4x8x8"] = Ammo4x8x8
	
list.Set( "ACFEnts", "Ammo", AmmoTable )	--end ammo containers listing
