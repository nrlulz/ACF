
TOOL.Category		= "ACF";
TOOL.Name			= "#Tool.acfcopy.listname";
TOOL.Author 		= "looter";
TOOL.Command		= nil;
TOOL.ConfigName		= "";

TOOL.GearboxCopyData = {};
TOOL.AmmoCopyData = {};

if CLIENT then

	language.Add( "Tool.acfcopy.listname", "ACF Copy Tool" );
	language.Add( "Tool.acfcopy.name", "Armored Combat Framework" );
	language.Add( "Tool.acfcopy.desc", "Copy ammo or gearbox data from one object to another" );
	language.Add( "Tool.acfcopy.0", "Left click to paste data, Right click to copy data" );

	function TOOL.BuildCPanel( CPanel )
	
	end

end

-- Update
function TOOL:LeftClick( trace )

	if CLIENT then return end

	local ent = trace.Entity;

	if !IsValid( ent ) then 
		return false;
	end

	local pl = self:GetOwner();

	if( ent:GetClass() == "acf_gearbox" and #self.GearboxCopyData > 1 and ent.CanUpdate ) then

		local success, msg = ent:Update( self.GearboxCopyData );

		ACF_SendNotify( pl, success, msg );

	end

	if( ent:GetClass() == "acf_ammo" and #self.AmmoCopyData > 1 and ent.CanUpdate ) then

		local success, msg = ent:Update( self.AmmoCopyData );

		ACF_SendNotify( pl, success, msg );

	end

	return true;

end

-- Copy
function TOOL:RightClick( trace )

	if CLIENT then return end

	local ent = trace.Entity;

	if !IsValid( ent ) then 
		return false;
	end

	local pl = self:GetOwner();

	if( ent:GetClass() == "acf_gearbox" ) then

		local ArgsTable = {};

		-- zero out the un-needed tool trace information
		ArgsTable[1] = pl;
		ArgsTable[2] = 0;
		ArgsTable[3] = 0;
		ArgsTable[4] = ent.Id;

		-- build gear data
		ArgsTable[5] = ent.GearTable[1];
		ArgsTable[6] = ent.GearTable[2];
		ArgsTable[7] = ent.GearTable[3];
		ArgsTable[8] = ent.GearTable[4];
		ArgsTable[9] = ent.GearTable[5];
		ArgsTable[10] = ent.GearTable[6];
		ArgsTable[11] = ent.GearTable[7];
		ArgsTable[12] = ent.GearTable[8];
		ArgsTable[13] = ent.GearTable[9];
		ArgsTable[14] = ent.GearTable.Final;

		self.GearboxCopyData = ArgsTable;

		ACF_SendNotify( pl, true, "Gearbox copied successfully!" );

	end

	if( ent:GetClass() == "acf_ammo" ) then

		local ArgsTable = {};

		-- zero out the un-needed tool trace information
		ArgsTable[1] = pl;
		ArgsTable[2] = 0;
		ArgsTable[3] = 0;
		ArgsTable[4] = 0; -- ArgsTable[4] isnt actually used anywhere within acf_ammo ENT:Update() and ENT:CreateAmmo(), just passed around?

		-- build gear data
		ArgsTable[5] = ent.RoundId;
		ArgsTable[6] = ent.RoundType;
		ArgsTable[7] = ent.RoundPropellant;
		ArgsTable[8] = ent.RoundProjectile;
		ArgsTable[9] = ent.RoundData5;
		ArgsTable[10] = ent.RoundData6;
		ArgsTable[11] = ent.RoundData7;
		ArgsTable[12] = ent.RoundData8;
		ArgsTable[13] = ent.RoundData9;
		ArgsTable[14] = ent.RoundData10;

		self.AmmoCopyData = ArgsTable;

		ACF_SendNotify( pl, true, "Ammo copied successfully!" );

	end

	return true;
	
end
