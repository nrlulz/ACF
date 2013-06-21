E2Lib.RegisterExtension("acf", true)
CreateConVar("sbox_acf_e2restrictinfo", 1) -- 0=any, 1=owned
-- [ To Do ] --

-- #general

-- #engine

-- #gearbox

-- #gun
--use an input to set reload manually, to remove timer?

-- #ammo

-- #prop armor
--get incident armor ?
--hit calcs ?
--conversions ?


-- [ Helper Functions ] --


local function isEngine(ent)
	if not validPhysics(ent) then return false end
	if (ent:GetClass() == "acf_engine") then return true else return false end
end

local function isGearbox(ent)
	if not validPhysics(ent) then return false end
	if (ent:GetClass() == "acf_gearbox") then return true else return false end
end

local function isGun(ent)
	if not validPhysics(ent) then return false end
	if (ent:GetClass() == "acf_gun") then return true else return false end
end

local function isAmmo(ent)
	if not validPhysics(ent) then return false end
	if (ent:GetClass() == "acf_ammo") then return true else return false end
end

local function restrictInfo(ply, ent)
	if GetConVar("sbox_acf_e2restrictinfo"):GetInt() != 0 then
		if isOwner(ply, ent) then return false else return true end
	end
	return false
end


-- [General Functions ] --


__e2setcost( 1 )

-- Returns 1 if functions returning sensitive info are restricted to owned props
e2function number acfInfoRestricted()
	return GetConVar("sbox_acf_e2restrictinfo"):GetInt() or 0
end

-- Returns the short name of an ACF entity
e2function string entity:acfNameShort()
	if isEngine(this) then return this.Id or "" end
	if isGearbox(this) then return this.Id or "" end
	if isGun(this) then return this.Id or "" end
	if isAmmo(this) then return this.RoundId or "" end
	return ""
end

-- Turns an ACF engine or ammo crate on or off
e2function void entity:acfActive( number on )
	if not (isEngine(this) or isAmmo(this)) then return end
	if not isOwner(self, this) then return end
	this:TriggerInput("Active", on)	
end

__e2setcost( 2 )

-- Returns the full name of an ACF entity
e2function string entity:acfName()
	if isAmmo(this) then return (this.RoundId .. " " .. this.RoundType) end
	local acftype = ""
	if isEngine(this) then acftype = "Mobility" end
	if isGearbox(this) then acftype = "Mobility" end
	if isGun(this) then acftype = "Guns" end
	if (acftype == "") then return "" end
	local List = list.Get("ACFEnts")
	return List[acftype][this.Id]["name"] or ""
end

-- Returns the type of ACF entity
e2function string entity:acfType()
	if isEngine(this) or isGearbox(this) then
		local List = list.Get("ACFEnts")
		return List["Mobility"][this.Id]["category"] or ""
	end
	if isGun(this) then
		local Classes = list.Get("ACFClasses")
		return Classes["GunClass"][this.Class]["name"] or ""
	end
	if isAmmo(this) then return this.RoundType or "" end
	return ""
end


-- [ Engine Functions ] --


__e2setcost( 1 )

-- Returns 1 if the entity is an ACF engine
e2function number entity:acfIsEngine()
	if isEngine(this) then return 1 else return 0 end
end

-- Returns the torque in N/m of an ACF engine
e2function number entity:acfMaxTorque()
	if not isEngine(this) then return 0 end
	return this.PeakTorque or 0
end

-- Returns the power in kW of an ACF engine
e2function number entity:acfMaxPower()
	if not isEngine(this) then return 0 end
	local peakpower
	if this.iselec then
		peakpower = math.floor(this.PeakTorque * this.LimitRPM / (4*9548.8))
	else
		peakpower = math.floor(this.PeakTorque * this.PeakMaxRPM / 9548.8)
	end
	return peakpower or 0
end

-- Returns the idle rpm of an ACF engine
e2function number entity:acfIdleRPM()
	if not isEngine(this) then return 0 end
	return this.IdleRPM or 0
end

-- Returns the powerband min of an ACF engine
e2function number entity:acfPowerbandMin()
	if not isEngine(this) then return 0 end
	return this.PeakMinRPM or 0
end

-- Returns the powerband max of an ACF engine
e2function number entity:acfPowerbandMax()
	if not isEngine(this) then return 0 end
	return this.PeakMaxRPM or 0
end

-- Returns the redline rpm of an ACF engine
e2function number entity:acfRedline()
	if not isEngine(this) then return 0 end
	return this.LimitRPM or 0
end

-- Returns the current rpm of an ACF engine
e2function number entity:acfRPM()
	if not isEngine(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	return math.floor(this.FlyRPM or 0)
end

-- Returns the current torque of an ACF engine
e2function number entity:acfTorque()
	if not isEngine(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	return math.floor(this.Torque or 0)
end

-- Returns the current power of an ACF engine
e2function number entity:acfPower()
	if not isEngine(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	return math.floor((this.Torque or 0) * (this.FlyRPM or 0) / 9548.8)
end

-- Returns 1 if the RPM of an ACF engine is inside the powerband
e2function number entity:acfInPowerband()
	if not isEngine(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	if (this.FlyRPM < this.PeakMinRPM) then return 0 end
	if (this.FlyRPM > this.PeakMaxRPM) then return 0 end
	return 1
end

-- Returns 1 if the ACF engine is on
e2function number entity:acfActive()
	if not isEngine(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	if (this.Active) then return 1 end
	return 0
end

-- Returns the throttle of an ACF engine
e2function number entity:acfThrottle()
	if not isEngine(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	return (this.Throttle or 0) * 100
end

__e2setcost( 5 )

-- Sets the throttle value for an ACF engine
e2function void entity:acfThrottle( number throttle )
	if not isEngine(this) then return end
	if not isOwner(self, this) then return end
	this:TriggerInput("Throttle", throttle)
end


-- [ Gearbox Functions ] --


__e2setcost( 1 )

-- Returns 1 if the entity is an ACF gearbox
e2function number entity:acfIsGearbox()
	if isGearbox(this) then return 1 else return 0 end
end

-- Returns the current gear for an ACF gearbox
e2function number entity:acfGear()
	if not isGearbox(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	return this.Gear or 0
end

-- Returns the number of gears for an ACF gearbox
e2function number entity:acfNumGears()
	if not isGearbox(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	return this.Gears or 0
end

-- Returns the final ratio for an ACF gearbox
e2function number entity:acfFinalRatio()
	if not isGearbox(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	return this.GearTable["Final"] or 0
end

-- Returns the total ratio (current gear * final) for an ACF gearbox
e2function number entity:acfTotalRatio()
	if not isGearbox(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	return this.GearRatio or 0
end

-- Returns the max torque for an ACF gearbox
e2function number entity:acfTorqueRating()
	if not isGearbox(this) then return 0 end
	return this.MaxTorque or 0
end

-- Returns whether an ACF gearbox is dual clutch
e2function number entity:acfIsDual()
	if not isGearbox(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	if (this.Dual) then return 1 end
	return 0
end

-- Returns the time in ms an ACF gearbox takes to change gears
e2function number entity:acfShiftTime()
	if not isGearbox(this) then return 0 end
	return (this.SwitchTime or 0) * 1000
end

-- Returns 1 if an ACF gearbox is in gear
e2function number entity:acfInGear()
	if not isGearbox(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	if (this.InGear) then return 1 end
	return 0
end

-- Returns the ratio for a specified gear of an ACF gearbox
e2function number entity:acfGearRatio( number gear )
	if not isGearbox(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	local g = math.Clamp(math.floor(gear),1,this.Gears)
	return this.GearTable[g] or 0
end

-- Returns the current torque output for an ACF gearbox
e2function number entity:acfTorqueOut()
	if not isGearbox(this) then return 0 end
	return math.min(this.TotalReqTq or 0, this.MaxTorque or 0) / (this.GearRatio or 1)
end

__e2setcost( 5 )

-- Sets the current gear for an ACF gearbox
e2function void entity:acfShift( number gear )
	if not isGearbox(this) then return end
	if not isOwner(self, this) then return end
	this:TriggerInput("Gear", gear)
end

-- Cause an ACF gearbox to shift up
e2function void entity:acfShiftUp()
	if not isGearbox(this) then return end
	if not isOwner(self, this) then return end
	this:TriggerInput("Gear Up", 1) --doesn't need to be toggled off
end

-- Cause an ACF gearbox to shift down
e2function void entity:acfShiftDown()
	if not isGearbox(this) then return end
	if not isOwner(self, this) then return end
	this:TriggerInput("Gear Down", 1) --doesn't need to be toggled off
end

-- Sets the brakes for an ACF gearbox
e2function void entity:acfBrake( number brake )
	if not isGearbox(this) then return end
	if not isOwner(self, this) then return end
	this:TriggerInput("Brake", brake)
end

-- Sets the left brakes for an ACF gearbox
e2function void entity:acfBrakeLeft( number brake )
	if not isGearbox(this) then return end
	if not isOwner(self, this) then return end
	if (not this.Dual) then return end
	this:TriggerInput("Left Brake", brake)
end

-- Sets the right brakes for an ACF gearbox
e2function void entity:acfBrakeRight( number brake )
	if not isGearbox(this) then return end
	if not isOwner(self, this) then return end
	if (not this.Dual) then return end
	this:TriggerInput("Right Brake", brake)
end

-- Sets the clutch for an ACF gearbox
e2function void entity:acfClutch( number clutch )
	if not isGearbox(this) then return end
	if not isOwner(self, this) then return end
	this:TriggerInput("Clutch", clutch)
end

-- Sets the left clutch for an ACF gearbox
e2function void entity:acfClutchLeft( number clutch )
	if not isGearbox(this) then return end
	if not isOwner(self, this) then return end
	if (not this.Dual) then return end
	this:TriggerInput("Left Clutch", clutch)
end

-- Sets the right clutch for an ACF gearbox
e2function void entity:acfClutchRight( number clutch )
	if not isGearbox(this) then return end
	if not isOwner(self, this) then return end
	if (not this.Dual) then return end
	this:TriggerInput("Right Clutch", clutch)
end


-- [ Gun Functions ] --


__e2setcost( 1 )

-- Returns 1 if the entity is an ACF gun
e2function number entity:acfIsGun()
	if isGun(this) and not restrictInfo(self, this) then return 1 else return 0 end
end

-- Returns 1 if the ACF gun is ready to fire
e2function number entity:acfReady()
	if not isGun(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	if (this.Ready) then return 1 end
	return 0
end

-- Returns the magazine size for an ACF gun
e2function number entity:acfMagSize()
	if not isGun(this) then return 0 end
	return this.MagSize or 1
end

-- Returns the spread for an ACF gun
e2function number entity:acfSpread()
	if not isGun(this) then return 0 end
	return this.Inaccuracy or 0
end

-- Returns 1 if an ACF gun is reloading
e2function number entity:acfIsReloading()
	if not isGun(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	if (this.Reloading) then return 1 end
	return 0
end

-- Returns the rate of fire of an acf gun
e2function number entity:acfFireRate()
	if not isGun(this) then return 0 end
	return math.Round(this.RateOfFire or 0,3)
end

-- Returns the number of rounds left in a magazine for an ACF gun
e2function number entity:acfMagRounds()
	if not isGun(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	if (this.MagSize > 1) then
		return (this.MagSize - this.CurrentShot) or 1
	end
	if (this.Ready) then return 1 end
	return 0
end

-- Sets the firing state of an ACF weapon
e2function void entity:acfFire( number fire )
	if not isGun(this) then return end
	if not isOwner(self, this) then return end
	this:TriggerInput("Fire", fire)	
end

-- Causes an ACF weapon to unload
e2function void entity:acfUnload()
	if not isGun(this) then return end
	if not isOwner(self, this) then return end
	this:UnloadAmmo()
end

__e2setcost( 10 )

-- Causes an ACF weapon to reload
e2function void entity:acfReload()
	if not isGun(this) then return end
	if not isOwner(self, this) then return end
	this:TriggerInput("Reload", 1)
	--this:TriggerInput("Reload", 0) --turns off input too fast, overrides the input to turn on
	timer.Simple( 0.1, function() this:TriggerInput("Reload", 0) end ) --wrap in function to avoid error
end

__e2setcost( 20 )

--Returns the number of rounds in active ammo crates linked to an ACF weapon
e2function number entity:acfAmmoCount()
	if not isGun(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	local Ammo = 0
	for Key,AmmoEnt in pairs(this.AmmoLink) do
		if AmmoEnt and AmmoEnt:IsValid() and AmmoEnt["Load"] then
			Ammo = Ammo + (AmmoEnt.Ammo or 0)
		end
	end
	return Ammo
end

--Returns the number of rounds in all ammo crates linked to an ACF weapon
e2function number entity:acfTotalAmmoCount()
	if not isGun(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	local Ammo = 0
	for Key,AmmoEnt in pairs(this.AmmoLink) do
		if AmmoEnt and AmmoEnt:IsValid() then
			Ammo = Ammo + (AmmoEnt.Ammo or 0)
		end
	end
	return Ammo
end

-- [ Ammo Functions ] --


__e2setcost( 1 )

-- Returns 1 if the entity is an ACF ammo crate
e2function number entity:acfIsAmmo()
	if isAmmo(this) and not restrictInfo(self, this) then return 1 else return 0 end
end

-- Returns the capacity of an acf ammo crate
e2function number entity:acfCapacity()
	if not isAmmo(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	return this.Capacity or 0
end

-- Returns the rounds left in an acf ammo crate
e2function number entity:acfRounds()
	if not isAmmo(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	return this.Ammo or 0
end

-- Returns the type of weapon the ammo in an ACF ammo crate loads into
e2function string entity:acfRoundType() --cartridge?
	if not isAmmo(this) then return "" end
	if restrictInfo(self, this) then return "" end
	return this.RoundId or ""
end

-- Returns the type of ammo in a crate or gun
e2function string entity:acfAmmoType()
	if not (isAmmo(this) or isGun(this)) then return "" end
	if restrictInfo(self, this) then return "" end
	return this.BulletData["Type"] or ""
end

-- Returns the muzzle velocity of the ammo in a crate or gun
e2function number entity:acfMuzzleVel()
	if not (isAmmo(this) or isGun(this)) then return 0 end
	if restrictInfo(self, this) then return 0 end
	return math.Round((this.BulletData["MuzzleVel"] or 0)*ACF.VelScale,3)
end

-- Returns the mass of the projectile in a crate or gun
e2function number entity:acfProjectileMass()
	if not (isAmmo(this) or isGun(this)) then return 0 end
	if restrictInfo(self, this) then return 0 end
	return math.Round(this.BulletData["ProjMass"] or 0,3)
end

__e2setcost( 5 )

-- Returns the penetration of an AP, APHE, or HEAT round
e2function number entity:acfPenetration()
	if not (isAmmo(this) or isGun(this)) then return 0 end
	if restrictInfo(self, this) then return 0 end
	local Type = this.BulletData["Type"] or ""
	local Energy
	if Type == "AP" or Type == "APHE" then
		Energy = ACF_Kinetic(this.BulletData["MuzzleVel"]*39.37, this.BulletData["ProjMass"] - (this.BulletData["FillerMass"] or 0), this.BulletData["LimitVel"] )
		return math.Round((Energy.Penetration/this.BulletData["PenAera"])*ACF.KEtoRHA,3)
	elseif Type == "HEAT" then
		Energy = ACF_Kinetic(this.BulletData["SlugMV"]*39.37, this.BulletData["SlugMass"], 9999999 )
		return math.Round((Energy.Penetration/this.BulletData["SlugPenAera"])*ACF.KEtoRHA,3)
	end
	return 0
end

-- Returns the blast radius of an HE, APHE, or HEAT round
e2function number entity:acfBlastRadius()
	if not (isAmmo(this) or isGun(this)) then return 0 end
	if restrictInfo(self, this) then return 0 end
	local Type = this.BulletData["Type"] or ""
	if Type == "HE" or Type == "APHE" then
		return math.Round(this.BulletData["FillerMass"]^0.33*5,3)
	elseif Type == "HEAT" then
		return math.Round((this.BulletData["FillerMass"]/2)^0.33*5,3)
	end
	return 0
end


-- [ Armor Functions ] --


__e2setcost( 10 )

-- Returns the current health of an entity
e2function number entity:acfPropHealth()
	if not validPhysics(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	if not ACF_Check(this) then return 0 end
	return math.Round(this.ACF.Health or 0,3)
end

-- Returns the current armor of an entity
e2function number entity:acfPropArmor()
	if not validPhysics(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	if not ACF_Check(this) then return 0 end
	return math.Round(this.ACF.Armour or 0,3)
end

-- Returns the max health of an entity
e2function number entity:acfPropHealthMax()
	if not validPhysics(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	if not ACF_Check(this) then return 0 end
	return math.Round(this.ACF.MaxHealth or 0,3)
end

-- Returns the max armor of an entity
e2function number entity:acfPropArmorMax()
	if not validPhysics(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	if not ACF_Check(this) then return 0 end
	return math.Round(this.ACF.MaxArmour or 0,3)
end

-- Returns the ductility of an entity
e2function number entity:acfPropDuctility()
	if not validPhysics(this) then return 0 end
	if restrictInfo(self, this) then return 0 end
	if not ACF_Check(this) then return 0 end
	return (this.ACF.Ductility or 0)*100
end


__e2setcost(nil)
