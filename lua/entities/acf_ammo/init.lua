AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include('shared.lua')

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
	
	self.WireDebugName = "Ammo Crate"
	self.Inputs = Wire_CreateInputs( self.Entity, { "Active" } ) --, "Fuse Length"
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Munitions" , "On Fire" } )
		
	self.NextThink = CurTime() +  1
	
	ACF.AmmoCrates = ACF.AmmoCrates or {}
end

function ENT:ACF_Activate( Recalc )
	
	local EmptyMass = math.max(self.EmptyMass, self:GetPhysicsObject():GetMass() - self:AmmoMass())

	self.ACF = self.ACF or {} 
	
	local PhysObj = self.Entity:GetPhysicsObject()
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

function ENT:ACF_OnDamage( Entity , Energy , FrAera , Angle , Inflictor )	--This function needs to return HitRes

	local HitRes = ACF_PropDamage( Entity , Energy , FrAera , Angle , Inflictor )	--Calling the standard damage prop function
	
	
	if self.Exploding or not self.IsExplosive then return HitRes end
	if HitRes.Kill then
		local CanDo = hook.Run("ACF_AmmoExplode", self.Entity, self.BulletData )
		if CanDo == false then return HitRes end
		self.Exploding = true
		if( Inflictor and Inflictor:IsValid() and Inflictor:IsPlayer() ) then
			self.Inflictor = Inflictor
		end
		if self.Ammo > 1 then
			ACF_AmmoExplosion( self.Entity , self.Entity:GetPos() )
		else
			ACF_HEKill( self.Entity , VectorRand() )
		end
	end
	
	if self.Damaged then return HitRes end
	local Ratio = (HitRes.Damage/self.BulletData["RoundVolume"])^0.2
	--print(Ratio)
	if ( Ratio * self.Capacity/self.Ammo ) > math.Rand(0,1) then  
		self.Inflictor = Inflictor
		self.Damaged = CurTime() + (5 - Ratio*3)
		Wire_TriggerOutput(self.Entity, "On Fire", 1)
	end
	
	return HitRes --This function needs to return HitRes
end

function MakeACF_Ammo(Owner, Pos, Angle, Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10)

	if not Owner:CheckLimit("_acf_ammo") then return false end
	
	local Ammo = ents.Create("ACF_Ammo")
	if not Ammo:IsValid() then return false end
	Ammo:SetAngles(Angle)
	Ammo:SetPos(Pos)
	Ammo:Spawn()
	Ammo:SetPlayer(Owner)
	Ammo.Owner = Owner
	
	Ammo.Model = ACF.Weapons["Ammo"][Id]["model"]
	Ammo:SetModel( Ammo.Model )	
	
	Ammo:PhysicsInit( SOLID_VPHYSICS )      	
	Ammo:SetMoveType( MOVETYPE_VPHYSICS )     	
	Ammo:SetSolid( SOLID_VPHYSICS )
	
	Ammo.Id = Id
	Ammo:CreateAmmo(Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10)
	
	Ammo.Ammo = Ammo.Capacity
	Ammo.EmptyMass = ACF.Weapons["Ammo"][Ammo.Id]["weight"]
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
list.Set( "ACFCvars", "acf_ammo" , {"id", "data1", "data2", "data3", "data4", "data5", "data6", "data7", "data8", "data9", "data10"} )
duplicator.RegisterEntityClass("acf_ammo", MakeACF_Ammo, "Pos", "Angle", "Id", "RoundId", "RoundType", "RoundPropellant", "RoundProjectile", "RoundData5", "RoundData6", "RoundData7", "RoundData8", "RoundData9", "RoundData10" )

function ENT:Update( ArgsTable )	--That table is the player data, as sorted in the ACFCvars above, with player who shot, and pos and angle of the tool trace inserted at the start

	local Feedback = "Ammocrate updated succesfully"
	
	if ( ArgsTable[1] != self.Owner ) then --Argtable[1] is the player that shot the tool
		Feedback = "You don't own that ammo crate !"
	return end
	
	if ( ArgsTable[6] == "Refill" ) then --Argtable[6] is the round type. If it's refill it shouldn't be loaded into guns, so we refuse to change to it
		Feedback = "Refill ammo type is only avaliable for new crates"
	return end
	
	if ( ArgsTable[5] != self.RoundId ) then --Argtable[5] is the weapon ID the new ammo loads into
		for Key, Gun in pairs( self.Master ) do
			if Gun:IsValid() then
				Gun:Unlink( self.Entity )
			end
		end
		Feedback = "New ammo type loaded, crate unlinked"
	end
	
	local AmmoPercent = self.Ammo/math.max(self.Capacity,1)
	
	self:CreateAmmo(ArgsTable[4], ArgsTable[5], ArgsTable[6], ArgsTable[7], ArgsTable[8], ArgsTable[9], ArgsTable[10], ArgsTable[11], ArgsTable[12], ArgsTable[13], ArgsTable[14])
	
	self.Ammo = math.floor(self.Capacity*AmmoPercent)
	local AmmoMass = self:AmmoMass()
	self.Mass = math.min(self.EmptyMass, self.Entity:GetPhysicsObject():GetMass() - AmmoMass) + AmmoMass*(self.Ammo/math.max(self.Capacity,1))
		
	return FeedBack
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
		PlayerData["Id"] = self.RoundId
		PlayerData["Type"] = self.RoundType
		PlayerData["PropLength"] = self.RoundPropellant
		PlayerData["ProjLength"] = self.RoundProjectile
		PlayerData["Data5"] = self.RoundData5
		PlayerData["Data6"] = self.RoundData6
		PlayerData["Data7"] = self.RoundData7
		PlayerData["Data8"] = self.RoundData8
		PlayerData["Data9"] = self.RoundData9
		PlayerData["Data10"] = self.RoundData10
	self.ConvertData = ACF.RoundTypes[self.RoundType]["convert"]
	self.BulletData = self:ConvertData( PlayerData )
	
	local Size = (self:OBBMaxs() - self:OBBMins())
	local Efficiency = 0.11 * ACF.AmmoMod			--This is the part of space that's actually useful, the rest is wasted on interround gaps, loading systems ..
	self.Volume = math.floor(Size.x * Size.y * Size.z)*Efficiency
	self.Capacity = math.floor(self.Volume*16.38/self.BulletData["RoundVolume"])
	
	self:SetNetworkedString("Ammo",self.Ammo)
	
	self.NetworkData = ACF.RoundTypes[self.RoundType]["network"]
	self:NetworkData( self.BulletData )
end

function ENT:AmmoMass() --Returns what the ammo mass would be if the crate was full
	return math.floor( (self.BulletData["ProjMass"] + self.BulletData["PropMass"]) * self.Capacity * 2 )
end


function ENT:TriggerInput( iname , value )

	if (iname == "Active") then
		if value > 0 then
			self.Load = true
			self:FirstLoad()
		else
			self.Load = false
		end
	elseif (iname == "Fuse Length" and value > 0 and (self.BulletData["RoundType"] == "HE" or self.BulletData["RoundType"] == "APHE")) then
	end

end

function ENT:FirstLoad()

	for Key,Value in pairs(self.Master) do
		if self.Master[Key] and self.Master[Key]:IsValid() and self.Master[Key]["BulletData"]["Type"] == "Empty" then
			--print("Send FirstLoad")
			self.Master[Key]:UnloadAmmo()
		end
	end
	
end

function ENT:Think()
	local AmmoMass = self:AmmoMass()
	self.Mass = math.max(self.EmptyMass, self.Entity:GetPhysicsObject():GetMass() - AmmoMass) + AmmoMass*(self.Ammo/math.max(self.Capacity,1))
	self.Entity:GetPhysicsObject():SetMass(self.Mass) 
	
	self:SetNetworkedString("Ammo",self.Ammo)
	
	local color = self.Entity:GetColor();
	self:SetNetworkedVector("TracerColour", Vector( color.r, color.g, color.b ) )
	
	local cvarGrav = GetConVar("sv_gravity")
	local vec = Vector(0,0,cvarGrav:GetInt()*-1)
	if( self.sitp_inspace ) then
		vec = Vector(0, 0, 0)
	end
		
	self:SetNetworkedVector("Accel", vec)
		
	self.Entity:NextThink( CurTime() +  1 )
	
	if self.Damaged then
		if self.Damaged < CurTime() then
			ACF_AmmoExplosion( self.Entity , self.Entity:GetPos() )
		else
			if not self.BulletData["Type"] == "Refill" then
				if math.Rand(0,150) > self.BulletData["RoundVolume"]^0.5 and math.Rand(0,1) < self.Ammo/math.max(self.Capacity,1) and ACF.RoundTypes[self.BulletData["Type"]] then
					self.Entity:EmitSound( "ambient/explosions/explode_4.wav" , 350 , math.max(255 - self.BulletData["PropMass"]*100,60)  )	
					local MuzzlePos = self.Entity:GetPos()
					local MuzzleVec = VectorRand()
					local Speed = ACF_MuzzleVelocity( self.BulletData["PropMass"], self.BulletData["ProjMass"]/2, self.Caliber )
					
					self.BulletData["Pos"] = MuzzlePos
					self.BulletData["Flight"] = (MuzzleVec):GetNormalized() * Speed * 39.37 + self:GetVelocity()
					self.BulletData["Owner"] = self.Inflictor or self.Owner
					self.BulletData["Gun"] = self.Entity
					self.BulletData["Crate"] = self.Entity:EntIndex()
					self.CreateShell = ACF.RoundTypes[self.BulletData["Type"]]["create"]
					self:CreateShell( self.BulletData )
					
					self.Ammo = self.Ammo - 1
					
				end
			end
			self.Entity:NextThink( CurTime() + 0.01 + self.BulletData["RoundVolume"]^0.5/100 )
		end
	elseif self.RoundType == "Refill" and self.Ammo > 0 then // Completely new, fresh, genius, beautiful, flawless refill system.
		if self.Load then
			for _,Ammo in pairs( ACF.AmmoCrates ) do
				if Ammo.RoundType ~= "Refill" then
					local dist = self.Entity:GetPos():Distance(Ammo:GetPos())
					if dist < ACF.RefillDistance then
					
						if Ammo.Capacity > Ammo.Ammo then
							self.SupplyingTo = self.SupplyingTo or {}
							if not table.HasValue( self.SupplyingTo, Ammo:EntIndex() ) then
								table.insert(self.SupplyingTo, Ammo:EntIndex())
								self:RefillEffect( Ammo )
							end
									
							local Supply = math.ceil((50000/((Ammo.BulletData["ProjMass"]+Ammo.BulletData["PropMass"])*1000))/dist)
							--Msg(tostring(50000).."/"..((Ammo.BulletData["ProjMass"]+Ammo.BulletData["PropMass"])*1000).."/"..dist.."="..Supply.."\n")
							local Transfert = math.min(Supply , Ammo.Capacity - Ammo.Ammo)
							Ammo.Ammo = Ammo.Ammo + Transfert
							self.Ammo = self.Ammo - Transfert
								
							Ammo.Supplied = true
							Ammo.Entity:EmitSound( "items/ammo_pickup.wav" , 500, 80 )
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
				local dist = self.Entity:GetPos():Distance(Ammo:GetPos())
				if dist > ACF.RefillDistance or Ammo.Capacity <= Ammo.Ammo or self.Damaged or not self.Load then // If ammo crate is out of refill max distance or is full or our refill crate is damaged or just in-active then stop refiliing it.
					table.remove(self.SupplyingTo, k)
					self:StopRefillEffect( Ammo )
				end
			end
		end
	end
	
	Wire_TriggerOutput(self.Entity, "Munitions", self.Ammo)
	return true

end

function ENT:RefillEffect( Target )
	umsg.Start("ACF_RefillEffect")
		umsg.Float( self.Entity:EntIndex() )
		umsg.Float( Target:EntIndex() )
		umsg.String( Target.RoundType )
	umsg.End()
end

function ENT:StopRefillEffect( Target )
	umsg.Start("ACF_StopRefillEffect")
		umsg.Float( self.Entity:EntIndex() )
		umsg.Float( Target:EntIndex() )
	umsg.End()
end

function ENT:ConvertData()
	--You overwrite this with your own function, defined in the ammo definition file
end

function ENT:NetworkData()
	--You overwrite this with your own function, defined in the ammo definition file
end

/*
function ENT:Touch( Supplier ) // OLD REFILL SYSTEM
	
	if ( Supplier:GetClass() == "acf_ammo" ) then

		if ( Supplier.RoundType == "Refill" ) then
		
			local Supply = math.floor(Supplier.Ammo/self.BulletData["RoundVolume"])
			
			if self.Capacity > self.Ammo then	
			
				local Transfert = math.min(Supply , self.Capacity - self.Ammo)
				--Msg("Reicever Ok " ..Transfert.. "\n")
				self.Ammo = self.Ammo + Transfert
				Supplier.Ammo = Supplier.Ammo - math.floor(Transfert*self.BulletData["RoundVolume"])
				
				self.Supplied = true
				self.Entity:EmitSound( "items/ammo_pickup.wav" , 500, 80 )
				
				if Transfer == Supply then			
					Supplier:Remove()
				end
				
			end
			
		end
		
	end
	
end
*/

function ENT:OnRemove()
	for Key,Value in pairs(self.Master) do
		if self.Master[Key] and self.Master[Key]:IsValid() then
			self.Master[Key]:Unlink( self.Entity )
			self.Ammo = 0
		end
	end
	for k,v in pairs(ACF.AmmoCrates) do
		if v == self then
			table.remove(ACF.AmmoCrates,k)
		end
	end
	Wire_Remove(self.Entity)
end

function ENT:OnRestore()
    Wire_Restored(self.Entity)
end

function ENT:PreEntityCopy()
	//Wire dupe info
	local DupeInfo = WireLib.BuildDupeInfo(self.Entity)
	if(DupeInfo) then
		duplicator.StoreEntityModifier(self.Entity,"WireDupeInfo",DupeInfo)
	end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
	//Wire dupe info
	if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
		WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end