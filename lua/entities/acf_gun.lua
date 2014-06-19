
AddCSLuaFile()

DEFINE_BASECLASS( "base_wire_entity" )

ENT.PrintName = "ACF Gun"
ENT.WireDebugName = "ACF Gun"

if CLIENT then

	local ACF_GunInfoWhileSeated = CreateClientConVar("ACF_GunInfoWhileSeated", 0, true, false)

	function ENT:Initialize()
		
		self.BaseClass.Initialize( self )
		
		self.LastFire = 0
		self.Reload = 1
		self.CloseTime = 1
		self.Rate = 1
		self.RateScale = 1
		self.FireAnim = self:LookupSequence( "shoot" )
		self.CloseAnim = self:LookupSequence( "load" )
		
	end
	
	-- copied from base_wire_entity: DoNormalDraw's notip arg isn't accessible from ENT:Draw defined there.
	function ENT:Draw()
	
		local lply = LocalPlayer()
		local hideBubble = not ACF_GunInfoWhileSeated:GetBool() and IsValid(lply) and lply:InVehicle()
		
		self.BaseClass.DoNormalDraw(self, false, hideBubble)
		Wire_Render(self)
		
		if self.GetBeamLength and (not self.GetShowBeam or self:GetShowBeam()) then 
			-- Every SENT that has GetBeamLength should draw a tracer. Some of them have the GetShowBeam boolean
			Wire_DrawTracerBeam( self, 1, self.GetBeamHighlight and self:GetBeamHighlight() or false ) 
		end
		
	end
	
	function ENT:Think()
		
		self.BaseClass.Think( self )
		
		local SinceFire = CurTime() - self.LastFire
		self:SetCycle( SinceFire * self.Rate / self.RateScale )
		if CurTime() > self.LastFire + self.CloseTime and self.CloseAnim then
			self:ResetSequence( self.CloseAnim )
			self:SetCycle( ( SinceFire - self.CloseTime ) * self.Rate / self.RateScale )
			self.Rate = 1 / ( self.Reload - self.CloseTime ) -- Base anim time is 1s, rate is in 1/10 of a second
			self:SetPlaybackRate( self.Rate )
		end
		
	end
	
	function ENT:Animate( Class, ReloadTime, LoadOnly )
		
		if self.CloseAnim and self.CloseAnim > 0 then
			self.CloseTime = math.max(ReloadTime-0.75,ReloadTime*0.75)
		else
			self.CloseTime = ReloadTime
			self.CloseAnim = nil
		end
		
		self:ResetSequence( self.FireAnim )
		self:SetCycle( 0 )
		self.RateScale = self:SequenceDuration()
		if LoadOnly then
			self.Rate = 1000000
		else
			self.Rate = 1/math.Clamp(self.CloseTime,0.1,1.5)	--Base anim time is 1s, rate is in 1/10 of a second
		end
		self:SetPlaybackRate( self.Rate )
		self.LastFire = CurTime()
		self.Reload = ReloadTime
		
	end

	function ACFGunGUICreate( Table )
			
		acfmenupanel:CPanelText("Name", Table.name)
		
		acfmenupanel.CData.DisplayModel = vgui.Create( "DModelPanel", acfmenupanel.CustomDisplay )
			acfmenupanel.CData.DisplayModel:SetModel( Table.model )
			acfmenupanel.CData.DisplayModel:SetCamPos( Vector( 250, 500, 250 ) )
			acfmenupanel.CData.DisplayModel:SetLookAt( Vector( 0, 0, 0 ) )
			acfmenupanel.CData.DisplayModel:SetFOV( 20 )
			acfmenupanel.CData.DisplayModel:SetSize(acfmenupanel:GetWide(),acfmenupanel:GetWide())
			acfmenupanel.CData.DisplayModel.LayoutEntity = function( panel, entity ) end
		acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.DisplayModel )
		
		acfmenupanel:CPanelText("ClassDesc", list.Get("ACFClasses").GunClass[Table.gunclass].desc)	
		acfmenupanel:CPanelText("GunDesc", Table.desc)
		acfmenupanel:CPanelText("Caliber", "Caliber : "..(Table.caliber*10).."mm")
		acfmenupanel:CPanelText("Weight", "Weight : "..Table.weight.."kg")
		
		acfmenupanel.CustomDisplay:PerformLayout()
		
	end
	
	return
	
end

function ENT:Initialize()
		
	self.ReloadTime = 1
	self.Ready = true
	self.Firing = nil
	self.Reloading = nil
	self.CrateBonus = 1
	self.NextFire = 0
	self.LastSend = 0
	self.LastLoadDuration = 0
	self.Owner = self
	
	self.IsMaster = true
	self.AmmoLink = {}
	self.CurAmmo = 1
	self.Sequence = 1
	
	self.BulletData = {}
		self.BulletData.Type = "Empty"
		self.BulletData.PropMass = 0
		self.BulletData.ProjMass = 0
	
	self.Inaccuracy 	= 1
	
	self.Inputs = Wire_CreateInputs( self, { "Fire", "Unload", "Reload" } )
	self.Outputs = WireLib.CreateSpecialOutputs( self, { "Ready", "AmmoCount", "Entity", "Shots Left", "Fire Rate", "Muzzle Weight", "Muzzle Velocity" }, { "NORMAL", "NORMAL", "ENTITY", "NORMAL", "NORMAL", "NORMAL", "NORMAL" } )
	Wire_TriggerOutput(self, "Entity", self)

end  

function MakeACF_Gun(Owner, Pos, Angle, Id)

	if not Owner:CheckLimit("_acf_gun") then return false end
	
	local Gun = ents.Create("acf_gun")
	local List = list.Get("ACFEnts")
	local Classes = list.Get("ACFClasses")
	if not Gun:IsValid() then return false end
	Gun:SetAngles(Angle)
	Gun:SetPos(Pos)
	Gun:Spawn()
	
	local EID
	if List.Guns[Id] then EID = Id else EID = "50mmC" end
	local Lookup = List.Guns[EID]

	Gun:SetPlayer(Owner)
	Gun.Owner = Owner
	Gun.Id = Id
	Gun.Caliber	= Lookup.caliber
	Gun.Model = Lookup.model
	Gun.Mass = Lookup.weight
	Gun.Class = Lookup.gunclass
	-- Custom BS for karbine. Per Gun ROF.
	Gun.PGRoFmod = 1
	if(Lookup.rofmod) then
		Gun.PGRoFmod = math.max(0, Lookup.rofmod)
	end
	-- Custom BS for karbine. Magazine Size, Mag reload Time
	Gun.CurrentShot = 0
	Gun.MagSize = 1
	if(Lookup.magsize) then
		Gun.MagSize = math.max(Gun.MagSize, Lookup.magsize)
	else
		Gun.Inputs = Wire_AdjustInputs( Gun, { "Fire", "Unload" } )
	end
	Gun.MagReload = 0
	if(Lookup.magreload) then
		Gun.MagReload = math.max(Gun.MagReload, Lookup.magreload)
	end
	
	Gun:SetNetworkedString( "WireName", Lookup.name )
	Gun:SetNWString( "Class", Gun.Class )
	Gun:SetNWString( "ID", Gun.Id )
	Gun.Muzzleflash = Classes.GunClass[Gun.Class].muzzleflash
	Gun.RoFmod = Classes.GunClass[Gun.Class].rofmod
	Gun.Sound = Classes.GunClass[Gun.Class].sound
	Gun:SetNWString( "Sound", Gun.Sound )
	Gun.Inaccuracy = Classes.GunClass[Gun.Class].spread
	Gun:SetModel( Gun.Model )	
	
	Gun:PhysicsInit( SOLID_VPHYSICS )      	
	Gun:SetMoveType( MOVETYPE_VPHYSICS )     	
	Gun:SetSolid( SOLID_VPHYSICS )
	
	local Muzzle = Gun:GetAttachment( Gun:LookupAttachment( "muzzle" ) )
	Gun.Muzzle = Gun:WorldToLocal(Muzzle.Pos)
	
	/*local Height = 30		--Damn you Garry
	local Width = 30
	local length = 105
	local Scale = Gun.Caliber/30
	local VertexFile = file.Read(Gun.Class..".txt", "DATA")
	local PerVertex = string.Explode( "v", VertexFile )
	local Import = {}
	for Key, Value in pairs(PerVertex) do
		local Table = string.Explode( " ", Value )
		local Vec = Vector(tonumber(Table[2],10),tonumber(Table[4],10),tonumber(Table[3],10))
		if Vec != Vector(1,1,1) then
			table.insert(Import, Vertex( Vec*Scale,0,0 ) )
		end
	end
	PrintTable(Import)  
	Gun:SetNWFloat( "Scale", Scale )
	
	local p1 = Vector(length/-2*Scale,Width/-2*Scale,Height/-2*Scale)
	local p2 = Vector(length/-2*Scale,Width/2*Scale,Height/-2*Scale)
	local p3 = Vector(length/2*Scale,Width/2*Scale,Height/-2*Scale)
	local p4 = Vector(length/2*Scale,Width/-2*Scale,Height/-2*Scale)
	local p5 = Vector(length/-2*Scale,Width/-2*Scale,Height/2*Scale)
	local p6 = Vector(length/-2*Scale,Width/2*Scale,Height/2*Scale)
	local p7 = Vector(length/2*Scale,Width/2*Scale,Height/2*Scale)
	local p8 = Vector(length/2*Scale,Width/-2*Scale,Height/2*Scale)
	
	local Vertices = {}
	table.Add( Vertices, MeshQuad( p5, p6, p7, p8, 0 ) )
	table.Add( Vertices, MeshQuad( p4, p3, p2, p1, 0 ) )
	table.Add( Vertices, MeshQuad( p8, p7, p3, p4, 0 ) )
	table.Add( Vertices, MeshQuad( p6, p5, p1, p2, 0 ) )
	table.Add( Vertices, MeshQuad( p5, p8, p4, p1, 0 ) )
	table.Add( Vertices, MeshQuad( p7, p6, p2, p3, 0 ) )
	
	PrintTable(Vertices) 
	Gun:PhysicsFromMesh( Import )*/

	local phys = Gun:GetPhysicsObject()  	
	if IsValid( phys ) then
		phys:SetMass( Gun.Mass ) 
	end 
	
	Gun:UpdateOverlayText()
	
	Owner:AddCount("_acf_gun", Gun)
	Owner:AddCleanup( "acfmenu", Gun )
	
	ACF_Activate(Gun, 0)
	
	return Gun
	
end
list.Set( "ACFCvars", "acf_gun", {"id"} )
duplicator.RegisterEntityClass("acf_gun", MakeACF_Gun, "Pos", "Angle", "Id")

function ENT:UpdateOverlayText()
	
	local roundType = self.BulletData.Type
	
	if self.BulletData.Tracer and self.BulletData.Tracer > 0 then 
		roundType = roundType .. "-T"
	end
	
	local isEmpty = self.BulletData.Type == "Empty"
	
	local clipLeft = isEmpty and 0 or (self.MagSize - self.CurrentShot)
	local ammoLeft = (self.Ammo or 0) + clipLeft
	local isReloading = not isEmpty and CurTime() < self.NextFire and (self.MagSize == 1 or (self.LastLoadDuration > self.ReloadTime))
	local gunStatus = isReloading and "reloading" or (clipLeft .. " in gun")
	
	--print(self.MagSize or "nil", isEmpty, clipLeft, self.CurrentShot)
	
	--print(self.LastLoadDuration, self.ReloadTime, self.LastLoadDuration > self.ReloadTime, gunStatus)
	
	local text = roundType .. " - " .. ammoLeft .. (ammoLeft == 1 and " shot left" or " shots left ( " .. gunStatus .. " )")
	/*
	local RoundData = ACF.RoundTypes[ self.BulletData.Type ]
	
	if RoundData and RoundData.cratetxt then
		text = text .. "\n" .. RoundData.cratetxt( self.BulletData )
	end
	//*/
	text = text .. "\nRounds Per Minute: " .. math.Round( self.RateOfFire or 0, 2 )
	
	self:SetOverlayText( text )
	
end

function ENT:Link( Target )

	-- Don't link if it's not an ammo crate
	if not IsValid( Target ) or Target:GetClass() ~= "acf_ammo" then
		return false, "Guns can only be linked to ammo crates!"
	end
	
	-- Don't link if it's not the right ammo type
	if Target.BulletData.Id ~= self.Id then
		--if not (self.Class == "AL" and string.find(Target.BulletData.Id, "mmC", 1, true)) then --allows AL to load cannon ammo
			return false, "Wrong ammo type!"
		--end
	end
	
	-- Don't link if it's a refill crate
	if Target.RoundType == "Refill" then
		return false, "Refill crates cannot be linked!"
	end
	
	-- Don't link if it's a blacklisted round type for this gun
	local Blacklist = ACF.AmmoBlacklist[ Target.RoundType ] or {}
	
	if table.HasValue( Blacklist, self.Class ) then
		return false, "That round type cannot be used with this gun!"
	end
	
	-- Don't link if it's already linked
	for k, v in pairs( self.AmmoLink ) do
		if v == Target then
			return false, "That crate is already linked to this gun!"
		end
	end
	
	table.insert( self.AmmoLink, Target )
	table.insert( Target.Master, self )
	
	if self.BulletData.Type == "Empty" and Target.Load then
		self:UnloadAmmo()
	end
	
	self.ReloadTime = ( ( Target.BulletData.RoundVolume / 500 ) ^ 0.60 ) * self.RoFmod * self.PGRoFmod
	self.RateOfFire = 60 / self.ReloadTime
	Wire_TriggerOutput( self, "Fire Rate", self.RateOfFire )
	Wire_TriggerOutput( self, "Muzzle Weight", math.floor( Target.BulletData.ProjMass * 1000 ) )
	Wire_TriggerOutput( self, "Muzzle Velocity", math.floor( Target.BulletData.MuzzleVel * ACF.VelScale ) )

	return true, "Link successful!"
	
end

function ENT:Unlink( Target )

	local Success = false
	for Key,Value in pairs(self.AmmoLink) do
		if Value == Target then
			table.remove(self.AmmoLink,Key)
			Success = true
		end
	end
	
	if Success then
		return true, "Unlink successful!"
	else
		return false, "That entity is not linked to this gun!"
	end
	
end

local WireTable = { "gmod_wire_adv_pod", "gmod_wire_pod", "gmod_wire_keyboard", "gmod_wire_joystick", "gmod_wire_joystick_multi" }

function ENT:GetUser( inp )
	if not inp then return nil end
	if inp:GetClass() == "gmod_wire_adv_pod" then
		if inp.Pod then
			return inp.Pod:GetDriver()
		end
	elseif inp:GetClass() == "gmod_wire_pod" then
		if inp.Pod then
			return inp.Pod:GetDriver()
		end
	elseif inp:GetClass() == "gmod_wire_keyboard" then
		if inp.ply then
			return inp.ply 
		end
	elseif inp:GetClass() == "gmod_wire_joystick" then
		if inp.Pod then 
			return inp.Pod:GetDriver()
		end
	elseif inp:GetClass() == "gmod_wire_joystick_multi" then
		if inp.Pod then 
			return inp.Pod:GetDriver()
		end
	elseif inp:GetClass() == "gmod_wire_expression2" then
		if inp.Inputs.Fire then
			return self:GetUser(inp.Inputs.Fire.Src) 
		elseif inp.Inputs.Shoot then
			return self:GetUser(inp.Inputs.Shoot.Src) 
		elseif inp.Inputs then
			for _,v in pairs(inp.Inputs) do
				if v.Src then
					if table.HasValue(WireTable, v.Src:GetClass()) then
						return self:GetUser(v.Src) 
					end
				end
			end
		end
	end
	return inp.Owner or inp:GetOwner()
	
end

function ENT:TriggerInput( iname, value )
	
	if (iname == "Unload" and value > 0) then
		self:UnloadAmmo()
	elseif ( iname == "Fire" and value > 0 and ACF.GunfireEnabled ) then
		if self.NextFire < CurTime() then
			self.User = self:GetUser(self.Inputs.Fire.Src) or self.Owner
			if not IsValid(self.User) then self.User = self.Owner end
			self:FireShell()
			self:Think()
		end
		self.Firing = true
	elseif ( iname == "Fire" and value <= 0 ) then
		self.Firing = false
	elseif ( iname == "Reload" and value ~= 0 ) then
		self.Reloading = true
	end		
end

local function RetDist( enta, entb )
	if not ((enta and enta:IsValid()) or (entb and entb:IsValid())) then return 0 end
	disp = enta:GetPos() - entb:GetPos()
	dist = math.sqrt( disp.x * disp.x + disp.y * disp.y + disp.z * disp.z )
	return dist
end

function ENT:Think()

	local Time = CurTime()
	if self.LastSend+1 <= Time then
		local Ammo = 0
		local CrateBonus = {}
		local rofbonus = 0
		local totalcap = 0
		
		for Key, Crate in pairs(self.AmmoLink) do
			if IsValid( Crate ) and Crate.Load then
				if RetDist( self, Crate ) < 512 then
					Ammo = Ammo + (Crate.Ammo or 0)
					CrateBonus[Crate.RoFMul] = (CrateBonus[Crate.RoFMul] or 0) + Crate.Capacity
					totalcap = totalcap + Crate.Capacity
				else
					self:Unlink( Crate )
					soundstr =  "physics/metal/metal_box_impact_bullet" .. tostring(math.random(1, 3)) .. ".wav"
					self:EmitSound(soundstr,500,100)
				end
			end
		end
		
		for mul, cap in pairs(CrateBonus) do
			rofbonus = rofbonus + (cap/totalcap)*mul 
		end

		self.CrateBonus = rofbonus or 1
		self.Ammo = Ammo
		self:UpdateOverlayText()
		
		Wire_TriggerOutput(self, "AmmoCount", Ammo)
		
		
		if( self.MagSize ) then
			Wire_TriggerOutput(self, "Shots Left", self.MagSize - self.CurrentShot)
		else
			Wire_TriggerOutput(self, "Shots Left", 1)
		end
		
		self:SetNetworkedBeamString("GunType",self.Id)
		self:SetNetworkedBeamInt("Ammo",Ammo)
		self:SetNetworkedBeamString("Type",self.BulletData.Type)
		self:SetNetworkedBeamInt("Mass",self.BulletData.ProjMass*100)
		self:SetNetworkedBeamInt("Propellant",self.BulletData.PropMass*1000)
		self:SetNetworkedBeamInt("FireRate",self.RateOfFire)
		
		self.LastSend = Time
	
	end
	
	if self.NextFire <= Time then
		self.Ready = true
		Wire_TriggerOutput(self, "Ready", 1)
		
		if self.MagSize and self.MagSize == 1 then
			self.CurrentShot = 0
		end
		
		if self.Firing then
			self:FireShell()	
		elseif self.Reloading then
			self:ReloadMag()
			self.Reloading = false
		end
	end

	self:NextThink(Time)
	return true
	
end

function ENT:CheckWeight()
	local mass = self:GetPhysicsObject():GetMass()
	local maxmass = GetConVarNumber("bnk_maxweight") * 1000 + 999
	
	local chk = false
	
	local allents = constraint.GetAllConstrainedEntities( self )
	for _, ent in pairs(allents) do
		if (ent and ent:IsValid() and not ent:IsPlayer() and not (ent == self)) then
			local phys = ent:GetPhysicsObject()
			if(phys:IsValid()) then
				mass = mass + phys:GetMass()
			end
		end
	end
	
	if( mass < maxmass ) then
		chk = true
	end
	
	return chk
end

function ENT:ReloadMag()
	if(self.IsUnderWeight == nil) then
		self.IsUnderWeight = true
		if(ISBNK) then
			self.IsUnderWeight = self:CheckWeight()
		end
	end
	if ( (self.CurrentShot > 0) and self.IsUnderWeight and self.Ready and self:GetPhysicsObject():GetMass() >= self.Mass and not self:GetParent():IsValid() ) then
		if ( ACF.RoundTypes[self.BulletData.Type] ) then		--Check if the roundtype loaded actually exists
			self:LoadAmmo(self.MagReload, false)	
			self:EmitSound("weapons/357/357_reload4.wav",500,100)
			self.CurrentShot = 0
			Wire_TriggerOutput(self, "Ready", 0)
		else
			self.CurrentShot = 0
			self.Ready = false
			Wire_TriggerOutput(self, "Ready", 0)
			self:LoadAmmo(false, true)	
		end
	end
end



function ENT:GetInaccuracy()
	local SpreadScale = ACF.SpreadScale
	local IaccMult = 1
	
	if (self.ACF.Health and self.ACF.MaxHealth) then
		IaccMult = math.Clamp(((1 - SpreadScale) / (0.5)) * ((self.ACF.Health/self.ACF.MaxHealth) - 1) + 1, 1, SpreadScale)
	end
	
	local coneAng = self.Inaccuracy * ACF.GunInaccuracyScale * IaccMult
	
	return coneAng
end



function ENT:FireShell()
	
	local CanDo = hook.Run("ACF_FireShell", self, self.BulletData )
	if CanDo == false then return end
	if(self.IsUnderWeight == nil) then
		self.IsUnderWeight = true
		if(ISBNK) then
			self.IsUnderWeight = self:CheckWeight()
		end
	end
	
	local bool = true
	if(ISSITP) then
		if(self.sitp_spacetype != "space" and self.sitp_spacetype != "planet") then
			bool = false
		end
		if(self.sitp_core == false) then
			bool = false
		end
	end
	if ( bool and self.IsUnderWeight and self.Ready and self:GetPhysicsObject():GetMass() >= self.Mass and not self:GetParent():IsValid() ) then
		Blacklist = {}
		if not ACF.AmmoBlacklist[self.BulletData.Type] then
			Blacklist = {}
		else
			Blacklist = ACF.AmmoBlacklist[self.BulletData.Type]	
		end
		if ( ACF.RoundTypes[self.BulletData.Type] and !table.HasValue( Blacklist, self.Class ) ) then		--Check if the roundtype loaded actually exists
		
			local MuzzlePos = self:LocalToWorld(self.Muzzle)
			local MuzzleVec = self:GetForward()
			
			local coneAng = math.tan(math.rad(self:GetInaccuracy())) 
			local randUnitSquare = (self:GetUp() * (2 * math.random() - 1) + self:GetRight() * (2 * math.random() - 1))
			local spread = randUnitSquare:GetNormalized() * coneAng * (math.random() ^ (1 / math.Clamp(ACF.GunInaccuracyBias, 0.5, 4)))
			local ShootVec = (MuzzleVec + spread):GetNormalized()
			
			self:MuzzleEffect( MuzzlePos, MuzzleVec )
			
			self.BulletData.Pos = MuzzlePos
			self.BulletData.Flight = ShootVec * self.BulletData.MuzzleVel * 39.37 + self:GetVelocity()
			self.BulletData.Owner = self.User
			self.BulletData.Gun = self
			self.CreateShell = ACF.RoundTypes[self.BulletData.Type].create
			self:CreateShell( self.BulletData )
		
			local Gun = self:GetPhysicsObject()  	
			if (Gun:IsValid()) then 	
				if(!self.acflastupdatemass) or (self.acflastupdatemass < (CurTime() + 10)) then
					ACF_CalcMassRatio( self )
				end
				local pushscale = GetConVarNumber("acf_recoilpush") or 1
				local physratio = 1 * pushscale
				if(self.acfphystotal) and (self.acftotal) then
					physratio = self.acfphystotal / self.acftotal
				end
				Gun:ApplyForceCenter( self:GetForward() * -(self.BulletData.ProjMass * self.BulletData.MuzzleVel * 39.37 + self.BulletData.PropMass * 3000 * 39.37) * physratio)			
			end
			
			self.Ready = false
			self.CurrentShot = math.min(self.CurrentShot + 1, self.MagSize)
			if((self.CurrentShot >= self.MagSize) and (self.MagSize > 1)) then
				self:LoadAmmo(self.MagReload, false)	
				self:EmitSound("weapons/357/357_reload4.wav",500,100)
				self.CurrentShot = 0
			else
				self:LoadAmmo(false, false)	
			end
			Wire_TriggerOutput(self, "Ready", 0)
		else
			self.CurrentShot = 0
			self.Ready = false
			Wire_TriggerOutput(self, "Ready", 0)
			self:LoadAmmo(false, true)	
		end
	end
	
end

function ENT:CreateShell()
	--You overwrite this with your own function, defined in the ammo definition file
end

function ENT:FindNextCrate()

	local MaxAmmo = table.getn(self.AmmoLink)
	local AmmoEnt = nil
	local i = 0
	
	while i <= MaxAmmo and not (AmmoEnt and AmmoEnt:IsValid() and AmmoEnt.Ammo > 0) do
		
		self.CurAmmo = self.CurAmmo + 1
		if self.CurAmmo > MaxAmmo then self.CurAmmo = 1 end
		
		AmmoEnt = self.AmmoLink[self.CurAmmo]
		if AmmoEnt and AmmoEnt:IsValid() and AmmoEnt.Ammo > 0 and AmmoEnt.Load then
			return AmmoEnt
		end
		AmmoEnt = nil
		
		i = i + 1
	end
	
	return false
end

function ENT:LoadAmmo( AddTime, Reload )

	local AmmoEnt = self:FindNextCrate()
	local curTime = CurTime()
	
	if AmmoEnt then
		AmmoEnt.Ammo = AmmoEnt.Ammo - 1
		self.BulletData = AmmoEnt.BulletData
		self.BulletData.Crate = AmmoEnt:EntIndex()
		
		self.ReloadTime = ((self.BulletData.RoundVolume/500)^0.60)*self.RoFmod*self.PGRoFmod * (self.MagReload == 0 and self.CrateBonus or 1)
		Wire_TriggerOutput(self, "Loaded", self.BulletData.Type)
		
		self.RateOfFire = (60/self.ReloadTime)
		Wire_TriggerOutput(self, "Fire Rate", self.RateOfFire)
		Wire_TriggerOutput(self, "Muzzle Weight", math.floor(self.BulletData.ProjMass*1000) )
		Wire_TriggerOutput(self, "Muzzle Velocity", math.floor(self.BulletData.MuzzleVel*ACF.VelScale) )
		
		self.NextFire = curTime + self.ReloadTime
		local reloadTime = self.ReloadTime
		
		if AddTime then
			reloadTime = reloadTime + AddTime * self.CrateBonus
		end
		if Reload then
			self:ReloadEffect()
		end
		
		self.NextFire = curTime + reloadTime
		self.LastLoadDuration = reloadTime
		
		self:Think()
		return true	
	else
		self.BulletData = {}
			self.BulletData.Type = "Empty"
			self.BulletData.PropMass = 0
			self.BulletData.ProjMass = 0
		
		self:EmitSound("weapons/pistol/pistol_empty.wav",500,100)
		Wire_TriggerOutput(self, "Loaded", "Empty")
				
		self.NextFire = curTime + 0.5
		self:Think()
	end
	return false
	
end

function ENT:UnloadAmmo()
	if not self.BulletData or not self.BulletData.Crate then return end -- Explanation: http://www.youtube.com/watch?v=dwjrui9oCVQ
	local Crate = Entity( self.BulletData.Crate )
	if Crate and Crate:IsValid() and self.BulletData.Type == Crate.BulletData.Type then
		Crate.Ammo = Crate.Ammo+1
	end
	
	self.Ready = false
	Wire_TriggerOutput(self, "Ready", 0)
	self:LoadAmmo( math.min(self.ReloadTime,math.max(self.ReloadTime - (self.NextFire - CurTime()),0) )	, true )
	self:EmitSound("weapons/357/357_reload4.wav",500,100)

end

function ENT:MuzzleEffect()
	
	local Effect = EffectData()
		Effect:SetEntity( self )
		Effect:SetScale( self.BulletData.PropMass )
		Effect:SetMagnitude( self.ReloadTime )
		Effect:SetSurfaceProp( ACF.RoundTypes[self.BulletData.Type].netid  )	--Encoding the ammo type into a table index
	util.Effect( "ACF_MuzzleFlash", Effect, true, true )

end

function ENT:ReloadEffect()

	local Effect = EffectData()
		Effect:SetEntity( self )
		Effect:SetScale( 0 )
		Effect:SetMagnitude( self.ReloadTime )
		Effect:SetSurfaceProp( ACF.RoundTypes[self.BulletData.Type].netid  )	--Encoding the ammo type into a table index
	util.Effect( "ACF_MuzzleFlash", Effect, true, true )
	
end

function ENT:PreEntityCopy()

	local info = {}
	local entids = {}
	for Key, Value in pairs(self.AmmoLink) do					--First clean the table of any invalid entities
		if not Value:IsValid() then
			table.remove(self.AmmoLink, Value)
		end
	end
	for Key, Value in pairs(self.AmmoLink) do					--Then save it
		table.insert(entids, Value:EntIndex())
	end
	info.entities = entids
	if info.entities then
		duplicator.StoreEntityModifier( self, "ACFAmmoLink", info )
	end
	
	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
	
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )

	if (Ent.EntityMods) and (Ent.EntityMods.ACFAmmoLink) and (Ent.EntityMods.ACFAmmoLink.entities) then
		local AmmoLink = Ent.EntityMods.ACFAmmoLink
		if AmmoLink.entities and table.Count(AmmoLink.entities) > 0 then
			for _,AmmoID in pairs(AmmoLink.entities) do
				local Ammo = CreatedEntities[ AmmoID ]
				if Ammo and Ammo:IsValid() and Ammo:GetClass() == "acf_ammo" then
					self:Link( Ammo )
				end
			end
		end
		Ent.EntityMods.ACFAmmoLink = nil
	end
	
	//Wire dupe info
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )

end
