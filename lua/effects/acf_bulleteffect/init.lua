   
function EFFECT:Init( data )

	self.Index = data:GetAttachment()
	self:SetModel("models/munitions/round_100mm_shot.mdl") 
	
	if not ( self.Index ) then 
		Msg("ACF_BulletEffect: Error! Insufficient data to spawn.\n")
		self:Remove() 
		return 
	end
	self.CreateTime = CurTime()
	
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
		self:Remove()	--This effect updated the old one, so it removes itself now	
	
	else
		--print("Creating Bullet Effect")
		local BulletData = {}
		BulletData.Crate = Entity(math.Round(data:GetMagnitude()))
		BulletData.SimFlight = data:GetStart()*10
		BulletData.SimPos = data:GetOrigin()
		BulletData.Caliber = BulletData.Crate:GetNetworkedInt( "Caliber" ) or 10
		BulletData.RoundMass = BulletData.Crate:GetNetworkedInt( "ProjMass" ) or 10
		BulletData.FillerMass = BulletData.Crate:GetNetworkedInt( "FillerMass" ) or 0
		BulletData.DragCoef = BulletData.Crate:GetNetworkedInt( "DragCoef" ) or 1
		BulletData.AmmoType = BulletData.Crate:GetNetworkedString( "AmmoType" )
		if BulletData.AmmoType == "" then BulletData.AmmoType = "AP" end
		
		if BulletData.Crate:GetNetworkedInt( "Tracer" ) > 0 then
			BulletData.Tracer = ParticleEmitter( BulletData.SimPos )
			local vec, col = BulletData.Crate:GetNetworkedVector( "Color" ), BulletData.Crate:GetColor()
			if vec then
				if vec ~= Vector( 0, 0, 0) then
					col = Color( vec.x, vec.y, vec.z )
				end
			end
			BulletData.TracerColour = Vector(col.r,col.g,col.b)

		end
		
		
		BulletData.Accel = BulletData.Crate:GetNetworkedVector( "Accel" ) or Vector(0,0,600*-1)
		
		BulletData.LastThink = CurTime()
		BulletData.Effect = self.Entity
		
		ACF.BulletEffect[self.Index] = BulletData		--Add all that data to the bullet table, overwriting if needed
		
		self:SetPos( BulletData.SimPos )									--Moving the effect to the calculated position
		self:SetAngles( BulletData.SimFlight:Angle() )
		
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
	if Bullet and self.CreateTime > CurTime()-30 then
		return true
	else
		self:Remove()
		return false
	end
	
end 

function EFFECT:ApplyMovement( Bullet )

	self:SetPos( Bullet.SimPos )									--Moving the effect to the calculated position
	self:SetAngles( Bullet.SimFlight:Angle() )
	
	if Bullet.Tracer then
		local DeltaTime = CurTime() - Bullet.LastThink
		local DeltaPos = Bullet.SimFlight*DeltaTime
		local Length =  math.max(DeltaPos:Length()*2,1)
		for i=1, 1 do
			--local Light = Bullet.Tracer:Add( "sprites/light_glow02_add.vmt", Bullet.SimPos - (DeltaPos*i/5) )
			local Light = Bullet.Tracer:Add( "sprites/acf_tracer.vmt", Bullet.SimPos - (DeltaPos*i/5) )
			if (Light) then		
				Light:SetAngles( Bullet.SimFlight:Angle() )
				Light:SetVelocity( Bullet.SimFlight:GetNormalized() )
				Light:SetColor( Bullet.TracerColour.x, Bullet.TracerColour.y, Bullet.TracerColour.z )
				Light:SetDieTime( 0.075 ) -- 0.1
				Light:SetStartAlpha( 255 )
				Light:SetEndAlpha( 155 )
				Light:SetStartSize( 15*Bullet.Caliber ) -- 5
				Light:SetEndSize( 1 )
				Light:SetStartLength( Length )
				Light:SetEndLength( 1 )
			end
			local Smoke = Bullet.Tracer:Add( "particle/smokesprites_000"..math.random(1,9), Bullet.SimPos - (DeltaPos*i/5) )
			if (Smoke) then		
				Smoke:SetAngles( Bullet.SimFlight:Angle() )
				--Smoke:SetVelocity( Vector(0,0,0) )
				Smoke:SetColor( 200 , 200 , 200 )
				Smoke:SetDieTime( 0.6 ) -- 1.2
				Smoke:SetStartAlpha( 10 )
				Smoke:SetEndAlpha( 0 )
				Smoke:SetStartSize( 1 )
				Smoke:SetEndSize( Length/400*Bullet.Caliber )
				Smoke:SetRollDelta( 0.1 )
				Smoke:SetAirResistance( 100 )
				--Smoke:SetGravity( VectorRand()*5 )
				--Smoke:SetCollide( 0 )
				--Smoke:SetLighting( 0 )
			end
		end
	end

end

-- function EFFECT:HitEffect( HitPos, Energy, EffectType )	--EffectType key : 1 = Round stopped, 2 = Round penetration

	-- if (EffectType > 0) then
		-- local BulletEffect = {}
			-- BulletEffect.Num = 1
			-- BulletEffect.Src = HitPos - self.SimFlight:GetNormalized()*20
			-- BulletEffect.Dir = self.SimFlight
			-- BulletEffect.Spread = Vector(0,0,0)
			-- BulletEffect.Tracer = 0
			-- BulletEffect.Force = 0
			-- BulletEffect.Damage = 0	 
		-- self.Entity:FireBullets(BulletEffect) 
	-- end
	-- if (EffectType == 2) then
		-- local Spall = EffectData()
			-- Spall:SetOrigin( HitPos )
			-- Spall:SetNormal( (self.SimFlight):GetNormalized() )
			-- Spall:SetScale( math.max(Energy/5000,1) )
		-- util.Effect( "AP_Hit", Spall )
	-- elseif (EffectType == 3) then
		-- local Sparks = EffectData()
			-- Sparks:SetOrigin( HitPos )
			-- Sparks:SetNormal( (self.SimFlight):GetNormalized() )
		-- util.Effect( "ManhackSparks", Sparks )
	-- end	

-- end

function EFFECT:Render()  

	local Bullet = ACF.BulletEffect[self.Index]
	
	if (Bullet) then
		self.Entity:SetModelScale( Bullet.Caliber/10 , 0 )
		self.Entity:DrawModel()       // Draw the model. 
	end
	
end 