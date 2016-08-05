
// Variables that are used on both client and server

SWEP.Author			= "Kafouille"
SWEP.Contact		= ""
SWEP.Purpose		= "Making holes in various materials"
SWEP.Instructions	= "ACF AMR"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.ViewModel			= "models/weapons/v_sniper.mdl"
SWEP.WorldModel			= "models/weapons/w_sniper.mdl"

SWEP.Weight				= 10

-- local GunsList = list.GetForEdit("ACFEnts")["Guns"]	
-- GunsList.AMR = {}
-- GunsList.AMR.nomenu = true	--Don't add that to the ACF menu
-- GunsList.AMR.id = "15.3mmAMR"
-- GunsList.AMR.caliber = 15.3
-- GunsList.AMR.round = {}
	-- GunsList.AMR.round.id = "15.3mmAMR"
	-- GunsList.AMR.round.maxlength = 999
	-- GunsList.AMR.round.propweight = 999
-- list.Set("ACFEnts", "Guns", GunsList) --The ID and the index you add to the table need to be identical

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 25
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "CombineCannon"
SWEP.Primary.UserData = {}
	SWEP.Primary.UserData["Id"] = "14.5mmMG"
	SWEP.Primary.UserData["Type"] = "HE"
	SWEP.Primary.UserData["PropLength"] = 2
	SWEP.Primary.UserData["ProjLength"] = 10
	SWEP.Primary.UserData["Data5"] = 1.6
	SWEP.Primary.UserData["Data6"] = 0
	SWEP.Primary.UserData["Data7"] = 0
	SWEP.Primary.UserData["Data8"] = 0
	SWEP.Primary.UserData["Data9"] = 0
	SWEP.Primary.UserData["Data10"] = 0

SWEP.Primary.Inaccuracy				= 0								--Base spray

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Irons = false
SWEP.IronsDelay = 1
SWEP.ViewModelFOV = 90

SWEP.FreeaimSightsPos 		= Vector(0,0,0)		--Lateral, Depth, Vertical
SWEP.FreeaimSightsAng 		= Vector(0,0,0)				--Pitch, Yaw, Roll
SWEP.IronSightsPos 			= Vector(0,0,0)		--Lateral, Depth, Vertical
SWEP.IronSightsAng 			= Vector(0,0,0)				--Pitch, Yaw, Roll

function SWEP:SetupDataTables()
	
	self:DTVar( "Bool", 0, "Irons" )
	self:DTVar( "Angle", 0, "View" )
 
 end
 
function SWEP:PrimaryAttack()

	if !self:CanPrimaryAttack() then return end
	
	if ( CLIENT ) then
		self:ApplyRecoil(math.min(Recoil,50))
		self:MuzzleEffect()
	else
		local MuzzlePos = self.Owner:GetShootPos()
		local MuzzleVec = self.Owner:GetAimVector()
		local Speed = self.Primary.BulletData["MuzzleVel"]
		local Modifiers = self:CalculateModifiers()
		local Recoil = (self.Primary.BulletData["ProjMass"] * self.Primary.BulletData["MuzzleVel"] + self.Primary.BulletData["PropMass"] * 3000)/self.Weight
		
		if ( self.RoundType ~= "Empty" ) then

			local Inaccuracy = VectorRand() / 360 * self.Inaccuracy * Modifiers
			local Flight = (MuzzleVec+Inaccuracy):GetNormalized() * Speed * 39.37
			
			self.Primary.BulletData["Pos"] = MuzzlePos
			self.Primary.BulletData["Velocity"] = (MuzzleVec+Inaccuracy):GetNormalized() * Speed * 39.37 + self:GetVelocity()
			self.Primary.BulletData["Owner"] = self.Owner
			self.Primary.BulletData["Gun"] = self.Owner
			self.Primary.BulletData["Crate"] = self:EntIndex()
			self.CreateShell = ACF.RoundTypes[self.Primary.BulletData["Type"]]["create"]
			self:CreateShell( self.Primary.BulletData )
			
			self:TakePrimaryAmmo(1)
		
		end
	end
	
end

function SWEP:SecondaryAttack()
	
	if self.LastIrons+1 < CurTime() then
		if self:GetDTBool(0) then
			self:SetDTBool(0,false )
		else
			self:SetDTBool(0,true )
		end
		self.LastIrons = CurTime()
	end
	
	return true
end
 
 -- Acuracy/recoil modifiers
function SWEP:CalculateModifiers()

	local modifier = 1

	if self.Owner:KeyDown(IN_FORWARD or IN_BACK or IN_MOVELEFT or IN_MOVERIGHT) then
		modifier = modifier*2
	end
	
	if not self.Owner:IsOnGround() then
		modifier = modifier*2 --You can't be jumping and crouching at the same time, so return here
	return modifier end
	
	if self.Owner:Crouching() then 
		modifier = modifier*0.5
	end
		
	return modifier

end
