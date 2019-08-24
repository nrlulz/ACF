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

local function isEngine ( ent )
	if not validPhysics( ent ) then return false end
	if ( ent:GetClass() == "acf_engine" ) then return true else return false end
end

local function isGearbox ( ent )
	if not validPhysics( ent ) then return false end
	if ( ent:GetClass() == "acf_gearbox" ) then return true else return false end
end

local function isGun ( ent )
	if not validPhysics( ent ) then return false end
	if ( ent:GetClass() == "acf_gun" ) then return true else return false end
end

local function isAmmo ( ent )
	if not validPhysics( ent ) then return false end
	if ( ent:GetClass() == "acf_ammo" ) then return true else return false end
end

local function isFuel ( ent )
	if not validPhysics(ent) then return false end
	if ( ent:GetClass() == "acf_fueltank" ) then return true else return false end
end

local function reloadTime( ent )
	if ent.CurrentShot and ent.CurrentShot > 0 then return ent.ReloadTime end
	return ent.MagReload
end

local propProtectionInstalled = FindMetaTable("Entity").CPPIGetOwner and true

local function restrictInfo ( ent )
	if not propProtectionInstalled then return false end
	if GetConVar("sbox_acf_restrictinfo"):GetInt() ~= 0 then
		if ent:CPPIGetOwner() ~= SF.instance.player then return true else return false end
	end
	return false
end

----------------------------------------
-- ACF Library

local acf_library = SF.RegisterLibrary("acf")

local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

local ents_metatable, ents_methods, vec_meta, ang_meta, wrap, unwrap, vwrap, vunwrap, awrap, aunwrap

SF.Permissions.registerPrivilege("acf.createMobility", "Create acf engine", "Allows the user to create ACF engines and gearboxes")
SF.Permissions.registerPrivilege("acf.createFuelTank", "Create acf fuel tank", "Allows the user to create ACF fuel tanks")
SF.Permissions.registerPrivilege("acf.createGun", "Create acf gun", "Allows the user to create ACF guns")
SF.Permissions.registerPrivilege("acf.createAmmo", "Create acf ammo", "Allows the user to create ACF ammoboxes")
SF.Permissions.registerPrivilege("entities.acf", "ACF", "Allows the user to control ACF components", { entities = {} })

local plyCount = SF.LimitObject("acf_components", "acf_components", -1, "The number of ACF components allowed to spawn via Starfall")
local plyBurst = SF.BurstObject("acf_components", "acf_components", 4, 4, "Rate ACF components can be spawned per second.", "Number of ACF components that can be spawned in a short time.")

local function propOnDestroy(ent, instance)
	local ply = instance.player
	plyCount:free(ply, 1)
	instance.data.props.props[ent] = nil
end

local function register(ent, instance)
	ent:CallOnRemove("starfall_prop_delete", propOnDestroy, instance)
	plyCount:free(instance.player, -1)
	instance.data.props.props[ent] = true
end

--- Returns true if functions returning sensitive info are restricted to owned props
-- @server
-- @return True if restriced, False if not
function acf_library.infoRestricted()
	return GetConVar("sbox_acf_restrictinfo"):GetInt() ~= 0
end

--- Returns current ACF drag divisor
-- @server
-- @return The current drag divisor
function acf_library.dragDivisor()
	return ACF.DragDiv
end

--- Returns the effective armor given an armor value and hit angle
-- @server
-- @return The effective armor
function acf_library.effectiveArmor(armor, angle)
	checkluatype(armor, TYPE_NUMBER)
	checkluatype(angle, TYPE_NUMBER)
	
	return math.Round(armor / math.abs(math.cos(math.rad(math.min(angle, 89.999)))), 1)
end

-- Dont create a cache on init because maby a new entity get registered later on?
local id_name_cache = {}
local function idFromName(list, name)
	id_name_cache[list] = id_name_cache[list] or {}
	
	if id_name_cache[list][name] then return id_name_cache[list][name] end
	
	for id, data in pairs(list) do
		if data.name == name then
			id_name_cache[list][name] = id
			
			return id
		end
	end
end

--- Creates a engine or gearbox given the id or name
-- @param pos Position of created engine or gearbox
-- @param ang Angle of created engine or gearbox
-- @param id id or name of the engine or gearbox to create
-- @param frozen True to spawn frozen
-- @param gear_ratio A table containing the gear ratios, only applied if the mobility is a gearbox. -1 is final drive
-- @server
-- @return The created engine or gearbox
function acf_library.createMobility(pos, ang, id, frozen, gear_ratio)
	checkpermission(SF.instance, nil, "acf.createMobility")
	
	local instance = SF.instance
	local ply = instance.player
	
	if not hook.Run("CanTool", ply, {Hit = true, Entity = game.GetWorld()}, "acfmenu") then SF.Throw("No permission to spawn ACF components", 2) end
	
	checktype(pos, vec_meta)
	checktype(ang, ang_meta)
	checkluatype(id, TYPE_STRING)
	frozen = frozen and true or false
	gear_ratio = type(gear_ratio) == "table" and gear_ratio or {}
	
	local pos = vunwrap(pos)
	local ang = aunwrap(ang)
	
	local list_entries = ACF.Weapons.Mobility
	
	-- Not a valid id, try name
	if not list_entries[id] then
		id = idFromName(list_entries, id)
		
		-- Name is also invalid, error
		if not id or not list_entries[id] then
			SF.Throw("Invalid id or name", 2)
		end
	end
	
	local type_id = list_entries[id]
	local dupe_class = duplicator.FindEntityClass(type_id.ent) 
	
	if not dupe_class then SF.Throw("Didn't find entity duplicator records", 2) end
	
	plyBurst:use(ply, 1)
	plyCount:checkuse(ply, 1)
	
	local args_table = {
		SF.clampPos(pos),
		ang,
		id
	}
	
	if type_id.ent == "acf_gearbox" then
		for i = 1, 9 do
			args_table[3 + i] = type(gear_ratio[i]) == "number" and gear_ratio[i] or (i < type_id.gears and i / 10 or -0.1)
		end
		
		args_table[13] = type(gear_ratio[-1]) == "number" and gear_ratio[-1] or 0.5
	end
	
	local ent = dupe_class.Func(ply, unpack(args_table))
	ent:Activate()
	
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(not frozen)
	end
	
	if instance.data.props.undo then
		undo.Create("ACF Mobility")
			undo.SetPlayer(ply)
			undo.AddEntity(ent)
		undo.Finish("ACF Mobility (" .. tostring(id) .. ")")
	end
	
	ply:AddCleanup("props", ent)
	register(ent, instance)
	
	return SF.WrapObject(ent)
end

--- Returns the specs of the engine or gearbox
-- @param id id or name of the engine or gearbox
-- @server
-- @return The specs table
function acf_library.getMobilitySpecs(id)
	checkluatype(id, TYPE_STRING)
	
	local list_entries = ACF.Weapons.Mobility
	
	-- Not a valid id, try name
	if not list_entries[id] then
		id = idFromName(list_entries, id)
		
		-- Name is also invalid, error
		if not id or not list_entries[id] then
			SF.Throw("Invalid id or name", 2)
		end
	end
	
	local specs = table.Copy(list_entries[id])
	specs.BaseClass = nil
	
	return specs
end

--- Returns a list of all mobility components
-- @server
-- @return The mobility component list
function acf_library.getAllMobility()
	local list = {}
	
	for id, _ in pairs(ACF.Weapons.Mobility) do
		table.insert(list, id)
	end
	
	return list
end

--- Returns a list of all engines
-- @server
-- @return The engine list
function acf_library.getAllEngines()
	local list = {}
	
	for id, d in pairs(ACF.Weapons.Mobility) do
		if d.ent == "acf_engine" then
			table.insert(list, id)
		end
	end
	
	return list
end

--- Returns a list of all gearboxes
-- @server
-- @return The gearbox list
function acf_library.getAllGearboxes()
	local list = {}
	
	for id, d in pairs(ACF.Weapons.Mobility) do
		if d.ent == "acf_gearbox" then
			table.insert(list, id)
		end
	end
	
	return list
end

--- Creates a fuel tank given the id
-- @param pos Position of created fuel tank
-- @param ang Angle of created fuel tank
-- @param id id of the fuel tank to create
-- @param frozen True to spawn frozen
-- @param fueltype The type of fuel to use (Diesel, Electric, Petrol)
-- @server
-- @return The created fuel tank
function acf_library.createFuelTank(pos, ang, id, fueltype, frozen)
	checkpermission(SF.instance, nil, "acf.createFuelTank")
	
	local instance = SF.instance
	local ply = instance.player
	
	if not hook.Run("CanTool", ply, {Hit = true, Entity = game.GetWorld()}, "acfmenu") then SF.Throw("No permission to spawn ACF components", 2) end
	
	checktype(pos, vec_meta)
	checktype(ang, ang_meta)
	checkluatype(id, TYPE_STRING)
	frozen = frozen and true or false
	fueltype = fueltype or "Diesel"
	checkluatype(fueltype, TYPE_STRING)
	
	local pos = vunwrap(pos)
	local ang = aunwrap(ang)
	
	if fueltype ~= "Diesel" and fueltype ~= "Electric" and fueltype ~= "Petrol" then SF.Throw("Invalid fuel type") end
	
	local list_entries = ACF.Weapons.FuelTanks
	if not list_entries[id] then SF.Throw("Invalid id", 2) end
	
	local type_id = list_entries[id]
	local dupe_class = duplicator.FindEntityClass(type_id.ent) 
	
	if not dupe_class then SF.Throw("Didn't find entity duplicator records", 2) end
	
	plyBurst:use(ply, 1)
	plyCount:checkuse(ply, 1)
	
	local ent = dupe_class.Func(ply, SF.clampPos(pos), ang, "Basic_FuelTank", id, fueltype)
	ent:Activate()
	
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(not frozen)
	end
	
	if instance.data.props.undo then
		undo.Create("ACF Fuel Tank")
			undo.SetPlayer(ply)
			undo.AddEntity(ent)
		undo.Finish("ACF Fuel Tank (" .. tostring(id) .. ")")
	end
	
	ply:AddCleanup("props", ent)
	register(ent, instance)
	
	return SF.WrapObject(ent)
end

--- Returns the specs of the fuel tank
-- @param id id of the engine or gearbox
-- @server
-- @return The specs table
function acf_library.getFuelTankSpecs(id)
	checkluatype(id, TYPE_STRING)
	
	local list_entries = ACF.Weapons.FuelTanks
	if not list_entries[id] then SF.Throw("Invalid id", 2) end
	
	local specs = table.Copy(list_entries[id])
	specs.BaseClass = nil
	
	return specs
end

--- Returns a list of all fuel tanks
-- @server
-- @return The fuel tank list
function acf_library.getAllFuelTanks()
	local list = {}
	
	for id, _ in pairs(ACF.Weapons.FuelTanks) do
		table.insert(list, id)
	end
	
	return list
end

--- Creates a fun given the id or name
-- @param pos Position of created gun
-- @param ang Angle of created gun
-- @param id id or name of the gun to create
-- @param frozen True to spawn frozen
-- @server
-- @return The created gun
function acf_library.createGun(pos, ang, id, frozen)
	checkpermission(SF.instance, nil, "acf.createGun")
	
	local instance = SF.instance
	local ply = instance.player
	
	if not hook.Run("CanTool", ply, {Hit = true, Entity = game.GetWorld()}, "acfmenu") then SF.Throw("No permission to spawn ACF components", 2) end
	
	checktype(pos, vec_meta)
	checktype(ang, ang_meta)
	checkluatype(id, TYPE_STRING)
	frozen = frozen and true or false
	
	local pos = vunwrap(pos)
	local ang = aunwrap(ang)
	
	local list_entries = ACF.Weapons.Guns
	
	-- Not a valid id, try name
	if not list_entries[id] then
		id = idFromName(list_entries, id)
		
		-- Name is also invalid, error
		if not id or not list_entries[id] then
			SF.Throw("Invalid id or name", 2)
		end
	end
	
	local type_id = list_entries[id]
	local dupe_class = duplicator.FindEntityClass(type_id.ent) 
	
	if not dupe_class then SF.Throw("Didn't find entity duplicator records", 2) end
	
	plyBurst:use(ply, 1)
	plyCount:checkuse(ply, 1)
	
	local ent = dupe_class.Func(ply, SF.clampPos(pos), ang, id)
	ent:Activate()
	
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(not frozen)
	end
	
	if instance.data.props.undo then
		undo.Create("ACF Gun")
			undo.SetPlayer(ply)
			undo.AddEntity(ent)
		undo.Finish("ACF Gun (" .. tostring(id) .. ")")
	end
	
	ply:AddCleanup("props", ent)
	register(ent, instance)
	
	return SF.WrapObject(ent)
end

--- Returns the specs of gun
-- @param id id or name of the gun
-- @server
-- @return The specs table
function acf_library.getGunSpecs(id)
	checkluatype(id, TYPE_STRING)
	
	local list_entries = ACF.Weapons.Guns
	
	-- Not a valid id, try name
	if not list_entries[id] then
		id = idFromName(list_entries, id)
		
		-- Name is also invalid, error
		if not id or not list_entries[id] then
			SF.Throw("Invalid id or name", 2)
		end
	end
	
	local specs = table.Copy(list_entries[id])
	specs.BaseClass = nil
	
	return specs
end

--- Returns a list of all guns
-- @server
-- @return The guns list
function acf_library.getAllGuns()
	local list = {}
	
	for id, _ in pairs(ACF.Weapons.Guns) do
		table.insert(list, id)
	end
	
	return list
end

-- Set ammo properties
local ammo_properties = {}

for id, data in pairs(list.Get("ACFRoundTypes")) do
	ammo_properties[id] = {
		name = data.name,
		desc = data.desc,
		model = data.model,
		gun_blacklist = ACF.AmmoBlacklist[id],
		create_data = {}
	}
end

-- No other way to get this so hardcoded here it is ;(
local ammo_property_data = {
	propellantLength = {
		type = "number",
		default = 0.01,
		data = 3,
		convert = function(value) return value end
	},
	
	projectileLength = {
		type = "number",
		default = 15,
		data = 4,
		convert = function(value) return value end
	},
	
	heFillerVolume = {
		type = "number",
		default = 0,
		data = 5,
		convert = function(value) return value end
	},
	
	tracer = {
		type = "boolean",
		default = false,
		data = 10,
		convert = function(value) return value and 0.5 or 0 end
	}
}

ammo_properties.AP.create_data = {
	propellantLength = ammo_property_data.propellantLength,
	projectileLength = ammo_property_data.projectileLength,
	tracer = ammo_property_data.tracer
}

ammo_properties.APHE.create_data = {
	propellantLength = ammo_property_data.propellantLength,
	projectileLength = ammo_property_data.projectileLength,
	heFillerVolume = ammo_property_data.heFillerVolume,
	tracer = ammo_property_data.tracer
}

ammo_properties.FL.create_data = {
	propellantLength = ammo_property_data.propellantLength,
	projectileLength = ammo_property_data.projectileLength,
	flechettes = {
		type = "number",
		default = 6,
		data = 5,
		convert = function(value) return value end
	},
	flechettesSpread = {
		type = "number",
		default = 10,
		data = 6,
		convert = function(value) return value end
	},
	tracer = ammo_property_data.tracer
}

ammo_properties.HE.create_data = {
	propellantLength = ammo_property_data.propellantLength,
	projectileLength = ammo_property_data.projectileLength,
	heFillerVolume = ammo_property_data.heFillerVolume,
	tracer = ammo_property_data.tracer
}

ammo_properties.HEAT.create_data = {
	propellantLength = ammo_property_data.propellantLength,
	projectileLength = ammo_property_data.projectileLength,
	heFillerVolume = ammo_property_data.heFillerVolume,
	crushConeAngle = {
		type = "number",
		default = 0,
		data = 6,
		convert = function(value) return value end
	},
	tracer = ammo_property_data.tracer
}

ammo_properties.HP.create_data = {
	propellantLength = ammo_property_data.propellantLength,
	projectileLength = ammo_property_data.projectileLength,
	heFillerVolume = ammo_property_data.heFillerVolume,
	hollowPointCavityVolume = {
		type = "number",
		default = 0,
		data = 5,
		convert = function(value) return value end
	},
	tracer = ammo_property_data.tracer
}

ammo_properties.SM.create_data = {
	propellantLength = ammo_property_data.propellantLength,
	projectileLength = ammo_property_data.projectileLength,
	smokeFillerVolume = ammo_property_data.heFillerVolume,
	wpFillerVolume = {
		type = "number",
		default = 0,
		data = 6,
		convert = function(value) return value end
	},
	fuseTime = {
		type = "number",
		default = 0,
		data = 7,
		convert = function(value) return value end
	},
	tracer = ammo_property_data.tracer
}

ammo_properties.Refill.create_data = {}

--- Creates a ammo box given the id
-- @param pos Position of created ammo box
-- @param ang Angle of created ammo box
-- @param id id of the ammo box to create
-- @param gun_id id of the gun
-- @param ammo_id id of the ammo
-- @param frozen True to spawn frozen
-- @param ammo_data the ammo data
-- @server
-- @return The created ammo box
-- @usage
-- If ammo_data isn't provided default values will be used (same as in the ACF menu)
-- Possible values for ammo_data corresponding to ammo_id:
-- 
-- AP:
-- \- propellantLength (number)
-- \- projectileLength (number)
-- \- tracer (bool)
-- 
-- APHE:
-- \- propellantLength (number)
-- \- projectileLength (number)
-- \- heFillerVolume (number)
-- \- tracer (bool)
-- 
-- FL:
-- \- propellantLength (number)
-- \- projectileLength (number)
-- \- flechettes (number)
-- \- flechettesSpread (number)
-- \- tracer (bool)
-- 
-- HE:
-- \- propellantLength (number)
-- \- projectileLength (number)
-- \- heFillerVolume (number)
-- \- tracer (bool)
-- 
-- HEAT:
-- \- propellantLength (number)
-- \- projectileLength (number)
-- \- heFillerVolume (number)
-- \- crushConeAngle (number)
-- \- tracer (bool)
-- 
-- HP:
-- \- propellantLength (number)
-- \- projectileLength (number)
-- \- heFillerVolume (number)
-- \- hollowPointCavityVolume (number)
-- \- tracer (bool)
-- 
-- SM:
-- \- propellantLength (number)
-- \- projectileLength (number)
-- \- smokeFillerVolume (number)
-- \- wpFillerVolume (number)
-- \- fuseTime (number)
-- \- tracer (bool)
-- 
-- Refil:
-- 
function acf_library.createAmmo(pos, ang, id, gun_id, ammo_id, frozen, ammo_data)
	checkpermission(SF.instance, nil, "acf.createAmmo")
	
	local instance = SF.instance
	local ply = instance.player
	
	if not hook.Run("CanTool", ply, {Hit = true, Entity = game.GetWorld()}, "acfmenu") then SF.Throw("No permission to spawn ACF components", 2) end
	
	checktype(pos, vec_meta)
	checktype(ang, ang_meta)
	checkluatype(id, TYPE_STRING)
	checkluatype(ammo_id, TYPE_STRING)
	checkluatype(gun_id, TYPE_STRING)
	frozen = frozen and true or false
	ammo_data = type(ammo_data) == "table" and ammo_data or {}
	
	local pos = vunwrap(pos)
	local ang = aunwrap(ang)
	
	local list_entries = ACF.Weapons.Ammo
	local type_id = list_entries[id]
	if not type_id then SF.Throw("Invalid id", 2) end
	
	local ammo = ammo_properties[ammo_id]
	if not ammo then SF.Throw("Invalid ammo id", 2) end
	
	local gun_list_entries = ACF.Weapons.Guns
	if not gun_list_entries[gun_id] then
		gun_id = idFromName(gun_list_entries, gun_id)
		
		if not gun_id or not gun_list_entries[gun_id] then
			SF.Throw("Invalid gun id or name", 2)
		end
	end
	
	local dupe_class = duplicator.FindEntityClass(type_id.ent) 
	if not dupe_class then SF.Throw("Didn't find entity duplicator records", 2) end
	
	plyBurst:use(ply, 1)
	plyCount:checkuse(ply, 1)
	
	local args_table = {
		SF.clampPos(pos),
		ang,
		id,
		gun_id,
		ammo_id,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
	}
	
	for k, v in pairs(ammo.create_data) do
		local value = ammo_data[k]
		
		if value then
			if type(value) == v.type then
				args_table[3 + v.data] = v.convert(value)
			else
				args_table[3 + v.data] = v.convert(v.default)
			end
		else
			args_table[3 + v.data] = v.convert(v.default)
		end
	end
	
	local ent = dupe_class.Func(ply, unpack(args_table))
	ent:Activate()
	
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(not frozen)
	end
	
	if instance.data.props.undo then
		undo.Create("ACF Ammo")
			undo.SetPlayer(ply)
			undo.AddEntity(ent)
		undo.Finish("ACF Ammo (" .. tostring(id) .. ")")
	end
	
	ply:AddCleanup("props", ent)
	register(ent, instance)
	
	return SF.WrapObject(ent)
end

--- Returns the specs of the ammo
-- @param id id of the ammo
-- @server
-- @return The specs table
function acf_library.getAmmoSpecs(id)
	checkluatype(id, TYPE_STRING)
	
	local data = ammo_properties[id]
	if not data then SF.Throw("Invalid id", 2) end
	
	local properties = {}
	for name, d in pairs(data.create_data) do
		properties[name] = {
			type = d.type,
			default = d.default,
			convert = d.convert
		}
	end
	
	return {
		name = data.name,
		desc = data.desc,
		model = data.model,
		properties = table.Copy(data.create_data)--properties
	}
end

--- Returns a list of all ammo types
-- @server
-- @return The ammo list
function acf_library.getAllAmmo()
	local list = {}
	
	for id, _ in pairs(ammo_properties) do
		table.insert(list, id)
	end
	
	return list
end

--- Returns a list of all ammo boxes
-- @server
-- @return The ammo box list
function acf_library.getAllAmmoBoxes()
	local list = {}
	
	for id, _ in pairs(ACF.Weapons.Ammo) do
		table.insert(list, id)
	end
	
	return list
end

----------------------------------------
-- Entity Methods

SF.AddHook("postload", function()
	ents_metatable = SF.Entities.Metatable
	ents_methods = SF.Entities.Methods
	
	vec_meta = SF.Vectors.Metatable
	ang_meta = SF.Angles.Metatable
	
	wrap = SF.Entities.Wrap
	unwrap = SF.Entities.Unwrap
	vwrap = SF.Vectors.Wrap
	vunwrap = SF.Vectors.Unwrap
	awrap = SF.Angles.Wrap
	aunwrap = SF.Angles.Unwrap

	-- [General Functions ] --

	-- Moved to acf lib
	-- Returns true if functions returning sensitive info are restricted to owned props
	--[[function ents_methods:acfInfoRestricted ()
		return GetConVar( "sbox_acf_restrictinfo" ):GetInt() ~= 0
	end]]

	--- Returns true if this entity contains sensitive info and is not accessable to us
	-- @server
	function ents_methods:acfIsInfoRestricted ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		return restrictInfo( this )
	end

	--- Returns the short name of an ACF entity
	-- @server
	function ents_methods:acfNameShort ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if isEngine( this ) then return this.Id or "" end
		if isGearbox( this ) then return this.Id or "" end
		if isGun( this ) then return this.Id or "" end
		if isAmmo( this ) then return this.RoundId or "" end
		if isFuel( this ) then return this.FuelType .. " " .. this.SizeId end
		
		return ""
	end

	--- Returns the capacity of an acf ammo crate or fuel tank
	-- @server
	function ents_methods:acfCapacity ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not ( isAmmo( this ) or isFuel( this ) ) then return 0 end
		if restrictInfo( this ) then return 0 end
		return this.Capacity or 1
	end

	--- Returns true if the acf engine, fuel tank, or ammo crate is active
	-- @server
	function ents_methods:acfGetActive ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not ( isEngine( this ) or isAmmo( this ) or isFuel( this ) ) then return false end
		if restrictInfo( this ) then return false end
		if not isAmmo( this ) then
			if this.Active then return true end
		else
			if this.Load then return true end
		end
		return false
	end

	--- Turns an ACF engine, ammo crate, or fuel tank on or off
	-- @server
	function ents_methods:acfSetActive ( on )
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not ( isEngine( this ) or isAmmo( this ) or isFuel( this ) ) then return end
		this:TriggerInput( "Active", on and 1 or 0 )    
	end

	--- Returns true if hitpos is on a clipped part of prop
	-- @server
	function ents_methods:acfHitClip( hitpos )
		checktype( self, ents_metatable )
		checktype( hitpos, vec_meta )
		local this = unwrap( self )
		local hitpos = vunwrap( hitpos )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" ) -- E2 has owner check so i guess having a check if the player has permission is sufficient enough?

		if ACF_CheckClips( nil, nil, this, hitpos ) then return true else return false end
	end

	local linkTables =
	{ -- link resources within each ent type. should point to an ent: true if adding link.Ent, false to add link itself
		acf_engine      = { GearLink = true, FuelLink = false },
		acf_gearbox     = { WheelLink = true, Master = false },
		acf_fueltank    = { Master = false },
		acf_gun         = { AmmoLink = false },
		acf_ammo        = { Master = false }
	}

	local function getLinks ( ent, enttype )    
		local ret = {}
		-- find the link resources available for this ent type
		for entry, mode in pairs( linkTables[ enttype ] ) do
			if not ent[ entry ] then error( "Couldn't find link resource " .. entry .. " for entity " .. tostring( ent ) ) return end

			-- find all the links inside the resources
			for _, link in pairs( ent[ entry ] ) do
				ret[ #ret + 1 ] = mode and wrap( link.Ent ) or link
			end
		end

		return ret
	end

	local function searchForGearboxLinks ( ent )
		local boxes = ents.FindByClass( "acf_gearbox" )

		local ret = {}

		for _, box in pairs( boxes ) do
			if IsValid( box ) then
				for _, link in pairs( box.WheelLink ) do
					if link.Ent == ent then
						ret[ #ret + 1 ] = wrap( box )
						break
					end
				end
			end
		end

		return ret
	end

	--- Returns the ACF links associated with the entity
	-- @server
	function ents_methods:acfLinks ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		local enttype = this:GetClass()

		if not linkTables[ enttype ] then
			return searchForGearboxLinks( this )
		end

		return getLinks( this, enttype )    
	end

	--- Returns the full name of an ACF entity
	-- @server
	function ents_methods:acfName ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

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

	--- Returns the type of ACF entity
	-- @server
	function ents_methods:acfType ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

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

	--- Perform ACF links
	-- @server
	function ents_methods:acfLinkTo ( target, notify )
		checktype( self, ents_metatable )
		checktype( target, ents_metatable )

		local this = unwrap( self )
		local tar = unwrap( target )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		if not ( tar and tar:IsValid() ) then SF.Throw( "Invalid Link Entity", 2 ) end

		checkpermission( SF.instance, this, "entities.acf" )
		checkpermission( SF.instance, tar, "entities.acf" )

		if not ( isGun( this ) or isEngine( this ) or isGearbox( this ) ) then
			SF.Throw( "Target must be a gun, engine, or gearbox", 2 )
		end

		local success, msg = this:Link( tar )
		if notify then
			ACF_SendNotify( self.player, success, msg )
		end
		return success, msg
	end

	--- Perform ACF unlinks
	-- @server
	function ents_methods:acfUnlinkFrom ( target, notify )
		checktype( self, ents_metatable )
		checktype( target, ents_metatable )

		local this = unwrap( self )
		local tar = unwrap( target )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		if not ( tar and tar:IsValid() ) then SF.Throw( "Invalid Link Entity", 2 ) end

		checkpermission( SF.instance, this, "entities.acf" )
		checkpermission( SF.instance, tar, "entities.acf" )

		if not ( isGun( this ) or isEngine( this ) or isGearbox( this ) ) then
			SF.Throw( "Target must be a gun, engine, or gearbox", 2 )
		end

		local success, msg = this:Unlink( tar )
		if notify then
			ACF_SendNotify( self.player, success, msg )
		end
		return success, msg
	end

	--- returns any wheels linked to this engine/gearbox or child gearboxes
	-- @server
	function ents_methods:acfGetLinkedWheels ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		if not ( isEngine(this) or isGearbox(this) ) then SF.Throw( "Target must be a engine, or gearbox", 2 ) end

		local wheels = {}
		for k, ent in pairs( ACF_GetLinkedWheels( this ) ) do
			table.insert( wheels, wrap( ent ) )
		end

		return wheels
	end

	-- [ Engine Functions ] --

	--- Returns true if the entity is an ACF engine
	-- @server
	function ents_methods:acfIsEngine ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		return isEngine( this )
	end

	--- Returns true if an ACF engine is electric
	-- @server
	function ents_methods:acfIsElectric ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		return this.iselec == true
	end

	--- Returns the torque in N/m of an ACF engine
	-- @server
	function ents_methods:acfMaxTorque ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return 0 end
		return this.PeakTorque or 0
	end

	--- Returns the torque in N/m of an ACF engine with fuel
	-- @server
	function ents_methods:acfMaxTorqueWithFuel ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return 0 end
		return (this.PeakTorque or 0) * (ACF.TorqueBoost or 0)
	end

	local function getMaxPower( ent )
		local peakpower
		
		if ent.iselec then
			peakpower = math.floor( ent.PeakTorque * ent.LimitRPM / ( 4 * 9548.8 ) )
		else
			peakpower = math.floor( ent.PeakTorque * ent.PeakMaxRPM / 9548.8 )
		end
		
		return peakpower or 0
	end

	--- Returns the power in kW of an ACF engine
	-- @server
	function ents_methods:acfMaxPower ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		return isEngine( this ) and getMaxPower( this ) or 0
	end

	--- Returns the power in kW of an ACF engine with fuel
	-- @server
	function ents_methods:acfMaxPowerWithFuel ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		return (isEngine( this ) and getMaxPower( this ) or 0) * (ACF.TorqueBoost or 0)
	end

	--- Returns the idle rpm of an ACF engine
	-- @server
	function ents_methods:acfIdleRPM ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return 0 end
		return this.IdleRPM or 0
	end

	--- Returns the powerband min and max of an ACF Engine
	-- @server
	function ents_methods:acfPowerband ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return 0, 0 end
		return this.PeakMinRPM or 0, this.PeakMaxRPM or 0
	end

	--- Returns the powerband min of an ACF engine
	-- @server
	function ents_methods:acfPowerbandMin ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return 0 end
		return this.PeakMinRPM or 0
	end

	--- Returns the powerband max of an ACF engine
	-- @server
	function ents_methods:acfPowerbandMax ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return 0 end
		return this.PeakMaxRPM or 0
	end

	--- Returns the redline rpm of an ACF engine
	-- @server
	function ents_methods:acfRedline ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return 0 end
		return this.LimitRPM or 0
	end

	--- Returns the current rpm of an ACF engine
	-- @server
	function ents_methods:acfRPM ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		return math.floor( this.FlyRPM ) or 0
	end

	--- Returns the current torque of an ACF engine
	-- @server
	function ents_methods:acfTorque ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		return math.floor( this.Torque or 0 )
	end

	--- Returns the inertia of an ACF engine's flywheel
	-- @server
	function ents_methods:acfFlyInertia ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return nil end
		if restrictInfo( this ) then return 0 end
		return this.Inertia or 0
	end

	--- Returns the mass of an ACF engine's flywheel
	-- @server
	function ents_methods:acfFlyMass ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return nil end
		if restrictInfo( this ) then return 0 end
		return this.Inertia / ( 3.1416 )^2 or 0
	end

	--- Returns the current power of an ACF engine
	-- @server
	function ents_methods:acfPower ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		return math.floor( ( this.Torque or 0 ) * ( this.FlyRPM or 0 ) / 9548.8 )
	end

	--- Returns true if the RPM of an ACF engine is inside the powerband
	-- @server
	function ents_methods:acfInPowerband ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return false end
		if restrictInfo( this ) then return false end
		if ( this.FlyRPM < this.PeakMinRPM ) then return false end
		if ( this.FlyRPM > this.PeakMaxRPM ) then return false end

		return true
	end

	--- Returns the throttle value
	-- @server
	function ents_methods:acfGetThrottle ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		return ( this.Throttle or 0 ) * 100
	end

	--- Sets the throttle value for an ACF engine
	-- @server
	function ents_methods:acfSetThrottle ( throttle )
		checktype( self, ents_metatable )
		checkluatype( throttle, TYPE_NUMBER )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isEngine( this ) then return end
		this:TriggerInput( "Throttle", throttle )
	end


	-- [ Gearbox Functions ] --

	--- Returns true if the entity is an ACF gearbox
	-- @server
	function ents_methods:acfIsGearbox ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		return isGearbox( this )
	end

	--- Returns the current gear for an ACF gearbox
	-- @server
	function ents_methods:acfGear ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGearbox( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		return this.Gear or 0
	end

	--- Returns the number of gears for an ACF gearbox
	-- @server
	function ents_methods:acfNumGears ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGearbox( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		return this.Gears or 0
	end

	--- Returns the final ratio for an ACF gearbox
	-- @server
	function ents_methods:acfFinalRatio ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGearbox( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		return this.GearTable[ "Final" ] or 0
	end

	--- Returns the total ratio (current gear * final) for an ACF gearbox
	-- @server
	function ents_methods:acfTotalRatio ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGearbox( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		return this.GearRatio or 0
	end

	--- Returns the max torque for an ACF gearbox
	-- @server
	function ents_methods:acfTorqueRating ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGearbox( this ) then return 0 end
		return this.MaxTorque or 0
	end

	--- Returns whether an ACF gearbox is dual clutch
	-- @server
	function ents_methods:acfIsDual ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGearbox( this ) then return false end
		if restrictInfo( this ) then return false end
		
		return this.Dual
	end

	--- Returns the time in ms an ACF gearbox takes to change gears
	-- @server
	function ents_methods:acfShiftTime ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGearbox( this ) then return 0 end
		return ( this.SwitchTime or 0 ) * 1000
	end

	--- Returns true if an ACF gearbox is in gear
	-- @server
	function ents_methods:acfInGear ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGearbox( this ) then return false end
		if restrictInfo( this ) then return false end
		
		return this.InGear
	end

	--- Returns the ratio for a specified gear of an ACF gearbox
	-- @server
	function ents_methods:acfGearRatio ( gear )
		checktype( self, ents_metatable )
		checkluatype( gear, TYPE_NUMBER )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGearbox( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		local g = math.Clamp( math.floor( gear ), 1, this.Gears )
		return this.GearTable[ g ] or 0
	end

	--- Returns the current torque output for an ACF gearbox
	-- @server
	function ents_methods:acfTorqueOut ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGearbox( this ) then return 0 end
		return math.min( this.TotalReqTq or 0, this.MaxTorque or 0 ) / ( this.GearRatio or 1 )
	end

	--- Sets the gear ratio of a CVT, set to 0 to use built-in algorithm
	-- @server
	function ents_methods:acfCVTRatio ( ratio )
		checktype( self, ents_metatable )
		checkluatype( ratio, TYPE_NUMBER )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isGearbox( this ) then return end
		if restrictInfo( this ) then return end
		if not this.CVT then return end
		this.CVTRatio = math.Clamp( ratio, 0, 1 )
	end

	--- Sets the current gear for an ACF gearbox
	-- @server
	function ents_methods:acfShift ( gear )
		checktype( self, ents_metatable )
		checkluatype( gear, TYPE_NUMBER )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isGearbox( this ) then return end
		if restrictInfo( this ) then return end
		this:TriggerInput( "Gear", gear )
	end

	--- Cause an ACF gearbox to shift up
	-- @server
	function ents_methods:acfShiftUp ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isGearbox( this ) then return end
		if restrictInfo( this ) then return end
		this:TriggerInput( "Gear Up", 1 ) --doesn't need to be toggled off
	end

	--- Cause an ACF gearbox to shift down
	-- @server
	function ents_methods:acfShiftDown ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isGearbox( this ) then return end
		if restrictInfo( this ) then return end
		this:TriggerInput( "Gear Down", 1 ) --doesn't need to be toggled off
	end

	--- Sets the brakes for an ACF gearbox
	-- @server
	function ents_methods:acfBrake ( brake )
		checktype( self, ents_metatable )
		checkluatype( brake, TYPE_NUMBER )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isGearbox( this ) then return end
		if restrictInfo( this ) then return end
		this:TriggerInput( "Brake", brake )
	end

	--- Sets the left brakes for an ACF gearbox
	-- @server
	function ents_methods:acfBrakeLeft ( brake )
		checktype( self, ents_metatable )
		checkluatype( brake, TYPE_NUMBER )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isGearbox( this ) then return end
		if restrictInfo( this ) then return end
		if not this.Dual then return end
		this:TriggerInput( "Left Brake", brake )
	end

	--- Sets the right brakes for an ACF gearbox
	-- @server
	function ents_methods:acfBrakeRight ( brake )
		checktype( self, ents_metatable )
		checkluatype( brake, TYPE_NUMBER )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isGearbox( this ) then return end
		if restrictInfo( this ) then return end
		if not this.Dual then return end
		this:TriggerInput("Right Brake", brake )
	end

	--- Sets the clutch for an ACF gearbox
	-- @server
	function ents_methods:acfClutch ( clutch )
		checktype( self, ents_metatable )
		checkluatype( clutch, TYPE_NUMBER )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isGearbox( this ) then return end
		if restrictInfo( this ) then return end
		this:TriggerInput( "Clutch", clutch )
	end

	--- Sets the left clutch for an ACF gearbox
	-- @server
	function ents_methods:acfClutchLeft( clutch )
		checktype( self, ents_metatable )
		checkluatype( clutch, TYPE_NUMBER )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isGearbox( this ) then return end
		if restrictInfo( this ) then return end
		if not this.Dual then return end
		this:TriggerInput( "Left Clutch", clutch )
	end

	--- Sets the right clutch for an ACF gearbox
	-- @server
	function ents_methods:acfClutchRight ( clutch )
		checktype( self, ents_metatable )
		checkluatype( clutch, TYPE_NUMBER )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isGearbox( this ) then return end
		if restrictInfo( this ) then return end
		if not this.Dual then return end
		this:TriggerInput( "Right Clutch", clutch )
	end

	--- Sets the steer ratio for an ACF gearbox
	-- @server
	function ents_methods:acfSteerRate ( rate )
		checktype( self, ents_metatable )
		checkluatype( rate, TYPE_NUMBER )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isGearbox( this ) then return end
		if restrictInfo( this ) then return end
		if not this.DoubleDiff then return end
		this:TriggerInput( "Steer Rate", rate )
	end

	--- Applies gear hold for an automatic ACF gearbox
	-- @server
	function ents_methods:acfHoldGear( hold )
		checktype( self, ents_metatable )
		checkluatype( hold, TYPE_NUMBER )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isGearbox( this ) then return end
		if restrictInfo( this ) then return end
		if not this.Auto then return end
		this:TriggerInput( "Hold Gear", hold )
	end

	--- Sets the shift point scaling for an automatic ACF gearbox
	-- @server
	function ents_methods:acfShiftPointScale( scale )
		checktype( self, ents_metatable )
		checkluatype( scale, TYPE_NUMBER )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isGearbox( this ) then return end
		if restrictInfo( this ) then return end
		if not this.Auto then return end
		this:TriggerInput( "Shift Speed Scale", scale )
	end


	-- [ Gun Functions ] --

	--- Returns true if the entity is an ACF gun
	-- @server
	function ents_methods:acfIsGun ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if isGun( this ) and not restrictInfo( this ) then return true else return false end
	end

	--- Returns true if the ACF gun is ready to fire
	-- @server
	function ents_methods:acfReady ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGun( this ) then return false end
		if restrictInfo( this ) then return false end
		if ( this.Ready ) then return true end
		return false
	end

	--- Returns the magazine size for an ACF gun
	-- @server
	function ents_methods:acfMagSize ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGun( this ) then return 0 end
		return this.MagSize or 1
	end

	--- Returns the spread for an ACF gun or flechette ammo
	-- @server
	function ents_methods:acfSpread ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGun( this ) or isAmmo( this ) then return 0 end
		local Spread = this.GetInaccuracy and this:GetInaccuracy() or this.Inaccuracy or 0
		if this.BulletData[ "Type" ] == "FL" then
			if restrictInfo( this ) then return Spread end
			return Spread + ( this.BulletData[ "FlechetteSpread" ] or 0 )
		end
		return Spread
	end

	--- Returns true if an ACF gun is reloading
	-- @server
	function ents_methods:acfIsReloading ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGun( this ) then return false end
		if restrictInfo( this ) then return false end
		if (this.Reloading) then return true end
		return false
	end

	--- Returns the rate of fire of an acf gun
	-- @server
	function ents_methods:acfFireRate ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGun( this ) then return 0 end
		return math.Round( this.RateOfFire or 0, 3 )
	end

	--- Returns the number of rounds left in a magazine for an ACF gun
	-- @server
	function ents_methods:acfMagRounds ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGun( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		if this.MagSize > 1 then
			return ( this.MagSize - this.CurrentShot ) or 1
		end
		if this.Ready then return 1 end
		return 0
	end

	--- Sets the firing state of an ACF weapon
	-- @server
	function ents_methods:acfFire ( fire )
		checktype( self, ents_metatable )
		checkluatype( fire, TYPE_NUMBER )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isGun( this ) then return end
		
		this:TriggerInput( "Fire", fire )
	end

	--- Causes an ACF weapon to unload
	-- @server
	function ents_methods:acfUnload ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isGun( this ) then return end
		
		this:UnloadAmmo()
	end

	--- Causes an ACF weapon to reload
	-- @server
	function ents_methods:acfReload ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isGun( this ) then return end
		
		this.Reloading = true
	end

	--- Returns the number of rounds in active ammo crates linked to an ACF weapon
	-- @server
	function ents_methods:acfAmmoCount ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGun( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		local Ammo = 0
		for Key, AmmoEnt in pairs( this.AmmoLink ) do
			if AmmoEnt and AmmoEnt:IsValid() and AmmoEnt[ "Load" ] then
				Ammo = Ammo + ( AmmoEnt.Ammo or 0 )
			end
		end
		return Ammo
	end

	--- Returns the number of rounds in all ammo crates linked to an ACF weapon
	-- @server
	function ents_methods:acfTotalAmmoCount ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isGun( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		local Ammo = 0
		for Key, AmmoEnt in pairs( this.AmmoLink ) do
			if AmmoEnt and AmmoEnt:IsValid() then
				Ammo = Ammo + ( AmmoEnt.Ammo or 0 )
			end
		end
		return Ammo
	end

	--- Returns time to next shot of an ACF weapon
	-- @server
	function ents_methods:acfReloadTime ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if restrictInfo( this ) or not isGun( this ) or this.Ready then return 0 end
		return reloadTime( this )
	end

	--- Returns number between 0 and 1 which represents reloading progress of an ACF weapon. Useful for progress bars
	-- @server
	function ents_methods:acfReloadProgress ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if restrictInfo( this ) or not isGun( this ) or this.Ready then return 1 end
		return math.Clamp( 1 - (this.NextFire - CurTime()) / reloadTime( this ), 0, 1 )
	end

	--- Returns time it takes for an ACF weapon to reload magazine
	-- @server
	function ents_methods:acfMagReloadTime ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if restrictInfo( SF.instance.player , this ) or not isGun( this ) or not this.MagReload then return 0 end
		return this.MagReload
	end

	-- [ Ammo Functions ] --

	--- Returns true if the entity is an ACF ammo crate
	-- @server
	function ents_methods:acfIsAmmo ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		return isAmmo( this ) and not restrictInfo( this )
	end

	--- Returns the rounds left in an acf ammo crate
	-- @server
	function ents_methods:acfRounds ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isAmmo( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		return this.Ammo or 0
	end

	--- Returns the type of weapon the ammo in an ACF ammo crate loads into
	-- @server
	function ents_methods:acfRoundType () --cartridge?
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isAmmo( this ) then return "" end
		if restrictInfo( this ) then return "" end
		--return this.RoundId or ""
		return this.RoundType or "" -- E2 uses this one now
	end

	--- Returns the type of ammo in a crate or gun
	-- @server
	function ents_methods:acfAmmoType ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isAmmo( this ) or isGun( this ) then return "" end
		if restrictInfo( this ) then return "" end
		return this.BulletData[ "Type" ] or ""
	end

	--- Returns the caliber of an ammo or gun
	-- @server
	function ents_methods:acfCaliber ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not ( isAmmo( this ) or isGun( this ) ) then return 0 end
		if restrictInfo( this ) then return 0 end
		return ( this.Caliber or 0 ) * 10
	end

	--- Returns the muzzle velocity of the ammo in a crate or gun
	-- @server
	function ents_methods:acfMuzzleVel ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not ( isAmmo( this ) or isGun( this ) ) then return 0 end
		if restrictInfo( this ) then return 0 end
		return math.Round( ( this.BulletData[ "MuzzleVel" ] or 0 ) * ACF.VelScale, 3 )
	end

	--- Returns the mass of the projectile in a crate or gun
	-- @server
	function ents_methods:acfProjectileMass ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not ( isAmmo( this ) or isGun( this ) ) then return 0 end
		if restrictInfo( this ) then return 0 end
		return math.Round( this.BulletData[ "ProjMass" ] or 0, 3 )
	end

	--- Returns the number of projectiles in a flechette round
	-- @server
	function ents_methods:acfFLSpikes ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not ( isAmmo( this ) or isGun( this ) ) then return 0 end
		if restrictInfo( this ) then return 0 end
		if not this.BulletData[ "Type" ] == "FL" then return 0 end
		return this.BulletData[ "Flechettes" ] or 0
	end

	--- Returns the mass of a single spike in a FL round in a crate or gun
	-- @server
	function ents_methods:acfFLSpikeMass ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not ( isAmmo( this ) or isGun( this ) ) then return 0 end
		if restrictInfo( this ) then return 0 end
		if not this.BulletData[ "Type" ] == "FL" then return 0 end
		return math.Round( this.BulletData[ "FlechetteMass" ] or 0, 3)
	end

	--- Returns the radius of the spikes in a flechette round in mm
	-- @server
	function ents_methods:acfFLSpikeRadius ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not ( isAmmo( this ) or isGun( this ) ) then return 0 end
		if restrictInfo( this ) then return 0 end
		if not this.BulletData[ "Type" ] == "FL" then return 0 end
		return math.Round( ( this.BulletData[ "FlechetteRadius" ] or 0 ) * 10, 3)
	end

	--- Returns the penetration of an AP, APHE, or HEAT round
	-- @server
	function ents_methods:acfPenetration ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not ( isAmmo( this ) or isGun( this ) ) then return 0 end
		if restrictInfo( this ) then return 0 end
		local Type = this.BulletData[ "Type" ] or ""
		local Energy
		
		--[[if Type == "AP" or Type == "APHE" then
			Energy = ACF_Kinetic( this.BulletData[ "MuzzleVel" ] * 39.37, this.BulletData[ "ProjMass" ] - ( this.BulletData[ "FillerMass" ] or 0 ), this.BulletData[ "LimitVel" ] )
			return math.Round( ( Energy.Penetration / this.BulletData[ "PenAera" ] ) * ACF.KEtoRHA, 3 )
		elseif Type == "HEAT" then
			Energy = ACF_Kinetic( this.BulletData[ "SlugMV" ] * 39.37, this.BulletData[ "SlugMass" ], 9999999 )
			return math.Round( ( Energy.Penetration / this.BulletData[ "SlugPenAera" ] ) * ACF.KEtoRHA, 3 )
		elseif Type == "FL" then
			Energy = ACF_Kinetic( this.BulletData[ "MuzzleVel" ] * 39.37 , this.BulletData[ "FlechetteMass" ], this.BulletData[ "LimitVel" ] )
			return math.Round( ( Energy.Penetration / this.BulletData[ "FlechettePenArea" ] ) * ACF.KEtoRHA, 3 )
		end]]
		
		if Type == "AP" or Type == "APHE" then
			Energy = ACF_Kinetic(this.BulletData["MuzzleVel"]*39.37, this.BulletData["ProjMass"] - (this.BulletData["FillerMass"] or 0), this.BulletData["LimitVel"] )
			return math.Round((Energy.Penetration/this.BulletData["PenAera"])*ACF.KEtoRHA,3)
		elseif Type == "HEAT" then
			local Crushed, HEATFillerMass, BoomFillerMass = ACF.RoundTypes["HEAT"].CrushCalc(this.BulletData.MuzzleVel, this.BulletData.FillerMass)
			if Crushed == 1 then return 0 end -- no HEAT jet to fire off, it was all converted to HE
			Energy = ACF_Kinetic(ACF.RoundTypes["HEAT"].CalcSlugMV( this.BulletData, HEATFillerMass )*39.37, this.BulletData["SlugMass"], 9999999 )
			return math.Round((Energy.Penetration/this.BulletData["SlugPenAera"])*ACF.KEtoRHA,3)
		elseif Type == "FL" then
			Energy = ACF_Kinetic(this.BulletData["MuzzleVel"]*39.37 , this.BulletData["FlechetteMass"], this.BulletData["LimitVel"] )
			return math.Round((Energy.Penetration/this.BulletData["FlechettePenArea"])*ACF.KEtoRHA, 3)
		end
		
		return 0
	end

	--- Returns the blast radius of an HE, APHE, or HEAT round
	-- @server
	function ents_methods:acfBlastRadius ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not ( isAmmo( this ) or isGun( this ) ) then return 0 end
		if restrictInfo( this ) then return 0 end
		local Type = this.BulletData[ "Type" ] or ""
		if Type == "HE" or Type == "APHE" then
			return math.Round( this.BulletData[ "FillerMass" ]^0.33 * 8, 3 )
		elseif Type == "HEAT" then
			return math.Round( ( this.BulletData[ "FillerMass" ] / 3)^0.33 * 8, 3 )
		end
		return 0
	end

	--- Returns the drag coef of the ammo in a crate or gun
	-- @server
	function ents_methods:acfDragCoef()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not ( isAmmo( this ) or isGun( this ) ) then return 0 end
		if restrictInfo( this ) then return 0 end
		return ( this.BulletData[ "DragCoef" ] or 0 ) / ACF.DragDiv
	end

	-- [ Armor Functions ] --

	--- Returns the current health of an entity
	-- @server
	function ents_methods:acfPropHealth ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not validPhysics( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		if not ACF_Check( this ) then return 0 end
		return math.Round( this.ACF.Health or 0, 3 )
	end

	--- Returns the current armor of an entity
	-- @server
	function ents_methods:acfPropArmor ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not validPhysics( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		if not ACF_Check( this ) then return 0 end
		return math.Round( this.ACF.Armour or 0, 3 )
	end

	--- Returns the max health of an entity
	-- @server
	function ents_methods:acfPropHealthMax ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not validPhysics( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		if not ACF_Check( this ) then return 0 end
		return math.Round( this.ACF.MaxHealth or 0, 3 )
	end

	--- Returns the max armor of an entity
	-- @server
	function ents_methods:acfPropArmorMax ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not validPhysics( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		if not ACF_Check( this ) then return 0 end
		return math.Round( this.ACF.MaxArmour or 0, 3 )
	end

	--- Returns the ductility of an entity
	-- @server
	function ents_methods:acfPropDuctility ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not validPhysics( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		if not ACF_Check( this ) then return 0 end
		return ( this.ACF.Ductility or 0 ) * 100
	end

	-- [ Fuel Functions ] --

	--- Returns true if the entity is an ACF fuel tank
	-- @server
	function ents_methods:acfIsFuel ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		return isFuel( this ) and not restrictInfo( this )
	end

	--- Returns true if the current engine requires fuel to run
	-- @server
	function ents_methods:acfFuelRequired ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return false end
		if restrictInfo( this ) then return false end
		return ( this.RequiresFuel and true ) or false
	end

	--- Sets the ACF fuel tank refuel duty status, which supplies fuel to other fuel tanks
	-- @server
	function ents_methods:acfRefuelDuty ( on )
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end
		checkpermission( SF.instance, this, "entities.acf" )

		if not isFuel( this ) then return end
		
		this:TriggerInput( "Refuel Duty", on and true or false )
	end

	--- Returns the remaining liters or kilowatt hours of fuel in an ACF fuel tank or engine
	-- @server
	function ents_methods:acfFuel ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if restrictInfo( this ) then return 0 end
		if isFuel( this ) then
			return math.Round( this.Fuel, 3 )
		elseif isEngine( this ) then
			if not #(this.FuelLink) then return 0 end --if no tanks, return 0

			local liters = 0
			for _, tank in pairs( this.FuelLink ) do
				if validPhysics( tank ) and tank.Active then
					liters = liters + tank.Fuel
				end
			end

			return math.Round( liters, 3 )
		end
		return 0
	end

	--- Returns the amount of fuel in an ACF fuel tank or linked to engine as a percentage of capacity
	-- @server
	function ents_methods:acfFuelLevel ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if isFuel( this ) then
			if restrictInfo( this ) then return 0 end
			return math.Round( this.Fuel / this.Capacity, 3 )
		elseif isEngine( this ) then
			if restrictInfo( this ) then return 0 end
			if not #( this.FuelLink ) then return 0 end --if no tanks, return 0

			local liters = 0
			local capacity = 0
			for _, tank in pairs( this.FuelLink ) do
				if validPhysics( tank ) and tank.Active then 
					capacity = capacity + tank.Capacity
					liters = liters + tank.Fuel
				end
			end
			if not capacity > 0 then return 0 end

			return math.Round( liters / capacity, 3 )
		end
		return 0
	end

	--- Returns the current fuel consumption in liters per minute or kilowatts of an engine
	-- @server
	function ents_methods:acfFuelUse ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		if not #( this.FuelLink ) then return 0 end --if no tanks, return 0

		local tank
		for _, fueltank in pairs( this.FuelLink ) do
			if validPhysics( fueltank ) and fueltank.Fuel > 0 and fueltank.Active then
				tank = fueltank
				break
			end
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

	--- Returns the peak fuel consumption in liters per minute or kilowatts of an engine at powerband max, for the current fuel type the engine is using
	-- @server
	function ents_methods:acfPeakFuelUse ()
		checktype( self, ents_metatable )
		local this = unwrap( self )

		if not ( this and this:IsValid() ) then SF.Throw( "Entity is not valid", 2 ) end

		if not isEngine( this ) then return 0 end
		if restrictInfo( this ) then return 0 end
		if not #( this.FuelLink ) then return 0 end --if no tanks, return 0

		local fuel = "Petrol"
		local tank
		for _, fueltank in pairs( this.FuelLink ) do
			if fueltank.Fuel > 0 and fueltank.Active then tank = fueltank break end
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
end)