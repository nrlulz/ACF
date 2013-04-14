/*
Weight STool 1.21
	by Spoco
*/

TOOL.Category		= "Armored Combat Framework"
TOOL.Name			= "#Tool.acfarmorprop.name"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar["mass"] = "1"
TOOL.ClientConVar["thick"] = "1"
TOOL.ClientConVar["ductility"] = "0"
TOOL.ClientConVar["mhealth"] = "1"
TOOL.ClientConVar["marmor"] = "1"
TOOL.ClientConVar["area"] = "1"

if CLIENT then
	language.Add( "Tool.acfarmorprop.name", "ACF Armor Properties" )
	language.Add( "Tool.acfarmorprop.desc", "Sets objects armor" )
	language.Add( "Tool.acfarmorprop.0", "Left click to apply options. Right click to props properties. Reload to get Total Mass of a Constrained Contraption" )
	language.Add( "Tool_acfarmorprop_weight", "Weight:" )
	language.Add( "Tool_acfarmorprop_thick" , "Armour Thickness")
	language.Add( "Tool_acfarmorprop_thick_desc" , "Set a thickness and the weight will be scaled" )
	language.Add( "Tool_acfarmorprop_ductility", "Durability:" )
	language.Add( "Tool_acfarmorprop_ductility_desc" , "Sets durability of prop. Higher than zero will make prop more resistant to penetration but it will lower its health. Lower than zero will make prop less resistant to penetration but it will endure longer fire" )
	language.Add( "Tool_acfarmorprop_zeromass", "Mass must be above 0!" )
end

if SERVER and not Weights then Weights = {} end

local function ApplySettings( Player, Entity, Data )
	if not SERVER then return end

	if Data.Mass then
		local physobj = Entity:GetPhysicsObject()
		if physobj:IsValid() then physobj:SetMass(Data.Mass) end
	end
	if Data.Ductility then
		Entity.ACF = Entity.ACF or {}
		Entity.ACF.Ductility = (Data.Ductility/100)
	end
	
	duplicator.StoreEntityModifier( Entity, "acfsettings", Data )
end

duplicator.RegisterEntityModifier( "acfsettings", ApplySettings )

local function Recalc(Ply, What)
	local Thick, Ductility, Area, Mass
	if SERVER or CLIENT then
		Thick = Ply:GetInfo("acfarmorprop_thick")
		Ductility = math.Clamp(Ply:GetInfo("acfarmorprop_ductility")/100,-0.8,0.8)
		Area = Ply:GetInfo("acfarmorprop_area") or 1
	end

	Mass = (39*Area*Ductility+39*Area)*Thick/50000
	if What == "ductility" then
		if Mass > 50000 then
			Mass = 50000
			Ductility = -(39*Area*Thick-50000*Mass)/(39*Area*Thick)
		elseif Mass < 0.1 then
			Mass = 0.1
			Ductility = -(39*Area*Thick-50000*Mass)/(39*Area*Thick)
		end
		Ply:ConCommand("acfarmorprop_ductility "..(Ductility*100));
	end
	
	if What == "thick" then
		if Mass > 50000 then
			Mass = 50000
			Thick = Mass*1000/(Area+Area*Ductility)/0.78
		elseif Mass < 0.1 then
			Mass = 0.1
			Thick = Mass*1000/(Area+Area*Ductility)/0.78
		end
		Ply:ConCommand("acfarmorprop_thick "..Thick);
	end
	Ply:ConCommand("acfarmorprop_mass "..Mass);
	
	if CLIENT then
		local MArmour = Mass*1000/(Area+Area*Ductility)/0.78
		local MHealth = (Area+Area*Ductility)/ACF.Threshold
		
		Ply:ConCommand("acfarmorprop_mhealth "..MHealth)
		Ply:ConCommand("acfarmorprop_marmor "..MArmour)
		Ply:ConCommand("acfarmorprop_reloadui")
	end
end

local function IsReallyValid(trace)
	if not trace.Entity:IsValid() then return false end
	if trace.Entity:IsPlayer() then return false end
	if SERVER and not trace.Entity:GetPhysicsObject():IsValid() then return false end
	return true
end

function TOOL:LeftClick( trace )
	if CLIENT and IsReallyValid(trace) then return true end
	if not IsReallyValid(trace) then return false end
	
	self:GetOwner():ConCommand("acfarmorprop_area "..trace.Entity.ACF.Aera);
	
	Recalc(self:GetOwner())
	
	local mass = tonumber(self:GetClientInfo("mass"))
	local ductility = tonumber(self:GetClientInfo("ductility"))
	
	ApplySettings( self:GetOwner(), trace.Entity, { Mass = mass, Ductility = ductility } )
	self.updateacf = true
	
	return true;
end

function TOOL:RightClick( trace )
	if CLIENT and IsReallyValid(trace) then return true end
	if not IsReallyValid(trace) then return end
	local ent = trace.Entity
	
	local mass = ent:GetPhysicsObject():GetMass()
	local ductility = ent.ACF.Ductility
	local mhealth = ent.ACF.MaxHealth
	local marmor = ent.ACF.MaxArmour
	local thick = ent.ACF.MaxArmour
	local area = ent.ACF.Aera
	self:GetOwner():ConCommand("acfarmorprop_mass "..mass);
	self:GetOwner():ConCommand("acfarmorprop_ductility "..ductility);
	self:GetOwner():ConCommand("acfarmorprop_mhealth "..mhealth);
	self:GetOwner():ConCommand("acfarmorprop_marmor "..marmor);
	self:GetOwner():ConCommand("acfarmorprop_thick "..marmor);
	self:GetOwner():ConCommand("acfarmorprop_area "..area);
	self:GetOwner():ConCommand("acfarmorprop_reloadui");
	
	self.updateacf = true
	return true;
end

function TOOL:Reload( trace )
	if CLIENT then return false end;
	if not IsReallyValid(trace) then return false end
	local mass = 0
		for ent , v in pairs( constraint.GetAllConstrainedEntities(trace.Entity) ) do
			if IsValid(ent) and ent != NULL then
				local phys = ent:GetPhysicsObject()
				mass = mass + phys:GetMass()
			end
		end
		self:GetOwner():PrintMessage(HUD_PRINTCENTER , "Total Mass is: "..tostring(mass) )
	return true
end


function TOOL:Think()
	if CLIENT then return end;
	local pl = self:GetOwner()
	local wep = pl:GetActiveWeapon()
	if not wep:IsValid() or wep:GetClass() != "gmod_tool" or pl:GetInfo("gmod_toolmode") != "acfarmorprop" then return end
	local trace = pl:GetEyeTrace()
	--if IsReallyValid(trace) then pl:SetNetworkedFloat("WeightMass", trace.Entity:GetPhysicsObject():GetMass()) end
	

	local ent = trace.Entity
	if ent != self.lastent or self.updateacf then
		if( ACF_Check ~= mil ) then
			local valid = ACF_Check( ent )
			if valid then
				local mass = ent:GetPhysicsObject():GetMass()
				self:GetOwner():ConCommand("acfarmorprop_mass "..mass);
				self:GetOwner():ConCommand("acfarmorprop_area "..ent.ACF.Aera);
				self.Weapon:SetNetworkedInt( "WeightMass", mass )
				self.Weapon:SetNetworkedInt( "HP", ent.ACF.Health )
				self.Weapon:SetNetworkedInt( "Armour", ent.ACF.Armour )
				self.Weapon:SetNetworkedInt( "MaxHP", ent.ACF.MaxHealth )
				self.Weapon:SetNetworkedInt( "MaxArmour", ent.ACF.MaxArmour )
				Recalc(self:GetOwner())
			end
		end
		self.lastent = ent
		self.updateacf = false
	end
	if ent:IsWorld() and !self.updateacf then
		self.Weapon:SetNetworkedInt( "WeightMass", 0 )
		self.Weapon:SetNetworkedInt( "HP", 0 )
		self.Weapon:SetNetworkedInt( "Armour", 0 )
		self.Weapon:SetNetworkedInt( "MaxHP", 0 )
		self.Weapon:SetNetworkedInt( "MaxArmour", 0 )
		self.updateacf = true
	end
end

if CLIENT then
	function TOOL.BuildCPanel( cp )
		cp:AddControl( "Header", { Text = "#Tool.acfarmorprop.name", Description	= "#Tool.acfarmorprop.desc" }  )

		local params = { Label = "#Presets", MenuButton = 1, Folder = "weight", Options = {}, CVars = {} }
		
		params.Options.default = { acf_weight_set = 1 }
		table.insert( params.CVars, "acfarmorprop_mass" )
		
		cp:AddControl("ComboBox", params )
		cp.mass = cp:AddControl("Header", {Text = "Actual Weight" , Description = "Weight: "..math.floor(GetConVarNumber("acfarmorprop_mass")*10)/10  } )
		cp.mhealth = cp:AddControl("Header", {Text = "Actual MaxHealth" , Description = "Max Health: "..math.floor(GetConVarNumber("acfarmorprop_mhealth")*10)/10  } )
		cp.marmor = cp:AddControl("Header", {Text = "Actual MaxArmor" , Description = "Max Armor: "..math.floor(GetConVarNumber("acfarmorprop_marmor")*10)/10  } )

		cp.thick = cp:AddControl("Slider", { Label = "#Tool_acfarmorprop_thick", Type = "Numeric", Min = "1", Max = "5000", Command = "acfarmorprop_thick" } )
		cp:AddControl("Header", {Text = "Armour Thickness Setting" , Description = "#Tool_acfarmorprop_thick_desc" } )		
		
		cp.ductility = cp:AddControl("Slider", { Label = "#Tool_acfarmorprop_ductility", Type = "Numeric", Min = "-99", Max = "99", Command = "acfarmorprop_ductility" } )
		cp:AddControl("Header", {Text = "Ductility Setting" , Description = "#Tool_acfarmorprop_ductility_desc" } )
	end

	--local BuildCPanel = TOOL.BuildCPanel
	concommand.Add( "acfarmorprop_reloadui", function()
		local cp = controlpanel.Get( "acfarmorprop" )
		if cp.mass then 
			cp.mass:SetText("Weight: "..math.floor(GetConVarNumber("acfarmorprop_mass")*10)/10)
		end
		if cp.mhealth then 
			cp.mhealth:SetText("Max Health: "..math.floor(GetConVarNumber("acfarmorprop_mhealth")*10)/10)
		end
		if cp.marmor then 
			cp.marmor:SetText("Max Armor: "..math.floor(GetConVarNumber("acfarmorprop_marmor")*10)/10)
		end
		if cp.thick then 
			local ConVar = GetConVar("acfarmorprop_thick"):GetFloat()
			cp.thick:SetValue( ConVar )
		end
		if cp.ductility then 
			local ConVar = GetConVar("acfarmorprop_ductility"):GetFloat()
			cp.ductility:SetValue( ConVar )
		end
		--BuildCPanel( CPanel )
	end)

	cvars.AddChangeCallback("acfarmorprop_ductility", function() 
		if timer.Exists("RecalcTimer") then timer.Remove("RecalcTimer") end
		timer.Create("RecalcTimer", 1, 1, function()
			Recalc(LocalPlayer(), "ductility")
		end)
	end)
	cvars.AddChangeCallback("acfarmorprop_thick", function() 
		if timer.Exists("RecalcTimer") then timer.Remove("RecalcTimer") end
		timer.Create("RecalcTimer", 1, 1, function()
			Recalc(LocalPlayer(), "thick")
		end)
	end)
	
	local TipColor = Color( 250, 250, 200, 255 )

	surface.CreateFont( "GModWorldtip", {font="coolvetica", size=24, weight=500, antialias=true, additive=false} )
	surface.CreateFont("Torchfont", {size=40, weight=1000, antialias=true, additive=false, font="arial"})
	
	local function DrawWeightTip()
		local pl = LocalPlayer()
		local wep = pl:GetActiveWeapon()
		if not wep:IsValid() or wep:GetClass() != "gmod_tool" or pl:GetInfo("gmod_toolmode") != "acfarmorprop" then return end
		local trace = pl:GetEyeTrace()
		if not IsReallyValid(trace) then return end
		
		local mass = math.floor((wep:GetNetworkedFloat("WeightMass") or 0) *10)/10
		local armour = math.floor((wep:GetNetworkedBool("MaxArmour") or 0) *100)/100
		local health = math.floor((wep:GetNetworkedBool("MaxHP") or 0) * 10)/10
		local mass2 = math.floor((GetConVarNumber("acfarmorprop_mass") or 0)*10)/10
		local armour2 = math.floor((GetConVarNumber("acfarmorprop_marmor") or 0)*10)/10
		local health2 = math.floor((GetConVarNumber("acfarmorprop_mhealth") or 0)*10)/10
		local text = "Current:\nWeight: "..mass.."\nArmour: "..armour.."\nHealth: "..health.."\nAfter:\nWeight: "..mass2.."\nArmour: "..armour2.."\nHealth: "..health2
	
		local pos = (trace.Entity:LocalToWorld(trace.Entity:OBBCenter())):ToScreen()
		
		local black = Color( 0, 0, 0, 255 )
		local tipcol = Color( TipColor.r, TipColor.g, TipColor.b, 255 )
		
		local x = 0
		local y = 0
		local padding = 10
		local offset = 50
		
		surface.SetFont( "GModWorldtip" )
		local w, h = surface.GetTextSize( text )
		
		x = pos.x - w 
		y = pos.y - h 
		
		x = x - offset
		y = y - offset

		draw.RoundedBox( 8, x-padding-2, y-padding-2, w+padding*2+4, h+padding*2+4, black )
		
		
		local verts = {}
		verts[1] = { x=x+w/1.5-2, y=y+h+2 }
		verts[2] = { x=x+w+2, y=y+h/2-1 }
		verts[3] = { x=pos.x-offset/2+2, y=pos.y-offset/2+2 }
		
		draw.NoTexture()
		surface.SetDrawColor( 0, 0, 0, tipcol.a )
		surface.DrawPoly( verts )
		
		
		draw.RoundedBox( 8, x-padding, y-padding, w+padding*2, h+padding*2, tipcol )
		
		local verts = {}
		verts[1] = { x=x+w/1.5, y=y+h }
		verts[2] = { x=x+w, y=y+h/2 }
		verts[3] = { x=pos.x-offset/2, y=pos.y-offset/2 }
		
		draw.NoTexture()
		surface.SetDrawColor( tipcol.r, tipcol.g, tipcol.b, tipcol.a )
		surface.DrawPoly( verts )
		
		
		draw.DrawText( text, "GModWorldtip", x + w/2, y, black, TEXT_ALIGN_CENTER )
	end
	
	hook.Add("HUDPaint", "ACF_WeightWorldTip", DrawWeightTip)

	function TOOL:DrawToolScreen(w,h)
		local Health = math.floor((self.Weapon:GetNetworkedBool("HP")or 0) *10)/10 
		local MaxHealth = math.floor((self.Weapon:GetNetworkedBool("MaxHP")or 0) * 10)/10
		local Armour = math.floor((self.Weapon:GetNetworkedBool("Armour")or 0) *100)/100
		local MaxArmour = math.floor((self.Weapon:GetNetworkedBool("MaxArmour")or 0) *100)/100
		
		local HealthTxt = Health.."/"..MaxHealth.."\n"
		local ArmourTxt = Armour.."/"..MaxArmour.."\n"
		
		local HealthPercent = (Health/MaxHealth) * 226
		local ArmourPercent = (Armour/MaxArmour) * 226
		
		cam.Start2D()
			render.Clear(0,0,0,0)
			local Flicker = 255
			surface.SetDrawColor(255,255,255,Flicker)
			local tex=surface.GetTextureID(	"models/props_combine/combine_interface_disp")
			surface.SetTexture(tex) 
			surface.DrawTexturedRect(0, 0, 256, 256)
			surface.SetDrawColor(255,255,255,255)

			surface.SetFont("Torchfont")
			local w, h = surface.GetTextSize(" ")
			
			draw.SimpleTextOutlined("ACF Stats", "Torchfont", 128, 30, Color(224, 224, 255, Flicker), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, Color(0, 0, 0, Flicker))
			
			draw.RoundedBox( 6, 10, 83, 236, 64, Color(200, 200, 200, Flicker))
			if Armour != 0 and MaxArmour != 0 then
				draw.RoundedBox( 6, 15, 88, ArmourPercent , 54, Color(0, 0, 200, Flicker))
			end
			
			draw.RoundedBox( 6, 10, 183, 236, 64, Color(200, 200, 200, Flicker))
			if Health != 0 and MaxHealth != 0 then
				draw.RoundedBox( 6, 15, 188, HealthPercent , 54, Color(200, 0, 0, Flicker))
			end
			
			draw.SimpleTextOutlined("Armour", "Torchfont", 128, 100, Color(224, 224, 255, Flicker), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, Color(0, 0, 0, Flicker))
				draw.SimpleTextOutlined(ArmourTxt, "Torchfont", 128, 150, Color(224, 224, 255, Flicker), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, Color(0, 0, 0, Flicker))
			
			draw.SimpleTextOutlined("Health", "Torchfont", 128, 200, Color(224, 224, 255, Flicker), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, Color(0, 0, 0, Flicker))
			draw.SimpleTextOutlined(HealthTxt, "Torchfont", 128, 250, Color(224, 224, 255, Flicker), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, Color(0, 0, 0, Flicker))
		cam.End2D()
	end
end






