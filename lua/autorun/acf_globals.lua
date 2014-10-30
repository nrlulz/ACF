ACF = {}
ACF.AmmoTypes = {}
ACF.MenuFunc = {}
ACF.AmmoBlacklist = {}
ACF.Version = 515 -- REMEMBER TO CHANGE THIS FOR GODS SAKE, OMFG!!!!!!! -wrex   Update the changelog too! -Ferv
ACF.CurrentVersion = 0 -- just defining a variable, do not change

ACF.Year = 1945

ACF.Threshold = 225	--Health Divisor
ACF.PartialPenPenalty = 5 --Exponent for the damage penalty for partial penetration
ACF.PenAreaMod = 0.85
ACF.KinFudgeFactor = 2.1	--True kinetic would be 2, over that it's speed biaised, below it's mass biaised
ACF.KEtoRHA = 0.25		--Empirical conversion from (kinetic energy in KJ)/(Aera in Cm2) to RHA penetration
ACF.GroundtoRHA = 0.05		--How much mm of steel is a mm of ground worth (Real soil is about 0.15
ACF.KEtoSpall = 1
ACF.AmmoMod = 0.6		-- Ammo modifier. 1 is 1x the amount of ammo
ACF.ArmorMod = 1
ACF.Spalling = 0
ACF.GunfireEnabled = true
ACF.MeshCalcEnabled = false

ACF.HEPower = 8000		--HE Filler power per KG in KJ
ACF.HEDensity = 1.65	--HE Filler density (That's TNT density)
ACF.HEFrag = 1500		--Mean fragment number for equal weight TNT and casing
ACF.HEBlastPen = 0.4	--Blast penetration exponent based of HE power

ACF.HEATMVScale = 0.73	--Filler KE to HEAT slug KE conversion expotential

ACF.DragDiv = 40		--Drag fudge factor
ACF.VelScale = 1		--Scale factor for the shell velocities in the game world
-- local PhysEnv = physenv.GetPerformanceSettings()
ACF.PhysMaxVel = 4000
ACF.SmokeWind = 5 + math.random()*35 --affects the ability of smoke to be used for screening effect

ACF.PBase = 1050		--1KG of propellant produces this much KE at the muzzle, in kj
ACF.PScale = 1	--Gun Propellant power expotential
ACF.MVScale = 0.5  --Propellant to MV convertion expotential
ACF.PDensity = 1.6	--Gun propellant density (Real powders go from 0.7 to 1.6, i'm using higher densities to simulate case bottlenecking)

ACF.TorqueBoost = 1.25 --torque multiplier from using fuel
ACF.FuelRate = 5.0  --multiplier for fuel usage, 1.0 is approx real world
ACF.ElecRate = 1.5 --multiplier for electrics
ACF.TankVolumeMul = 1.0 -- multiplier for fuel tank volume

ACF.FuelDensity = {}
ACF.FuelDensity["Diesel"] = 0.832  --kg/liter
ACF.FuelDensity["Petrol"] = 0.745
ACF.FuelDensity["Electric"] = 3.89 -- li-ion

ACF.Efficiency = {} --how efficient various engine types are, higher is worse
ACF.Efficiency["GenericPetrol"] = 0.304 --kg per kw hr
ACF.Efficiency["GenericDiesel"] = 0.243 --up to 0.274
ACF.Efficiency["Turbine"] = 0.46 -- previously 0.231
ACF.Efficiency["Wankel"] = 0.335
ACF.Efficiency["Radial"] = 0.4 -- 0.38 to 0.53
ACF.Efficiency["Electric"] = 0.85 --percent efficiency converting chemical kw into mechanical kw

ACF.LiIonED = 0.458 -- li-ion energy density: kw hours / liter
ACF.CuIToLiter = 0.0163871 -- cubic inches to liters

ACF.RefillDistance = 300 --Distance in which ammo crate starts refilling.
ACF.RefillSpeed = 700 -- (ACF.RefillSpeed / RoundMass) / Distance 

ACF.DebrisScale = 20 -- Ignore debris that is less than this bounding radius.
ACF.SpreadScale = 4		-- The maximum amount that damage can decrease a gun's accuracy.  Default 4x
ACF.GunInaccuracyScale = 1 -- A multiplier for gun accuracy.
ACF.GunInaccuracyBias = 2  -- Higher numbers make shots more likely to be inaccurate.  Choose between 0.5 to 4. Default is 2 (unbiased).

ACF.TorqueScale = 1/4
ACF.DieselTorqueScale = 1/10
ACF.EngineHPMult = 1/8
ACF.DieselEngineHPMult = 1/2

ACF.EnableDefaultDP = false -- Enable the inbuilt damage protection system.


if file.Exists("acf/shared/acf_userconfig.lua", "LUA") then
	include("acf/shared/acf_userconfig.lua")
end


CreateConVar('sbox_max_acf_gun', 12)
CreateConVar('sbox_max_acf_ammo', 32)
CreateConVar('sbox_max_acf_misc', 32)
CreateConVar('acf_meshvalue', 1)

AddCSLuaFile()
AddCSLuaFile( "acf/client/cl_acfballistics.lua" )
AddCSLuaFile( "acf/client/cl_acfmenu_gui.lua" )
AddCSLuaFile( "acf/client/cl_acfrender.lua" )

if SERVER and ACF.EnableDefaultDP then
	AddCSLuaFile( "acf/client/cl_acfpermission.lua" )
	AddCSLuaFile( "acf/client/gui/cl_acfsetpermission.lua" )
end

if SERVER then

	util.AddNetworkString( "ACF_KilledByACF" )
	util.AddNetworkString( "ACF_RenderDamage" )
	util.AddNetworkString( "ACF_Notify" )

	include("acf/server/sv_acfbase.lua")
	include("acf/server/sv_acfdamage.lua")
	include("acf/server/sv_acfballistics.lua")
	
	if ACF.EnableDefaultDP then
		include("acf/server/sv_acfpermission.lua")
	end

elseif CLIENT then

	include("acf/client/cl_acfballistics.lua")
	include("acf/client/cl_acfrender.lua")
	
	if ACF.EnableDefaultDP then
		include("acf/client/cl_acfpermission.lua")
		include("acf/client/gui/cl_acfsetpermission.lua")
	end
	
	killicon.Add( "acf_AC", "HUD/killicons/acf_AC", Color( 200, 200, 48, 255 ) )
	killicon.Add( "acf_AL", "HUD/killicons/acf_AL", Color( 200, 200, 48, 255 ) )
	killicon.Add( "acf_C", "HUD/killicons/acf_C", Color( 200, 200, 48, 255 ) )
	killicon.Add( "acf_GL", "HUD/killicons/acf_GL", Color( 200, 200, 48, 255 ) )
	killicon.Add( "acf_HMG", "HUD/killicons/acf_HMG", Color( 200, 200, 48, 255 ) )
	killicon.Add( "acf_HW", "HUD/killicons/acf_HW", Color( 200, 200, 48, 255 ) )
	killicon.Add( "acf_MG", "HUD/killicons/acf_MG", Color( 200, 200, 48, 255 ) )
	killicon.Add( "acf_MO", "HUD/killicons/acf_MO", Color( 200, 200, 48, 255 ) )
	killicon.Add( "acf_RAC", "HUD/killicons/acf_RAC", Color( 200, 200, 48, 255 ) )
	killicon.Add( "acf_SA", "HUD/killicons/acf_SA", Color( 200, 200, 48, 255 ) )
	killicon.Add( "acf_ammo", "HUD/killicons/acf_ammo", Color( 200, 200, 48, 255 ) )
	
	CreateConVar("acf_cl_particlemul", 1)
end

include("acf/shared/rounds/roundap.lua")
include("acf/shared/rounds/roundaphe.lua")
include("acf/shared/rounds/roundhe.lua")
include("acf/shared/rounds/roundheat.lua")
include("acf/shared/rounds/roundfl.lua")
include("acf/shared/rounds/roundhp.lua")
include("acf/shared/rounds/roundsmoke.lua")
include("acf/shared/rounds/roundrefill.lua")
include("acf/shared/rounds/roundfunctions.lua")

include("acf/shared/acfloader.lua")
include("acf/shared/acfcratelist.lua")
--include("acf/shared/acfmissilelist.lua")

ACF.Weapons = list.Get("ACFEnts")
	
ACF.Classes = list.Get("ACFClasses")

ACF.RoundTypes = list.Get("ACFRoundTypes")

ACF.IdRounds = list.Get("ACFIdRounds")	--Lookup tables so i can get rounds classes from clientside with just an integer

game.AddParticles("particles/acf_muzzleflashes.pcf")
game.AddParticles("particles/explosion1.pcf")
game.AddParticles("particles/rocket_motor.pcf")

game.AddDecal("GunShot1", "decals/METAL/shot5")

-- Add the ACF tool category
if CLIENT then

	ACF.CustomToolCategory = CreateClientConVar( "acf_tool_category", 1, true, false );

	if( ACF.CustomToolCategory:GetBool() ) then

		language.Add( "spawnmenu.tools.acf", "ACF" );

		-- We use this hook so that the ACF category is always at the top
		hook.Add( "AddToolMenuTabs", "CreateACFCategory", function()

			spawnmenu.AddToolCategory( "Main", "ACF", "#spawnmenu.tools.acf" );

		end );

	end

end

timer.Simple( 0, function()
	for Class,Table in pairs(ACF.Classes["GunClass"]) do
		PrecacheParticleSystem(Table["muzzleflash"])
	end
end)

if CLIENT then

	-- Returns whether or not a sound actually exists, fixes client timeout issues
	function IsValidSound( path )

		if( file.Exists( string.format( "sound/%s", tostring( path ) ), "GAME" ) ) then

			return true;

		end

		return false;

	end

end

-- changes here will be automatically reflected in the armor properties tool
function ACF_CalcArmor( Area, Ductility, Mass )
	
	return ( Mass * 1000 / Area / 0.78 ) / ( 1 + Ductility ) ^ 0.5 * ACF.ArmorMod
	
end

function ACF_MuzzleVelocity( Propellant, Mass, Caliber )

	local PEnergy = ACF.PBase * ((1+Propellant)^ACF.PScale-1)
	local Speed = ((PEnergy*2000/Mass)^ACF.MVScale)
	local Final = Speed -- - Speed * math.Clamp(Speed/2000,0,0.5)

	return Final
end

function ACF_Kinetic( Speed , Mass, LimitVel )
	
	LimitVel = LimitVel or 99999
	Speed = Speed/39.37
	
	local Energy = {}
		Energy.Kinetic = ((Mass) * ((Speed)^2))/2000 --Energy in KiloJoules
		Energy.Momentum = (Speed * Mass)
		
		local KE = (Mass * (Speed^ACF.KinFudgeFactor))/2000 + Energy.Momentum
		Energy.Penetration = math.max( KE - (math.max(Speed-LimitVel,0)^2)/(LimitVel*5) * (KE/200)^0.95 , KE*0.1 )
		--Energy.Penetration = math.max( KE - (math.max(Speed-LimitVel,0)^2)/(LimitVel*5) * (KE/200)^0.95 , KE*0.1 )
		--Energy.Penetration = math.max(Energy.Momentum^ACF.KinFudgeFactor - math.max(Speed-LimitVel,0)/(LimitVel*5) * Energy.Momentum , Energy.Momentum*0.1)
	
	return Energy
end

-- Global Ratio Setting Function
function ACF_CalcMassRatio( obj )
	if not IsValid(obj) then return end
	local Mass = 0
	local PhysMass = 0
	
	-- find the physical parent highest up the chain
	local Parent = obj
	local depth = 0
	
	while Parent:GetParent():IsValid() and depth<6 do
		Parent = Parent:GetParent()
		depth = depth + 1
	end
	
	-- get the shit that is physically attached to the vehicle
	local PhysEnts = ACF_GetAllPhysicalConstraints( Parent )
	
	-- add any parented but not constrained props you sneaky bastards
	local AllEnts = table.Copy( PhysEnts )
	for k, v in pairs( AllEnts ) do
		
		table.Merge( AllEnts, ACF_GetAllChildren( v ) )
	
	end
	
	for k, v in pairs( AllEnts ) do
		
		if not IsValid( v ) then continue end
		
		local phys = v:GetPhysicsObject()
		if not IsValid( phys ) then continue end
		
		Mass = Mass + phys:GetMass()
		
		if PhysEnts[ v ] then
			PhysMass = PhysMass + phys:GetMass()
		end
		
	end
	
	for k, v in pairs( AllEnts ) do
		v.acfphystotal = PhysMass
		v.acftotal = Mass
		v.acflastupdatemass = CurTime()
	end
	
end

-- Cvars for recoil/he push
CreateConVar("acf_hepush", 1)
CreateConVar("acf_recoilpush", 1)

-- New healthmod/armormod/ammomod cvars
CreateConVar("acf_healthmod", 1)
CreateConVar("acf_armormod", 1)
CreateConVar("acf_ammomod", 1)
CreateConVar("acf_spalling", 0)
CreateConVar("acf_gunfire", 1)

function ACF_CVarChangeCallback(CVar, Prev, New)
	if( CVar == "acf_healthmod" ) then
		ACF.Threshold = 150 / math.max(New, 0.01)
		print ("Health Mod changed to a factor of " .. New)
	elseif( CVar == "acf_armormod" ) then
		ACF.ArmorMod = 1 * math.max(New, 0)
		print ("Armor Mod changed to a factor of " .. New)
	elseif( CVar == "acf_ammomod" ) then
		ACF.AmmoMod = 1 * math.max(New, 0.01)
		print ("Ammo Mod changed to a factor of " .. New)
	elseif( CVar == "acf_spalling" ) then
		ACF.Spalling = math.floor(math.Clamp(New, 0, 1))
		local text = "off"
		if(ACF.Spalling > 0) then
			text = "on"
		end
		print ("ACF Spalling is now " .. text)
	elseif( CVar == "acf_gunfire" ) then
		ACF.GunfireEnabled = tobool( New )
		local text = "disabled"
		if ACF.GunfireEnabled then 
			text = "enabled" 
		end
		print ("ACF Gunfire has been " .. text)
	end
end

if SERVER then
	function ACF_SendNotify( ply, success, msg )
		net.Start( "ACF_Notify" )
			net.WriteBit( success )
			net.WriteString( msg or "" )
		net.Send( ply )
	end
else
	local function ACF_Notify()
		local Type = NOTIFY_ERROR
		if tobool( net.ReadBit() ) then Type = NOTIFY_GENERIC end
		
		GAMEMODE:AddNotify( net.ReadString(), Type, 7 )
	end
	net.Receive( "ACF_Notify", ACF_Notify )
end

function ACF_UpdateChecking( )
	http.Fetch("https://github.com/nrlulz/ACF",function(contents,size)
		local rev = tonumber(string.match( contents, "%s*(%d+)\n%s*</span>\n%s*commits" )) or 0 --"history\"></span>\n%s*(%d+)\n%s*</span>"
		if rev and ACF.Version >= rev then
			print("[ACF] ACF Is Up To Date, Latest Version: "..rev)
		elseif !rev then
			print("[ACF] No Internet Connection Detected! ACF Update Check Failed")
		else
			print("[ACF] A newer version of ACF is available! Version: "..rev..", You have Version: "..ACF.Version)
			if CLIENT then chat.AddText( Color( 255, 0, 0 ), "A newer version of ACF is available!" ) end
		end
		ACF.CurrentVersion = rev
		
	end, function() end)
end
ACF_UpdateChecking( )

local function OnInitialSpawn( ply )
	local Table = {}
	for k,v in pairs( ents.GetAll() ) do
		if v.ACF and v.ACF.PrHealth then
			table.insert(Table,{ID = v:EntIndex(), Health = v.ACF.Health, v.ACF.MaxHealth})
		end
	end
	if Table ~= {} then
		net.Start("ACF_RenderDamage")
			net.WriteTable(Table)
		net.Send(ply)
	end
end

hook.Add( "PlayerInitialSpawn", "renderdamage", OnInitialSpawn )

cvars.AddChangeCallback("acf_healthmod", ACF_CVarChangeCallback)
cvars.AddChangeCallback("acf_armormod", ACF_CVarChangeCallback)
cvars.AddChangeCallback("acf_ammomod", ACF_CVarChangeCallback)
cvars.AddChangeCallback("acf_spalling", ACF_CVarChangeCallback)
cvars.AddChangeCallback("acf_gunfire", ACF_CVarChangeCallback)

-- smoke-wind cvar handling
if SERVER then
	local function msgtoconsole(hud, msg)
			print(msg)
	end

	util.AddNetworkString("acf_smokewind")
	concommand.Add( "acf_smokewind", function(ply, cmd, args, str)
			local validply = IsValid(ply)
			local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole
			
			if not args[1] then printmsg(HUD_PRINTCONSOLE,
					"Set the wind intensity upon all smoke munitions." ..
					"\n   This affects the ability of smoke to be used for screening effect." ..
					"\n   Example; acf_smokewind 300")
					return false
			end
			
			if validply and not ply:IsAdmin() then
					printmsg(HUD_PRINTCONSOLE, "You can't use this because you are not an admin.")
					return false
					
			else
					local wind = tonumber(args[1])

					if not wind then
							printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: that wind value could not be interpreted as a number!")
							return false
					end
					
					ACF.SmokeWind = wind
					
					net.Start("acf_smokewind")
							net.WriteFloat(wind)
					net.Broadcast()
					
					printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: set smoke-wind to " .. wind .. "!")
					return true        
			end
	end)

	local function sendSmokeWind(ply)
			net.Start("acf_smokewind")
					net.WriteFloat(ACF.SmokeWind)
			net.Send(ply)
	end
	hook.Add( "PlayerInitialSpawn", "ACF_SendSmokeWind", sendSmokeWind )
else
	local function recvSmokeWind(len)
		ACF.SmokeWind = net.ReadFloat()
	end
	net.Receive("acf_smokewind", recvSmokeWind)
end

/*
ONE HUGE HACK to get good killicons.
*/
-- disabling this for now because it was breaking killicons completely and i don't want to deal with it right now
/*
if SERVER then
	
	hook.Add("PlayerDeath", "ACF_PlayerDeath",function( victim, inflictor, attacker )
		if inflictor:GetClass() == "acf_ammo" then
			net.Start("ACF_KilledByACF")
				net.WriteString( victim:Nick()..";ammo;"..attacker:Nick() )
			net.Broadcast()
		end
		if inflictor:GetClass() == "acf_gun" then
			net.Start("ACF_KilledByACF")
				net.WriteString( victim:Nick()..";"..inflictor.Class..";"..attacker:Nick() )
			net.Broadcast()
		end
	end)
end


if CLIENT then
	
	net.Receive("ACF_KilledByACF", function()
		local Table = string.Explode(";", net.ReadString())
		local victim, gun, attacker = Table[1], Table[2], Table[3]
		
		if attacker == "worldspawn" then attacker = "" end
		GAMEMODE:AddDeathNotice( attacker, -1, "acf_"..gun, victim, 1001 )
	end)
	
	if not ACF.replacedPlayerKilled then
		timer.Create("ACF_replacePlayerKilled", 1, 0, function()
			local Hooks = usermessage.GetTable()
			if Hooks["PlayerKilled"] then
				local ACF_PlayerKilled = Hooks["PlayerKilled"].Function
				ACF.replacedPlayerKilled = true
				Hooks["PlayerKilled"].Function = function(msg)
					local victim     = msg:ReadEntity()
					if ( !IsValid( victim ) ) then return end
					local inflictor    = msg:ReadString()
					local attacker     = msg:ReadString()
					if inflictor != "acf_gun" and inflictor != "acf_ammo" then
						ACF_PlayerKilled(msg)
					end
				end
				timer.Destroy("ACF_replacePlayerKilled")
				Msg("[ACF] Replaced PlayerKilled\n")
			end
		end)
	end
	if not ACF.replacedPlayerKilledByPlayer then
		timer.Create("ACF_replacePlayerKilledByPlayer", 1, 0, function()
			local Hooks = usermessage.GetTable()
			if Hooks["PlayerKilledByPlayer"] then
				local ACF_PlayerKilledByPlayer = Hooks["PlayerKilledByPlayer"].Function
				ACF.replacedPlayerKilledByPlayer = true
				Hooks["PlayerKilledByPlayer"].Function = function(msg)
					local victim     = msg:ReadEntity()
					local inflictor    = msg:ReadString()
					local attacker     = msg:ReadEntity()

					if ( !IsValid( attacker ) ) then return end
					if ( !IsValid( victim ) ) then return end
					if inflictor != "acf_gun" and inflictor != "acf_ammo" then
						ACF_PlayerKilledByPlayer(msg)
					end
				end
				timer.Destroy("ACF_replacePlayerKilledByPlayer")
				Msg("[ACF] Replaced PlayerKilledByPlayer\n")
			end
		end)
	end
end
*/
