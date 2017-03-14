   
function EFFECT:Init( data )

	self.Index = data:GetAttachment()
	self:SetModel("models/munitions/round_100mm_shot.mdl") 
	if not ( self.Index ) then 
		--self:Remove()
		self.Alive = false
		return 
	end
	self.CreateTime = ACF.CurTime
	
	local Hit = data:GetScale()
	local Bullet = ACF.BulletEffect[self.Index]
	
	if (Hit > 0 and Bullet) then	--Scale encodes the hit type, so if it's 0 it's a new bullet, else it's an update so we need to remove the effect
	
		--print("Updating Bullet Effect")
		Bullet.SimFlight = data:GetStart()*10		--Updating old effect with new values
		Bullet.SimPos = data:GetOrigin()
		
		if (Hit == 1) then		--Bullet has reached end of flight, remove old effect
			
			self.HitEnd = ACF.RoundTypes[Bullet.AmmoType]["endeffect"]
			self:HitEnd( Bullet )
			ACF.BulletEffect[self.Index] = nil			--This is crucial, to effectively remove the bullet flight model from the client
			
		elseif (Hit == 2) then		--Bullet penetrated, don't remove old effect
	
			self.HitPierce = ACF.RoundTypes[Bullet.AmmoType]["pierceeffect"]
			self:HitPierce( Bullet )
			
		elseif (Hit == 3) then		--Bullet ricocheted, don't remove old effect
			
			self.HitRicochet = ACF.RoundTypes[Bullet.AmmoType]["ricocheteffect"]
			self:HitRicochet( Bullet )
			
		end	
		ACF_SimBulletFlight( Bullet, self.Index )
		--self:Remove()	--This effect updated the old one, so it removes itself now	
		if IsValid(Bullet.Tracer) then Bullet.Tracer:Finish() end
		self.Alive = false
	
	else
		--print("Creating Bullet Effect")
		local BulletData = {}
		BulletData.Crate = data:GetEntity()
		--TODO: Check if it is actually a crate
		if not IsValid(BulletData.Crate) then
			--self:Remove()
			self.Alive = false
			return
		end
		BulletData.SimFlight = data:GetStart()*10
		BulletData.SimPos = data:GetOrigin()
		BulletData.SimPosLast = BulletData.SimPos
		BulletData.Caliber = BulletData.Crate:GetNWFloat( "Caliber", 10 )
		BulletData.RoundMass = BulletData.Crate:GetNWFloat( "ProjMass", 10 )
		BulletData.FillerMass = BulletData.Crate:GetNWFloat( "FillerMass" )
		BulletData.WPMass = BulletData.Crate:GetNWFloat( "WPMass" )
		BulletData.DragCoef = BulletData.Crate:GetNWFloat( "DragCoef", 1 )
		BulletData.AmmoType = BulletData.Crate:GetNWString( "AmmoType", "AP" )
		
		if BulletData.Crate:GetNWFloat( "Tracer" ) > 0 then
			BulletData.Tracer = ParticleEmitter( BulletData.SimPos )
			BulletData.TracerColour = BulletData.Crate:GetNWVector( "TracerColour", BulletData.Crate:GetColor() ) or Vector(255,255,255)
		end
		
		
		BulletData.Accel = BulletData.Crate:GetNWVector( "Accel", Vector(0,0,-600))
		
		BulletData.LastThink = CurTime() --ACF.CurTime
		BulletData.Effect = self.Entity
		
		ACF.BulletEffect[self.Index] = BulletData		--Add all that data to the bullet table, overwriting if needed
		
		self:SetPos( BulletData.SimPos )									--Moving the effect to the calculated position
		self:SetAngles( BulletData.SimFlight:Angle() )
		self.Alive = true
		
		ACF_SimBulletFlight( ACF.BulletEffect[self.Index], self.Index )
		
	end
	
end

function EFFECT:HitEnd()
	--You overwrite this with your own function, defined in the ammo definition file
	ACF.BulletEffect[self.Index] = nil			--Failsafe
end

function EFFECT:HitPierce()
	--You overwrite this with your own function, defined in the ammo definition file
	ACF.BulletEffect[self.Index] = nil			--Failsafe
end

function EFFECT:HitRicochet()
	--You overwrite this with your own function, defined in the ammo definition file
	ACF.BulletEffect[self.Index] = nil			--Failsafe
end

function EFFECT:Think()

	local Bullet = ACF.BulletEffect[self.Index]
	
	if self.Alive and Bullet and self.CreateTime > ACF.CurTime-30 then
		return true
	end
	
	--self:Remove()
	if Bullet and IsValid(Bullet.Tracer) then Bullet.Tracer:Finish() end
	return false

end 

function EFFECT:ApplyMovement( Bullet )

	local setPos = Bullet.SimPos
	if((math.abs(setPos.x) > 16380) or (math.abs(setPos.y) > 16380) or (setPos.z < -16380)) then
		--self:Remove()
		if IsValid(Bullet.Tracer) then Bullet.Tracer:Finish() end
		self.Alive = false
		return
	end
	if( setPos.z < 16380 ) then
		self:SetPos( setPos )--Moving the effect to the calculated position
		self:SetAngles( Bullet.SimFlight:Angle() )
	end

	if Bullet.Tracer then
		local DeltaTime = ACF.CurTime - Bullet.LastThink
		--local DeltaPos = Bullet.SimFlight*DeltaTime
		local DeltaPos = Bullet.SimPos - Bullet.SimPosLast
		local Length =  math.max(DeltaPos:Length()*2,1)
		local MaxSprites = 2 --math.min(math.floor(math.max(Bullet.Caliber/5,1)*1.333)+1,5)
		local Light = Bullet.Tracer:Add( "sprites/acf_tracer.vmt", setPos)-- - DeltaPos )
		if (Light) then
			Light:SetAngles( Bullet.SimFlight:Angle() )
			Light:SetVelocity( Bullet.SimFlight:GetNormalized() ) --Vector() ) --Bullet.SimFlight )
			Light:SetColor( Bullet.TracerColour.x, Bullet.TracerColour.y, Bullet.TracerColour.z )
			Light:SetDieTime( math.Clamp(ACF.CurTime-self.CreateTime,0.075,0.15) ) -- 0.075, 0.1
			Light:SetStartAlpha( 255 )
			Light:SetEndAlpha( 155 )
			Light:SetStartSize( 15*Bullet.Caliber ) -- 5
			Light:SetEndSize( 1 ) --15*Bullet.Caliber
			Light:SetStartLength( Length )
			Light:SetEndLength( 1 ) --Length
		end
		for i=1, MaxSprites do
			local Smoke = Bullet.Tracer:Add( "particle/smokesprites_000"..math.random(1,9), setPos - (DeltaPos*i/MaxSprites) )
			if (Smoke) then		
				Smoke:SetAngles( Bullet.SimFlight:Angle() )
				Smoke:SetVelocity( Bullet.SimFlight*0.05 )
				Smoke:SetColor( 200 , 200 , 200 )
				Smoke:SetDieTime( 0.6 ) -- 1.2
				Smoke:SetStartAlpha( 10 )
				Smoke:SetEndAlpha( 0 )
				Smoke:SetStartSize( 1 )
				Smoke:SetEndSize( Length/400*Bullet.Caliber )
				Smoke:SetRollDelta( 0.1 )
				Smoke:SetAirResistance( 150 )
				Smoke:SetGravity( Vector(0,0,20) )
				--Smoke:SetCollide( 0 )
				--Smoke:SetLighting( 0 )
			end
		end
	end
end

--[[
function EFFECT:HitEffect( HitPos, Energy, EffectType )	--EffectType key : 1 = Round stopped, 2 = Round penetration

	if (EffectType > 0) then
		local BulletEffect = {}
			BulletEffect.Num = 1
			BulletEffect.Src = HitPos - self.SimFlight:GetNormalized()*20
			BulletEffect.Dir = self.SimFlight
			BulletEffect.Spread = Vector(0,0,0)
			BulletEffect.Tracer = 0
			BulletEffect.Force = 0
			BulletEffect.Damage = 0	 
		self.Entity:FireBullets(BulletEffect) 
	end
	if (EffectType == 2) then
		local Spall = EffectData()
			Spall:SetOrigin( HitPos )
			Spall:SetNormal( (self.SimFlight):GetNormalized() )
			Spall:SetScale( math.max(Energy/5000,1) )
		util.Effect( "AP_Hit", Spall )
	elseif (EffectType == 3) then
		local Sparks = EffectData()
			Sparks:SetOrigin( HitPos )
			Sparks:SetNormal( (self.SimFlight):GetNormalized() )
		util.Effect( "ManhackSparks", Sparks )
	end	

end
--]]

function EFFECT:Render()  

	local Bullet = ACF.BulletEffect[self.Index]
	
	if (Bullet) then
		self.Entity:SetModelScale( Bullet.Caliber/10 , 0 )
		self.Entity:DrawModel()       // Draw the model. 
	end
	
end 
