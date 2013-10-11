AddCSLuaFile()

DEFINE_BASECLASS( "base_wire_entity" )

ENT.PrintName = "ACF Gearbox"
ENT.WireDebugName = "ACF Gearbox"

if CLIENT then
	
	function ACFGearboxGUICreate( Table )
		
		if not acfmenupanel.GearboxData then
			acfmenupanel.GearboxData = {}
		end
		if not acfmenupanel.GearboxData[Table.id] then
			acfmenupanel.GearboxData[Table.id] = {}
			acfmenupanel.GearboxData[Table.id].GearTable = Table.geartable
		end
			
		acfmenupanel:CPanelText("Name", Table.name)
		
		acfmenupanel.CData.DisplayModel = vgui.Create( "DModelPanel", acfmenupanel.CustomDisplay )
			acfmenupanel.CData.DisplayModel:SetModel( Table.model )
			acfmenupanel.CData.DisplayModel:SetCamPos( Vector( 250, 500, 250 ) )
			acfmenupanel.CData.DisplayModel:SetLookAt( Vector( 0, 0, 0 ) )
			acfmenupanel.CData.DisplayModel:SetFOV( 20 )
			acfmenupanel.CData.DisplayModel:SetSize(acfmenupanel:GetWide(),acfmenupanel:GetWide())
			acfmenupanel.CData.DisplayModel.LayoutEntity = function( panel, entity ) end
		acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.DisplayModel )
		
		acfmenupanel:CPanelText("Desc", Table.desc)	--Description (Name, Desc)
		
		if (acfmenupanel.GearboxData[Table.id].GearTable[-2] or 0) != 0 then
			ACF_GearsSlider(2, acfmenupanel.GearboxData[Table.id].GearTable[2], Table.id)
			ACF_GearsSlider(3, acfmenupanel.GearboxData[Table.id].GearTable[-3], Table.id, "Min Target RPM",true)
			ACF_GearsSlider(4, acfmenupanel.GearboxData[Table.id].GearTable[-2], Table.id, "Max Target RPM",true)
			ACF_GearsSlider(10, acfmenupanel.GearboxData[Table.id].GearTable[-1], Table.id, "Final Drive")
			RunConsoleCommand( "acfmenu_data1", 0.01 )
		else
			for ID,Value in pairs(acfmenupanel.GearboxData[Table.id].GearTable) do
				if ID > 0 then
					ACF_GearsSlider(ID, Value, Table.id)
				elseif ID == -1 then
					ACF_GearsSlider(10, Value, Table.id, "Final Drive")
				end
			end
		end
		
		acfmenupanel:CPanelText("Desc", Table.desc)
		acfmenupanel:CPanelText("MaxTorque", "Clutch Maximum Torque Rating : "..(Table.maxtq).."n-m / "..math.Round(Table.maxtq*0.73).."ft-lb")
		acfmenupanel:CPanelText("Weight", "Weight : "..Table.weight.."kg")
		
		acfmenupanel.CustomDisplay:PerformLayout()
		maxtorque = Table.maxtq
	end

	function ACF_GearsSlider(Gear, Value, ID, Desc, CVT)

		if Gear and not acfmenupanel.CData[Gear] then	
			acfmenupanel.CData[Gear] = vgui.Create( "DNumSlider", acfmenupanel.CustomDisplay )
				acfmenupanel.CData[Gear]:SetText( Desc or "Gear "..Gear )
				acfmenupanel.CData[Gear].Label:SizeToContents()
				acfmenupanel.CData[Gear]:SetDark( true )
				acfmenupanel.CData[Gear]:SetMin( CVT and 1 or -1 )
				acfmenupanel.CData[Gear]:SetMax( CVT and 10000 or 1 )
				acfmenupanel.CData[Gear]:SetDecimals( (not CVT) and 2 or 0 )
				acfmenupanel.CData[Gear].Gear = Gear
				acfmenupanel.CData[Gear].ID = ID
				acfmenupanel.CData[Gear]:SetValue(Value)
				RunConsoleCommand( "acfmenu_data"..Gear, Value )
				acfmenupanel.CData[Gear].OnValueChanged = function( slider, val )
					acfmenupanel.GearboxData[slider.ID].GearTable[slider.Gear] = val
					RunConsoleCommand( "acfmenu_data"..Gear, val )
				end
			acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData[Gear] )
		end

	end
	
	return
	
end

function ENT:Initialize()
	
	self.IsGeartrain = true
	self.Master = {}
	self.IsMaster = true
	
	self.WheelLink = {} -- a "Link" has these components: Ent, Side, Axis, Rope, RopeLen, Output, ReqTq, Vel
	
	self.TotalReqTq = 0
	self.RClutch = 0
	self.LClutch = 0
	self.LBrake = 0
	self.RBrake = 0
	self.SteerRate = 0

	self.Gear = 1
	self.GearRatio = 0
	self.ChangeFinished = 0
	
	self.LegalThink = 0
	
	self.RPM = {}
	self.CurRPM = 0
    self.CVT = false
	self.DoubleDiff = false
	self.InGear = false
	self.CanUpdate = true
	self.LastActive = 0
	self.Legal = true
	
end  

function MakeACF_Gearbox(Owner, Pos, Angle, Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10)

	if not Owner:CheckLimit("_acf_misc") then return false end
	
	local Gearbox = ents.Create("acf_gearbox")
	local List = list.Get("ACFEnts")
	local Classes = list.Get("ACFClasses")
	if not IsValid( Gearbox ) then return false end
	Gearbox:SetAngles(Angle)
	Gearbox:SetPos(Pos)
	Gearbox:Spawn()

	Gearbox:SetPlayer(Owner)
	Gearbox.Owner = Owner
	Gearbox.Id = Id
	Gearbox.Model = List.Mobility[Id].model
	Gearbox.Mass = List.Mobility[Id].weight
	Gearbox.SwitchTime = List.Mobility[Id].switch
	Gearbox.MaxTorque = List.Mobility[Id].maxtq
	Gearbox.Gears = List.Mobility[Id].gears
	Gearbox.Dual = List.Mobility[Id].doubleclutch
    Gearbox.CVT = List.Mobility[Id].cvt
	Gearbox.DoubleDiff = List.Mobility[Id].doublediff
	
    if Gearbox.CVT then
		Gearbox.TargetMinRPM = Data3
		Gearbox.TargetMaxRPM = math.max(Data4,Data3+100)
		Gearbox.CVTRatio = nil
	end
	
	Gearbox.GearTable = List.Mobility[Id].geartable
		Gearbox.GearTable.Final = Data10
		Gearbox.GearTable[1] = Data1
		Gearbox.GearTable[2] = Data2
		Gearbox.GearTable[3] = Data3
		Gearbox.GearTable[4] = Data4
		Gearbox.GearTable[5] = Data5
		Gearbox.GearTable[6] = Data6
		Gearbox.GearTable[7] = Data7
		Gearbox.GearTable[8] = Data8
		Gearbox.GearTable[9] = Data9
		Gearbox.GearTable[0] = 0
		
		Gearbox.Gear0 = Data10
		Gearbox.Gear1 = Data1
		Gearbox.Gear2 = Data2
		Gearbox.Gear3 = Data3
		Gearbox.Gear4 = Data4
		Gearbox.Gear5 = Data5
		Gearbox.Gear6 = Data6
		Gearbox.Gear7 = Data7
		Gearbox.Gear8 = Data8
		Gearbox.Gear9 = Data9
				
	Gearbox:SetModel( Gearbox.Model )	
		
	local Inputs = {"Gear","Gear Up","Gear Down"}
	if Gearbox.CVT then
		table.insert(Inputs,"CVT Ratio")
	elseif Gearbox.DoubleDiff then
		table.insert(Inputs, "Steer Rate")
	end
	
	if Gearbox.Dual then
		table.insert(Inputs, "Left Clutch")
		table.insert(Inputs, "Right Clutch")
		table.insert(Inputs, "Left Brake")
		table.insert(Inputs, "Right Brake")
	else
		table.insert(Inputs, "Clutch")
		table.insert(Inputs, "Brake")
	end
	
    local Outputs = { "Ratio", "Entity", "Current Gear" }
    local OutputTypes = { "NORMAL", "ENTITY", "NORMAL" }
    if Gearbox.CVT then
        table.insert(Outputs,"Min Target RPM")
        table.insert(Outputs,"Max Target RPM")
        table.insert(OutputTypes,"NORMAL")
    end
	
	Gearbox.Inputs = Wire_CreateInputs( Gearbox, Inputs )
	Gearbox.Outputs = WireLib.CreateSpecialOutputs( Gearbox, Outputs, OutputTypes )
	Wire_TriggerOutput(Gearbox, "Entity", Gearbox)
	
    if Gearbox.CVT then
		Wire_TriggerOutput(Gearbox, "Min Target RPM", Gearbox.TargetMinRPM)
		Wire_TriggerOutput(Gearbox, "Max Target RPM", Gearbox.TargetMaxRPM)
	end
	
	Gearbox.LClutch = Gearbox.MaxTorque
	Gearbox.RClutch = Gearbox.MaxTorque

	Gearbox:PhysicsInit( SOLID_VPHYSICS )      	
	Gearbox:SetMoveType( MOVETYPE_VPHYSICS )     	
	Gearbox:SetSolid( SOLID_VPHYSICS )

	local phys = Gearbox:GetPhysicsObject()  	
	if IsValid( phys ) then 
		phys:SetMass( Gearbox.Mass ) 
	end
	
	Gearbox.In = Gearbox:WorldToLocal(Gearbox:GetAttachment(Gearbox:LookupAttachment( "input" )).Pos)
	Gearbox.OutL = Gearbox:WorldToLocal(Gearbox:GetAttachment(Gearbox:LookupAttachment( "driveshaftL" )).Pos)
	Gearbox.OutR = Gearbox:WorldToLocal(Gearbox:GetAttachment(Gearbox:LookupAttachment( "driveshaftR" )).Pos)
	
	Owner:AddCount("_acf_gearbox", Gearbox)
	Owner:AddCleanup( "acfmenu", Gearbox )
	
	Gearbox:ChangeGear(1)
	
	if Gearbox.Dual or Gearbox.DoubleDiff then
		Gearbox:SetBodygroup(1, 1)
	else
		Gearbox:SetBodygroup(1, 0)
	end
	
	Gearbox:SetNetworkedString( "WireName", List.Mobility[Id].name )
	Gearbox:UpdateOverlayText()
		
	return Gearbox
end
list.Set( "ACFCvars", "acf_gearbox", {"id", "data1", "data2", "data3", "data4", "data5", "data6", "data7", "data8", "data9", "data10"} )
duplicator.RegisterEntityClass("acf_gearbox", MakeACF_Gearbox, "Pos", "Angle", "Id", "Gear1", "Gear2", "Gear3", "Gear4", "Gear5", "Gear6", "Gear7", "Gear8", "Gear9", "Gear0" )

function ENT:Update( ArgsTable )
	-- That table is the player data, as sorted in the ACFCvars above, with player who shot, 
	-- and pos and angle of the tool trace inserted at the start
	
	if ArgsTable[1] ~= self.Owner then -- Argtable[1] is the player that shot the tool
		return false, "You don't own that gearbox!"
	end
	
	local Id = ArgsTable[4]	-- Argtable[4] is the engine ID
	local List = list.Get("ACFEnts")
	
	if List.Mobility[Id].model ~= self.Model then
		return false, "The new gearbox must have the same model!"
	end
		
	if self.Id != Id then
	
		self.Id = Id
		self.Mass = List.Mobility[Id].weight
		self.SwitchTime = List.Mobility[Id].switch
		self.MaxTorque = List.Mobility[Id].maxtq
		self.Gears = List.Mobility[Id].gears
		self.Dual = List.Mobility[Id].doubleclutch
        self.CVT = List.Mobility[Id].cvt
		self.DoubleDiff = List.Mobility[Id].doublediff
		
		local Inputs = {"Gear","Gear Up","Gear Down"}
		if self.CVT then
			table.insert(Inputs,"CVT Ratio")
		elseif self.DoubleDiff then
			table.insert(Inputs, "Steer Rate")
		end
	
		if self.Dual then
			table.insert(Inputs, "Left Clutch")
			table.insert(Inputs, "Right Clutch")
			table.insert(Inputs, "Left Brake")
			table.insert(Inputs, "Right Brake")
		else
			table.insert(Inputs, "Clutch")
			table.insert(Inputs, "Brake")
		end
		
		local Outputs = { "Ratio", "Entity", "Current Gear" }
		local OutputTypes = { "NORMAL", "ENTITY", "NORMAL" }
		if self.CVT then
			table.insert(Outputs,"Min Target RPM")
			table.insert(Outputs,"Max Target RPM")
			table.insert(OutputTypes,"NORMAL")
		end
		
		self.Inputs = Wire_CreateInputs( self, Inputs )
        self.Outputs = WireLib.CreateSpecialOutputs( self, Outputs, OutputTypes )
        Wire_TriggerOutput( self, "Entity", self )
	end
    
    if self.CVT then 
        self.TargetMinRPM = ArgsTable[7]
        self.TargetMaxRPM = math.max(ArgsTable[8],ArgsTable[7]+100)
		self.CVTRatio = nil
		Wire_TriggerOutput(self, "Min Target RPM", self.TargetMinRPM)
		Wire_TriggerOutput(self, "Max Target RPM", self.TargetMaxRPM)
    end
	
	self.GearTable.Final = ArgsTable[14]
	self.GearTable[1] = ArgsTable[5]
	self.GearTable[2] = ArgsTable[6]
	self.GearTable[3] = ArgsTable[7]
	self.GearTable[4] = ArgsTable[8]
	self.GearTable[5] = ArgsTable[9]
	self.GearTable[6] = ArgsTable[10]
	self.GearTable[7] = ArgsTable[11]
	self.GearTable[8] = ArgsTable[12]
	self.GearTable[9] = ArgsTable[13]
	self.GearTable[0] = 0
	
	self.Gear0 = ArgsTable[14]
	self.Gear1 = ArgsTable[5]
	self.Gear2 = ArgsTable[6]
	self.Gear3 = ArgsTable[7]
	self.Gear4 = ArgsTable[8]
	self.Gear5 = ArgsTable[9]
	self.Gear6 = ArgsTable[10]
	self.Gear7 = ArgsTable[11]
	self.Gear8 = ArgsTable[12]
	self.Gear9 = ArgsTable[13]
	
	self:ChangeGear(1)
	
	if self.Dual or self.DoubleDiff then
		self:SetBodygroup(1, 1)
	else
		self:SetBodygroup(1, 0)
	end	
	
	self:SetNetworkedString( "WireName", List.Mobility[Id].name )
	self:UpdateOverlayText()
	
	return true, "Gearbox updated successfully!"
end

function ENT:UpdateOverlayText()
	
	local text = ""
	
	if self.CVT then
		text = "Gear 2: " .. math.Round( self.GearTable[ 2 ], 2 ) -- maybe a better name than "gear 2"...?
		text = text .. "\nTarget: " .. math.Round( self.TargetMinRPM ) .. " - " .. math.Round( self.TargetMaxRPM ) .. " RPM\n"
	else
		for i = 1, self.Gears do
			text = text .. "Gear " .. i .. ": " .. math.Round( self.GearTable[ i ], 2 ) .. "\n"
		end
	end
	
	text = text .. "Final Drive: " .. math.Round( self.Gear0, 2 ) .. "\n"
	text = text .. "Torque Rating: " .. self.MaxTorque .. " Nm / " .. math.Round( self.MaxTorque * 0.73 ) .. " ft-lb"
	
	self:SetOverlayText( text )
	
end


-- prevent people from changing bodygroup
function ENT:CanProperty( ply, property )

	return property ~= "bodygroups"

end

function ENT:TriggerInput( iname, value )

	if ( iname == "Gear" and self.Gear != math.floor(value) ) then
		self:ChangeGear(math.floor(value))
	elseif ( iname == "Gear Up" ) then
		if ( self.Gear < self.Gears and value > 0 ) then
			self:ChangeGear(math.floor(self.Gear + 1))
		end
	elseif ( iname == "Gear Down" ) then
		if ( self.Gear > 1 and value > 0 ) then
			self:ChangeGear(math.floor(self.Gear - 1))
		end
	elseif ( iname == "Clutch" ) then
		self.LClutch = math.Clamp(1-value,0,1)*self.MaxTorque
		self.RClutch = math.Clamp(1-value,0,1)*self.MaxTorque
	elseif ( iname == "Brake" ) then
		self.LBrake = math.Clamp(value,0,100)
		self.RBrake = math.Clamp(value,0,100)
	elseif ( iname == "Left Brake" ) then
		self.LBrake = math.Clamp(value,0,100)
	elseif ( iname == "Right Brake" ) then
		self.RBrake = math.Clamp(value,0,100)
	elseif ( iname == "Left Clutch" ) then
		self.LClutch = math.Clamp(1-value,0,1)*self.MaxTorque
	elseif ( iname == "Right Clutch" ) then
		self.RClutch = math.Clamp(1-value,0,1)*self.MaxTorque
	elseif ( iname == "CVT Ratio" ) then
		self.CVTRatio = math.Clamp(value,0,1)
	elseif ( iname == "Steer Rate" ) then
		self.SteerRate = math.Clamp(value,-1,1)
	end		

end

function ENT:Think()
	
	local Time = CurTime()
	
	if self.LastActive + 2 > Time then
		self:CheckRopes()
	end
	
	self.Legal = self:CheckLegal()
	
	self:NextThink( Time + math.random( 5, 10 ) )
	return true
	
end

function ENT:CheckLegal()
	
	-- make sure weight is not below stock
	if self:GetPhysicsObject():GetMass() < self.Mass then return false end
	
	-- if it's not parented we're fine
	if not IsValid( self:GetParent() ) then return true end
	
	-- but not if it's parented to a parented prop
	if IsValid( self:GetParent():GetParent() ) then return false end
	
	-- parenting is only legal if it's also welded
	for k, v in pairs( constraint.FindConstraints( self, "Weld" ) ) do
		
		if v.Ent1 == self:GetParent() or v.Ent2 == self:GetParent() then return true end
		
	end
	
	return false
	
end

function ENT:CheckRopes()

	for Key, Link in pairs( self.WheelLink ) do
	
		local Ent = Link.Ent
		
		-- make sure the rope is still there
		if not IsValid( Link.Rope ) then 
			self:Unlink( Ent )
		continue end
		
		local OutPos = self:LocalToWorld( Link.Output )
		local InPos = Ent:GetPos()
		if Ent.IsGeartrain then
			InPos = Ent:LocalToWorld( Ent.In )
		end
		
		-- make sure it is not stretched too far
		if OutPos:Distance( InPos ) > Link.RopeLen * 1.5 then
			self:Unlink( Ent )
		continue end
		
		-- make sure the angle is not excessive
		local DrvAngle = ( OutPos - InPos ):GetNormalized():DotProduct( ( self:GetRight() * Link.Output.y ):GetNormalized() )
		if DrvAngle < 0.7 then
			self:Unlink( Ent )
		end
		
	end

end

-- Check if every entity we are linked to still actually exists
-- and remove any links that are invalid.
function ENT:CheckEnts()
	
	for Key, Link in pairs( self.WheelLink ) do
	
		if not IsValid( Link.Ent ) then
			table.remove( self.WheelLink, Key )
		continue end

		local Phys = Link.Ent:GetPhysicsObject()
		if not IsValid( Phys ) then
			Link.Ent:Remove()
			table.remove( self.WheelLink, Key )
		end
		
	end
	
end

function ENT:Calc( InputRPM, InputInertia )

	if self.LastActive == CurTime() then
		return math.min( self.TotalReqTq, self.MaxTorque )
	end
	
	if self.ChangeFinished < CurTime() then
		self.InGear = true
	end
	
	self:CheckEnts()

	local BoxPhys = self:GetPhysicsObject()
	local SelfWorld = self:LocalToWorld( BoxPhys:GetAngleVelocity() ) - self:GetPos()
	
	self.TotalReqTq = 0
	
	for Key, Link in pairs( self.WheelLink ) do
		if not IsValid( Link.Ent ) then
			table.remove( self.WheelLink, Key )
		continue end
		
		local Clutch = 0
		if Link.Side == 0 then
			Clutch = self.LClutch
		elseif Link.Side == 1 then
			Clutch = self.RClutch
		end
	
		if self.CVT and self.Gear == 1 then
			if self.CVTRatio and self.CVTRatio > 0 then
				self.GearTable[1] = math.Clamp(self.CVTRatio,0.01,1)
			else
				self.GearTable[1] = math.Clamp((InputRPM - self.TargetMinRPM) / ((self.TargetMaxRPM - self.TargetMinRPM) or 1),0.05,1)
			end
			self.GearRatio = (self.GearTable[1] or 0)*self.GearTable.Final
			Wire_TriggerOutput(self, "Ratio", self.GearRatio)
		end		
		
	
		Link.ReqTq = 0
		if Link.Ent.IsGeartrain then
			if not Link.Ent.Legal then continue end
			local Inertia = 0
			if self.GearRatio ~= 0 then Inertia = InputInertia / self.GearRatio end
			Link.ReqTq = math.min( Clutch, math.abs( Link.Ent:Calc( InputRPM * self.GearRatio, Inertia ) * self.GearRatio ) )
		elseif self.DoubleDiff then
			local RPM = self:CalcWheel( Link, SelfWorld )
			if self.GearRatio ~= 0 and ( ( InputRPM > 0 and RPM < InputRPM ) or ( InputRPM < 0 and RPM > InputRPM ) ) then
				local NTq = math.min( Clutch, ( InputRPM - RPM) * InputInertia)
			
				if( self.SteerRate ~= 0 ) then
					Sign = self.SteerRate / math.abs( self.SteerRate )
				else
					Sign = 0
				end
				if Link.Side == 0 then 
						local DTq = math.Clamp( ( self.SteerRate * ( InputRPM - (RPM * Sign) ) ) * InputInertia, -self.MaxTorque, self.MaxTorque )
					Link.ReqTq = ( NTq + DTq )
				elseif Link.Side == 1 then
						local DTq = math.Clamp( ( self.SteerRate * ( InputRPM + (RPM * Sign) ) ) * InputInertia, -self.MaxTorque, self.MaxTorque )
					Link.ReqTq = ( NTq - DTq )
				end
			end
		else
			local RPM = self:CalcWheel( Link, SelfWorld )
			if self.GearRatio ~= 0 and ( ( InputRPM > 0 and RPM < InputRPM ) or ( InputRPM < 0 and RPM > InputRPM ) ) then
				Link.ReqTq = math.min( Clutch, ( InputRPM - RPM ) * InputInertia )
			end
		end
		self.TotalReqTq = self.TotalReqTq + math.abs( Link.ReqTq )
	end
			
	return math.min( self.TotalReqTq, self.MaxTorque )
	
end

function ENT:CalcWheel( Link, SelfWorld )

	local Wheel = Link.Ent
	local WheelPhys = Wheel:GetPhysicsObject()
	local VelDiff = ( Wheel:LocalToWorld( WheelPhys:GetAngleVelocity() ) - Wheel:GetPos() ) - SelfWorld
	local BaseRPM = VelDiff:Dot( Wheel:LocalToWorld( Link.Axis ) - Wheel:GetPos() )
	Link.Vel = BaseRPM
	
	if self.GearRatio == 0 then return 0 end
	
	-- Reported BaseRPM is in angle per second and in the wrong direction, so we convert and add the gearratio
	return BaseRPM / self.GearRatio / -6
	
end

function ENT:Act( Torque, DeltaTime )
	
	local ReactTq = 0	
	-- Calculate the ratio of total requested torque versus what's avaliable, and then multiply it but the current gearratio
	local AvailTq = 0
	if Torque ~= 0 then
		AvailTq = math.min( math.abs( Torque ) / self.TotalReqTq, 1 ) / self.GearRatio * -( -Torque / math.abs( Torque ) )
	end
	
	for Key, Link in pairs( self.WheelLink ) do
		
		local Brake = 0
		if Link.Side == 0 then
			Brake = self.LBrake
		elseif Link.Side == 1 then
			Brake = self.RBrake
		end
		
		if Link.Ent.IsGeartrain then
			Link.Ent:Act( Link.ReqTq * AvailTq, DeltaTime )
		else
			self:ActWheel( Link, Link.ReqTq * AvailTq, Brake, DeltaTime )
			ReactTq = ReactTq + Link.ReqTq * AvailTq
		end
		
	end
	
	local BoxPhys = self:GetPhysicsObject()
	if IsValid( BoxPhys ) and ReactTq ~= 0 then	
		local Force = self:GetForward() * ReactTq - self:GetForward()
		BoxPhys:ApplyForceOffset( Force * 39.37 * DeltaTime, self:GetPos() + self:GetUp() * -39.37 )
		BoxPhys:ApplyForceOffset( Force * -39.37 * DeltaTime, self:GetPos() + self:GetUp() * 39.37 )
	end
	
	self.LastActive = CurTime()
	
end

function ENT:ActWheel( Link, Torque, Brake, DeltaTime )
	
	local Phys = Link.Ent:GetPhysicsObject()
	local Pos = Link.Ent:GetPos()
	local TorqueAxis = Link.Ent:LocalToWorld( Link.Axis ) - Pos
	local Cross = TorqueAxis:Cross( Vector( TorqueAxis.y, TorqueAxis.z, TorqueAxis.x ) )
	local TorqueVec = TorqueAxis:Cross( Cross ):GetNormalized()
	
	local BrakeMult = 0
	if Brake > 0 then
		BrakeMult = Link.Vel * Phys:GetInertia() * Brake / 10
	end
	
	local Force = TorqueVec * Torque * 0.75 + TorqueVec * BrakeMult
	Phys:ApplyForceOffset( Force * -39.37 * DeltaTime, Pos + Cross * 39.37 )
	Phys:ApplyForceOffset( Force * 39.37 * DeltaTime, Pos + Cross * -39.37 )
	
end

function ENT:ChangeGear(value)

	self.Gear = math.Clamp(value,0,self.Gears)
	self.GearRatio = (self.GearTable[self.Gear] or 0)*self.GearTable.Final
	self.ChangeFinished = CurTime() + self.SwitchTime
	self.InGear = false
	
	Wire_TriggerOutput(self, "Current Gear", self.Gear)
	self:EmitSound("buttons/lever7.wav",250,100)
	Wire_TriggerOutput(self, "Ratio", self.GearRatio)
	
end

function ENT:Link( Target )

	if not IsValid( Target ) or ( Target:GetClass() ~= "prop_physics" and Target:GetClass() ~= "acf_gearbox" ) then
		return false, "Can only link props or gearboxes!"
	end
	
	-- Check if target is already linked
	for Key, Link in pairs( self.WheelLink ) do
		if Link.Ent == Target then 
			return false, "That is already linked to this gearbox!"
		end
	end
	
	-- make sure the angle is not excessive
	local InPos = Vector( 0, 0, 0 )
	if Target.IsGeartrain then
		InPos = Target.In
	end
	local InPosWorld = Target:LocalToWorld( InPos )
	
	local OutPos = self.OutR
	local Side = 1
	if self:WorldToLocal( InPosWorld ).y < 0 then
		OutPos = self.OutL
		Side = 0
	end
	local OutPosWorld = self:LocalToWorld( OutPos )
	
	local DrvAngle = ( OutPosWorld - InPosWorld ):GetNormalized():DotProduct( ( self:GetRight() * OutPos.y ):GetNormalized() )
	if DrvAngle < 0.7 then
		return false, "Cannot link due to excessive driveshaft angle!"
	end
	
	local Rope = constraint.CreateKeyframeRope( OutPosWorld, 1, "cable/cable2", nil, self, OutPos, 0, Target, InPos, 0 )
	
	local Link = {
		Ent = Target,
		Side = Side,
		Axis = Target:WorldToLocal( self:GetRight() + InPosWorld ),
		Rope = Rope,
		RopeLen = ( OutPosWorld - InPosWorld ):Length(),
		Output = OutPos,
		ReqTq = 0,
		Vel = 0
	}
	table.insert( self.WheelLink, Link )
	
	return true, "Link successful!"
	
end

function ENT:Unlink( Target )
	
	for Key, Link in pairs( self.WheelLink ) do
		
		if Link.Ent == Target then
			
			-- Remove any old physical ropes leftover from dupes
			for Key, Rope in pairs( constraint.FindConstraints( Link.Ent, "Rope" ) ) do
				if Rope.Ent1 == self or Rope.Ent2 == self then
					Rope.Constraint:Remove()
				end
			end
			
			if IsValid( Link.Rope ) then
				Link.Rope:Remove()
			end
			
			table.remove( self.WheelLink, Key )
			
			return true, "Unlink successful!"
			
		end
		
	end
	
	return false, "That entity is not linked to this gearbox!"
	
end

function ENT:PreEntityCopy()
	
	-- Link Saving
	local info = {}
	local entids = {}
	
	-- Clean the table of any invalid entities
	for Key, Link in pairs( self.WheelLink ) do
		if not IsValid( Link.Ent ) then
			table.remove( self.WheelLink, Key )
		end
	end
	
	-- Then save it
	for Key, Link in pairs( self.WheelLink ) do
		table.insert( entids, Link.Ent:EntIndex() )
	end
	
	info.entities = entids
	if info.entities then
		duplicator.StoreEntityModifier( self, "WheelLink", info )
	end
	
	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
	
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	
	-- Link Pasting
	if Ent.EntityMods and Ent.EntityMods.WheelLink and Ent.EntityMods.WheelLink.entities then
		local WheelLink = Ent.EntityMods.WheelLink
		if WheelLink.entities and table.Count( WheelLink.entities ) > 0 then
			timer.Simple( 0, function() -- this timer is a workaround for an ad2/makespherical issue https://github.com/nrlulz/ACF/issues/14#issuecomment-22844064
				for _, ID in pairs( WheelLink.entities ) do
					local Linked = CreatedEntities[ ID ]
					if IsValid( Linked ) then
						self:Link( Linked )
					end
				end
			end )
		end
		Ent.EntityMods.WheelLink = nil
	end
	
	//Wire dupe info
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )

end

function ENT:OnRemove()

	for Key,Value in pairs(self.Master) do		--Let's unlink ourselves from the engines properly
		if IsValid( self.Master[Key] ) then
			self.Master[Key]:Unlink( self )
		end
	end
	
end

