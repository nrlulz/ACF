
TOOL.Category		= "Construction";
TOOL.Name			= "#Tool.acfcopy.listname";
TOOL.Command		= nil;
TOOL.ConfigName		= "";

cleanup.Register( "acfcopy" )

if CLIENT then

	language.Add( "Tool.acfcopy.listname", "ACF Gearbox Copy" );
	language.Add( "Tool.acfcopy.name", "Armored Combat Framework" );
	language.Add( "Tool.acfcopy.desc", "Copy gearbox data from one to another" );
	language.Add( "Tool.acfcopy.0", "Left click to paste gearbox data, Right click to copy gearbox data" );

	--[[------------------------------------
		BuildCPanel
	--------------------------------------]]
	function TOOL.BuildCPanel( CPanel )
	
		--local pnldef_acfcopy = vgui.RegisterFile( "acf/client/cl_acfcopy_gui.lua" )
		
		-- create
		--local DPanel = vgui.CreateFromTable( pnldef_acfcopy )
		--CPanel:AddPanel( DPanel )
	
	end

end

TOOL.CopyData = {};

-- Update
function TOOL:LeftClick( trace )

	if CLIENT then return end

	local ent = trace.Entity;

	if !IsValid( ent ) or ent:GetClass() != "acf_gearbox" then 
		return false;
	end

	if( #self.CopyData > 1 and ent.CanUpdate ) then

		local pl = self:GetOwner();

		local success, msg = ent:Update( self.CopyData );

		ACF_SendNotify( pl, success, msg );

	end

end

-- Copy
function TOOL:RightClick( trace )

	if CLIENT then return end

	local ent = trace.Entity;

	if !IsValid( ent ) or ent:GetClass() != "acf_gearbox" then 
		return false;
	end

	local pl = self:GetOwner();

	local ArgTable = {};

	-- null out the un-needed tool trace information
	ArgTable[1] = pl;
	ArgTable[2] = 0;
	ArgTable[3] = 0;
	ArgTable[4] = ent.Id;

	-- build gear data
	ArgTable[5] = ent.GearTable[1];
	ArgTable[6] = ent.GearTable[2];
	ArgTable[7] = ent.GearTable[3];
	ArgTable[8] = ent.GearTable[4];
	ArgTable[9] = ent.GearTable[5];
	ArgTable[10] = ent.GearTable[6];
	ArgTable[11] = ent.GearTable[7];
	ArgTable[12] = ent.GearTable[8];
	ArgTable[13] = ent.GearTable[9];
	ArgTable[14] = ent.GearTable.Final;

	self.CopyData = ArgTable;

	PrintTable( self.CopyData );

	ACF_SendNotify( pl, true, "Gearbox copied successfully!" );
	
end
