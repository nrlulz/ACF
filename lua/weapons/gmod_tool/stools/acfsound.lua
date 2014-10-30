
local cat = ((ACF.CustomToolCategory and ACF.CustomToolCategory:GetBool()) and "ACF" or "Construction");

TOOL.Category		= cat
TOOL.Name			= "#Tool.acfsound.name"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar["pitch"] = "1"
if CLIENT then
	language.Add( "Tool.acfsound.name", "ACF Sound Replacer" )
	language.Add( "Tool.acfsound.desc", "Change sound of guns/engines." )
	language.Add( "Tool.acfsound.0", "Left click to apply sound. Right click to copy sound. Reload to set default sound." )
end

local function ReplaceSound( ply , Entity , data)
	if !IsValid( Entity ) then return end
	local sound = data[1]
	local pitch = data[2] or 1
	timer.Simple(1, function()
		if Entity:GetClass() == "acf_engine" then
			Entity.SoundPath = sound
			Entity.SoundPitch = pitch
		elseif Entity:GetClass() == "acf_gun" then
			Entity.Sound = sound
			Entity:SetNWString( "Sound", sound )
		end
	end)
			
	duplicator.StoreEntityModifier( Entity, "acf_replacesound", {sound, pitch} )
end

duplicator.RegisterEntityModifier( "acf_replacesound", ReplaceSound )

local function IsReallyValid(trace, ply)
	local True = true
	if not trace.Entity:IsValid() then True = false end
	if trace.Entity:IsPlayer() then True = false end
	if trace.Entity:GetClass() ~= "acf_gun" and trace.Entity:GetClass() ~= "acf_engine" then True = false end
	if SERVER and not trace.Entity:GetPhysicsObject():IsValid() then True = false end
	
	
	if True then
		return false
	else
		ply:PrintMessage(HUD_PRINTNOTIFY , "You need to aim at engine or gun to change it's sound" )
		return true
	end
end

function TOOL:LeftClick( trace )
	if CLIENT or IsReallyValid( trace, self:GetOwner() ) then return false end
	local sound = self:GetOwner():GetInfo("wire_soundemitter_sound")
	local pitch = self:GetOwner():GetInfo("acfsound_pitch")
	ReplaceSound( self:GetOwner(), trace.Entity, {sound, pitch} )
	return true
end

function TOOL:RightClick( trace )
	if CLIENT or IsReallyValid( trace, self:GetOwner() ) then return false end
	if trace.Entity:GetClass() == "acf_engine" then
		self:GetOwner():ConCommand("wire_soundemitter_sound "..trace.Entity.SoundPath);
		self:GetOwner():ConCommand("acfsound_pitch "..trace.Entity.SoundPitch);
	elseif trace.Entity:GetClass() == "acf_gun" then
		self:GetOwner():ConCommand("wire_soundemitter_sound "..trace.Entity.Sound);
	end
	return true
end

function TOOL:Reload( trace )
	if CLIENT or IsReallyValid( trace, self:GetOwner() ) then return false end
	if trace.Entity:GetClass() == "acf_engine" then
		local Id = trace.Entity.Id
		local List = list.Get("ACFEnts")
		local pitch = List["Mobility"][Id]["pitch"] or 1
		self:GetOwner():ConCommand("acfsound_pitch " ..pitch);
		ReplaceSound( self:GetOwner(), trace.Entity, {List["Mobility"][Id]["sound"], pitch} )
	elseif trace.Entity:GetClass() == "acf_gun" then
		local Class = trace.Entity.Class
		local Classes = list.Get("ACFClasses")
		ReplaceSound( self:GetOwner(), trace.Entity, {Classes["GunClass"][Class]["sound"]} )
	end
	return true
end

function TOOL.BuildCPanel(panel)
	local wide = panel:GetWide()

	local SoundNameText = vgui.Create("DTextEntry", ValuePanel)
	SoundNameText:SetText("")
	SoundNameText:SetWide(wide)
	SoundNameText:SetTall(20)
	SoundNameText:SetMultiline(false)
	SoundNameText:SetConVar("wire_soundemitter_sound")
	SoundNameText:SetVisible(true)
	panel:AddItem(SoundNameText)

	local SoundBrowserButton = vgui.Create("DButton")
	SoundBrowserButton:SetText("Open Sound Browser")
	SoundBrowserButton:SetWide(wide)
	SoundBrowserButton:SetTall(20)
	SoundBrowserButton:SetVisible(true)
	SoundBrowserButton.DoClick = function()
		RunConsoleCommand("wire_sound_browser_open",SoundNameText:GetValue())
	end
	panel:AddItem(SoundBrowserButton)

	local SoundPre = vgui.Create("DPanel")
	SoundPre:SetWide(wide)
	SoundPre:SetTall(20)
	SoundPre:SetVisible(true)

	local SoundPreWide = SoundPre:GetWide()

	local SoundPrePlay = vgui.Create("DButton", SoundPre)
	SoundPrePlay:SetText("Play")
	SoundPrePlay:SetWide(SoundPreWide / 2)
	SoundPrePlay:SetPos(0, 0)
	SoundPrePlay:SetTall(20)
	SoundPrePlay:SetVisible(true)
	SoundPrePlay.DoClick = function()
		RunConsoleCommand("play",SoundNameText:GetValue())
	end

	local SoundPreStop = vgui.Create("DButton", SoundPre)
	SoundPreStop:SetText("Stop")
	SoundPreStop:SetWide(SoundPreWide / 2)
	SoundPreStop:SetPos(SoundPreWide / 2, 0)
	SoundPreStop:SetTall(20)
	SoundPreStop:SetVisible(true)
	SoundPreStop.DoClick = function()
		RunConsoleCommand("play", "common/NULL.WAV") //Playing a silent sound will mute the preview but not the sound emitters.
	end
	panel:AddItem(SoundPre)
	SoundPre:InvalidateLayout(true)
	SoundPre.PerformLayout = function()
		local SoundPreWide = SoundPre:GetWide()
		SoundPrePlay:SetWide(SoundPreWide / 2)
		SoundPreStop:SetWide(SoundPreWide / 2)
		SoundPreStop:SetPos(SoundPreWide / 2, 0)
	end
	
	panel:AddControl("Slider", {
        Label = "Pitch:",
        Command = "acfsound_pitch",
        Type = "Float",
        Min = "0.1",
        Max = "2",
    }):SetTooltip("Works only for engines.")
	/*
	local SoundPitch = vgui.Create("DNumSlider")
	SoundPitch:SetMin( 0.1 )
	SoundPitch:SetMax( 2 )
    SoundPitch:SetDecimals( 0.1 )
	SoundPitch:SetWide(wide)
	SoundPitch:SetText("Pitch:")
	SoundPitch:SetToolTip("Works only for engines")
	SoundPitch:SetConVar( "acfsound_pitch" )
	SoundPitch:SetValue( 1 )
	panel:AddItem(SoundPitch)
	*/
end
