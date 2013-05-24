include("shared.lua")

ENT.RenderGroup 		= RENDERGROUP_OPAQUE

function ENT:Draw()
	self:DoNormalDraw()
	self:DrawModel()
    Wire_Render(self)
end

function ENT:DoNormalDraw()
	local e = self
	if (LocalPlayer():GetEyeTrace().Entity == e and EyePos():Distance(e:GetPos()) < 256) then
		local txt = self:GetOverlayText()
		if txt ~= "" then
			AddWorldTip( e:EntIndex(), txt, 0.5, e:GetPos(), e )
		end
	end
end

function ENT:GetOverlayText()
	local List = list.Get( "ACFEnts" )
	
	local name = self:GetNetworkedString( "WireName" )
	local id = self:GetNetworkedBeamString( "ID" )
	local txt = List["Mobility"][id]["name"].."\n"
	local cvt
	if List["Mobility"][id]["cvt"] then cvt = 1 else cvt = 0 end
	for i = 1+cvt, List["Mobility"][id]["gears"] do
		local gear = math.Round( self:GetNetworkedBeamFloat( "Gear" .. i ), 3 )
		txt = txt .. "Gear " .. i .. ": " .. tostring( gear ) .. "\n"
	end
	local fd = math.Round( self:GetNetworkedBeamFloat( "FinalDrive" ), 3 )
	txt = txt .. "Final Drive: " .. tostring( fd ) .. "\n"
	
	if cvt == 1 then
		local targetrpm = self:GetNetworkedBeamInt( "TargetRPM" )
		txt = txt.."Target Input RPM: " .. tostring( targetrpm ) .. "\n"
	end
	
	local maxtq = List["Mobility"][id]["maxtq"]
	txt = txt .. "Maximum Torque Rating: " .. tostring( maxtq ) .. "n-m / " .. tostring( math.Round( maxtq * 0.73 ) ) .. "ft-lb"
	if (not game.SinglePlayer()) then
		local PlayerName = self:GetPlayerName()
		txt = txt .. "\n(" .. PlayerName .. ")"
	end
	
	if(name and name ~= "") then
	    if (txt == "") then
	        return "- "..name.." -"
	    end
	    return "- "..name.." -\n"..txt
	end
	
	return txt
end

function ACFGearboxGUICreate( Table )

	if not acfmenupanel.GearboxData then
		acfmenupanel.GearboxData = {}
	end
	if not acfmenupanel.GearboxData[Table.id] then
		acfmenupanel.GearboxData[Table.id] = {}
		acfmenupanel.GearboxData[Table.id]["GearTable"] = Table.geartable
	end
		
	acfmenupanel:CPanelText("Name", Table.name)
	
	acfmenupanel.CData.DisplayModel = vgui.Create( "DModelPanel", acfmenupanel.CustomDisplay )
		acfmenupanel.CData.DisplayModel:SetModel( Table.model )
		acfmenupanel.CData.DisplayModel:SetCamPos( Vector( 250 , 500 , 250 ) )
		acfmenupanel.CData.DisplayModel:SetLookAt( Vector( 0, 0, 0 ) )
		acfmenupanel.CData.DisplayModel:SetFOV( 20 )
		acfmenupanel.CData.DisplayModel:SetSize(acfmenupanel:GetWide(),acfmenupanel:GetWide())
		acfmenupanel.CData.DisplayModel.LayoutEntity = function( panel , entity ) end
	acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.DisplayModel )
	
	acfmenupanel:CPanelText("Desc", Table.desc)	--Description (Name, Desc)
	
	if (acfmenupanel.GearboxData[Table.id]["GearTable"][-2] or 0) != 0 then
		ACF_GearsSlider(2, acfmenupanel.GearboxData[Table.id]["GearTable"][2], Table.id)
		ACF_GearsSlider(9, acfmenupanel.GearboxData[Table.id]["GearTable"][-2], Table.id, "Target Input RPM")
		ACF_GearsSlider(10, acfmenupanel.GearboxData[Table.id]["GearTable"][-1], Table.id, "Final Drive")
		RunConsoleCommand( "acfmenu_data1", 0.01 )
	else
		for ID,Value in pairs(acfmenupanel.GearboxData[Table.id]["GearTable"]) do
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

function ACF_GearsSlider(Gear, Value, ID, Desc)

	if Gear and not acfmenupanel["CData"][Gear] then	
		local CVT = Gear == 9
		acfmenupanel["CData"][Gear] = vgui.Create( "DNumSlider", acfmenupanel.CustomDisplay )
			acfmenupanel["CData"][Gear]:SetText( Desc or "Gear "..Gear )
			acfmenupanel["CData"][Gear]:SetDark( true )
			acfmenupanel["CData"][Gear]:SetMin( CVT and 1 or -1 )
			acfmenupanel["CData"][Gear]:SetMax( CVT and 10000 or 1 )
			acfmenupanel["CData"][Gear]:SetDecimals( (not CVT) and 2 or 0 )
			acfmenupanel["CData"][Gear]["Gear"] = Gear
			acfmenupanel["CData"][Gear]["ID"] = ID
			acfmenupanel["CData"][Gear]:SetValue(Value)
			RunConsoleCommand( "acfmenu_data"..Gear, Value )
			acfmenupanel["CData"][Gear].OnValueChanged = function( slider, val )
				acfmenupanel.GearboxData[slider.ID]["GearTable"][slider.Gear] = val
				RunConsoleCommand( "acfmenu_data"..Gear, val )
			end
		acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"][Gear] )
	end

end