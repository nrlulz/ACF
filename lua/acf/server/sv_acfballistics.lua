ACF.Bullet = {}
ACF.CurBulletIndex = 0
ACF.BulletIndexLimit = 1000
local IndexLimit = ACF.BulletIndexLimit
local Bullets = ACF.Bullet
local FlightTr = {}
	FlightTr.mask  = MASK_SHOT

local util_TraceLine = util.TraceLine
local math_Random = math.random
local util_IsInWorld = util.IsInWorld
local util_Effect = util.Effect
--local hook_Run = hook.Run, 109
local table_Copy = table.Copy
local math_Round = math.Round

function ACF_CreateBullet( BulletData )
	ACF.CurBulletIndex = ACF.CurBulletIndex + 1 > IndexLimit and 1 or ACF.CurBulletIndex + 1
	local Index = ACF.CurBulletIndex
	
	BulletData["Accel"]         = Vector(0, 0, GetConVar("sv_gravity"):GetInt()*-1)			--Those are BulletData settings that are global and shouldn't change round to round
	BulletData["LastThink"]     = SysTime()
	BulletData["InitTime"]      = BulletData["FuseLength"] and SysTime() or nil
	BulletData["Filter"]        = { BulletData["Gun"] }
	--BulletData["Index"]         = Index

	if IsValid(BulletData["Gun"]) then
		local Gun = BulletData["Gun"]
		if Gun.sitp_inspace then
			BulletData["Accel"] = Vector(0, 0, 0)
			BulletData["DragCoef"] = 0
		end

		BulletData["Pos"] = BulletData["Pos"] + ACF_GetAncestor(Gun):GetVelocity() * engine.TickInterval() * 1.1 -- Predicting where we'll be next tick so we dont shoot ourselves
	end
		
	Bullets[Index] = table_Copy(BulletData)		--Place the bullet at the current index pos
	ACF_BulletClient( Index, Bullets[Index], "Init", 0 )
	ACF_CalcBulletFlight( Index, Bullets[Index] )
end


function ACF_ManageBullets()
	for Index, Bullet in pairs(Bullets) do
		--if not Bullet.HandlesOwnIteration then
			ACF_CalcBulletFlight( Index, Bullet )			--This is the bullet entry in the table, the Index var omnipresent refers to this
		--end
	end
end
hook.Add("Tick", "ACF_ManageBullets", ACF_ManageBullets)


function ACF_RemoveBullet( Index )
	local Bullet = Bullets[Index]
	
	Bullets[Index] = nil
	
	if Bullet and Bullet.OnRemoved then Bullet:OnRemoved() end
end


function ACF_CheckClips(Ent, HitPos )
	if not Ent.ClipData or Ent:GetClass() ~= "prop_physics" then return false end
	
	for i = 1, #Ent.ClipData do
		local N = Ent.ClipData[i]["n"]
		if Ent:LocalToWorldAngles(N):Forward():Dot((Ent:LocalToWorld(N:Forward() * Ent.ClipData[i]["d"]) - HitPos):GetNormalized()) > 0 then return true end
	end
	
	return false
end


function ACF_Trace()
	local TraceRes = util_TraceLine(FlightTr)
	
	if TraceRes.Hit and IsValid(TraceRes.Entity) and ( not ACF_Check(TraceRes.Entity) or ACF_CheckClips(TraceRes.Entity, TraceRes.HitPos) ) then
		FlightTr.filter[#FlightTr.filter + 1] = TraceRes.Entity
		
		return ACF_Trace(FlightTr)
	end
	
	return TraceRes
end

function ACF_CalcBulletFlight( Index, Bullet, Override)
	// perf concern: none of the ACF devs know how to code
	if Bullet.PreCalcFlight then Bullet:PreCalcFlight() end
	
	if not Bullet.LastThink then 
		ACF_RemoveBullet( Index ) 
	else
		local Time = SysTime()
		local DeltaTime = Time - Bullet.LastThink
		
		local Drag = Bullet.Flight:GetNormalized() * Bullet.DragCoef * Bullet.Flight:LengthSqr() / ACF.DragDiv
		Bullet.NextPos = Bullet.Pos + Bullet.Flight * ACF.VelScale * DeltaTime		--Calculates the next shell position
		Bullet.Flight = Bullet.Flight + (Bullet.Accel - Drag) * DeltaTime				--Calculates the next shell vector
		Bullet.LastThink = Time
		
		ACF_DoBulletsFlight( Index, Bullet )
	end
	
	
	// perf concern: use direct function call stored on bullet over hook system.
	if Bullet.PostCalcFlight then Bullet:PostCalcFlight() end
end

function ACF_DoBulletsFlight( Index, Bullet)
	--if hook_Run("ACF_BulletsFlight", Index, Bullet ) == false then return end
	
	if Bullet.FuseLength and CurTime() - Bullet.InitTime > Bullet.FuseLength then
		if not util_IsInWorld(Bullet.Pos) then
			ACF_RemoveBullet( Index )
		else
			Bullet.Pos = LerpVector(math_Random(), Bullet.Pos, Bullet.NextPos)

			if Bullet.OnEndFlight then Bullet.OnEndFlight(Index, Bullet, FlightRes) end
			
			ACF_BulletClient( Index, Bullet, "Update" , 1 , Bullet.Pos  )
			ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
			ACF_BulletEndFlight( Index, Bullet, Bullet.Pos, Bullet.Flight:GetNormalized() )	
		end
	end
	
	if Bullet.SkyLvL then
		if CurTime() - Bullet.LifeTime > 30 then			 -- We don't want to calculate bullets that will never come back to map.
			ACF_RemoveBullet( Index )
			
			return
		elseif Bullet.NextPos.z > Bullet.SkyLvL then 
			Bullet.Pos = Bullet.NextPos
			
			return
		elseif not util_IsInWorld(Bullet.NextPos) then
			ACF_RemoveBullet( Index )
			
			return
		else
			Bullet.SkyLvL = nil
			Bullet.LifeTime = nil
			Bullet.Pos = Bullet.NextPos
			Bullet.SkipNextHit = true
			
			return
		end
	end

		FlightTr.start  = Bullet.Pos
		FlightTr.endpos = Bullet.NextPos
		FlightTr.filter = Bullet.Filter
	local FlightRes = ACF_Trace()

	
	if Bullet.SkipNextHit then
		if not FlightRes.StartSolid and not FlightRes.HitNoDraw then Bullet.SkipNextHit = nil end
		Bullet.Pos = Bullet.NextPos
	elseif FlightRes.Hit then
		--debugoverlay.Line( Bullet.Pos, FlightRes.HitPos, 20, Color(255, 255, 0), false )
		--debugoverlay.Line( FlightRes.HitPos, Bullet.NextPos, 20, Color(255, 0, 0), false)

		
		if FlightRes.HitWorld then
			if FlightRes.HitSky then
				if FlightRes.HitNormal == Vector(0, 0, -1) then
					Bullet.SkyLvL = FlightRes.HitPos.z 						-- Lets save height on which bullet went through skybox. So it will start tracing after falling bellow this level. This will prevent from hitting higher levels of map
					Bullet.LifeTime = CurTime()
					Bullet.Pos = Bullet.NextPos
				else 
					ACF_RemoveBullet( Index )
				end
			else
				local Retry = ACF.RoundTypes[Bullet.Type]["worldimpact"]( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )
				if Retry == "Penetrated" then 								--if it is, we soldier on	
					if Bullet.OnPenetrated then Bullet.OnPenetrated(Index, Bullet, FlightRes) end
					
					ACF_BulletClient( Index, Bullet, "Update" , 2 , FlightRes.HitPos  )
					ACF_CalcBulletFlight( Index, Bullet )
				elseif Retry == "Ricochet"  then
					if Bullet.OnRicocheted then Bullet.OnRicocheted(Index, Bullet, FlightRes) end
					
					ACF_BulletClient( Index, Bullet, "Update" , 3 , FlightRes.HitPos  )
					ACF_CalcBulletFlight( Index, Bullet )
				else														--If not, end of the line, boyo
					if Bullet.OnEndFlight then Bullet.OnEndFlight(Index, Bullet, FlightRes) end
					
					ACF_BulletClient( Index, Bullet, "Update" , 1 , FlightRes.HitPos  )
					ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
					ACF_BulletEndFlight( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )	
				end
			end
		else -- Hit entity	
			local Retry = ACF.RoundTypes[Bullet.Type]["propimpact"]( Index, Bullet, FlightRes.Entity , FlightRes.HitNormal , FlightRes.HitPos , FlightRes.HitGroup )				--If we hit stuff then send the resolution to the damage function	
			if Retry == "Penetrated" then		--If we should do the same trace again, then do so
				if Bullet.OnPenetrated then Bullet.OnPenetrated(Index, Bullet, FlightRes) end
				
				ACF_BulletClient( Index, Bullet, "Update" , 2 , FlightRes.HitPos  )
				ACF_DoBulletsFlight( Index, Bullet )
			elseif Retry == "Ricochet"  then
				if Bullet.OnRicocheted then Bullet.OnRicocheted(Index, Bullet, FlightRes) end
				
				ACF_BulletClient( Index, Bullet, "Update" , 3 , FlightRes.HitPos  )
				ACF_CalcBulletFlight( Index, Bullet )
			else						--Else end the flight here
				if Bullet.OnEndFlight then Bullet.OnEndFlight(Index, Bullet, FlightRes) end
				
				ACF_BulletClient( Index, Bullet, "Update" , 1 , FlightRes.HitPos  )
				ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
				ACF_BulletEndFlight( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )	
			end
		end
	else
		--debugoverlay.Line( Bullet.Pos, Bullet.NextPos, 20, Color(0, 255, 255), false )
		Bullet.Pos = Bullet.NextPos
	end
end


function ACF_BulletClient( Index, Bullet, Type, Hit, HitPos )
	if Type == "Update" then
		local Effect = EffectData()
			Effect:SetAttachment( Index )		--Bulet Index
			Effect:SetStart( Bullet.Flight/10 )	--Bullet Direction
			if Hit > 0 then		-- If there is a hit then set the effect pos to the impact pos instead of the retry pos
				Effect:SetOrigin( HitPos )		--Bullet Pos
			else
				Effect:SetOrigin( Bullet.Pos )
			end
			Effect:SetScale( Hit )	--Hit Type 
		util_Effect( "ACF_BulletEffect", Effect, true, true )
	else
		local Effect = EffectData()
			local Filler = 0
			if Bullet["FillerMass"] then Filler = Bullet["FillerMass"]*15 end
			Effect:SetAttachment( Index )		--Bulet Index
			Effect:SetStart( Bullet.Flight/10 )	--Bullet Direction
			Effect:SetOrigin( Bullet.Pos )
			Effect:SetEntity( Entity(Bullet["Crate"]) )
			Effect:SetScale( 0 )
		util_Effect( "ACF_BulletEffect", Effect, true, true )

	end
end