
-- This now loads the files in the engines and gearboxes folders!
-- Go edit those files instead of this one.

AddCSLuaFile()

local MobilityTable = {}
local FuelTankTable = {}

-- setup base engine/gearbox tables so we're not repeating a bunch of unnecessary shit
local engine_base = {}
engine_base.ent = "acf_engine"
engine_base.type = "Mobility"
/*engine_base.powerband = function( rpm ) -- should return a percentage (0-1) of peak torque available
	math.max( math.min( rpm / self.PeakMinRPM, ( self.LimitRPM - rpm ) / ( self.LimitRPM - self.PeakMaxRPM ), 1 ), 0 )
end*/

local gearbox_base = {}
gearbox_base.ent = "acf_gearbox"
gearbox_base.type = "Mobility"
gearbox_base.sound = "vehicles/junker/jnk_fourth_cruise_loop2.wav"

local fueltank_base = {}
fueltank_base.ent = "acf_fueltank"
fueltank_base.type = "Mobility"

if CLIENT then
	engine_base.guicreate = function( panel, tbl ) ACFEngineGUICreate( tbl ) end or nil
	engine_base.guiupdate = function() return end
	gearbox_base.guicreate = function( panel, tbl ) ACFGearboxGUICreate( tbl ) end or nil
	gearbox_base.guiupdate = function() return end
	fueltank_base.guicreate = function( panel, tbl ) ACFFuelTankGUICreate( tbl ) end or nil
	fueltank_base.guiupdate = function( panel, tbl ) ACFFuelTankGUIUpdate( tbl ) end or nil
end

-- some functions for defining engines and gearboxes
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

-- now that the mobility table is populated, throw it in the acf ents list
list.Set( "ACFEnts", "Mobility", MobilityTable )
list.Set( "ACFEnts", "FuelTanks", FuelTankTable )
