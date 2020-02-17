AddCSLuaFile()

DEFINE_BASECLASS( "base_wire_entity" )

ENT.PrintName = "ACF Gearbox"
ENT.WireDebugName = "ACF Gearbox"

if CLIENT then

	local ACF_GearboxInfoWhileSeated = CreateClientConVar("ACF_GearboxInfoWhileSeated", 0, true, false)
	
	-- copied from base_wire_entity: DoNormalDraw's notip arg isn't accessible from ENT:Draw defined there.
	function ENT:Draw()
	
		local lply = LocalPlayer()
		local hideBubble = not GetConVar("ACF_GearboxInfoWhileSeated"):GetBool() and IsValid(lply) and lply:InVehicle()
		
		self.BaseClass.DoNormalDraw(self, false, hideBubble)
		Wire_Render(self)
		
		if self.GetBeamLength and (not self.GetShowBeam or self:GetShowBeam()) then 
			-- Every SENT that has GetBeamLength should draw a tracer. Some of them have the GetShowBeam boolean
			Wire_DrawTracerBeam( self, 1, self.GetBeamHighlight and self:GetBeamHighlight() or false ) 
		end
		
	end
	
	function ACFGearboxGUICreate( Table )
	
		if not acfmenupanel.Serialize then
			acfmenupanel.Serialize = function( tbl, factor )
				local str = ""
				for i=1,7 do 
					str = str..math.Round(tbl[i] * factor,1)..","
				end
				RunConsoleCommand( "acfmenu_data9", str )
			end
		end
		
		if not acfmenupanel.GearboxData then
			acfmenupanel.GearboxData = {}
		end
		
		if not acfmenupanel.GearboxData[Table.id] then
			acfmenupanel.GearboxData[Table.id] = {}
			acfmenupanel.GearboxData[Table.id].GearTable = Table.geartable
		end
		
		if Table.auto and not acfmenupanel.GearboxData[Table.id].ShiftTable then
			acfmenupanel.GearboxData[Table.id].ShiftTable = {10,20,30,40,50,60,70}
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
		
		if Table.auto and not acfmenupanel.CData.UnitsInput then
			acfmenupanel.CData.UnitsInput = vgui.Create( "DComboBox", acfmenupanel.CustomDisplay )
				acfmenupanel.CData.UnitsInput.ID = Table.id
				acfmenupanel.CData.UnitsInput.Gears = Table.gears
				acfmenupanel.CData.UnitsInput:SetSize( 60,22 )
				acfmenupanel.CData.UnitsInput:SetTooltip( "If using the shift point generator, recalc after changing units." )
				acfmenupanel.CData.UnitsInput:AddChoice( "KPH", 10.936, true )
				acfmenupanel.CData.UnitsInput:AddChoice( "MPH", 17.6 )
				acfmenupanel.CData.UnitsInput:AddChoice( "GMU", 1 )
				acfmenupanel.CData.UnitsInput:SetDark( true )
				acfmenupanel.CData.UnitsInput.OnSelect = function( panel, index, label, data )
					acfmenupanel.Serialize( acfmenupanel.GearboxData[panel.ID].ShiftTable, data )  --dot intentional
				end
			acfmenupanel.CustomDisplay:AddItem(acfmenupanel.CData.UnitsInput)
		end
		
		if Table.cvt then
			ACF_GearsSlider(2, acfmenupanel.GearboxData[Table.id].GearTable[2], Table.id)
			ACF_GearsSlider(3, acfmenupanel.GearboxData[Table.id].GearTable[-3], Table.id, "Min Target RPM",true)
			ACF_GearsSlider(4, acfmenupanel.GearboxData[Table.id].GearTable[-2], Table.id, "Max Target RPM",true)
			ACF_GearsSlider(10, acfmenupanel.GearboxData[Table.id].GearTable[-1], Table.id, "Final Drive")
			RunConsoleCommand( "acfmenu_data1", 0.01 )
		else
			for ID,Value in pairs(acfmenupanel.GearboxData[Table.id].GearTable) do
				if ID > 0 and not (Table.auto and ID == 8) then
					ACF_GearsSlider(ID, Value, Table.id)
					if Table.auto then
						ACF_ShiftPoint(ID, acfmenupanel.GearboxData[Table.id].ShiftTable[ID], Table.id, "Gear "..ID.." upshift speed: ")
					end
				elseif Table.auto and (ID == -2 or ID == 8) then
					ACF_GearsSlider(8, Value, Table.id, "Reverse")
				elseif ID == -1 then
					ACF_GearsSlider(10, Value, Table.id, "Final Drive")
				end
			end
		end
		
		acfmenupanel:CPanelText("Desc", Table.desc)
		acfmenupanel:CPanelText("MaxTorque", "Clutch Maximum Torque Rating : "..(Table.maxtq).."n-m / "..math.Round(Table.maxtq*0.73).."ft-lb")
		acfmenupanel:CPanelText("Weight", "Weight : "..Table.weight.."kg")
		
		if Table.parentable then
			acfmenupanel:CPanelText("Parentable", "\nThis gearbox can be parented without welding.")
		end
		
		if Table.auto then
			acfmenupanel:CPanelText( "ShiftPointGen", "\nShift Point Generator:" )
			
			if not acfmenupanel.CData.ShiftGenPanel then
				acfmenupanel.CData.ShiftGenPanel = vgui.Create( "DPanel" )
					acfmenupanel.CData.ShiftGenPanel:SetPaintBackground( false )
					acfmenupanel.CData.ShiftGenPanel:DockPadding( 4, 0, 4, 0 )
					acfmenupanel.CData.ShiftGenPanel:SetTall( 60 )
					acfmenupanel.CData.ShiftGenPanel:SizeToContentsX()
					acfmenupanel.CData.ShiftGenPanel.Gears = Table.gears
					
				acfmenupanel.CData.ShiftGenPanel.Calc = acfmenupanel.CData.ShiftGenPanel:Add( "DButton" )
					acfmenupanel.CData.ShiftGenPanel.Calc:SetText( "Calculate" )
					acfmenupanel.CData.ShiftGenPanel.Calc:Dock( BOTTOM )
					--acfmenupanel.CData.ShiftGenPanel.Calc:SetWide( 80 )
					acfmenupanel.CData.ShiftGenPanel.Calc:SetTall( 20 )
					acfmenupanel.CData.ShiftGenPanel.Calc.DoClick = function()
						local str, factor = acfmenupanel.CData.UnitsInput:GetSelected()
						local mul = math.pi * acfmenupanel.CData.ShiftGenPanel.RPM:GetValue() * acfmenupanel.CData.ShiftGenPanel.Ratio:GetValue() * acfmenupanel.CData[10]:GetValue() * acfmenupanel.CData.ShiftGenPanel.Wheel:GetValue() / (60 * factor)
						for i=1,acfmenupanel.CData.ShiftGenPanel.Gears do
							acfmenupanel.CData[10+i].Input:SetValue( math.Round( math.abs( mul * acfmenupanel.CData[i]:GetValue() ), 2 ) )
							acfmenupanel.GearboxData[acfmenupanel.CData.UnitsInput.ID].ShiftTable[i] = tonumber(acfmenupanel.CData[10+i].Input:GetValue())
						end
						acfmenupanel.Serialize( acfmenupanel.GearboxData[acfmenupanel.CData.UnitsInput.ID].ShiftTable, factor )  --dot intentional
					end
					
					acfmenupanel.CData.WheelPanel = acfmenupanel.CData.ShiftGenPanel:Add( "DPanel" )
						acfmenupanel.CData.WheelPanel:SetPaintBackground( false )
						acfmenupanel.CData.WheelPanel:DockMargin( 4, 0, 4, 0 )
						acfmenupanel.CData.WheelPanel:Dock( RIGHT )
						acfmenupanel.CData.WheelPanel:SetWide( 76 )
						acfmenupanel.CData.WheelPanel:SetTooltip( "If you use default spherical settings, add 0.5 to your wheel diameter.\nFor treaded vehicles, use the diameter of road wheels, not drive wheels." )

						acfmenupanel.CData.ShiftGenPanel.WheelLabel = acfmenupanel.CData.WheelPanel:Add( "DLabel" )
							acfmenupanel.CData.ShiftGenPanel.WheelLabel:Dock( TOP )
							acfmenupanel.CData.ShiftGenPanel.WheelLabel:SetDark( true )
							acfmenupanel.CData.ShiftGenPanel.WheelLabel:SetText( "Wheel Diameter:" )
						
						acfmenupanel.CData.ShiftGenPanel.Wheel = acfmenupanel.CData.WheelPanel:Add( "DNumberWang" )
							acfmenupanel.CData.ShiftGenPanel.Wheel:HideWang()
							acfmenupanel.CData.ShiftGenPanel.Wheel:SetDrawBorder( false )
							acfmenupanel.CData.ShiftGenPanel.Wheel:Dock( BOTTOM )
							acfmenupanel.CData.ShiftGenPanel.Wheel:SetDecimals( 2 )
							acfmenupanel.CData.ShiftGenPanel.Wheel:SetMinMax( 0, 9999 )
							acfmenupanel.CData.ShiftGenPanel.Wheel:SetValue( 30 )
					
					acfmenupanel.CData.RatioPanel = acfmenupanel.CData.ShiftGenPanel:Add( "DPanel" )
						acfmenupanel.CData.RatioPanel:SetPaintBackground( false )
						acfmenupanel.CData.RatioPanel:DockMargin( 4, 0, 4, 0 )
						acfmenupanel.CData.RatioPanel:Dock( RIGHT )
						acfmenupanel.CData.RatioPanel:SetWide( 76 )
						acfmenupanel.CData.RatioPanel:SetTooltip( "Total ratio is the ratio of all gearboxes (exluding this one) multiplied together.\nFor example, if you use engine to automatic to diffs to wheels, your total ratio would be (diff gear ratio * diff final ratio)." )

						acfmenupanel.CData.ShiftGenPanel.RatioLabel = acfmenupanel.CData.RatioPanel:Add( "DLabel" )
							acfmenupanel.CData.ShiftGenPanel.RatioLabel:Dock( TOP )
							acfmenupanel.CData.ShiftGenPanel.RatioLabel:SetDark( true )
							acfmenupanel.CData.ShiftGenPanel.RatioLabel:SetText( "Total ratio:" )
					
						acfmenupanel.CData.ShiftGenPanel.Ratio = acfmenupanel.CData.RatioPanel:Add( "DNumberWang" )
							acfmenupanel.CData.ShiftGenPanel.Ratio:HideWang()
							acfmenupanel.CData.ShiftGenPanel.Ratio:SetDrawBorder( false )
							acfmenupanel.CData.ShiftGenPanel.Ratio:Dock( BOTTOM )
							acfmenupanel.CData.ShiftGenPanel.Ratio:SetDecimals( 2 )
							acfmenupanel.CData.ShiftGenPanel.Ratio:SetMinMax( 0, 9999 )
							acfmenupanel.CData.ShiftGenPanel.Ratio:SetValue( 0.1 )
					
					acfmenupanel.CData.RPMPanel = acfmenupanel.CData.ShiftGenPanel:Add( "DPanel" )
						acfmenupanel.CData.RPMPanel:SetPaintBackground( false )
						acfmenupanel.CData.RPMPanel:DockMargin( 4, 0, 4, 0 )
						acfmenupanel.CData.RPMPanel:Dock( RIGHT )
						acfmenupanel.CData.RPMPanel:SetWide( 76 )
						acfmenupanel.CData.RPMPanel:SetTooltip( "Target engine RPM to upshift at." )
				
						acfmenupanel.CData.ShiftGenPanel.RPMLabel = acfmenupanel.CData.RPMPanel:Add( "DLabel" )
							acfmenupanel.CData.ShiftGenPanel.RPMLabel:Dock( TOP )
							acfmenupanel.CData.ShiftGenPanel.RPMLabel:SetDark( true )
							acfmenupanel.CData.ShiftGenPanel.RPMLabel:SetText( "Upshift RPM:" )
				
						acfmenupanel.CData.ShiftGenPanel.RPM = acfmenupanel.CData.RPMPanel:Add( "DNumberWang" )
							acfmenupanel.CData.ShiftGenPanel.RPM:HideWang()
							acfmenupanel.CData.ShiftGenPanel.RPM:SetDrawBorder( false )
							acfmenupanel.CData.ShiftGenPanel.RPM:Dock( BOTTOM )
							acfmenupanel.CData.ShiftGenPanel.RPM:SetDecimals( 2 )
							acfmenupanel.CData.ShiftGenPanel.RPM:SetMinMax( 0, 9999 )
							acfmenupanel.CData.ShiftGenPanel.RPM:SetValue( 5000 )
				
				acfmenupanel.CustomDisplay:AddItem(acfmenupanel.CData.ShiftGenPanel)
			end
		end
		
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
	
	function ACF_ShiftPoint(Gear, Value, ID, Desc)
		local Index = Gear + 10
		if Gear and not acfmenupanel.CData[Index] then
			acfmenupanel.CData[Index] = vgui.Create( "DPanel" )
				acfmenupanel.CData[Index]:SetPaintBackground( false )
				acfmenupanel.CData[Index]:SetTall( 20 )
				acfmenupanel.CData[Index]:SizeToContentsX()

			acfmenupanel.CData[Index].Input = acfmenupanel.CData[Index]:Add( "DNumberWang" )
				acfmenupanel.CData[Index].Input.Gear = Gear
				acfmenupanel.CData[Index].Input.ID = ID
				acfmenupanel.CData[Index].Input:HideWang()
				acfmenupanel.CData[Index].Input:SetDrawBorder( false )
				acfmenupanel.CData[Index].Input:SetDecimals( 2 )
				acfmenupanel.CData[Index].Input:SetMinMax( 0, 9999 )
				acfmenupanel.CData[Index].Input:SetValue( Value )
				acfmenupanel.CData[Index].Input:Dock( RIGHT )
				acfmenupanel.CData[Index].Input:SetWide( 45 )
				acfmenupanel.CData[Index].Input.OnValueChanged = function( box, value )
					acfmenupanel.GearboxData[box.ID].ShiftTable[box.Gear] = value
					local str, factor = acfmenupanel.CData.UnitsInput:GetSelected()
					acfmenupanel.Serialize( acfmenupanel.GearboxData[acfmenupanel.CData.UnitsInput.ID].ShiftTable, factor )  --dot intentional
				end
				RunConsoleCommand( "acfmenu_data9", "10,20,30,40,50,60,70" )

			acfmenupanel.CData[Index].Label = acfmenupanel.CData[Index]:Add( "DLabel" )
				acfmenupanel.CData[Index].Label:Dock( RIGHT )
				acfmenupanel.CData[Index].Label:SetWide( 120 )
				acfmenupanel.CData[Index].Label:SetDark( true )
				acfmenupanel.CData[Index].Label:SetText( Desc )

			acfmenupanel.CustomDisplay:AddItem(acfmenupanel.CData[Index])
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

	self.Gear = 0
	self.GearRatio = 0
	self.ChangeFinished = 0
	
	self.LegalThink = 0
	
	self.RPM = {}
	self.CurRPM = 0
    self.CVT = false
	self.DoubleDiff = false
	self.Auto = false
	self.InGear = false
	self.CanUpdate = true
	self.LastActive = 0
	self.Legal = true
	self.Parentable = true
	self.RootParent = nil
	self.NextLegalCheck = ACF.CurTime + 30 -- give any spawning issues time to iron themselves out
	self.LegalIssues = ""
	
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
	Gearbox.Dual = List.Mobility[Id].doubleclutch or false
    Gearbox.CVT = List.Mobility[Id].cvt or false
	Gearbox.DoubleDiff = List.Mobility[Id].doublediff or false
	Gearbox.Auto = List.Mobility[Id].auto or false
	Gearbox.Parentable = List.Mobility[Id].parentable or false
	
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
		Gearbox.GearTable[0] = List.Mobility[Id].geartable[0]
		
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
		
	Gearbox.GearRatio = (Gearbox.GearTable[0] or 0)*Gearbox.GearTable.Final
	
	if Gearbox.Auto then
		Gearbox.ShiftPoints = {}
		for part in string.gmatch(Data9, "[^,]+") do Gearbox.ShiftPoints[#Gearbox.ShiftPoints+1] = tonumber(part) end
		Gearbox.ShiftPoints[0] = -1
		Gearbox.Reverse = Gearbox.Gears+1
		Gearbox.GearTable[Gearbox.Reverse] = Data8
		Gearbox.Drive = 1
		Gearbox.ShiftScale = 1
	end
	
	Gearbox:SetModel( Gearbox.Model )	
		
	local Inputs = {"Gear","Gear Up","Gear Down"}
	if Gearbox.CVT then
		table.insert(Inputs,"CVT Ratio")
	elseif Gearbox.DoubleDiff then
		table.insert(Inputs, "Steer Rate")
	elseif Gearbox.Auto then
		table.insert(Inputs, "Hold Gear")
		table.insert(Inputs, "Shift Speed Scale")
		Gearbox.Hold = false
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
		Gearbox.ModelInertia = 0.99 * phys:GetInertia()/phys:GetMass() -- giving a little wiggle room
	end
	
	Gearbox.In = Gearbox:WorldToLocal(Gearbox:GetAttachment(Gearbox:LookupAttachment( "input" )).Pos)
	Gearbox.OutL = Gearbox:WorldToLocal(Gearbox:GetAttachment(Gearbox:LookupAttachment( "driveshaftL" )).Pos)
	Gearbox.OutR = Gearbox:WorldToLocal(Gearbox:GetAttachment(Gearbox:LookupAttachment( "driveshaftR" )).Pos)
	
	Owner:AddCount("_acf_misc", Gearbox)
	Owner:AddCleanup( "acfmenu", Gearbox )
	
	Gearbox:ChangeGear(1)
	
	if Gearbox.Dual or Gearbox.DoubleDiff then
		Gearbox:SetBodygroup(1, 1)
	else
		Gearbox:SetBodygroup(1, 0)
	end
	
	Gearbox:SetNWString( "WireName", List.Mobility[Id].name )
	Gearbox:UpdateOverlayText()
	
	ACF_Activate( Gearbox, 0 )
	
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
		self.Dual = List.Mobility[Id].doubleclutch or false
        self.CVT = List.Mobility[Id].cvt or false
		self.DoubleDiff = List.Mobility[Id].doublediff or false
		self.Auto = List.Mobility[Id].auto or false
		self.Parentable = List.Mobility[Id].parentable or false
		
		local Inputs = {"Gear","Gear Up","Gear Down"}
		if self.CVT then
			table.insert(Inputs,"CVT Ratio")
		elseif self.DoubleDiff then
			table.insert(Inputs, "Steer Rate")
		elseif self.Auto then
			table.insert(Inputs, "Hold Gear")
			table.insert(Inputs, "Shift Speed Scale")
			self.Hold = false
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
		
		local phys = self:GetPhysicsObject()    
		if IsValid( phys ) then 
			phys:SetMass( self.Mass ) 
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
	self.GearTable[0] = List.Mobility[Id].geartable[0]
	
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
	
	self.GearRatio = (self.GearTable[0] or 0)*self.GearTable.Final
	
	if self.Auto then
		self.ShiftPoints = {}
		for part in string.gmatch(ArgsTable[13], "[^,]+") do self.ShiftPoints[#self.ShiftPoints+1] = tonumber(part) end
		self.ShiftPoints[0] = -1
		self.Reverse = self.Gears+1
		self.GearTable[self.Reverse] = ArgsTable[12]
		self.Drive = 1
		self.ShiftScale = 1
	end
	
	--self:ChangeGear(1) -- fails on updating because func exits on detecting same gear
	self.Gear = 1
	self.GearRatio = (self.GearTable[self.Gear] or 0)*self.GearTable.Final
	self.ChangeFinished = CurTime() + self.SwitchTime
	self.InGear = false
	
	if self.Dual or self.DoubleDiff then
		self:SetBodygroup(1, 1)
	else
		self:SetBodygroup(1, 0)
	end	
	
	self:SetNWString( "WireName", List.Mobility[Id].name )
	self:UpdateOverlayText()
	
	ACF_Activate( self, 1 )
	
	return true, "Gearbox updated successfully!"
end

function ENT:UpdateOverlayText()
	
	local text = ""
	
	if self.CVT then
		text = "Reverse Gear: " .. math.Round( self.GearTable[ 2 ], 2 ) -- maybe a better name than "gear 2"...?
		text = text .. "\nTarget: " .. math.Round( self.TargetMinRPM ) .. " - " .. math.Round( self.TargetMaxRPM ) .. " RPM\n"
	elseif self.Auto then
		for i = 1, self.Gears do
			text = text .. "Gear " .. i .. ": " .. math.Round( self.GearTable[ i ], 2 ) .. ", Upshift @ ".. math.Round( self.ShiftPoints[i]/10.936, 1 ) .. " kph / " .. math.Round( self.ShiftPoints[i]/17.6 ,1 ) .. " mph\n"
		end
	else
		for i = 1, self.Gears do
			text = text .. "Gear " .. i .. ": " .. math.Round( self.GearTable[ i ], 2 ) .. "\n"
		end
	end
	if self.Auto then
		text = text.."Reverse gear: "..math.Round( self.GearTable[ self.Reverse ], 2 ).."\n"
	end
	
	text = text .. "Final Drive: " .. math.Round( self.Gear0, 2 ) .. "\n"
	text = text .. "Torque Rating: " .. self.MaxTorque .. " Nm / " .. math.Round( self.MaxTorque * 0.73 ) .. " ft-lb"

	if not self.Legal then
		text = text .. "\nNot legal, disabled for " .. math.ceil(self.NextLegalCheck - ACF.CurTime) .. "s\nIssues: " .. self.LegalIssues
	end
	
	self:SetOverlayText( text )
	
end


-- prevent people from changing bodygroup
function ENT:CanProperty( ply, property )

	return property ~= "bodygroups"

end

function ENT:TriggerInput( iname, value )

	if ( iname == "Gear" ) then
		if self.Auto then
			self:ChangeDrive(value)
		else
			self:ChangeGear(value)
		end
	elseif ( iname == "Gear Up" ) and not (value == 0) then
		if self.Auto then
			self:ChangeDrive(self.Drive + 1)
		else
			self:ChangeGear(self.Gear + 1)
		end
	elseif ( iname == "Gear Down" ) and not (value == 0) then
		if self.Auto then
			self:ChangeDrive(self.Drive - 1)
		else
			self:ChangeGear(self.Gear - 1)
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
	elseif ( iname == "Hold Gear" ) then
		self.Hold = not (value == 0)
	elseif ( iname == "Shift Speed Scale" ) then
		self.ShiftScale = math.Clamp(value,0.1,1.5)
	end		

end

function ENT:Think()

	if ACF.CurTime > self.NextLegalCheck then
		self.Legal, self.LegalIssues = ACF_CheckLegal(self, self.Model, self.Mass, self.ModelInertia, false, true, false, true) -- 
		self.NextLegalCheck = ACF.LegalSettings:NextCheck(self.Legal)
		self:UpdateOverlayText()

		if self.Legal then
			if self.Parentable then self.RootParent = ACF_GetPhysicalParent(self) end
		end
	end
	
	local Time = CurTime()
	
	if self.LastActive + 2 > Time then
		self:CheckRopes()
	end
	
	self:NextThink( Time + math.random( 5, 10 ) )
	return true
	
end

function ENT:CheckRopes()

	for Key, Link in pairs( self.WheelLink ) do
	
		local Ent = Link.Ent
		
		local OutPos = self:LocalToWorld( Link.Output )
		local InPos = Ent:GetPos()
		if Ent.IsGeartrain then
			InPos = Ent:LocalToWorld( Ent.In )
		end
		
		-- make sure it is not stretched too far
		if OutPos:Distance( InPos ) > Link.RopeLen * 1.5 then
			self:Unlink( Ent )
		end
		
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

	if not self.Legal then return 0 end

	if self.LastActive == CurTime() then
		return math.min( self.TotalReqTq, self.MaxTorque )
	end
	
	if self.ChangeFinished < CurTime() then
		self.InGear = true
	end
	
	self:CheckEnts()

	local BoxPhys = self:GetPhysicsObject()
	local SelfWorld = BoxPhys:LocalToWorldVector( BoxPhys:GetAngleVelocity() )
	
	if self.CVT and self.Gear == 1 then
		if self.CVTRatio and self.CVTRatio > 0 then
			self.GearTable[1] = math.Clamp(self.CVTRatio,0.01,1)
		else
			self.GearTable[1] = math.Clamp((InputRPM - self.TargetMinRPM) / ((self.TargetMaxRPM - self.TargetMinRPM) or 1),0.05,1)
		end
		self.GearRatio = (self.GearTable[1] or 0)*self.GearTable.Final
		Wire_TriggerOutput(self, "Ratio", self.GearRatio)
	end
	
	if self.Auto and self.Drive == 1 and self.InGear then
		local vel = BoxPhys:GetVelocity():Length()
		if vel > (self.ShiftPoints[self.Gear] * self.ShiftScale) and not (self.Gear == self.Gears) and not self.Hold then
			self:ChangeGear(self.Gear + 1)
		elseif vel < (self.ShiftPoints[self.Gear-1] * self.ShiftScale) then 
			self:ChangeGear(self.Gear - 1)
		end
	end
	
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
						local DTq = math.Clamp( ( self.SteerRate * ( ( InputRPM * ( math.abs( self.SteerRate ) + 1 ) ) - (RPM * Sign) ) ) * InputInertia, -self.MaxTorque, self.MaxTorque )
					Link.ReqTq = ( NTq + DTq )
				elseif Link.Side == 1 then
						local DTq = math.Clamp( ( self.SteerRate * ( ( InputRPM * ( math.abs( self.SteerRate ) + 1 ) ) + (RPM * Sign) ) ) * InputInertia, -self.MaxTorque, self.MaxTorque )
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
	local VelDiff = WheelPhys:LocalToWorldVector( WheelPhys:GetAngleVelocity() ) - SelfWorld
	local BaseRPM = VelDiff:Dot( WheelPhys:LocalToWorldVector( Link.Axis ) )
	Link.Vel = BaseRPM
	
	if self.GearRatio == 0 then return 0 end
	
	-- Reported BaseRPM is in angle per second and in the wrong direction, so we convert and add the gearratio
	return BaseRPM / self.GearRatio / -6
	
end

function ENT:Act( Torque, DeltaTime, MassRatio )
	if not self.Legal then self.LastActive = CurTime() return end

	--internal torque loss from being damaged
	local Loss = math.Clamp(((1 - 0.4) / (0.5)) * ((self.ACF.Health/self.ACF.MaxHealth) - 1) + 1, 0.4, 1)
	
	--internal torque loss from inefficiency
	local Slop = self.Auto and 0.9 or 1
	
	local ReactTq = 0	
	-- Calculate the ratio of total requested torque versus what's avaliable, and then multiply it but the current gearratio
	local AvailTq = 0
	if Torque ~= 0 and self.GearRatio ~= 0 then
		AvailTq = math.min( math.abs( Torque ) / self.TotalReqTq, 1 ) / self.GearRatio * -( -Torque / math.abs( Torque ) ) * Loss * Slop
	end
	
	for Key, Link in pairs( self.WheelLink ) do
		
		local Brake = 0
		if Link.Side == 0 then
			Brake = self.LBrake
		elseif Link.Side == 1 then
			Brake = self.RBrake
		end
		
		if Link.Ent.IsGeartrain then
			Link.Ent:Act( Link.ReqTq * AvailTq, DeltaTime, MassRatio )
		else
			self:ActWheel( Link, Link.ReqTq * AvailTq, Brake, DeltaTime )
			ReactTq = ReactTq + Link.ReqTq * AvailTq
		end
		
	end
	
	local BoxPhys
	if IsValid( self.RootParent ) then
		BoxPhys = self.RootParent:GetPhysicsObject()
	else
		BoxPhys = self:GetPhysicsObject()
	end

	if IsValid( BoxPhys ) and ReactTq ~= 0 then
		local Torque = self:GetRight() * math.Clamp( 2 * math.deg( ReactTq * MassRatio ) * DeltaTime, -500000, 500000 )
		BoxPhys:ApplyTorqueCenter( Torque )
	end
	
	self.LastActive = CurTime()
	
end

function ENT:ActWheel( Link, Torque, Brake, DeltaTime )
	
	local Phys = Link.Ent:GetPhysicsObject()
	local TorqueAxis = Phys:LocalToWorldVector( Link.Axis )

	local BrakeMult = 0
	if Brake > 0 then
		BrakeMult = Link.Vel * Link.Inertia * Brake / 5
	end

	local Torque = TorqueAxis * math.Clamp( math.deg( -Torque * 1.5 - BrakeMult ) * DeltaTime, -500000, 500000 )
	Phys:ApplyTorqueCenter( Torque )
end

function ENT:ChangeGear(value)

	local new = math.Clamp(math.floor(value),0,self.Gears)
	if self.Gear == new then return end
	
	self.Gear = new
	self.GearRatio = (self.GearTable[self.Gear] or 0)*self.GearTable.Final
	self.ChangeFinished = CurTime() + self.SwitchTime
	self.InGear = false
	
	Wire_TriggerOutput(self, "Current Gear", self.Gear)
	self:EmitSound("buttons/lever7.wav",250,100)
	Wire_TriggerOutput(self, "Ratio", self.GearRatio)
	
end

--handles gearing for automatics; 0=neutral, 1=forward autogearing, 2=reverse
function ENT:ChangeDrive(value)

	local new = math.Clamp(math.floor(value),0,2)
	if self.Drive == new then return end
	
	self.Drive = new
	if self.Drive == 2 then
		self.Gear = self.Reverse
		self.GearRatio = (self.GearTable[self.Gear] or 0)*self.GearTable.Final
		self.ChangeFinished = CurTime() + self.SwitchTime
		self.InGear = false
		
		Wire_TriggerOutput(self, "Current Gear", self.Gear)
		self:EmitSound("buttons/lever7.wav",250,100)
		Wire_TriggerOutput(self, "Ratio", self.GearRatio)
	else
		self:ChangeGear(self.Drive) --autogearing in :calc will set correct gear
	end
	
end

-- Searches the "tree" which gearbox-gearbox connections forms, if the source is found
-- anywhere in the targets link tree, this function will return true
function ACF_SearchGearboxLinkTree(source, target)
	local queue = { target }
	
	-- search the link tree
	while #queue > 0 do
		local ent = table.remove(queue)

		if ent == source then
			return true
		end
		
		if not ent.WheelLink then continue end

		-- add each link to the queue
		for k, v in ipairs(ent.WheelLink) do
			table.insert(queue, v.Ent)
		end
	end

	return false
end

function ENT:Link( Target )

	if not IsValid( Target ) or not table.HasValue( { "prop_physics", "acf_gearbox", "tire" }, Target:GetClass() ) then
		return false, "Can only link props or gearboxes!"
	end
	
	-- Check if target is already linked
	for Key, Link in pairs( self.WheelLink ) do
		if Link.Ent == Target then 
			return false, "That is already linked to this gearbox!"
		end
	end

	if ACF_SearchGearboxLinkTree(self, Target) then
		return false, "You cannot link gearboxes in a loop!"
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
	
	local Rope = nil
	if self.Owner:GetInfoNum( "ACF_MobilityRopeLinks", 1) == 1 then
		Rope = constraint.CreateKeyframeRope( OutPosWorld, 1, "cable/cable2", nil, self, OutPos, 0, Target, InPos, 0 )
	end
	local Phys = Target:GetPhysicsObject()
	local Axis = Phys:WorldToLocalVector( self:GetRight() )
	local Inertia = ( Axis * Phys:GetInertia() ):Length()
	
	local Link = {
		Ent = Target,
		Side = Side,
		Axis = Axis,
		Inertia = Inertia,
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

