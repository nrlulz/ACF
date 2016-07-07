ACF.BulletEffect = {}

function ACF_ManageBulletEffects()
	
	for _,Bullet in pairs(ACF.BulletEffect) do
		ACF_SimBulletFlight( Bullet )			--This is the bullet entry in the table, the omnipresent Index var refers to this
	end
	
end
hook.Add("Think", "ACF_ManageBulletEffects", ACF_ManageBulletEffects)

function ACF_SimBulletFlight( Bullet )

	local Time = CurTime()
	local DeltaTime = Time - Bullet.LastThink
	
	local Drag = Bullet.SimFlight:GetNormalized() * (Bullet.DragCoef * Bullet.SimFlight:Length()^2)/ACF.DragDiv
	--print(Drag)

	Bullet.SimPos = Bullet.SimPos + (Bullet.SimFlight * ACF.VelScale * DeltaTime)		--Calculates the next shell position
	Bullet.SimFlight = Bullet.SimFlight + (Bullet.Accel - Drag)*DeltaTime			--Calculates the next shell vector
	
	if Bullet and IsValid(Bullet.Effect) then
		Bullet.Effect:ApplyMovement( Bullet )
	end

	Bullet.LastThink = Time
end
