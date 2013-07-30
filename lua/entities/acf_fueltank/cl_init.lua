include("shared.lua")

ENT.RenderGroup 		= RENDERGROUP_OPAQUE

function ENT:Draw()
	self:DoNormalDraw()
    Wire_Render(self)
end

function ENT:DoNormalDraw()
	local e = self
	local FuelType = self:GetNetworkedString("FuelType")
	local FuelLevel = self:GetNetworkedFloat("FuelLevel")
	if (LocalPlayer():GetEyeTrace().Entity == e and EyePos():Distance(e:GetPos()) < 256) then
		local txt = "Fuel Type: " ..FuelType
		if FuelType == "Electric" then
			txt = txt.."\nCharge Level: "..math.Round(FuelLevel,1).." kW hours / "..math.Round(3.6*FuelLevel,1).." MJ"
		else
			txt = txt.."\nFuel Remaining: " ..math.Round(FuelLevel,1).." liters / " ..math.Round(FuelLevel*0.264172,1).. " gallons"
		end
		if (not game.SinglePlayer()) then
			local PlayerName = self:GetPlayerName()
			txt = txt.. "\n(" .. PlayerName .. ")"
		end
		AddWorldTip(e:EntIndex(),txt,0.5,e:GetPos(),e)
	end
	e:DrawModel()
end

function ENT:Think()
	if (CurTime() >= (self.NextRBUpdate or 0)) then
	    self.NextRBUpdate = CurTime() + math.random(30,100)/10 --update renderbounds every 3 to 10 seconds
		Wire_UpdateRenderBounds(self)
	end
end

function ACFFuelTankGUICreate( Table )
	if not acfmenupanel.CustomDisplay then return end
	if not acfmenupanel.FuelTankData then
		acfmenupanel.FuelTankData = {}
		acfmenupanel.FuelTankData["Id"] = "Crate_2x2x4"
		acfmenupanel.FuelTankData["FuelID"] = "Petrol"
	end
	
	local Tanks = list.Get("ACFEnts")["FuelTanks"]
	--table.sort(Tanks, function(a,b) return a.name < b.name end )
	--table.sort(Tanks, function(a,b) return (a["dims"][1]*a["dims"][2]*a["dims"][3]) < (b["dims"][1]*b["dims"][2]*b["dims"][3]) end )

	--because table.sort was uncooperative
	local SortedTanks = {}
	local I = 1
	for k,v in pairs(Tanks) do
		SortedTanks[I] = k
		I = I+1
	end
	
	for I=1,#SortedTanks do
		for J=I+1,#SortedTanks do
			local a = Tanks[SortedTanks[I]]["dims"]
			local b = Tanks[SortedTanks[J]]["dims"]
			if b[1]*b[2]*b[3] < a[1]*a[2]*a[3] then -- volume J < volume I
				local temp = SortedTanks[I]
				SortedTanks[I] = SortedTanks[J]
				SortedTanks[J] = temp
			end
		end
	end
	--it's not the most elegant solution, but it does the job
	
	acfmenupanel:CPanelText("Name", Table.name)
	acfmenupanel:CPanelText("Desc", Table.desc)
	
	-- tank size dropbox
	acfmenupanel.CData.TankSizeSelect = vgui.Create( "DComboBox", acfmenupanel.CustomDisplay )
		acfmenupanel.CData.TankSizeSelect:SetSize(100, 30)
		for I=1, #SortedTanks do
			acfmenupanel.CData.TankSizeSelect:AddChoice( SortedTanks[I] )
		end
		acfmenupanel.CData.TankSizeSelect.OnSelect = function( index , value , data )
			RunConsoleCommand( "acfmenu_data1", data )
			acfmenupanel.FuelTankData["Id"] = data
			ACFFuelTankGUIUpdate( Table )
		end
		acfmenupanel.CData.TankSizeSelect:SetText(acfmenupanel.FuelTankData["Id"])
		RunConsoleCommand( "acfmenu_data1", acfmenupanel.FuelTankData["Id"] )
	acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.TankSizeSelect )
	
	-- fuel type dropbox
	acfmenupanel.CData.FuelSelect = vgui.Create( "DComboBox", acfmenupanel.CustomDisplay )
		acfmenupanel.CData.FuelSelect:SetSize(100, 30)
		for Key, Value in pairs( ACF.FuelDensity ) do
			acfmenupanel.CData.FuelSelect:AddChoice( Key )
		end
		acfmenupanel.CData.FuelSelect.OnSelect = function( index , value , data )
			RunConsoleCommand( "acfmenu_data2", data )
			acfmenupanel.FuelTankData["FuelID"] = data
			ACFFuelTankGUIUpdate( Table )
		end
		acfmenupanel.CData.FuelSelect:SetText(acfmenupanel.FuelTankData["FuelID"])
		RunConsoleCommand( "acfmenu_data2", acfmenupanel.FuelTankData["FuelID"] )
	acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.FuelSelect )
	
	ACFFuelTankGUIUpdate( Table )
	
	acfmenupanel.CustomDisplay:PerformLayout()
	
end

function ACFFuelTankGUIUpdate( Table )

	if not acfmenupanel.CustomDisplay then return end
	
	local Tanks = list.Get("ACFEnts")["FuelTanks"]
	
	local TankID = acfmenupanel.FuelTankData["Id"]
	local FuelID = acfmenupanel.FuelTankData["FuelID"]
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
	
	--fuel tank model display
	if not acfmenupanel.CData.DisplayModel then
		acfmenupanel.CData.DisplayModel = vgui.Create( "DModelPanel", acfmenupanel.CustomDisplay )
			acfmenupanel.CData.DisplayModel:SetModel( Tanks[TankID].model )
			acfmenupanel.CData.DisplayModel:SetCamPos( Vector( 250 , 500 , 200 ) )
			acfmenupanel.CData.DisplayModel:SetLookAt( Vector( 0, 0, 0 ) )
			acfmenupanel.CData.DisplayModel:SetFOV( 10 )
			acfmenupanel.CData.DisplayModel:SetSize(acfmenupanel:GetWide(),acfmenupanel:GetWide())
			acfmenupanel.CData.DisplayModel.LayoutEntity = function( panel , entity ) end
		acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.DisplayModel )
	end
	acfmenupanel.CData.DisplayModel:SetModel( Tanks[TankID].model )
	
end