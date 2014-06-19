// This file defines damage permission with all ACF weaponry

ACF = ACF or {}
ACF.Permissions = {}
local this = ACF.Permissions

//TODO: make player-customizable
this.Selfkill = true

this.Safezones = false

this.Player = {}
this.Modes = {}
this.ModeDescs = {}
this.ModeThinks = {}

//TODO: convar this
local mapSZDir = "ACF/safezones/"
local mapDPMDir = "ACF/permissions/"
file.CreateDir(mapDPMDir)



local function msgtoconsole(hud, msg)
	print(msg)
end




local function resolveAABBs(mins, maxs)
	
	/*
	for xyz, val in pairs(mins) do	// ensuring points conform to AABB mins/maxs
		if val > maxs.xyz then
			local store = maxs.xyz
			maxs.xyz = val
			mins.xyz = store
		end
	end
	//*/
	
	local store
	if mins.x > maxs.x then
		store = maxs.x
		maxs.x = mins.x
		mins.x = store
	end
	
	if mins.y > maxs.y then
		store = maxs.y
		maxs.y = mins.y
		mins.y = store
	end
	
	if mins.z > maxs.z then
		store = maxs.z
		maxs.z = mins.z
		mins.z = store
	end
	
	return mins, maxs
end


//TODO: sanitize safetable instead of marking it all as bad
local function validateSZs(safetable)
	if type(safetable) ~= "table" then return false end
	
	--PrintTable(safetable)

	for k, v in pairs(safetable) do
		if type(k) ~= "string" then return false end
		if not (#v == 2 and v[1] and v[2]) then return false end
		
		for a, b in ipairs(v) do
			if not (b.x and b.y and b.z) then return false end
		end
		
		local mins = v[1]
		local maxs = v[2]
		
		mins, maxs = resolveAABBs(mins, maxs)
		
	end
	
	return true
end




local function getMapFilename()
	
	local mapname = string.gsub(game.GetMap(), "[^%a%d-_]", "_")
	return mapSZDir .. mapname .. ".txt"
	
end



local function getMapSZs()
	local mapname = getMapFilename()
	local mapSZFile = file.Read(mapname, "DATA") or ""
	
	local safezones = util.JSONToTable(mapSZFile)
	
	if not validateSZs(safezones) then
		// TODO: generate default safezones around spawnpoints.
		return false
	end
	
	this.Safezones = safezones
	return true
end


local function SaveMapDPM(mode)
	local mapname = string.gsub(game.GetMap(), "[^%a%d-_]", "_")
	file.Write(mapDPMDir .. mapname .. ".txt", mode)
end

local function LoadMapDPM()
	local mapname = string.gsub(game.GetMap(), "[^%a%d-_]", "_")
	return file.Read(mapDPMDir .. mapname .. ".txt", "DATA")
end


hook.Add( "Initialize", "ACF_LoadSafesForMap", function()
	if not getMapSZs() then
		print("!!!!!!!!!!!!!!!!!!\nWARNING: Safezone file " .. getMapFilename() .. " is missing, invalid or corrupt!  Safezones will not be restored this time.\n!!!!!!!!!!!!!!!!!!")
	end
end )


local plyzones = {}
hook.Add("Think", "ACF_DetectSZTransition", function()
	for k, ply in pairs(player.GetAll()) do
		local sid = ply:SteamID()
		local trans = false
		local pos = ply:GetPos()
		local oldzone = plyzones[sid]
		
		local zone = this.IsInSafezone(pos) or nil
		plyzones[sid] = zone
		
		if oldzone ~= zone then
			hook.Call("ACF_PlayerChangedZone", GAMEMODE, ply, zone, oldzone)
		end
	end
end)


concommand.Add( "ACF_AddSafeZone", function(ply, cmd, args, str)
	local validply = IsValid(ply)
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole
	
	if not args[1] then printmsg(HUD_PRINTCONSOLE,
		" - Add a safezone as an AABB box." ..
		"\n   Input a name and six numbers.  First three numbers are minimum co-ords, last three are maxs." ..
		"\n   Example; ACF_addsafezone airbase -500 -500 0 500 500 1000")
		return false
	end
	
	if validply and not ply:IsAdmin() then
		printmsg(HUD_PRINTCONSOLE, "You can't use this because you are not an admin.")
		return false
		
	else
		local szname = tostring(args[1])
		args[1] = nil
		local default = tostring(args[8])
		if default ~= "default" then default = nil end
		
		if not this.Safezones then this.Safezones = {} end
		
		if this.Safezones[szname] and this.Safezones[szname].default then 
			printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: an unmodifiable safezone called " .. szname .. " already exists!")
			return false
		end
	
		for k, v in ipairs(args) do			
			args[k] = tonumber(v)
			if args[k] == nil then 
				printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: argument " .. k .. " could not be interpreted as a number (" .. v .. ")")
				return false
			end
		end
		
		local mins = Vector(args[2], args[3], args[4])
		local maxs = Vector(args[5], args[6], args[7])
		mins, maxs = resolveAABBs(mins, maxs)
		
		this.Safezones[szname] = {mins, maxs}
		if default then this.Safezones[szname].default = true end
		printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: added a safezone called " .. szname .. " between " .. tostring(mins) .. " and " .. tostring(maxs) .. "!")
		return true	
	end
end)




concommand.Add( "ACF_RemoveSafeZone", function(ply, cmd, args, str)
	local validply = IsValid(ply)
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole
	
	if not args[1] then printmsg(HUD_PRINTCONSOLE,
		" - Delete a safezone using its name." ..
		"\n   Input a safezone name.  If it exists, it will be removed." ..
		"\n   Deletion is not permanent until safezones are saved.")
		return false
	end
	
	if validply and not ply:IsAdmin() then
		printmsg(HUD_PRINTCONSOLE, "You can't use this because you are not an admin.")
		return false
		
	else
		local szname = tostring(args[1])
		if not szname then 
			printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: could not interpret your input as a string.")
			return false
		end
		
		if not (this.Safezones and this.Safezones[szname]) then
			printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: could not find a safezone called " .. szname .. ".")
			return false
		end
		
		if this.Safezones[szname].default then 
			printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: an unmodifiable safezone called " .. szname .. " already exists!")
			return false
		end
		
		this.Safezones[szname] = nil
		printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: removed the safezone called " .. szname .. "!")
		return true	
	end
end)


concommand.Add( "ACF_SaveSafeZones", function(ply, cmd, args, str)
	local validply = IsValid(ply)
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole
	
	if validply and not ply:IsAdmin() then
		printmsg(HUD_PRINTCONSOLE, "You can't use this because you are not an admin.")
		return false
		
	else	
		if not this.Safezones then 
			printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: There are no safezones on the map which can be saved.")
			return false
		end
		
		local szjson = util.TableToJSON(this.Safezones)
		
		local mapname = getMapFilename()
		file.CreateDir(mapSZDir)
		file.Write(mapname, szjson)
		
		printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: All safezones on the map have been made restorable.")
		return true	
	end
end)


concommand.Add( "ACF_ReloadSafeZones", function(ply, cmd, args, str)
	local validply = IsValid(ply)
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole
	
	if validply and not ply:IsAdmin() then
		printmsg(HUD_PRINTCONSOLE, "You can't use this because you are not an admin.")
		return false
		
	else
		local ret = getMapSZs()
		
		if ret then
			printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: All safezones on the map have been restored.")
		else
			printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: Safezone file for this map is missing, invalid or corrupt.")
		end
		return ret
	end
end)


concommand.Add( "ACF_SetPermissionMode", function(ply, cmd, args, str)
	local validply = IsValid(ply)
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole

	if not args[1] then 
		local modes = ""
		for k, v in pairs(this.Modes) do
			modes = modes .. k .. " "
		end
		printmsg(HUD_PRINTCONSOLE,
		" - Set damage permission behaviour mode." ..
		"\n   Available modes: " .. modes)
		return false
	end
	
	if validply and not ply:IsAdmin() then
		printmsg(HUD_PRINTCONSOLE, "You can't use this because you are not an admin.")
		return false
		
	else
		local mode = tostring(args[1])
		if not this.Modes[mode] then
			printmsg(HUD_PRINTCONSOLE, 
			"Command unsuccessful: " .. mode .. " is not a valid permission mode!" .. 
			"\nUse this command without arguments to see all available modes.")
			return false
		end
		
		local oldmode = table.KeyFromValue(this.Modes, this.DamagePermission)
		this.DamagePermission = this.Modes[mode]
		
		printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: Current damage permission policy is now " .. mode .. "!")
		
		hook.Call("ACF_ProtectionModeChanged", GAMEMODE, mode, oldmode)
		
		return true
	end
end)

concommand.Add( "ACF_SetDefaultPermissionMode", function(ply, cmd, args, str)

	local validply = IsValid(ply)
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole

	if not args[1] then 
		local modes = ""
		for k, v in pairs(this.Modes) do
			modes = modes .. k .. " "
		end
		printmsg(HUD_PRINTCONSOLE,
		" - Set damage permission behaviour mode." ..
		"\n   Available modes: " .. modes)
		return false
	end
	
	if validply and not ply:IsAdmin() then
		printmsg(HUD_PRINTCONSOLE, "You can't use this because you are not an admin.")
		return false
		
	else
		local mode = tostring(args[1])
		if not this.Modes[mode] then
			printmsg(HUD_PRINTCONSOLE, 
			"Command unsuccessful: " .. mode .. " is not a valid permission mode!" .. 
			"\nUse this command without arguments to see all available modes.")
			return false
		end
		
		if this.DefaultPermission == mode then return false end
		
		SaveMapDPM(mode)
		this.DefaultPermission = mode
		
		printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: Default permission mode for "..game.GetMap().." set to: "..mode)
			
		for k,v in pairs(player.GetAll()) do
			if v:IsAdmin() then
				v:SendLua("chat.AddText(Color(255,0,0),\"Default permission mode for "..game.GetMap().." has been set to " .. mode .. "!\")") 
			end
		end
		
		this.ResendPermissionsOnChanged()
		return true
	end
end)

	
concommand.Add( "ACF_ReloadPermissionModes", function(ply, cmd, args, str)
	local validply = IsValid(ply)
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole
	
	if validply and not ply:IsAdmin() then
		printmsg(HUD_PRINTCONSOLE, "You can't use this because you are not an admin.")
		return false
		
	else
		if not aaa_IncludeHere then
			printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: folder-loading function is not available.")
			return false
		end
		
		aaa_IncludeHere("ACF/server/permissionmodes")
		
		local mode = table.KeyFromValue(this.Modes, this.DamagePermission)
		
		if not mode then
			this.DamagePermission = function() end
			hook.Call("ACF_ProtectionModeChanged", GAMEMODE, "default", nil)
			mode = "default"
		end
		
		printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: Current damage permission policy is now " .. mode .. "!")
		return true
	end
end)



local function tellPlysAboutDPMode(mode, oldmode)
	if mode == oldmode then return end
	
	for k, v in pairs(player.GetAll()) do
		v:SendLua("chat.AddText(Color(255,0,0),\"Damage protection has been changed to " .. mode .. " mode!\")") 
	end
end
hook.Add("ACF_ProtectionModeChanged", "ACF_TellPlysAboutDPMode", tellPlysAboutDPMode)




function this.IsInSafezone(pos)

	if not this.Safezones then return false end
	
	local szmin, szmax
	for szname, szpts in pairs(this.Safezones) do
		szmin = szpts[1]
		szmax = szpts[2]
		
		if	(pos.x > szmin.x and pos.y > szmin.y and pos.z > szmin.z) and 
			(pos.x < szmax.x and pos.y < szmax.y and pos.z < szmax.z) then
			return szname
		end
	end
	return false
end



function this.RegisterMode(mode, name, desc, default, think, defaultaction)

	this.Modes[name] = mode
	this.ModeDescs[name] = desc
	this.ModeThinks[name] = think or function() end
	this.DefaultCanDamage = defaultaction or false
	print("ACF: Registered damage permission mode \"" .. name .. "\"!")
	
	
	if LoadMapDPM() == name or default then 
		print("ACF: Setting permission mode to: "..name)
		this.DamagePermission = this.Modes[name]
		this.DefaultPermission = name
	end
	
end



function this.CanDamage(Type, Entity, Energy, FrAera, Angle, Inflictor, Bone, Gun)
	local owner = CPPI and Entity:CPPIGetOwner() or Entity:GetOwner()
	
	if not (IsValid(owner) and owner:IsPlayer()) then
		if IsValid(Entity) and Entity:IsPlayer() then
			owner = Entity
		else
			if this.DefaultCanDamage then return
			else return this.DefaultCanDamage end
		end
	end
	
	if not (IsValid(Inflictor) and Inflictor:IsPlayer()) then
		if this.DefaultCanDamage then return
		else return this.DefaultCanDamage end
	end
	
	return this.DamagePermission(owner, Inflictor, Entity)
end
hook.Add("ACF_BulletDamage", "ACF_DamagePermissionCore", this.CanDamage)



this.thinkWrapper = function()
	local curmode = table.KeyFromValue(this.Modes, this.DamagePermission)
	--print(curmode)
	local think = this.ModeThinks[curmode]
	local nextthink
	
	if think then
		nextthink = think()
	end
	
	timer.Simple(nextthink or 0.01, this.thinkWrapper)
end

timer.Simple(0.01, this.thinkWrapper)

 
function this.GetDamagePermissions(ownerid)
	if not this.Player[ownerid] then
		this.Player[ownerid] = {[ownerid] = true}
	end

	return this.Player[ownerid]
end


function this.AddDamagePermission(owner, attacker)
	local ownerid = owner:SteamID()
	local attackerid = attacker:SteamID()

	local ownerprefs = this.GetDamagePermissions(ownerid)
	
	ownerprefs[attackerid] = true
end


function this.RemoveDamagePermission(owner, attacker)
	local ownerid = owner:SteamID()
	if not this.Player[ownerid] then return end
	
	local attackerid = attacker:SteamID()
	this.Player[ownerid][attackerid] = nil
end


function this.ClearDamagePermissions(owner)
	local ownerid = owner:SteamID()
	if not this.Player[ownerid] then return end
	
	this.Player[ownerid] = nil
end


function this.PermissionsRaw(ownerid, attackerid, value)
	if not ownerid then return end
	
	local ownerprefs = this.GetDamagePermissions(ownerid)
	
	if attackerid then
		local old = ownerprefs[attackerid] and true or nil
		local new = value and true or nil
		ownerprefs[attackerid] = new
		return old != new
	end
	
	return false
end


local function onDisconnect( ply )
	plyid = ply:SteamID()
	
	if this.Player[plyid] then
		this.Player[plyid] = nil
	end
	
	plyzones[plyid] = nil
end
hook.Add( "PlayerDisconnected", "ACF_PermissionDisconnect", onDisconnect )




local function plyBySID(steamid)
	for k, v in pairs(player.GetAll()) do
		if v:SteamID() == steamid then
			return v
		end
	end
	
	return false
end




-- -- -- -- -- Client sync -- -- -- -- --

// All code below modified from the NADMOD client permissions menu, by Nebual
// http://www.facepunch.com/showthread.php?t=1221183
util.AddNetworkString("ACF_dmgfriends")
util.AddNetworkString("ACF_refreshfeedback")
net.Receive("ACF_dmgfriends", function(len, ply)
	//Msg("\nsv dmgfriends\n")
	if not ply:IsValid() then return end

	local perms = net.ReadTable()
	local ownerid = ply:SteamID()
	
	//Msg("ownerid = ", ownerid)
	//PrintTable(perms)
	
	local changed
	for k, v in pairs(perms) do
		changed = this.PermissionsRaw(ownerid, k, v)
		//Msg(k, " has ", changed and "changed\n" or "not changed\n")
		
		if changed then
			local targ = plyBySID(k)
			if targ then
				local note = v and "given you" or "removed your"
				//Msg("Sending", targ, " ", note, "\n")
				targ:SendLua( string.format( "GAMEMODE:AddNotify(%q,%s,7)", ply:Nick() .. " has " .. note .. " permission to damage their objects with ACF!", "NOTIFY_GENERIC" ) )
			end
		end
	end
	
	net.Start("ACF_refreshfeedback")
		net.WriteBit(true)
	net.Send(ply)
	
end)




function this.RefreshPlyDPFriends(ply)
	//Msg("\nsv refreshfriends\n")
	if not ply:IsValid() then return end

	local perms = this.GetDamagePermissions(ply:SteamID())
	
	net.Start("ACF_refreshfriends")
		net.WriteTable(perms)
	net.Send(ply)
end
util.AddNetworkString("ACF_refreshfriends")
net.Receive("ACF_refreshfriends", function(len, ply) this.RefreshPlyDPFriends(ply) end)




function this.SendPermissionsState(ply)

	local modes = this.ModeDescs
	local current = table.KeyFromValue(this.Modes, this.DamagePermission)

	net.Start("ACF_refreshpermissions")
		net.WriteTable(modes)	
		net.WriteString(current or this.DefaultPermission)
		net.WriteString(this.DefaultPermission or "")
	net.Send(ply)
end
util.AddNetworkString("ACF_refreshpermissions")
net.Receive("ACF_refreshpermissions", function(len, ply) this.SendPermissionsState(ply) end)




function this.ResendPermissionsOnChanged()
	for k, ply in pairs(player.GetAll()) do
		this.SendPermissionsState(ply)
	end
end
hook.Add("ACF_ProtectionModeChanged", "ACF_ResendPermissionsOnChanged", this.ResendPermissionsOnChanged)




-- -- -- -- -- Initial DP mode load -- -- -- -- --

if not aaa_IncludeHere then
	this.DamagePermission = function() end
	hook.Call("ACF_ProtectionModeChanged", GAMEMODE, "default", nil)
	mode = "default"
else
	aaa_IncludeHere("ACF/server/permissionmodes")

	local mode = table.KeyFromValue(this.Modes, this.DamagePermission)

	if not mode then
		this.DamagePermission = function() end
		hook.Call("ACF_ProtectionModeChanged", GAMEMODE, "default", nil)
		mode = "default"
	end
end