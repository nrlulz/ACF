
local cat = ((ACF.CustomToolCategory and ACF.CustomToolCategory:GetBool()) and "ACF" or "Construction");

TOOL.Category		= cat
TOOL.Name			= "#Tool.acfmenu.listname"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "type" ] = "gun"
TOOL.ClientConVar[ "id" ] = "12.7mmMG"

TOOL.ClientConVar[ "data1" ] = "12.7mmMG"
TOOL.ClientConVar[ "data2" ] = "AP"
TOOL.ClientConVar[ "data3" ] = 0
TOOL.ClientConVar[ "data4" ] = 0
TOOL.ClientConVar[ "data5" ] = 0
TOOL.ClientConVar[ "data6" ] = 0
TOOL.ClientConVar[ "data7" ] = 0
TOOL.ClientConVar[ "data8" ] = 0
TOOL.ClientConVar[ "data9" ] = 0
TOOL.ClientConVar[ "data10" ] = 0

cleanup.Register( "acfmenu" )

if CLIENT then
	language.Add( "Tool.acfmenu.listname", "ACF Menu" )
	language.Add( "Tool.acfmenu.name", "Armored Combat Framework" )
	language.Add( "Tool.acfmenu.desc", "Spawn the Armored Combat Framework weapons and ammo" )
	language.Add( "Tool.acfmenu.0", "Left click to spawn the entity of your choice, Right click to link an entity to another (+Use to unlink)" )
	language.Add( "Tool.acfmenu.1", "Right click to link the selected sensor to a pod" )
	
	language.Add( "Undone_ACF Entity", "Undone ACF Entity" )
	language.Add( "Undone_acf_engine", "Undone ACF Engine" )
	language.Add( "Undone_acf_gearbox", "Undone ACF Gearbox" )
	language.Add( "Undone_acf_ammo", "Undone ACF Ammo" )
	language.Add( "Undone_acf_gun", "Undone ACF Gun" )
	language.Add( "SBoxLimit_acf_gun", "You've reached the ACF Guns limit!" )
	language.Add( "SBoxLimit_acf_rack", "You've reached the ACF Launchers limit!" )
	language.Add( "SBoxLimit_acf_ammo", "You've reached the ACF Explosives limit!" )
	language.Add( "SBoxLimit_acf_sensor", "You've reached the ACF Sensors limit!" )

	/*------------------------------------
		BuildCPanel
	------------------------------------*/
	function TOOL.BuildCPanel( CPanel )
	
		local pnldef_ACFmenu = vgui.RegisterFile( "acf/client/cl_acfmenu_gui.lua" )
		
		// create
		local DPanel = vgui.CreateFromTable( pnldef_ACFmenu )
		CPanel:AddPanel( DPanel )
	
	end
end

-- Spawn/update functions
function TOOL:LeftClick( trace )

	if CLIENT then return true end
	if not IsValid( trace.Entity ) and not trace.Entity:IsWorld() then return false end
	
	local ply = self:GetOwner()
	local Type = self:GetClientInfo( "type" )
	local Id = self:GetClientInfo( "id" )
	
	local DupeClass = duplicator.FindEntityClass( ACF.Weapons[Type][Id]["ent"] ) 
	
	if DupeClass then
		local ArgTable = {}
			ArgTable[2] = trace.HitNormal:Angle():Up():Angle()
			ArgTable[1] = trace.HitPos + trace.HitNormal*32
			
		local ArgList = list.Get("ACFCvars")
		
		-- Reading the list packaged with the ent to see what client CVar it needs
		for Number, Key in pairs( ArgList[ACF.Weapons[Type][Id]["ent"]] ) do
			ArgTable[ Number+2 ] = self:GetClientInfo( Key )
		end
		
		if trace.Entity:GetClass() == ACF.Weapons[Type][Id]["ent"] and trace.Entity.CanUpdate then
			table.insert( ArgTable, 1, ply )
			local success, msg = trace.Entity:Update( ArgTable )
			ACF_SendNotify( ply, success, msg )
		else
			-- Using the Duplicator entity register to find the right factory function
			local Ent = DupeClass.Func( ply, unpack( ArgTable ) )
			Ent:Activate()
			Ent:GetPhysicsObject():Wake()
			
			undo.Create( ACF.Weapons[Type][Id]["ent"] )
				undo.AddEntity( Ent )
				undo.SetPlayer( ply )
			undo.Finish()
		end
			
		return true
	else
		print("Didn't find entity duplicator records")
	end

end

-- Link/unlink functions
function TOOL:RightClick( trace )

	if not IsValid( trace.Entity ) then return false end
	if CLIENT then return true end
	
	local ply = self:GetOwner()
	
	if self:GetStage() == 0 and trace.Entity.IsMaster then
		self.Master = trace.Entity
		self:SetStage( 1 )
		return true
	elseif self:GetStage() == 1 then
		local success, msg
		
		if ply:KeyDown( IN_USE ) or ply:KeyDown( IN_SPEED ) then
			success, msg = self.Master:Unlink( trace.Entity )
		else
			success, msg = self.Master:Link( trace.Entity )
		end
		
		ACF_SendNotify( ply, success, msg )
		
		self:SetStage( 0 )
		self.Master = nil
		return true
	else
		return false
	end
	
end
