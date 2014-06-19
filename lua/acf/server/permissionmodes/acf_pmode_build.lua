/**
	ACF Permission mode: Build
		This mode blocks all damage to entities without the owner's permission.
		Owners can permit damage from specific players.
		Players and NPCs remain vulnerable to damage.  This is what admin mods are for.
		This mode requires a CPPI-compatible prop-protector to function properly.
//*/

if not ACF or not ACF.Permissions or not ACF.Permissions.RegisterMode then error("ACF: Tried to load the " .. modename .. " permission-mode before the permission-core has loaded!") end
local perms = ACF.Permissions


// the name for this mode used in commands and identification
local modename = "build"

// a short description of what the mode does
local modedescription = "Disables all ACF damage unless the owner permits it. PvP is allowed."

// if the attacker or victim can't be identified, what should we do?  true allows damage, false blocks it.
local DefaultPermission = false


/*
	Defines the behaviour of ACF damage protection under this protection mode.
	This function is called every time an entity can be affected by potential ACF damage.
	Args;
		owner		Player:	The owner of the potentially-damaged entity
		attacker	Player:	The initiator of the ACF damage event
		ent			Entity:	The entity which may be damaged.
	Return: boolean
		true if the entity should be damaged, false if the entity should be protected from the damage.
//*/
local function modepermission(owner, attacker, ent)
	
	if IsValid(ent) and ent:IsPlayer() or ent:IsNPC() then 
		--print("is squishy")
		return true
	end
	
	if not (owner.SteamID or attacker.SteamID) then
		--print("ACF ERROR: owner or attacker is not a player!", tostring(owner), tostring(attacker), "\n", debug.traceback())
		if DefaultPermission then return
		else return DefaultPermission end
	end	
	
	local ownerid = owner:SteamID()
	local attackerid = attacker:SteamID()
	local ownerperms = perms.GetDamagePermissions(ownerid)
	
	if ownerperms[attackerid] then
		--print("permitted")
		return
	end
	
	--print("disallowed")
	return false
end


if not CPPI then
	print("WARNING: ACF protection mode \"" .. modename .. "\" works best with a CPPI-compliant prop protection script.  Try NADMOD!")
end


perms.RegisterMode(modepermission, modename, modedescription, false, nil, DefaultPermission)
