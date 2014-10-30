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

-- #fuel


-- [ Helper Functions ] --

local acf_lib, _ = SF.Libraries.Register( "acf" )
local ents_methods = SF.Entities.Methods
local ents_metatable = SF.Entities.Metatable
local wrap, unwrap = SF.Entities.Wrap, SF.Entities.Unwrap

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege( "acf.access", "Access", "If granted, the user does not have to be the owner of the prop to get ACF information" )
end

local function isEngine( ent )
	if not validPhysics( ent ) then return false end
	if ( ent:GetClass( ) == "acf_engine" ) then return true else return false end
end

local function isGearbox( ent )
	if not validPhysics( ent ) then return false end
	if ( ent:GetClass( ) == "acf_gearbox" ) then return true else return false end
end

local function isGun( ent )
	if not validPhysics( ent ) then return false end
	if ( ent:GetClass( ) == "acf_gun" ) then return true else return false end
end

local function isAmmo( ent )
	if not validPhysics( ent ) then return false end
	if ( ent:GetClass( ) == "acf_ammo" ) then return true else return false end
end

local function isFuel( ent )
	if not validPhysics(ent) then return false end
	if ( ent:GetClass( ) == "acf_fueltank" ) then return true else return false end
end

local function restrictInfo( ent )
	if not SF.Permissions.check( SF.instance.player, ent, "acf.access" ) then return true else return false end
end

-- [General Functions ] --

-- Returns the short name of an ACF entity
function ents_methods:acfNameShort ( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if isEngine( this ) then return this.Id or "" end
	if isGearbox( this ) then return this.Id or "" end
	if isGun( this ) then return this.Id or "" end
	if isAmmo( this ) then return this.RoundId or "" end
	if isFuel( this ) then return this.FuelType .. " " .. this.SizeId end
end

-- Returns the capacity of an acf ammo crate or fuel tank
function ents_methods:acfCapacity( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not ( isAmmo( this ) or isFuel( this ) ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	return this.Capacity or 1
end

-- Returns true if the acf engine, fuel tank, or ammo crate is active
function ents_methods:acfGetActive( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )	

	if not ( isEngine( this ) or isAmmo( this ) or isFuel( this ) ) then return false end
	if restrictInfo( SF.instance.player, this ) then return false end
	if not isAmmo( this ) then
		if this.Active then return true end
	else
		if this.Load then return true end
	end
	return false
end

-- Turns an ACF engine, ammo crate, or fuel tank on or off
function ents_methods:acfSetActive( on )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )	

	if not ( isEngine( this ) or isAmmo( this ) or isFuel( this ) ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	this:TriggerInput( "Active", on and 1 or 0 )	
end

local linkTables =
{ -- link resources within each ent type.  should point to an ent: true if adding link.Ent, false to add link itself
	acf_engine 		= { GearLink = true, FuelLink = false },
	acf_gearbox		= { WheelLink = true, Master = false },
	acf_fueltank	= { Master = false },
	acf_gun			= { AmmoLink = false },
	acf_ammo		= { Master = false }
}

local function getLinks( ent, enttype )	
	local ret = { }
	-- find the link resources available for this ent type
	for entry, mode in pairs( linkTables[ enttype ] ) do
		if not ent[ entry ] then error( "Couldn't find link resource " .. entry .. " for entity " .. tostring( ent ) ) return end
		
		-- find all the links inside the resources
		for _, link in pairs( ent[ entry ] ) do
			ret[ #ret + 1 ] = mode and link.Ent or link
		end
	end
	
	return ret
end

local function searchForGearboxLinks( ent )
	local boxes = ents.FindByClass( "acf_gearbox" )
	
	local ret = { }
	
	for _, box in pairs( boxes ) do
		if IsValid( box ) then
			for _, link in pairs( box.WheelLink ) do
				if link.Ent == ent then
					ret[ #ret + 1 ] = box
					break
				end
			end
		end
	end
	
	return ret
end

-- Returns the ACF links associated with the entity
function ents_methods:acfLinks( )	
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not IsValid( this ) then return { } end
	
	local enttype = this:GetClass( )
	
	if not linkTables[ enttype ] then
		return searchForGearboxLinks( this )
	end
	
	return getLinks( this, enttype )	
end

-- Returns the full name of an ACF entity
function ents_methods:acfName( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if isAmmo( this ) then return ( this.RoundId .. " " .. this.RoundType) end
	if isFuel( this ) then return this.FuelType .. " " .. this.SizeId end
	
	local acftype = ""
	if isEngine( this ) then acftype = "Mobility" end
	if isGearbox( this ) then acftype = "Mobility" end
	if isGun( this ) then acftype = "Guns" end
	if ( acftype == "" ) then return "" end
	local List = list.Get( "ACFEnts" )
	return List[ acftype ][ this.Id ][ "name" ] or ""
end

-- Returns the type of ACF entity
function ents_methods:acfType( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if isEngine( this ) or isGearbox( this ) then
		local List = list.Get( "ACFEnts" )
		return List[ "Mobility" ][ this.Id ][ "category" ] or ""
	end
	if isGun( this ) then
		local Classes = list.Get( "ACFClasses" )
		return Classes[ "GunClass" ][ this.Class ][ "name" ] or ""
	end
	if isAmmo( this ) then return this.RoundType or "" end
	if isFuel( this ) then return this.FuelType or "" end
	return ""
end


-- [ Engine Functions ] --

-- Returns true if the entity is an ACF engine
function ents_methods:acfIsEngine( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if isEngine( this ) then return true else return false end
end

-- Returns the torque in N/m of an ACF engine
function ents_methods:acfMaxTorque( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isEngine( this ) then return 0 end
	return this.PeakTorque or 0
end

-- Returns the power in kW of an ACF engine
function ents_methods:acfMaxPower( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isEngine( this ) then return 0 end
	local peakpower
	if this.iselec then
		peakpower = math.floor( this.PeakTorque * this.LimitRPM / ( 4 * 9548.8 ) )
	else
		peakpower = math.floor( this.PeakTorque * this.PeakMaxRPM / 9548.8 )
	end
	return peakpower or 0
end

-- Returns the idle rpm of an ACF engine
function ents_methods:acfIdleRPM( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isEngine( this ) then return 0 end
	return this.IdleRPM or 0
end

-- Returns the powerband min of an ACF engine
function ents_methods:acfPowerbandMin( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isEngine( this ) then return 0 end
	return this.PeakMinRPM or 0
end

-- Returns the powerband max of an ACF engine
function ents_methods:acfPowerbandMax( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isEngine( this ) then return 0 end
	return this.PeakMaxRPM or 0
end

-- Returns the redline rpm of an ACF engine
function ents_methods:acfRedline( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isEngine(this) then return 0 end
	return this.LimitRPM or 0
end

-- Returns the current rpm of an ACF engine
function ents_methods:acfRPM( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isEngine( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	return math.floor( this.FlyRPM ) or 0
end

-- Returns the current torque of an ACF engine
function ents_methods:acfTorque( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isEngine( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	return math.floor( this.Torque or 0 )
end

-- Returns the current power of an ACF engine
function ents_methods:acfPower( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isEngine( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	return math.floor( ( this.Torque or 0 ) * ( this.FlyRPM or 0 ) / 9548.8 )
end

-- Returns true if the RPM of an ACF engine is inside the powerband
function ents_methods:acfInPowerband( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isEngine( this ) then return false end
	if restrictInfo( SF.instance.player, this ) then return false end
	if ( this.FlyRPM < this.PeakMinRPM ) then return false end
	if ( this.FlyRPM > this.PeakMaxRPM ) then return false end
	return true
end

function ents_methods:acfGetThrottle( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isEngine( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	return ( this.Throttle or 0 ) * 100
end

-- Sets the throttle value for an ACF engine
function ents_methods:acfSetThrottle( throttle  )
	SF.CheckType( self, ents_metatable )
	SF.CheckType( throttle, "number" )
	local this = unwrap( self )
	
	if not isEngine( this ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	this:TriggerInput( "Throttle", throttle)
end


-- [ Gearbox Functions ] --

-- Returns true if the entity is an ACF gearbox
function ents_methods:acfIsGearbox( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if isGearbox( this ) then return true else return false end
end

-- Returns the current gear for an ACF gearbox
function ents_methods:acfGear( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	return this.Gear or 0
end

-- Returns the number of gears for an ACF gearbox
function ents_methods:acfNumGears( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	return this.Gears or 0
end

-- Returns the final ratio for an ACF gearbox
function ents_methods:acfFinalRatio( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	return this.GearTable[ "Final" ] or 0
end

-- Returns the total ratio (current gear * final) for an ACF gearbox
function ents_methods:acfTotalRatio( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	return this.GearRatio or 0
end

-- Returns the max torque for an ACF gearbox
function ents_methods:acfTorqueRating( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return 0 end
	return this.MaxTorque or 0
end

-- Returns whether an ACF gearbox is dual clutch
function ents_methods:acfIsDual( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return false end
	if restrictInfo( SF.instance.player, this ) then return false end
	if this.Dual then return true end
	return false
end

-- Returns the time in ms an ACF gearbox takes to change gears
function ents_methods:acfShiftTime( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return 0 end
	return ( this.SwitchTime or 0 ) * 1000
end

-- Returns true if an ACF gearbox is in gear
function ents_methods:acfInGear( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return false end
	if restrictInfo( SF.instance.player, this ) then return false end
	if this.InGear then return true end
	return false
end

-- Returns the ratio for a specified gear of an ACF gearbox
function ents_methods:acfGearRatio( gear  )
	SF.CheckType( self, ents_metatable )
	SF.CheckType( gear, "number" )
	
	local this = unwrap( self )
	
	if not isGearbox( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	local g = math.Clamp( math.floor( gear ), 1, this.Gears )
	return this.GearTable[ g ] or 0
end

-- Returns the current torque output for an ACF gearbox
function ents_methods:acfTorqueOut( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return 0 end
	return math.min( this.TotalReqTq or 0, this.MaxTorque or 0 ) / ( this.GearRatio or 1 )
end

-- Sets the gear ratio of a CVT, set to 0 to use built-in algorithm
function ents_methods:acfCVTRatio( ratio  )
	SF.CheckType( self, ents_metatable )
	SF.CheckType( ratio, "number" )
	
	local this = unwrap( self )
	
	if not isGearbox( this ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	if not this.CVT then return end
	this.CVTRatio = math.Clamp( ratio, 0, 1 )
end

-- Sets the current gear for an ACF gearbox
function ents_methods:acfShift( gear  )
	SF.CheckType( self, ents_metatable )
	SF.CheckType( gear, "number" )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	this:TriggerInput( "Gear", gear )
end

-- Cause an ACF gearbox to shift up
function ents_methods:acfShiftUp( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	this:TriggerInput( "Gear Up", 1 ) --doesn't need to be toggled off
end

-- Cause an ACF gearbox to shift down
function ents_methods:acfShiftDown( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	this:TriggerInput( "Gear Down", 1 ) --doesn't need to be toggled off
end

-- Sets the brakes for an ACF gearbox
function ents_methods:acfBrake( brake  )
	SF.CheckType( self, ents_metatable )
	SF.CheckType( brake, "number" )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	this:TriggerInput("Brake", brake)
end

-- Sets the left brakes for an ACF gearbox
function ents_methods:acfBrakeLeft( brake  )
	SF.CheckType( self, ents_metatable )
	SF.CheckType( brake, "number" )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	if not this.Dual then return end
	this:TriggerInput( "Left Brake", brake )
end

-- Sets the right brakes for an ACF gearbox
function ents_methods:acfBrakeRight( brake  )
	SF.CheckType( self, ents_metatable )
	SF.CheckType( brake, "number" )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	if not this.Dual then return end
	this:TriggerInput("Right Brake", brake)
end

-- Sets the clutch for an ACF gearbox
function ents_methods:acfClutch( clutch  )
	SF.CheckType( self, ents_metatable )
	SF.CheckType( clutch, "number" )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	this:TriggerInput( "Clutch", clutch )
end

-- Sets the left clutch for an ACF gearbox
function ents_methods:acfClutchLeft( clutch  )
	SF.CheckType( self, ents_metatable )
	SF.CheckType( clutch, "number" )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	if not this.Dual then return end
	this:TriggerInput( "Left Clutch", clutch )
end

-- Sets the right clutch for an ACF gearbox
function ents_methods:acfClutchRight( clutch  )
	SF.CheckType( self, ents_metatable )
	SF.CheckType( clutch, "number" )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	if not this.Dual then return end
	this:TriggerInput( "Right Clutch", clutch )
end

-- Sets the steer ratio for an ACF gearbox
function ents_methods:acfSteerRate( rate  )
	SF.CheckType( self, ents_metatable )
	SF.CheckType( rate, "number" )
	local this = unwrap( self )
	
	if not isGearbox( this ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	if not this.DoubleDiff then return end
	this:TriggerInput( "Steer Rate", rate )
end


-- [ Gun Functions ] --

-- Returns true if the entity is an ACF gun
function ents_methods:acfIsGun(  )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if isGun( this ) and not restrictInfo( SF.instance.player, this ) then return true else return false end
end

-- Returns true if the ACF gun is ready to fire
function ents_methods:acfReady( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGun( this ) then return false end
	if restrictInfo( SF.instance.player, this ) then return false end
	if ( this.Ready ) then return true end
	return false
end

-- Returns the magazine size for an ACF gun
function ents_methods:acfMagSize( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGun( this ) then return 0 end
	return this.MagSize or 1
end

-- Returns the spread for an ACF gun or flechette ammo
function ents_methods:acfSpread( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGun( this ) or isAmmo( this ) then return 0 end
	local Spread = this.GetInaccuracy and this:GetInaccuracy( ) or this.Inaccuracy or 0
	if this.BulletData[ "Type" ] == "FL" then
		if restrictInfo( SF.instance.player, this ) then return Spread end
		return Spread + ( this.BulletData[ "FlechetteSpread" ] or 0 )
	end
	return Spread
end

-- Returns true if an ACF gun is reloading
function ents_methods:acfIsReloading( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGun( this ) then return false end
	if restrictInfo( SF.instance.player, this ) then return false end
	if (this.Reloading) then return true end
	return false
end

-- Returns the rate of fire of an acf gun
function ents_methods:acfFireRate( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGun( this ) then return 0 end
	return math.Round( this.RateOfFire or 0, 3 )
end

-- Returns the number of rounds left in a magazine for an ACF gun
function ents_methods:acfMagRounds( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGun( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	if this.MagSize > 1 then
		return ( this.MagSize - this.CurrentShot ) or 1
	end
	if this.Ready then return 1 end
	return 0
end

-- Sets the firing state of an ACF weapon
function ents_methods:acfFire( fire  )
	SF.CheckType( self, ents_metatable )
	SF.CheckType( fire, "number" )
	local this = unwrap( self )
	
	if not isGun( this ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	this:TriggerInput("Fire", fire)	
end

-- Causes an ACF weapon to unload
function ents_methods:acfUnload( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGun( this ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	this:UnloadAmmo( )
end

-- Causes an ACF weapon to reload
function ents_methods:acfReload( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGun( this ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	this.Reloading = true
end

--Returns the number of rounds in active ammo crates linked to an ACF weapon
function ents_methods:acfAmmoCount( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGun( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	local Ammo = 0
	for Key, AmmoEnt in pairs( this.AmmoLink ) do
		if AmmoEnt and AmmoEnt:IsValid( ) and AmmoEnt[ "Load" ] then
			Ammo = Ammo + ( AmmoEnt.Ammo or 0 )
		end
	end
	return Ammo
end

--Returns the number of rounds in all ammo crates linked to an ACF weapon
function ents_methods:acfTotalAmmoCount( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isGun( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	local Ammo = 0
	for Key, AmmoEnt in pairs( this.AmmoLink ) do
		if AmmoEnt and AmmoEnt:IsValid( ) then
			Ammo = Ammo + ( AmmoEnt.Ammo or 0 )
		end
	end
	return Ammo
end

-- [ Ammo Functions ] --

-- Returns true if the entity is an ACF ammo crate
function ents_methods:acfIsAmmo( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if isAmmo( this ) and not restrictInfo( SF.instance.player, this ) then return true else return false end
end

-- Returns the rounds left in an acf ammo crate
function ents_methods:acfRounds( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isAmmo( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	return this.Ammo or 0
end

-- Returns the type of weapon the ammo in an ACF ammo crate loads into
function ents_methods:acfRoundType( ) --cartridge?
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isAmmo( this ) then return "" end
	if restrictInfo( SF.instance.player, this ) then return "" end
	return this.RoundId or ""
end

-- Returns the type of ammo in a crate or gun
function ents_methods:acfAmmoType( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isAmmo( this ) or isGun( this ) then return "" end
	if restrictInfo( SF.instance.player, this ) then return "" end
	return this.BulletData[ "Type" ] or ""
end

-- Returns the caliber of an ammo or gun
function ents_methods:acfCaliber( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isAmmo( this ) or isGun( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	return ( this.Caliber or 0 ) * 10
end

-- Returns the muzzle velocity of the ammo in a crate or gun
function ents_methods:acfMuzzleVel( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isAmmo( this ) or isGun( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	return math.Round( ( this.BulletData[ "MuzzleVel" ] or 0 ) * ACF.VelScale, 3 )
end

-- Returns the mass of the projectile in a crate or gun
function ents_methods:acfProjectileMass( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isAmmo( this ) or isGun( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	return math.Round( this.BulletData[ "ProjMass" ] or 0, 3 )
end

-- Returns the number of projectiles in a flechette round
function ents_methods:acfFLSpikes( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isAmmo( this ) or isGun( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	if not this.BulletData[ "Type" ] == "FL" then return 0 end
	return this.BulletData[ "Flechettes" ] or 0
end

-- Returns the mass of a single spike in a FL round in a crate or gun
function ents_methods:acfFLSpikeMass( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isAmmo( this ) or isGun( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	if not this.BulletData[ "Type" ] == "FL" then return 0 end
	return math.Round( this.BulletData[ "FlechetteMass" ] or 0, 3)
end

-- Returns the radius of the spikes in a flechette round in mm
function ents_methods:acfFLSpikeRadius( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isAmmo( this ) or isGun( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	if not this.BulletData[ "Type" ] == "FL" then return 0 end
	return math.Round( ( this.BulletData[ "FlechetteRadius" ] or 0 ) * 10, 3)
end

-- Returns the penetration of an AP, APHE, or HEAT round
function ents_methods:acfPenetration( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isAmmo( this ) or isGun( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	local Type = this.BulletData[ "Type" ] or ""
	local Energy
	if Type == "AP" or Type == "APHE" then
		Energy = ACF_Kinetic( this.BulletData[ "MuzzleVel" ] * 39.37, this.BulletData[ "ProjMass" ] - ( this.BulletData[ "FillerMass" ] or 0 ), this.BulletData[ "LimitVel" ] )
		return math.Round((Energy.Penetration/this.BulletData["PenAera"])*ACF.KEtoRHA,3)
	elseif Type == "HEAT" then
		Energy = ACF_Kinetic( this.BulletData[ "SlugMV" ] * 39.37, this.BulletData[ "SlugMass" ], 9999999 )
		return math.Round( ( Energy.Penetration / this.BulletData[ "SlugPenAera" ] ) * ACF.KEtoRHA, 3 )
	elseif Type == "FL" then
		Energy = ACF_Kinetic( this.BulletData[ "MuzzleVel" ] * 39.37 , this.BulletData[ "FlechetteMass" ], this.BulletData[ "LimitVel" ] )
		return math.Round( ( Energy.Penetration / this.BulletData[ "FlechettePenArea" ] ) * ACF.KEtoRHA, 3 )
	end
	return 0
end

-- Returns the blast radius of an HE, APHE, or HEAT round
function ents_methods:acfBlastRadius( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isAmmo( this ) or isGun( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	local Type = this.BulletData[ "Type" ] or ""
	if Type == "HE" or Type == "APHE" then
		return math.Round( this.BulletData[ "FillerMass" ]^0.33 * 8, 3 )
	elseif Type == "HEAT" then
		return math.Round( ( this.BulletData[ "FillerMass" ]/3)^0.33 * 8, 3 )
	end
	return 0
end


-- [ Armor Functions ] --

-- Returns the current health of an entity
function ents_methods:acfPropHealth( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not validPhysics( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	if not ACF_Check( this ) then return 0 end
	return math.Round( this.ACF.Health or 0, 3 )
end

-- Returns the current armor of an entity
function ents_methods:acfPropArmor( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not validPhysics( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	if not ACF_Check( this ) then return 0 end
	return math.Round( this.ACF.Armour or 0, 3 )
end

-- Returns the max health of an entity
function ents_methods:acfPropHealthMax( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not validPhysics( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	if not ACF_Check( this ) then return 0 end
	return math.Round( this.ACF.MaxHealth or 0, 3 )
end

-- Returns the max armor of an entity
function ents_methods:acfPropArmorMax( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not validPhysics( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	if not ACF_Check( this ) then return 0 end
	return math.Round( this.ACF.MaxArmour or 0, 3 )
end

-- Returns the ductility of an entity
function ents_methods:acfPropDuctility( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not validPhysics( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	if not ACF_Check( this ) then return 0 end
	return ( this.ACF.Ductility or 0 ) * 100
end

-- [ Fuel Functions ] --

-- Returns true if the entity is an ACF fuel tank
function ents_methods:acfIsFuel( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if isFuel( this ) and not restrictInfo( SF.instance.player, this ) then return true else return false end
end

-- Returns true if the current engine requires fuel to run
function ents_methods:acfFuelRequired( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isEngine( this ) then return false end
	if restrictInfo( SF.instance.player, this ) then return false end
	return ( this.RequiresFuel and true ) or false
end

-- Sets the ACF fuel tank refuel duty status, which supplies fuel to other fuel tanks
function ents_methods:acfRefuelDuty( on )
	SF.CheckType( self, ents_metatable )
	SF.CheckType( on, "boolean" )
	local this = unwrap( self )
	
	if not isFuel( this ) then return end
	if restrictInfo( SF.instance.player, this ) then return end
	this:TriggerInput( "Refuel Duty", on )
end

-- Returns the remaining liters or kilowatt hours of fuel in an ACF fuel tank or engine
function ents_methods:acfFuel( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if isFuel( this ) then
		if restrictInfo( SF.instance.player, this ) then return 0 end
		return math.Round( this.Fuel, 3 )
	elseif isEngine( this ) then
		if restrictInfo( SF.instance.player, this ) then return 0 end
		if not #(this.FuelLink) then return 0 end --if no tanks, return 0
		
		local liters = 0
		for _, tank in pairs( this.FuelLink ) do
			if not validPhysics( tank ) then continue end
			if tank.Active then liters = liters + tank.Fuel end
		end
		
		return math.Round( liters, 3 )
	end
	return 0
end

-- Returns the amount of fuel in an ACF fuel tank or linked to engine as a percentage of capacity
function ents_methods:acfFuelLevel( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if isFuel( this ) then
		if restrictInfo( SF.instance.player, this ) then return 0 end
		return math.Round( this.Fuel / this.Capacity, 3 )
	elseif isEngine( this ) then
		if restrictInfo( SF.instance.player, this ) then return 0 end
		if not #( this.FuelLink ) then return 0 end --if no tanks, return 0
		
		local liters = 0
		local capacity = 0
		for _, tank in pairs( this.FuelLink ) do
			if not validPhysics( tank ) then continue end
			if tank.Active then 
				capacity = capacity + tank.Capacity
				liters = liters + tank.Fuel
			end
		end
		if not capacity > 0 then return 0 end
		
		return math.Round( liters / capacity, 3 )
	end
	return 0
end

-- Returns the current fuel consumption in liters per minute or kilowatts of an engine
function ents_methods:acfFuelUse( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isEngine( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	if not #( this.FuelLink ) then return 0 end --if no tanks, return 0
	
	local Tank = nil
	for _, fueltank in pairs( this.FuelLink ) do
		if not validPhysics( fueltank ) then continue end
		if fueltank.Fuel > 0 and fueltank.Active then Tank = fueltank break end
	end
	if not tank then return 0 end
	
	local Consumption
	if this.FuelType == "Electric" then
		Consumption = 60 * ( this.Torque * this.FlyRPM / 9548.8 ) * this.FuelUse
	else
		local Load = 0.3 + this.Throttle * 0.7
		Consumption = 60 * Load * this.FuelUse * ( this.FlyRPM / this.PeakKwRPM ) / ACF.FuelDensity[ tank.FuelType ]
	end
	return math.Round( Consumption, 3 )
end

-- Returns the peak fuel consumption in liters per minute or kilowatts of an engine at powerband max, for the current fuel type the engine is using
function ents_methods:acfPeakFuelUse( )
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	
	if not isEngine( this ) then return 0 end
	if restrictInfo( SF.instance.player, this ) then return 0 end
	if not #( this.FuelLink ) then return 0 end --if no tanks, return 0
	
	local fuel = "Petrol"
	local Tank = nil
	for _, fueltank in pairs( this.FuelLink ) do
		if fueltank.Fuel > 0 and fueltank.Active then Tank = fueltank break end
	end
	if tank then fuel = tank.Fuel end
	
	local Consumption
	if this.FuelType == "Electric" then
		Consumption = 60 * ( this.PeakTorque * this.LimitRPM / ( 4 * 9548.8 ) ) * this.FuelUse
	else
		local Load = 0.3 + this.Throttle * 0.7
		Consumption = 60 * this.FuelUse / ACF.FuelDensity[ fuel ]
	end
	return math.Round( Consumption, 3 )
end
