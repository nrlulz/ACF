
-- This loads the files in the engine, gearbox, fuel, and gun folders!
-- Go edit those files instead of this one.

AddCSLuaFile()

local GunClasses = {}
local GunTable = {}
local MobilityTable = {}
local FuelTankTable = {}

-- setup base classes
local gun_base = {
	ent = "acf_gun",
	type = "Guns"
}

local engine_base = {
	ent = "acf_engine",
	type = "Mobility"
}

local gearbox_base = {
	ent = "acf_gearbox",
	type = "Mobility",
	sound = "vehicles/junker/jnk_fourth_cruise_loop2.wav"
}

local fueltank_base = {
	ent = "acf_fueltank",
	type = "Mobility"
}

-- add gui stuff to base classes if this is client
if CLIENT then
	gun_base.guicreate = function( Panel, Table ) ACFGunGUICreate( Table ) end or nil
	gun_base.guiupdate = function() return end
	engine_base.guicreate = function( panel, tbl ) ACFEngineGUICreate( tbl ) end or nil
	engine_base.guiupdate = function() return end
	gearbox_base.guicreate = function( panel, tbl ) ACFGearboxGUICreate( tbl ) end or nil
	gearbox_base.guiupdate = function() return end
	fueltank_base.guicreate = function( panel, tbl ) ACFFuelTankGUICreate( tbl ) end or nil
	fueltank_base.guiupdate = function( panel, tbl ) ACFFuelTankGUIUpdate( tbl ) end or nil
end

-- some factory functions for defining ents
function ACF_defineGunClass( id, data )
	data.id = id
	GunClasses[ id ] = data
end

function ACF_defineGun( id, data )
	data.id = id
	data.round.id = id
	table.Inherit( data, gun_base )
	GunTable[ id ] = data
end

function ACF_DefineEngine( id, data )
	data.id = id
	table.Inherit( data, engine_base )
	MobilityTable[ id ] = data
end

function ACF_DefineGearbox( id, data )
	data.id = id
	table.Inherit( data, gearbox_base )
	MobilityTable[ id ] = data
end

function ACF_DefineFuelTank( id, data )
	data.id = id
	table.Inherit( data, fueltank_base )
	MobilityTable[ id ] = data
end

function ACF_DefineFuelTankSize( id, data )
	data.id = id
	table.Inherit( data, fueltank_base )
	FuelTankTable[ id ] = data
end

-- search for and load a bunch of files or whatever
local guns = file.Find( "acf/shared/guns/*.lua", "LUA" )
for k, v in pairs( guns ) do
	AddCSLuaFile( "acf/shared/guns/" .. v )
	include( "acf/shared/guns/" .. v )
end

local engines = file.Find( "acf/shared/engines/*.lua", "LUA" )
for k, v in pairs( engines ) do
	AddCSLuaFile( "acf/shared/engines/" .. v )
	include( "acf/shared/engines/" .. v )
end

local gearboxes = file.Find( "acf/shared/gearboxes/*.lua", "LUA" )
for k, v in pairs( gearboxes ) do
	AddCSLuaFile( "acf/shared/gearboxes/" .. v )
	include( "acf/shared/gearboxes/" .. v )
end

local fueltanks = file.Find( "acf/shared/fueltanks/*.lua", "LUA" )
for k, v in pairs( fueltanks ) do
	AddCSLuaFile( "acf/shared/fueltanks/" .. v )
	include( "acf/shared/fueltanks/" .. v )
end

-- now that the tables are populated, throw them in the acf ents list
list.Set( "ACFClasses", "GunClass", GunClasses )
list.Set( "ACFEnts", "Guns", GunTable )
list.Set( "ACFEnts", "Mobility", MobilityTable )
list.Set( "ACFEnts", "FuelTanks", FuelTankTable )
