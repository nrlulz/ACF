
AddCSLuaFile()

DEFINE_BASECLASS( "base_wire_entity" )

ENT.PrintName = "ACF Ammo Crate"
ENT.WireDebugName = "ACF Ammo Crate"

if CLIENT then
	
	/*-------------------------------------
	Shamefully stolen from lua rollercoaster. I'M SO SORRY. I HAD TO.
	-------------------------------------*/

	local function Bezier( a, b, c, d, t )
		local ab,bc,cd,abbc,bccd 
		
		ab = LerpVector(t, a, b)
		bc = LerpVector(t, b, c)
		cd = LerpVector(t, c, d)
		abbc = LerpVector(t, ab, bc)
		bccd = LerpVector(t, bc, cd)
		dest = LerpVector(t, abbc, bccd)
		
		return dest
	end


	local function BezPoint(perc, Table)
		perc = perc or self.Perc
		
		local vec = Vector(0, 0, 0)
		
		vec = Bezier(Table[1], Table[2], Table[3], Table[4], perc)
		
		return vec
	end
	
	function ACF_DrawRefillAmmo( Table )
		for k,v in pairs( Table ) do
			local St, En = v.EntFrom:LocalToWorld(v.EntFrom:OBBCenter()), v.EntTo:LocalToWorld(v.EntTo:OBBCenter())
			local Distance = (En - St):Length()
			local Amount = math.Clamp((Distance/50),2,100)
			local Time = (SysTime() - v.StTime)
			local En2, St2 = En + Vector(0,0,100), St + ((En-St):GetNormalized() * 10)
			local vectab = { St, St2, En2, En}
			local center = (St+En)/2
			for I = 1, Amount do
				local point = BezPoint(((((I+Time)%Amount))/Amount), vectab)
				local ang = (point - center):Angle()
				local MdlTbl = {
					model = v.Model,
					pos = point,
					angle = ang
				}
				render.Model( MdlTbl )
			end
		end
	end

	function ENT:Draw()
		
		self.BaseClass.Draw( self )
		
		if self.RefillAmmoEffect then
			ACF_DrawRefillAmmo( self.RefillAmmoEffect )
		end
		
	end
	
	usermessage.Hook("ACF_RefillEffect", function( msg )
		local EntFrom, EntTo, Weapon = ents.GetByIndex( msg:ReadFloat() ), ents.GetByIndex( msg:ReadFloat() ), msg:ReadString()
		if not IsValid( EntFrom ) or not IsValid( EntTo ) then return end
		//local List = list.Get( "ACFRoundTypes")	
		-- local Mdl = ACF.Weapons.Guns[Weapon].round.model or "models/munitions/round_100mm_shot.mdl"
		local Mdl = "models/munitions/round_100mm_shot.mdl"
		EntFrom.RefillAmmoEffect = EntFrom.RefillAmmoEffect or {}
		table.insert( EntFrom.RefillAmmoEffect, {EntFrom = EntFrom, EntTo = EntTo, Model = Mdl, StTime = SysTime()} )
	end)
	
	usermessage.Hook("ACF_StopRefillEffect", function( msg )
		local EntFrom, EntTo = ents.GetByIndex( msg:ReadFloat() ), ents.GetByIndex( msg:ReadFloat() )
		if not IsValid( EntFrom ) or not IsValid( EntTo )or not EntFrom.RefillAmmoEffect then return end
		for k,v in pairs( EntFrom.RefillAmmoEffect ) do
			if v.EntTo == EntTo then
				if #EntFrom.RefillAmmoEffect<=1 then 
					EntFrom.RefillAmmoEffect = nil
					return
				end
				table.remove(EntFrom.RefillAmmoEffect, k)
			end
		end
	end)
	
	return
	
end

function ENT:Initialize()
	
	self.SpecialHealth = true	--If true needs a special ACF_Activate function
	self.SpecialDamage = true	--If true needs a special ACF_OnDamage function
	self.IsExplosive = true
	self.Exploding = false
	self.Damaged = false
	self.CanUpdate = true
	self.Load = false
	self.EmptyMass = 0
	self.Ammo = 0
	
	self.Master = {}
	self.Sequence = 0
	
	self.Inputs = Wire_CreateInputs( self, { "Active" } ) --, "Fuse Length"
	self.Outputs = Wire_CreateOutputs( self, { "Munitions", "On Fire" } )
		
	self.NextThink = CurTime() +  1
	
	ACF.AmmoCrates = ACF.AmmoCrates or {}
	
end

function ENT:ACF_Activate( Recalc )
	
	local EmptyMass = math.max(self.EmptyMass, self:GetPhysicsObject():GetMass() - self:AmmoMass())

	self.ACF = self.ACF or {} 
	
	local PhysObj = self:GetPhysicsObject()
	if not self.ACF.Aera then
		self.ACF.Aera = PhysObj:GetSurfaceArea() * 6.45
	end
	if not self.ACF.Volume then
		self.ACF.Volume = PhysObj:GetVolume() * 16.38
	end
	
	local Armour = EmptyMass*1000 / self.ACF.Aera / 0.78 --So we get the equivalent thickness of that prop in mm if all it's weight was a steel plate
	local Health = self.ACF.Volume/ACF.Threshold							--Setting the threshold of the prop aera gone 
	local Percent = 1 
	
	if Recalc and self.ACF.Health and self.ACF.MaxHealth then
		Percent = self.ACF.Health/self.ACF.MaxHealth
	end
	
	self.ACF.Health = Health * Percent
	self.ACF.MaxHealth = Health
	self.ACF.Armour = Armour * (0.5 + Percent/2)
	self.ACF.MaxArmour = Armour
	self.ACF.Type = nil
	self.ACF.Mass = self.Mass
	self.ACF.Density = (self:GetPhysicsObject():GetMass()*1000) / self.ACF.Volume
	self.ACF.Type = "Prop"
	
end

function ENT:ACF_OnDamage( Entity, Energy, FrAera, Angle, Inflictor, Bone, Type )	--This function needs to return HitRes

	local Mul = ((Type == "HEAT" and 13.2) or 1) --Heat penetrators deal bonus damage to ammo, roughly equal to an AP round
	local HitRes = ACF_PropDamage( Entity, Energy, FrAera * Mul, Angle, Inflictor )	--Calling the standard damage prop function
	
	if self.Exploding or not self.IsExplosive then return HitRes end
	
	if HitRes.Kill then
		if hook.Run("ACF_AmmoExplode", self, self.BulletData ) == false then return HitRes end
		self.Exploding = true
		if( Inflictor and Inflictor:IsValid() and Inflictor:IsPlayer() ) then
			self.Inflictor = Inflictor
		end
		if self.Ammo > 1 then
			ACF_ScaledExplosion( self )
		else
			ACF_HEKill( self, VectorRand() )
		end
	end
	
	if self.Damaged then return HitRes end
	local Ratio = (HitRes.Damage/self.BulletData.RoundVolume)^0.2
	--print(Ratio)
	if ( Ratio * self.Capacity/self.Ammo ) > math.Rand(0,1) then  
		self.Inflictor = Inflictor
		self.Damaged = CurTime() + (5 - Ratio*3)
		Wire_TriggerOutput(self, "On Fire", 1)
	end
	
	return HitRes --This function needs to return HitRes
end

function MakeACF_Ammo(Owner, Pos, Angle, Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10)

	if not Owner:CheckLimit("_acf_ammo") then return false end
	
	local Ammo = ents.Create("acf_ammo")
	if not Ammo:IsValid() then return false end
	Ammo:SetAngles(Angle)
	Ammo:SetPos(Pos)
	Ammo:Spawn()
	Ammo:SetPlayer(Owner)
	Ammo.Owner = Owner
	
	Ammo.Model = ACF.Weapons.Ammo[Id].model
	Ammo:SetModel( Ammo.Model )	
	
	Ammo:PhysicsInit( SOLID_VPHYSICS )      	
	Ammo:SetMoveType( MOVETYPE_VPHYSICS )     	
	Ammo:SetSolid( SOLID_VPHYSICS )
	
	Ammo.Id = Id
	Ammo:CreateAmmo(Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10)
	
	Ammo.Ammo = Ammo.Capacity
	Ammo.EmptyMass = ACF.Weapons.Ammo[Ammo.Id].weight
	Ammo.Mass = Ammo.EmptyMass + Ammo:AmmoMass()
	
	local phys = Ammo:GetPhysicsObject()  	
	if (phys:IsValid()) then 
		phys:SetMass( Ammo.Mass ) 
	end
	
	Owner:AddCount( "_acf_ammo", Ammo )
	Owner:AddCleanup( "acfmenu", Ammo )
	
	table.insert(ACF.AmmoCrates, Ammo)
	
	
	return Ammo
end
list.Set( "ACFCvars", "acf_ammo", {"id", "data1", "data2", "data3", "data4", "data5", "data6", "data7", "data8", "data9", "data10"} )
duplicator.RegisterEntityClass("acf_ammo", MakeACF_Ammo, "Pos", "Angle", "Id", "RoundId", "RoundType", "RoundPropellant", "RoundProjectile", "RoundData5", "RoundData6", "RoundData7", "RoundData8", "RoundData9", "RoundData10" )

function ENT:Update( ArgsTable )
	
	-- That table is the player data, as sorted in the ACFCvars above, with player who shot, 
	-- and pos and angle of the tool trace inserted at the start

	local msg = "Ammo crate updated successfully!"
	
	if ArgsTable[1] ~= self.Owner then -- Argtable[1] is the player that shot the tool
		return false, "You don't own that ammo crate!"
	end
	
	if ArgsTable[6] == "Refill" then -- Argtable[6] is the round type. If it's refill it shouldn't be loaded into guns, so we refuse to change to it
		return false, "Refill ammo type is only avaliable for new crates!"
	end
	
	if ArgsTable[5] ~= self.RoundId then -- Argtable[5] is the weapon ID the new ammo loads into
		for Key, Gun in pairs( self.Master ) do
			if IsValid( Gun ) then
				Gun:Unlink( self )
			end
		end
		msg = "New ammo type loaded, crate unlinked."
	else -- ammotype wasn't changed, but let's check if new roundtype is blacklisted
		local Blacklist = ACF.AmmoBlacklist[ ArgsTable[6] ] or {}
		
		for Key, Gun in pairs( self.Master ) do
			if IsValid( Gun ) and table.HasValue( Blacklist, Gun.Class ) then
				Gun:Unlink( self )
				msg = "New round type cannot be used with linked gun, crate unlinked."
			end
		end
	end
	
	local AmmoPercent = self.Ammo/math.max(self.Capacity,1)
	
	self:CreateAmmo(ArgsTable[4], ArgsTable[5], ArgsTable[6], ArgsTable[7], ArgsTable[8], ArgsTable[9], ArgsTable[10], ArgsTable[11], ArgsTable[12], ArgsTable[13], ArgsTable[14])
	
	self.Ammo = math.floor(self.Capacity*AmmoPercent)
	local AmmoMass = self:AmmoMass()
	self.Mass = math.min(self.EmptyMass, self:GetPhysicsObject():GetMass() - AmmoMass) + AmmoMass*(self.Ammo/math.max(self.Capacity,1))
	
	return true, msg
	
end

function ENT:UpdateOverlayText()
	
	local roundType = self.RoundType
	
	if self.BulletData.Tracer and self.BulletData.Tracer > 0 then 
		roundType = roundType .. "-T"
	end
	
	local text = roundType .. " - " .. self.Ammo .. " / " .. self.Capacity
	--text = text .. "\nRound Type: " .. self.RoundType
	
	local RoundData = ACF.RoundTypes[ self.RoundType ]
	
	if RoundData and RoundData.cratetxt then
		text = text .. "\n" .. RoundData.cratetxt( self.BulletData )
	end
	
	self:SetOverlayText( text )
	
end

function ENT:CreateAmmo(Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10)

	--Data 1 to 4 are should always be Round ID, Round Type, Propellant lenght, Projectile lenght
	self.RoundId = Data1		--Weapon this round loads into, ie 140mmC, 105mmH ...
	self.RoundType = Data2		--Type of round, IE AP, HE, HEAT ...
	self.RoundPropellant = Data3--Lenght of propellant
	self.RoundProjectile = Data4--Lenght of the projectile
	self.RoundData5 = ( Data5 or 0 )
	self.RoundData6 = ( Data6 or 0 )
	self.RoundData7 = ( Data7 or 0 )
	self.RoundData8 = ( Data8 or 0 )
	self.RoundData9 = ( Data9 or 0 )
	self.RoundData10 = ( Data10 or 0 )
	
	local PlayerData = {}
		PlayerData.Id = self.RoundId
		PlayerData.Type = self.RoundType
		PlayerData.PropLength = self.RoundPropellant
		PlayerData.ProjLength = self.RoundProjectile
		PlayerData.Data5 = self.RoundData5
		PlayerData.Data6 = self.RoundData6
		PlayerData.Data7 = self.RoundData7
		PlayerData.Data8 = self.RoundData8
		PlayerData.Data9 = self.RoundData9
		PlayerData.Data10 = self.RoundData10
	self.ConvertData = ACF.RoundTypes[self.RoundType].convert
	self.BulletData = self:ConvertData( PlayerData )
	
	local Size = (self:OBBMaxs() - self:OBBMins())
	local Efficiency = 0.11 * ACF.AmmoMod			--This is the part of space that's actually useful, the rest is wasted on interround gaps, loading systems ..
	local vol = math.floor(Size.x * Size.y * Size.z)
	self.Volume = vol*Efficiency	
	local CapMul = (vol > 46000) and ((math.log(vol*0.00066)/math.log(2)-4)*0.125+1) or 1
	self.Capacity = math.floor(CapMul*self.Volume*16.38/self.BulletData.RoundVolume)
	self.Caliber = list.Get("ACFEnts").Guns[self.RoundId].caliber
	self.RoFMul = (vol > 46000) and (1-(math.log(vol*0.00066)/math.log(2)-4)*0.05) or 1 --*0.0625 for 25% @ 4x8x8, 0.025 10%, 0.0375 15%, 0.05 20%

	local List = list.Get("ACFEnts")
	
	self:SetNetworkedString( "Ammo", self.Ammo )
	self:SetNetworkedString( "WireName", List.Guns[self.RoundId].name .. " Ammo" )
	
	self.NetworkData = ACF.RoundTypes[self.RoundType].network
	self:NetworkData( self.BulletData )
	
	self:UpdateOverlayText()
	
end

function ENT:AmmoMass() --Returns what the ammo mass would be if the crate was full
	return math.floor( (self.BulletData.ProjMass + self.BulletData.PropMass) * self.Capacity * 2 )
end



function ENT:GetInaccuracy()
	local SpreadScale = ACF.SpreadScale
	local inaccuracy = 0
	local Gun = list.Get("ACFEnts").Guns[self.RoundId]
	
	if Gun then
		local Classes = list.Get("ACFClasses")
		inaccuracy = (Classes.GunClass[Gun.gunclass] or {spread = 0}).spread
	end
	
	local coneAng = inaccuracy * ACF.GunInaccuracyScale
	return coneAng
end



function ENT:TriggerInput( iname, value )

	if (iname == "Active") then
		if value > 0 then
			self.Load = true
			self:FirstLoad()
		else
			self.Load = false
		end
	elseif (iname == "Fuse Length" and value > 0 and (self.BulletData.RoundType == "HE" or self.BulletData.RoundType == "APHE")) then
	end

end

function ENT:FirstLoad()

	for Key,Value in pairs(self.Master) do
		if self.Master[Key] and self.Master[Key]:IsValid() and self.Master[Key].BulletData.Type == "Empty" then
			--print("Send FirstLoad")
			self.Master[Key]:UnloadAmmo()
		end
	end
	
end

function ENT:Think()
	local AmmoMass = self:AmmoMass()
	self.Mass = math.max(self.EmptyMass, self:GetPhysicsObject():GetMass() - AmmoMass) + AmmoMass*(self.Ammo/math.max(self.Capacity,1))
	self:GetPhysicsObject():SetMass(self.Mass) 
	
	if self.Ammo ~= self.AmmoLast then
		self:UpdateOverlayText()
		self.AmmoLast = self.Ammo
	end
	
	local color = self:GetColor()
	self:SetNetworkedVector("TracerColour", Vector( color.r, color.g, color.b ) )
	
	local cvarGrav = GetConVar("sv_gravity")
	local vec = Vector(0,0,cvarGrav:GetInt()*-1)
	if( self.sitp_inspace ) then
		vec = Vector(0, 0, 0)
	end
		
	self:SetNetworkedVector("Accel", vec)
		
	self:NextThink( CurTime() +  1 )
	
	if self.Damaged then
		if self.Damaged < CurTime() then
			ACF_ScaledExplosion( self )
		else
			if not (self.BulletData.Type == "Refill") then
				if math.Rand(0,150) > self.BulletData.RoundVolume^0.5 and math.Rand(0,1) < self.Ammo/math.max(self.Capacity,1) and ACF.RoundTypes[self.BulletData.Type] then
					self:EmitSound( "ambient/explosions/explode_4.wav", 350, math.max(255 - self.BulletData.PropMass*100,60)  )	
					local MuzzlePos = self:GetPos()
					local MuzzleVec = VectorRand()
					local Speed = ACF_MuzzleVelocity( self.BulletData.PropMass, self.BulletData.ProjMass/2, self.Caliber )
					
					self.BulletData.Pos = MuzzlePos
					self.BulletData.Flight = (MuzzleVec):GetNormalized() * Speed * 39.37 + self:GetVelocity()
					self.BulletData.Owner = self.Inflictor or self.Owner
					self.BulletData.Gun = self
					self.BulletData.Crate = self:EntIndex()
					self.CreateShell = ACF.RoundTypes[self.BulletData.Type].create
					self:CreateShell( self.BulletData )
					
					self.Ammo = self.Ammo - 1
					
				end
			end
			self:NextThink( CurTime() + 0.01 + self.BulletData.RoundVolume^0.5/100 )
		end
	elseif self.RoundType == "Refill" and self.Ammo > 0 then // Completely new, fresh, genius, beautiful, flawless refill system.
		if self.Load then
			for _,Ammo in pairs( ACF.AmmoCrates ) do
				if Ammo.RoundType ~= "Refill" then
					local dist = self:GetPos():Distance(Ammo:GetPos())
					if dist < ACF.RefillDistance then
					
						if Ammo.Capacity > Ammo.Ammo then
							self.SupplyingTo = self.SupplyingTo or {}
							if not table.HasValue( self.SupplyingTo, Ammo:EntIndex() ) then
								table.insert(self.SupplyingTo, Ammo:EntIndex())
								self:RefillEffect( Ammo )
							end
									
							local Supply = math.ceil((50000/((Ammo.BulletData.ProjMass+Ammo.BulletData.PropMass)*1000))/dist)
							--Msg(tostring(50000).."/"..((Ammo.BulletData.ProjMass+Ammo.BulletData.PropMass)*1000).."/"..dist.."="..Supply.."\n")
							local Transfert = math.min(Supply, Ammo.Capacity - Ammo.Ammo)
							Ammo.Ammo = Ammo.Ammo + Transfert
							self.Ammo = self.Ammo - Transfert
								
							Ammo.Supplied = true
							Ammo.Entity:EmitSound( "items/ammo_pickup.wav", 500, 80 )
						end
					end
				end
			end
		end
	end
	
	if self.SupplyingTo then
		for k,v in pairs( self.SupplyingTo ) do
			local Ammo = ents.GetByIndex(v)
			if not IsValid( Ammo ) then 
				table.remove(self.SupplyingTo, k)
				self:StopRefillEffect( Ammo )
			else
				local dist = self:GetPos():Distance(Ammo:GetPos())
				if dist > ACF.RefillDistance or Ammo.Capacity <= Ammo.Ammo or self.Damaged or not self.Load then // If ammo crate is out of refill max distance or is full or our refill crate is damaged or just in-active then stop refiliing it.
					table.remove(self.SupplyingTo, k)
					self:StopRefillEffect( Ammo )
				end
			end
		end
	end
	
	Wire_TriggerOutput(self, "Munitions", self.Ammo)
	return true

end

function ENT:RefillEffect( Target )
	umsg.Start("ACF_RefillEffect")
		umsg.Float( self:EntIndex() )
		umsg.Float( Target:EntIndex() )
		umsg.String( Target.RoundType )
	umsg.End()
end

function ENT:StopRefillEffect( Target )
	umsg.Start("ACF_StopRefillEffect")
		umsg.Float( self:EntIndex() )
		umsg.Float( Target:EntIndex() )
	umsg.End()
end

function ENT:ConvertData()
	--You overwrite this with your own function, defined in the ammo definition file
end

function ENT:NetworkData()
	--You overwrite this with your own function, defined in the ammo definition file
end

function ENT:OnRemove()
	
	for Key,Value in pairs(self.Master) do
		if self.Master[Key] and self.Master[Key]:IsValid() then
			self.Master[Key]:Unlink( self )
			self.Ammo = 0
		end
	end
	for k,v in pairs(ACF.AmmoCrates) do
		if v == self then
			table.remove(ACF.AmmoCrates,k)
		end
	end
	
end
