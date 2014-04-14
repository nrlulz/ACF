AddCSLuaFile()

DEFINE_BASECLASS( "base_wire_entity" )

ENT.PrintName = "ACF Fuel Tank"
ENT.WireDebugName = "ACF Fuel Tank"

--don't forget:
--armored tanks

if CLIENT then
	
	function ACFFuelTankGUICreate( Table )
		if not acfmenupanel.CustomDisplay then return end
		if not acfmenupanel.FuelTankData then
			acfmenupanel.FuelTankData = {}
			acfmenupanel.FuelTankData.Id = "Tank_4x4x2"
			acfmenupanel.FuelTankData.FuelID = "Petrol"
		end
		
		local Tanks = list.Get("ACFEnts").FuelTanks
		local SortedTanks = {}
		for n in pairs(Tanks) do table.insert(SortedTanks,n) end
		table.sort(SortedTanks)
		
		acfmenupanel:CPanelText("Name", Table.name)
		acfmenupanel:CPanelText("Desc", Table.desc)
		
		-- tank size dropbox
		acfmenupanel.CData.TankSizeSelect = vgui.Create( "DComboBox", acfmenupanel.CustomDisplay )
			acfmenupanel.CData.TankSizeSelect:SetSize(100, 30)
			for k,v in ipairs(SortedTanks) do acfmenupanel.CData.TankSizeSelect:AddChoice( v ) end
			acfmenupanel.CData.TankSizeSelect.OnSelect = function( index, value, data )
				RunConsoleCommand( "acfmenu_data1", data )
				acfmenupanel.FuelTankData.Id = data
				ACFFuelTankGUIUpdate( Table )
			end
			acfmenupanel.CData.TankSizeSelect:SetText(acfmenupanel.FuelTankData.Id)
			RunConsoleCommand( "acfmenu_data1", acfmenupanel.FuelTankData.Id )
		acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.TankSizeSelect )
		
		-- fuel type dropbox
		acfmenupanel.CData.FuelSelect = vgui.Create( "DComboBox", acfmenupanel.CustomDisplay )
			acfmenupanel.CData.FuelSelect:SetSize(100, 30)
			for Key, Value in pairs( ACF.FuelDensity ) do
				acfmenupanel.CData.FuelSelect:AddChoice( Key )
			end
			acfmenupanel.CData.FuelSelect.OnSelect = function( index, value, data )
				RunConsoleCommand( "acfmenu_data2", data )
				acfmenupanel.FuelTankData.FuelID = data
				ACFFuelTankGUIUpdate( Table )
			end
			acfmenupanel.CData.FuelSelect:SetText(acfmenupanel.FuelTankData.FuelID)
			RunConsoleCommand( "acfmenu_data2", acfmenupanel.FuelTankData.FuelID )
		acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.FuelSelect )
		
		ACFFuelTankGUIUpdate( Table )
		
		acfmenupanel.CustomDisplay:PerformLayout()
		
	end

	function ACFFuelTankGUIUpdate( Table )

		if not acfmenupanel.CustomDisplay then return end
		
		local Tanks = list.Get("ACFEnts").FuelTanks
		
		local TankID = acfmenupanel.FuelTankData.Id
		local FuelID = acfmenupanel.FuelTankData.FuelID
		local Dims = Tanks[TankID].dims
		
		local Wall = 0.1 --wall thickness in inches
		local Size = math.floor(Dims[1] * Dims[2] * Dims[3])
		local Volume = math.floor((Dims[1] - Wall) * (Dims[2] - Wall) * (Dims[3] - Wall))
		local Capacity = Volume * ACF.CuIToLiter * ACF.TankVolumeMul * 0.125
		local EmptyMass = ((Size - Volume)*16.387)*7.9/1000
		local Mass = EmptyMass + Capacity * ACF.FuelDensity[FuelID]
			
		--fuel and tank info
		if FuelID == "Electric" then
			local kwh = Capacity * ACF.LiIonED
			acfmenupanel:CPanelText("TankName", Tanks[TankID].name .. " Li-Ion Battery")
			acfmenupanel:CPanelText("TankDesc", Tanks[TankID].desc .. "\n")
			acfmenupanel:CPanelText("Cap", "Charge: " ..math.Round(kwh,1).. " kW hours / " ..math.Round(kwh*3.6,1).. " MJ")
			acfmenupanel:CPanelText("Mass", "Mass: " ..math.Round(Mass,1).. " kg")
		else 
			acfmenupanel:CPanelText("TankName", Tanks[TankID].name .. " fuel tank")
			acfmenupanel:CPanelText("TankDesc", Tanks[TankID].desc .. "\n")
			acfmenupanel:CPanelText("Cap", "Capacity: " ..math.Round(Capacity,1).. " liters / " ..math.Round(Capacity*0.264172,1).. " gallons")
			acfmenupanel:CPanelText("Mass", "Full mass: " ..math.Round(Mass,1).. " kg, Empty mass: " ..math.Round(EmptyMass,1).. " kg")
		end

		local text = "\n"
		if Tanks[TankID].nolinks then
			text = "\nThis fuel tank won\'t link to engines. It's intended to resupply fuel to other fuel tanks."
		end
		acfmenupanel:CPanelText("Links", text)
		
		--fuel tank model display
		if not acfmenupanel.CData.DisplayModel then
			acfmenupanel.CData.DisplayModel = vgui.Create( "DModelPanel", acfmenupanel.CustomDisplay )
				acfmenupanel.CData.DisplayModel:SetModel( Tanks[TankID].model )
				acfmenupanel.CData.DisplayModel:SetCamPos( Vector( 250, 500, 200 ) )
				acfmenupanel.CData.DisplayModel:SetLookAt( Vector( 0, 0, 0 ) )
				acfmenupanel.CData.DisplayModel:SetFOV( 10 )
				acfmenupanel.CData.DisplayModel:SetSize(acfmenupanel:GetWide(),acfmenupanel:GetWide())
				acfmenupanel.CData.DisplayModel.LayoutEntity = function( panel, entity ) end
			acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.DisplayModel )
		end
		acfmenupanel.CData.DisplayModel:SetModel( Tanks[TankID].model )
		
	end
	
	return
	
end

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

function ENT:ACF_OnDamage( Entity, Energy, FrAera, Angle, Inflictor )	--This function needs to return HitRes

	local HitRes = ACF_PropDamage( Entity, Energy, FrAera, Angle, Inflictor )	--Calling the standard damage prop function
	
	if self.Exploding or not self.IsExplosive then return HitRes end
	
	if HitRes.Kill then
		if hook.Run( "ACF_FuelExplode", self ) == false then return HitRes end
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
		if hook.Run( "ACF_FuelExplode", self ) == false then return HitRes end
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

	if IsValid(Owner) and not Owner:CheckLimit("_acf_misc") then return false end
	
	local SId = Data1
	local Tanks = list.Get("ACFEnts").FuelTanks
	if not Tanks[SId].model then return false end --SId = "Tank_4x4x2" end
	
	local Tank = ents.Create("acf_fueltank")
	if not IsValid(Tank) then return false end
	Tank:SetAngles(Angle)
	Tank:SetPos(Pos)
	Tank:Spawn()
	Tank:SetPlayer(Owner)
	Tank.Owner = Owner
	
	Tank.Id = Id
	Tank.SizeId = SId
	Tank.Model = Tanks[Tank.SizeId].model
	Tank:SetModel( Tank.Model )	
	
	Tank:PhysicsInit( SOLID_VPHYSICS )      	
	Tank:SetMoveType( MOVETYPE_VPHYSICS )     	
	Tank:SetSolid( SOLID_VPHYSICS )

	Tank:UpdateFuelTank(Id, SId, Data2)
	
	if IsValid(Owner) then
		Owner:AddCount( "_acf_fueltank", Tank )
		Owner:AddCleanup( "acfmenu", Tank )
	end
	
	table.insert(ACF.FuelTanks, Tank)
	
	return Tank
	
end
list.Set( "ACFCvars", "acf_fueltank", {"id", "data1", "data2"} )
duplicator.RegisterEntityClass("acf_fueltank", MakeACF_FuelTank, "Pos", "Angle", "Id", "SizeId", "FuelType" )

function ENT:UpdateFuelTank(Id, Data1, Data2)

	local lookup = list.Get("ACFEnts").FuelTanks
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
	self.IsExplosive = (self.FuelType ~= "Electric" or self.FuelType ~= "Diesel") and lookup[Data1].explosive ~= false
	self.NoLinks = lookup[Data1].nolinks == true
	
	if self.FuelType == "Electric" then
		self.Liters = self.Capacity --batteries capacity is different from internal volume
		self.Capacity = self.Capacity * ACF.LiIonED
		self.Fuel = pct * self.Capacity
	else
		self.Fuel = pct * self.Capacity
	end
	
	self:UpdateFuelMass()
	
	Wire_TriggerOutput( self, "Capacity", math.Round(self.Capacity,2) )
	self:UpdateOverlayText()
	
end

function ENT:UpdateOverlayText()
	
	local text = "Fuel Type: " .. self.FuelType
	
	if self.FuelType == "Electric" then
		text = text .. "\nCharge Level: " .. math.Round( self.Fuel, 1 ) .. " kWh / " .. math.Round( self.Fuel * 3.6, 1 ) .. " MJ"
	else
		text = text .. "\nFuel Remaining: " .. math.Round( self.Fuel, 1 ) .. " liters / " .. math.Round( self.Fuel * 0.264172, 1 ) .. " gallons"
	end
	
	self:SetOverlayText( text )
	
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
	
	self:UpdateOverlayText()
	
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

function ENT:TriggerInput( iname, value )

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
							sound.Play("ambient/energy/newspark04.wav",Tank:GetPos(),75,100,0.5)
						else
							sound.Play("vehicles/jetski/jetski_no_gas_start.wav",Tank:GetPos(),75,120,0.5)
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
		if IsValid( self.Master[Key] ) then
			self.Master[Key]:Unlink( self )
		end
	end
	
	if #ACF.FuelTanks > 0 then
		for k,v in pairs(ACF.FuelTanks) do
			if v == self then
				table.remove(ACF.FuelTanks,k)
			end
		end
	end
	
end
