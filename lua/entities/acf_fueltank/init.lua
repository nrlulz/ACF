AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include('shared.lua')

--don't forget:
--armored tanks

function ENT:Initialize()
	
	self.CanUpdate = true
	self.SpecialHealth = true	--If true, use the ACF_Activate function defined by this ent
	self.SpecialDamage = true	--If true, use the ACF_OnDamage function defined by this ent
	self.IsExplosive = true		
	self.Exploding = false
	
	self.Size = 0 --outer dimensions
	self.Volume = 0 --total internal volume in cubic inches
	self.Capacity = 0  --max fuel capacity in liters
	self.Fuel = 0  --current fuel level in liters
	self.FuelType = nil
	self.EmptyMass = 0 --mass of tank only
	self.Id = nil --model id
	self.Active = false
	self.SupplyFuel = false
	self.Leaking = 0
	
	self.WireDebugName = "Fuel Tank"
	self.Inputs = Wire_CreateInputs( self, { "Active", "Refuel Duty" } )
	self.Outputs = WireLib.CreateSpecialOutputs( self,
		{ "Fuel", "Capacity", "Leaking", "Entity" }, 
		{ "NORMAL", "NORMAL", "NORMAL", "ENTITY" }
	)
	Wire_TriggerOutput( self, "Leaking", 0 )
	Wire_TriggerOutput( self, "Entity", self )
	
	self.Master = {} --engines linked to this tank
	ACF.FuelTanks = ACF.FuelTanks or {} --master list of acf fuel tanks
	
	self.LastThink = 0
	self.NextThink = CurTime() +  1
	
end

function ENT:ACF_Activate( Recalc )
	
	self.ACF = self.ACF or {} 
	
	local PhysObj = self:GetPhysicsObject()
	if not self.ACF.Aera then
		self.ACF.Aera = PhysObj:GetSurfaceArea() * 6.45
	end
	if not self.ACF.Volume then
		self.ACF.Volume = PhysObj:GetVolume() * 1
	end
	
	local Armour = self.EmptyMass*1000 / self.ACF.Aera / 0.78 --So we get the equivalent thickness of that prop in mm if all it's weight was a steel plate
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
	self.ACF.Density = (PhysObj:GetMass()*1000) / self.ACF.Volume
	self.ACF.Type = "Prop"
	
end

function ENT:ACF_OnDamage( Entity , Energy , FrAera , Angle , Inflictor )	--This function needs to return HitRes

	local HitRes = ACF_PropDamage( Entity , Energy , FrAera , Angle , Inflictor )	--Calling the standard damage prop function
	
	if self.Exploding or not self.IsExplosive then return HitRes end
	
	if HitRes.Kill then
		self.Exploding = true
		if( Inflictor and Inflictor:IsValid() and Inflictor:IsPlayer() ) then
			self.Inflictor = Inflictor
		end
		ACF_ScaledExplosion( self )
		return HitRes
	end
	
	local Ratio = (HitRes.Damage/self.ACF.Health)^0.75 --chance to explode from sheer damage, small shots = small chance
	local ExplodeChance = (1-(self.Fuel/self.Capacity))^0.75 --chance to explode from fumes in tank, less fuel = more explodey
	 
	if math.Rand(0,1) < (ExplodeChance + Ratio) then  --it's gonna blow
		self.Inflictor = Inflictor
		self.Exploding = true
		ACF_ScaledExplosion( self )
	else 												--spray some fuel around
		self:NextThink( CurTime() + 0.1 )
		self.Leaking = self.Leaking + self.Fuel * ((HitRes.Damage/self.ACF.Health)^1.5) * 0.25
	end
	
	return HitRes
end

function MakeACF_FuelTank(Owner, Pos, Angle, Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10)

	if not Owner:CheckLimit("_acf_misc") then return false end
	
	local Tank = ents.Create("acf_fueltank")
	if not Tank:IsValid() then return false end
	Tank:SetAngles(Angle)
	Tank:SetPos(Pos)
	Tank:Spawn()
	Tank:SetPlayer(Owner)
	Tank.Owner = Owner
	
	local Tanks = list.Get("ACFEnts")["FuelTanks"]
	
	Tank.Id = Id
	Tank.SizeId = Data1
	Tank.Model = Tanks[Tank.SizeId]["model"]
	Tank:SetModel( Tank.Model )	
	
	Tank:PhysicsInit( SOLID_VPHYSICS )      	
	Tank:SetMoveType( MOVETYPE_VPHYSICS )     	
	Tank:SetSolid( SOLID_VPHYSICS )

	Tank:UpdateFuelTank(Id, Data1, Data2)
	
	Owner:AddCount( "_acf_fueltank", Tank )
	Owner:AddCleanup( "acfmenu", Tank )
	
	table.insert(ACF.FuelTanks, Tank)
	
	return Tank
end
list.Set( "ACFCvars", "acf_fueltank" , {"id", "data1", "data2"} )
duplicator.RegisterEntityClass("acf_fueltank", MakeACF_FuelTank, "Pos", "Angle", "Id", "SizeId", "FuelType" )

function ENT:UpdateFuelTank(Id, Data1, Data2)

	local Size = self:OBBMaxs() - self:OBBMins() --outer dimensions of tank
	local Wall = 0.1 --wall thickness in inches
	local pct = 1 --how full is the tank?
	local new = self.Capacity == 0 -- is it new or updated?
	if not new then pct = self.Fuel / self.Capacity end 
	self.Size = math.floor(Size.x * Size.y * Size.z) -- total volume of tank (cu in)
	self.Volume = math.floor((Size.x - Wall) * (Size.y - Wall) * (Size.z - Wall)) -- internal volume in cubic inches
	self.Capacity = self.Volume * ACF.CuIToLiter * ACF.TankVolumeMul * 0.125 --internal volume available for fuel in liters
	self.EmptyMass = ((self.Size - self.Volume)*16.387)*7.9/1000  -- total wall volume * cu in to cc * density of steel (kg/cc)
	self.FuelType = Data2
	
	if self.FuelType == "Electric" then
		self.Liters = self.Capacity --batteries capacity is different from internal volume
		self.Capacity = self.Capacity * ACF.LiIonED
		self.Fuel = pct * self.Capacity
		self.IsExplosive = false
	else
		self.Fuel = pct * self.Capacity
		self.IsExplosive = true
	end
	
	self:UpdateFuelMass()
	
	Wire_TriggerOutput( self, "Capacity", math.Round(self.Capacity,2) )
	self:SetNetworkedString("FuelType",self.FuelType)
	self:SetNetworkedFloat("FuelLevel",math.Round(self.Fuel,1))
end

function ENT:UpdateFuelMass()

	if self.FuelType == "Electric" then
		self.Mass = self.EmptyMass + self.Liters * ACF.FuelDensity[self.FuelType]
	else
		local FuelMass = self.Fuel * ACF.FuelDensity[self.FuelType]
		self.Mass = self.EmptyMass + FuelMass
	end
	
	local phys = self:GetPhysicsObject()  	
	if (phys:IsValid()) then 
		phys:SetMass( self.Mass ) 
	end
	
	self:SetNetworkedFloat("FuelLevel",math.Round(self.Fuel,1))
end

function ENT:Update( ArgsTable )

	local Feedback = ""
	
	if ( ArgsTable[1] != self.Owner ) then --Argtable[1] is the player that shot the tool
		return false, "You don't own that fuel tank!"
	end
	
	if ( ArgsTable[6] != self.FuelType ) then
		for Key, Engine in pairs( self.Master ) do
			if Engine:IsValid() then
				Engine:Unlink( self )
			end
		end
		Feedback = " New fuel type loaded, fuel tank unlinked."
	end
	
	self:UpdateFuelTank(ArgsTable[4], ArgsTable[5], ArgsTable[6]) --Id, SizeId, FuelType

	return true, "Fuel tank successfully updated."..Feedback
end

function ENT:TriggerInput( iname , value )

	if (iname == "Active") then
		if not (value == 0) then
			self.Active = true
		else
			self.Active = false
		end
	elseif iname == "Refuel Duty" then
		if not (value == 0) then
			self.SupplyFuel = true
		else
			self.SupplyFuel = false
		end
	end

end

function ENT:Think()
	
	self:NextThink( CurTime() +  1 )
	
	if self.Leaking > 0 then
		self:NextThink( CurTime() + 0.25 )
		self.Fuel = math.max(self.Fuel - self.Leaking,0)
		self.Leaking = math.Clamp(self.Leaking - (1 / math.max(self.Fuel,1))^0.5, 0, self.Fuel) --fuel tanks are self healing
		Wire_TriggerOutput(self, "Leaking", (self.Leaking > 0) and 1 or 0)
	end
	
	--refuelling
	if self.Active and self.SupplyFuel and self.Fuel > 0 then
		for _,Tank in pairs(ACF.FuelTanks) do
			if self.FuelType == Tank.FuelType and not Tank.SupplyFuel then --don't refuel the refuellers, otherwise it'll be one big circlejerk
				local dist = self:GetPos():Distance(Tank:GetPos())
				if dist < ACF.RefillDistance then
					if Tank.Capacity - Tank.Fuel > 0.1 then
						local exchange = (CurTime() - self.LastThink) * ACF.RefillSpeed * (((self.FuelType == "Electric") and ACF.ElecRate) or ACF.FuelRate) / 3500
						exchange = math.min(exchange, self.Fuel, Tank.Capacity - Tank.Fuel)
						self.Fuel = self.Fuel - exchange
						Tank.Fuel = Tank.Fuel + exchange
						if Tank.FuelType == "Electric" then
							Tank:EmitSound( "ambient/energy/newspark04.wav" , 500, 100 )
						else
							Tank:EmitSound( "vehicles/jetski/jetski_no_gas_start.wav" , 500, 120 )
						end
					end
				end
			end
		end
	end
	
	self:UpdateFuelMass()
	
	Wire_TriggerOutput(self, "Fuel", self.Fuel)
	
	self.LastThink = CurTime()
	
	return true

end

function ENT:OnRemove()
	for Key,Value in pairs(self.Master) do
		if self.Master[Key] and self.Master[Key]:IsValid() then
			self.Master[Key]:Unlink( self )
		end
	end
	if #ACF.FuelTanks then
		for k,v in pairs(ACF.FuelTanks) do
			if v == self then
				table.remove(ACF.FuelTanks,k)
			end
		end
	end
	Wire_Remove(self)
end

function ENT:OnRestore()
    Wire_Restored(self)
end

function ENT:PreEntityCopy() --Wire dupe info
	local DupeInfo = WireLib.BuildDupeInfo(self)
	if(DupeInfo) then
		duplicator.StoreEntityModifier(self,"WireDupeInfo",DupeInfo)
	end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities) --Wire dupe info
	if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
		WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end