ACF.Bullet = {}
ACF.CurBulletIndex = 0
ACF.BulletIndexLimit = 1000
local IndexLimit = ACF.BulletIndexLimit
local Bullets = ACF.Bullet
local DragDiv = ACF.DragDiv
local FlightTr = {}
	FlightTr.mask  = MASK_SHOT

local util_TraceLine = util.TraceLine
local math_Random = math.random
local util_IsInWorld = util.IsInWorld
local util_Effect = util.Effect
--local hook_Run = hook.Run, 109
local math_Round = math.Round

function ACF_CreateBullet( Data )
	ACF.CurBulletIndex = ACF.CurBulletIndex + 1 > IndexLimit and 1 or ACF.CurBulletIndex + 1
	local Index = ACF.CurBulletIndex
	
	local BulletData = {}
		BulletData.Accel		= ACF.Gravity + Vector(0, 0, 0)		
		BulletData.DragCoef		= Data.DragCoef
		BulletData.FillerMass	= Data.FillerMass
		BulletData.ProjMass		= Data.ProjMass
		BulletData.Pos			= Data.Pos
		BulletData.Velocity		= Data.Velocity

		BulletData.PenArea		= Data.PenArea
		BulletData.FrArea		= Data.FrArea
		BulletData.KETransfert	= Data.KETransfert
		BulletData.LimitVel		= Data.LimitVel
		BulletData.Ricochet		= Data.Ricochet
		BulletData.ShovePower	= Data.ShovePower

		BulletData.Owner		= Data.Owner
		BulletData.Crate		= Data.Crate
		BulletData.LastThink	= SysTime()
		BulletData.DetTime		= Data.FuzeTime and CurTime() + Data.FuzeTime or nil
		BulletData.Filter		= Data.Gun and { Data.Gun } or {}
		BulletData.Type			= Data.Type

		BulletData.CasingMass	= Data.CasingMass
		BulletData.SlugDragCoef = Data.SlugDragCoef
		BulletData.SlugMass		= Data.SlugMass
		BulletData.SlugPenArea	= Data.SlugPenArea
		BulletData.SlugRicochet	= Data.SlugRicochet
		BulletData.SlugMV		= Data.SlugMV
		
	Bullets[Index] = BulletData		--Place the bullet at the current index pos
	ACF_BulletClient( Index, Bullets[Index], "Init", 0 )
	ACF_CalcBulletFlight( Index, Bullets[Index] )
end


local function ACF_ManageBullets()
	for Index, Bullet in pairs(Bullets) do
		--if not Bullet.HandlesOwnIteration then
			ACF_CalcBulletFlight( Index, Bullet )			--This is the bullet entry in the table, the Index var omnipresent refers to this
		--end
	end
end
hook.Add("Tick", "ACF_ManageBullets", ACF_ManageBullets)


function ACF_RemoveBullet(Index)
	--local Bullet = Bullets[Index]
	
	Bullets[Index] = nil
	
	--if Bullet and Bullet.OnRemoved then Bullet:OnRemoved() end
end


function ACF_CheckClips(Ent, HitPos)
	if not Ent.ClipData or Ent:GetClass() ~= "prop_physics" then return false end
	
	local Data = Ent.ClipData
	for i = 1, #Data do
		local DataI = Data[i]
		local N = DataI[n]

		if Ent:LocalToWorldAngles(N):Forward():Dot((Ent:LocalToWorld(N:Forward() * DataI[d]) - HitPos):GetNormalized()) > 0 then return true end
	end
	
	return false
end


function ACF_Trace()
	local TraceRes = util_TraceLine(FlightTr)
	
	if TraceRes.HitNonWorld and ( not ACF_Check(TraceRes.Entity) or ACF_CheckClips(TraceRes.Entity, TraceRes.HitPos) ) then
		FlightTr.filter[#FlightTr.filter + 1] = TraceRes.Entity
		
		return ACF_Trace(FlightTr)
	end
	
	return TraceRes
end

function ACF_CalcBulletFlight(Index, Bullet, Override)
	// perf concern: none of the ACF devs know how to code
	--if Bullet.PreCalcFlight then Bullet:PreCalcFlight() end
	
	local Time = SysTime()
	local DeltaTime = Time - Bullet.LastThink
	
	local Drag = Bullet.Velocity:GetNormalized() * Bullet.DragCoef * Bullet.Velocity:LengthSqr() / DragDiv
	Bullet.NextPos = Bullet.Pos + Bullet.Velocity * DeltaTime		--Calculates the next shell position
	Bullet.Velocity = Bullet.Velocity + (Bullet.Accel - Drag) * DeltaTime				--Calculates the next shell vector
	Bullet.LastThink = Time
	
	ACF_DoBulletsFlight( Index, Bullet )
	
	// perf concern: use direct function call stored on bullet over hook system.
	--if Bullet.PostCalcFlight then Bullet:PostCalcFlight() end
end

function ACF_DoBulletsFlight(Index, Bullet)
	--if hook_Run("ACF_BulletsFlight", Index, Bullet ) == false then return end
	
	if Bullet.DetTime and CurTime() >= Bullet.DetTime then
		if not util_IsInWorld(Bullet.Pos) then
			ACF_RemoveBullet( Index )
		else
			Bullet.Pos = LerpVector(math_Random(), Bullet.Pos, Bullet.NextPos)

			--if Bullet.OnEndFlight then Bullet.OnEndFlight(Index, Bullet, FlightRes) end
			
			ACF_BulletClient( Index, Bullet, "Update" , 1 , Bullet.Pos  )
			ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
			ACF_BulletEndFlight( Index, Bullet, Bullet.Pos, Bullet.Velocity:GetNormalized() )	
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
					--if Bullet.OnPenetrated then Bullet.OnPenetrated(Index, Bullet, FlightRes) end
					
					ACF_BulletClient( Index, Bullet, "Update" , 2 , FlightRes.HitPos  )
					ACF_CalcBulletFlight( Index, Bullet )
				elseif Retry == "Ricochet"  then
					--if Bullet.OnRicocheted then Bullet.OnRicocheted(Index, Bullet, FlightRes) end
					
					ACF_BulletClient( Index, Bullet, "Update" , 3 , FlightRes.HitPos  )
					ACF_CalcBulletFlight( Index, Bullet )
				else														--If not, end of the line, boyo
					--if Bullet.OnEndFlight then Bullet.OnEndFlight(Index, Bullet, FlightRes) end
					
					ACF_BulletClient( Index, Bullet, "Update" , 1 , FlightRes.HitPos  )
					ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
					ACF_BulletEndFlight( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )	
				end
			end
		else -- Hit entity	
			local Retry = ACF.RoundTypes[Bullet.Type]["propimpact"]( Index, Bullet, FlightRes.Entity , FlightRes.HitNormal , FlightRes.HitPos , FlightRes.HitGroup )				--If we hit stuff then send the resolution to the damage function	
			if Retry == "Penetrated" then		--If we should do the same trace again, then do so
				--if Bullet.OnPenetrated then Bullet.OnPenetrated(Index, Bullet, FlightRes) end
				
				ACF_BulletClient( Index, Bullet, "Update" , 2 , FlightRes.HitPos  )
				ACF_DoBulletsFlight( Index, Bullet )
			elseif Retry == "Ricochet"  then
				--if Bullet.OnRicocheted then Bullet.OnRicocheted(Index, Bullet, FlightRes) end
				
				ACF_BulletClient( Index, Bullet, "Update" , 3 , FlightRes.HitPos  )
				ACF_CalcBulletFlight( Index, Bullet )
			else						--Else end the flight here
				--if Bullet.OnEndFlight then Bullet.OnEndFlight(Index, Bullet, FlightRes) end
				
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
			Effect:SetStart( Bullet.Velocity/10 )	--Bullet Direction
			if Hit > 0 then		-- If there is a hit then set the effect pos to the impact pos instead of the retry pos
				Effect:SetOrigin( HitPos )		--Bullet Pos
			else
				Effect:SetOrigin( Bullet.Pos )
			end
			Effect:SetScale( Hit )	--Hit Type 
		util_Effect( "ACF_BulletEffect", Effect, true, true )
	else
		local Effect = EffectData()
			Effect:SetAttachment( Index )		--Bulet Index
			Effect:SetStart( Bullet.Velocity/10 )	--Bullet Direction
			Effect:SetOrigin( Bullet.Pos )
			Effect:SetEntity( Entity(Bullet["Crate"]) )
			Effect:SetScale( 0 )
		util_Effect( "ACF_BulletEffect", Effect, true, true )
	end
end