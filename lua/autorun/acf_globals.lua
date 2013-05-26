ACF = {}
ACF.AmmoTypes = {}
ACF.MenuFunc = {}
ACF.AmmoBlacklist = {}
ACF.Version = 357 -- Make sure to change this as the version goes up or the update check is for nothing! -wrex
ACF.CurrentVersion = 0 -- just defining a variable, do not change

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

ACF.PBase = 1050		--1KG of propellant produces this much KE at the muzzle, in kj
ACF.PScale = 1	--Gun Propellant power expotential
ACF.MVScale = 0.5  --Propellant to MV convertion expotential
ACF.PDensity = 1.6	--Gun propellant density (Real powders go from 0.7 to 1.6, i'm using higher densities to simulate case bottlenecking)

ACF.RefillDistance = 300 --Distance in which ammo crate starts refilling.
ACF.RefillSpeed = 700 -- (ACF.RefillSpeed / RoundMass) / Distance 

ACF.Year = 1945

CreateConVar('sbox_max_acf_gun', 12)
CreateConVar('sbox_max_acf_ammo', 32)
CreateConVar('sbox_max_acf_misc', 32)
CreateConVar('acf_meshvalue', 1)

AddCSLuaFile()
AddCSLuaFile( "acf/client/cl_acfballistics.lua" )
AddCSLuaFile( "acf/client/cl_acfmenu_gui.lua" )

AddCSLuaFile( "acf/client/cl_acfballistics.lua" )
AddCSLuaFile( "acf/client/cl_acfmenu_gui.lua" )
AddCSLuaFile( "acf/client/cl_acfrender.lua" )

if (SERVER) then
	util.AddNetworkString( "ACF_KilledByACF" )
	util.AddNetworkString( "ACF_RenderDamage" )

	include("acf/server/sv_acfbase.lua")
	include("acf/server/sv_acfdamage.lua")
	include("acf/server/sv_acfballistics.lua")

	
elseif (CLIENT) then

	include("acf/client/cl_acfballistics.lua")
	include("acf/client/cl_acfrender.lua")
	--include("ACF/Client/cl_ACFMenu_GUI.lua")
	
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
	
end

include("acf/shared/rounds/roundap.lua")
include("acf/shared/rounds/roundaphe.lua")
include("acf/shared/rounds/roundhe.lua")
include("acf/shared/rounds/roundheat.lua")
include("acf/shared/rounds/roundhp.lua")
include("acf/shared/rounds/roundsmoke.lua")
include("acf/shared/rounds/roundrefill.lua")
include("acf/shared/rounds/roundfunctions.lua")

include("acf/shared/acfgunlist.lua")
include("acf/shared/acfmobilitylist.lua")
include("acf/shared/acfsensorlist.lua")
include("acf/shared/acfmissilelist.lua")

ACF.Weapons = list.Get("ACFEnts")
	
ACF.Classes = list.Get("ACFClasses")

ACF.RoundTypes = list.Get("ACFRoundTypes")

ACF.IdRounds = list.Get("ACFIdRounds")	--Lookup tables so i can get rounds classes from clientside with just an integer

game.AddParticles("particles/acf_muzzleflashes.pcf")
game.AddParticles("particles/explosion1.pcf")
game.AddParticles("particles/rocket_motor.pcf")

game.AddDecal("GunShot1", "decals/METAL/shot5")

timer.Simple( 0, function()
	for Class,Table in pairs(ACF.Classes["GunClass"]) do
		PrecacheParticleSystem(Table["muzzleflash"])
	end
end)

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


function ACF_UpdateChecking( )
	
	http.Fetch("https://github.com/nrlulz/ACF",function(contents,size)
		local rev = tonumber(string.match( contents, "([0-9]+) commits" ))
		if rev and ACF.Version >= rev then
			print("[ACF] ACF Is Up To Date, Latest Version: "..rev)
			
		elseif !rev then
			print("[ACF] No Internet Connection Detected! ACF Update Check Failed")
		else
			print("[ACF] A newer version of ACF is available! Version: "..rev..", You have Version: "..ACF.Version)
		end
		ACF.CurrentVersion = rev
		
	end, function() end)
end
ACF_UpdateChecking( )

function ACF_ChatVersionPrint(ply)
	if not ACF.Version or ACF.Version < ACF.CurrentVersion then
	timer.Simple( 2,function()
		ply:SendLua(
			"chat.AddText(Color(255,0,0),\"A newer version of ACF is available!\")"
			) 
		end)
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
end

hook.Add("PlayerInitialSpawn","versioncheck",ACF_ChatVersionPrint)

cvars.AddChangeCallback("acf_healthmod", ACF_CVarChangeCallback)
cvars.AddChangeCallback("acf_armormod", ACF_CVarChangeCallback)
cvars.AddChangeCallback("acf_ammomod", ACF_CVarChangeCallback)
cvars.AddChangeCallback("acf_spalling", ACF_CVarChangeCallback)
cvars.AddChangeCallback("acf_gunfire", ACF_CVarChangeCallback)

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
