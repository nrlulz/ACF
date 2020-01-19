-- This file is meant for the advanced damage functions used by the Armored Combat Framework

-- optimization; reuse tables for ballistics traces
local TraceRes = { }
local TraceInit = { output = TraceRes }

--[[----------------------------------------------------------------------------
	Function:
		ACF_HE
	Arguments:
		HitPos 		- detonation center,
		FillerMass 	- mass of TNT being detonated in KG
		FragMass 	- mass of the round casing for fragmentation purposes
		Inflictor	- owner of said TNT
		NoOcc		- table with entities to ignore
		Gun			- gun entity from which round is fired
	Purpose:
		Handles ACF explosions
------------------------------------------------------------------------------]]
function ACF_HE( Hitpos , HitNormal , FillerMass, FragMass, Inflictor, NoOcc, Gun )
	local Power = FillerMass * ACF.HEPower					--Power in KiloJoules of the filler mass of  TNT
	local Radius = (FillerMass)^0.33*8*39.37				--Scalling law found on the net, based on 1PSI overpressure from 1 kg of TNT at 15m
	local MaxSphere = (4 * 3.1415 * (Radius*2.54 )^2) 		--Surface Aera of the sphere at maximum radius
	local Amp = math.min(Power/2000,50)
	util.ScreenShake( Hitpos, Amp, Amp, Amp/15, Radius*10 )  
	--debugoverlay.Sphere(Hitpos, Radius, 15, Color(255,0,0,32), 1) --developer 1   in console to see
	
	local Targets = ents.FindInSphere( Hitpos, Radius )
	
	local Fragments = math.max(math.floor((FillerMass/FragMass)*ACF.HEFrag),2)
	local FragWeight = FragMass/Fragments
	local FragVel = (Power*50000/FragWeight/Fragments)^0.5
	local FragAera = (FragWeight/7.8)^0.33
	
	local OccFilter = { NoOcc }
	TraceInit.filter = OccFilter
	local LoopKill = true
	
	while LoopKill and Power > 0 do
		LoopKill = false
		local PowerSpent = 0
		local Iterations = 0
		local Damage = {}
		local TotalAera = 0
		for i,Tar in pairs(Targets) do
			Iterations = i
			if ( Tar != nil and Power > 0 and not Tar.Exploding ) then
				local Type = ACF_Check(Tar)
				if ( Type ) then
					local Hitat = nil
					if Type == "Squishy" then 	--A little hack so it doesn't check occlusion at the feet of players
						local Eyes = Tar:LookupAttachment("eyes")
						if Eyes then
							Hitat = Tar:GetAttachment( Eyes )
							if Hitat then
								--Msg("Hitting Eyes\n")
								Hitat = Hitat.Pos
							else
								Hitat = Tar:NearestPoint( Hitpos )
							end
						end
					else
						Hitat = Tar:NearestPoint( Hitpos )
					end
					
					--if hitpos inside hitbox of victim prop, nearest point doesn't work as intended
					if Hitat == Hitpos then Hitat = Tar:GetPos() end
					
					--[[see if we have a clean view to victim prop
					local Occlusion = {}
						Occlusion.start = Hitpos
						Occlusion.endpos = Hitat + (Hitat-Hitpos):GetNormalized()*100
						Occlusion.filter = OccFilter
						Occlusion.mask = MASK_SOLID
					local Occ = util.TraceLine( Occlusion )	
					]]--

					TraceInit.start = Hitpos
					TraceInit.endpos = Hitat + (Hitat-Hitpos):GetNormalized()*100
					TraceInit.filter = OccFilter
					TraceInit.mask = MASK_SOLID

					util.TraceLine( TraceInit ) -- automatically stored in output table: TraceRes
					
					--[[
					--retry for prop center if no hits at all, might have whiffed through bounding box and missed phys hull
					--nearestpoint uses intersect of bbox from source point to origin (getpos), this is effectively just redoing the same thing
					if ( !Occ.Hit and Hitpos != Hitat ) then
						local Hitat = Tar:GetPos()
						local Occlusion = {}
							Occlusion.start = Hitpos
							Occlusion.endpos = Hitat + (Hitat-Hitpos):GetNormalized()*100
							Occlusion.filter = OccFilter
							Occlusion.mask = MASK_SOLID
						Occ = util.TraceLine( Occlusion )	
					end
					--]]
					
					if ( !TraceRes.Hit ) then
						--no hit
					elseif ( TraceRes.Hit and TraceRes.Entity:EntIndex() != Tar:EntIndex() ) then
						--occluded, no hit
					else
						Targets[i] = nil	--Remove the thing we just hit from the table so we don't hit it again in the next round
						local Table = {}
							Table.Ent = Tar
							if Tar:GetClass() == "acf_engine" or Tar:GetClass() == "acf_ammo" or Tar:GetClass() == "acf_fueltank" then
								Table.LocalHitpos = WorldToLocal(Hitpos, Angle(0,0,0), Tar:GetPos(), Tar:GetAngles())
							end
							Table.Dist = Hitpos:Distance(Tar:GetPos())
							Table.Vec = (Tar:GetPos() - Hitpos):GetNormalized()
							local Sphere = math.max(4 * 3.1415 * (Table.Dist*2.54 )^2,1) --Surface Aera of the sphere at the range of that prop
							local AreaAdjusted = Tar.ACF.Aera
							Table.Aera = math.min(AreaAdjusted/Sphere,0.5)*MaxSphere --Project the aera of the prop to the aera of the shadow it projects at the explosion max radius
						table.insert(Damage, Table)	--Add it to the Damage table so we know to damage it once we tallied everything
						-- is it adding it too late?
						TotalAera = TotalAera + Table.Aera
					end
				else
					Targets[i] = nil	--Target was invalid, so let's ignore it
					table.insert( OccFilter , Tar ) -- updates the filter in TraceInit too
				end	
			end
		end
		
		for i,Table in pairs(Damage) do
			
			local Tar = Table.Ent
			local Feathering = (1-math.min(1,Table.Dist/Radius)) ^ ACF.HEFeatherExp
			local AeraFraction = Table.Aera/TotalAera
			local PowerFraction = Power * AeraFraction	--How much of the total power goes to that prop
			local AreaAdjusted = (Tar.ACF.Aera / ACF.Threshold) * Feathering
			
			local BlastRes
			local Blast = {
				--Momentum = PowerFraction/(math.max(1,Table.Dist/200)^0.05), --not used for anything
				Penetration = PowerFraction^ACF.HEBlastPen*AreaAdjusted
			}
			
			local FragRes
			local FragHit = Fragments * AeraFraction
			local FragVel = math.max(FragVel - ( (Table.Dist/FragVel) * FragVel^2 * FragWeight^0.33/10000 )/ACF.DragDiv,0)
			local FragKE = ACF_Kinetic( FragVel , FragWeight*FragHit, 1500 )
			if FragHit < 0 then 
				if math.Rand(0,1) > FragHit then FragHit = 1 else FragHit = 0 end
			end
			
			-- erroneous HE penetration bug workaround; retries trace on crit ents after a short delay to ensure a hit.
			-- we only care about hits on critical ents, saves on processing power
			-- not going to re-use tables in the timer, shouldn't make too much difference
			if Tar:GetClass() == "acf_engine" or Tar:GetClass() == "acf_ammo" or Tar:GetClass() == "acf_fueltank" then
				timer.Simple(0.015*2, function() 
					if not IsValid(Tar) then return end
					
					--recreate the hitpos and hitat, add slight jitter to hitpos and move it away some
					local NewHitpos = LocalToWorld(Table.LocalHitpos + Table.LocalHitpos:GetNormalized()*3, Angle(math.random(),math.random(),math.random()), Tar:GetPos(), Tar:GetAngles())
					local NewHitat = Tar:NearestPoint( NewHitpos )
					
					local Occlusion = {
						start = NewHitpos,
						endpos = NewHitat + (NewHitat-NewHitpos):GetNormalized()*100,
						filter = NoOcc,
						mask = MASK_SOLID
					}
					local Occ = util.TraceLine( Occlusion )	
					
					if ( !Occ.Hit and NewHitpos != NewHitat ) then
						local NewHitat = Tar:GetPos()
						local Occlusion = {
							start = NewHitpos,
							endpos = NewHitat + (NewHitat-NewHitpos):GetNormalized()*100,
							filter = NoOcc,
							mask = MASK_SOLID
						}
						Occ = util.TraceLine( Occlusion )	
					end
					
					if ( Occ.Hit and Occ.Entity:EntIndex() != Tar:EntIndex() ) then
						--occluded, confirmed HE bug
						--print("HE bug on "..Tar:GetClass()..", occluded by "..(Occ.Entity:GetModel()))
						--debugoverlay.Sphere(Hitpos, 4, 20, Color(16,16,16,32), 1)
						--debugoverlay.Sphere(NewHitpos,3,20,Color(0,255,0,32), true)
						--debugoverlay.Sphere(NewHitat,3,20,Color(0,0,255,32), true)
					elseif ( !Occ.Hit and NewHitpos != NewHitat ) then
						--no hit, confirmed HE bug
						--print("HE bug on "..Tar:GetClass())
					else
						--confirmed proper hit, apply damage
						--print("No HE bug on "..Tar:GetClass())
						
						BlastRes = ACF_Damage ( Tar    , Blast  , AreaAdjusted , 0     , Inflictor , 0    , Gun , "HE" )
						FragRes = ACF_Damage ( Tar , FragKE , FragAera*FragHit , 0 , Inflictor , 0, Gun, "Frag" )
						if (BlastRes and BlastRes.Kill) or (FragRes and FragRes.Kill) then
							local Debris = ACF_HEKill( Tar, (Tar:GetPos() - NewHitpos):GetNormalized(), PowerFraction , Hitpos)
						else
							ACF_KEShove(Tar, NewHitpos, (Tar:GetPos() - NewHitpos):GetNormalized(), PowerFraction * 33.3 * (GetConVarNumber("acf_hepush") or 1) )
						end
					end
				end)
				
				--calculate damage that would be applied (without applying it), so HE deals correct damage to other props
				BlastRes = ACF_CalcDamage( Tar, Blast, AreaAdjusted, 0 )
				--FragRes = ACF_CalcDamage( Tar , FragKE , FragAera*FragHit , 0 ) --not used for anything in this case
			else
				BlastRes = ACF_Damage ( Tar , Blast , AreaAdjusted , 0 , Inflictor ,0 , Gun, "HE" )
				FragRes = ACF_Damage ( Tar , FragKE , FragAera*FragHit , 0 , Inflictor , 0, Gun, "Frag" )
				if (BlastRes and BlastRes.Kill) or (FragRes and FragRes.Kill) then
					local Debris = ACF_HEKill( Tar , Table.Vec , PowerFraction , Hitpos )
					table.insert( OccFilter , Debris )						--Add the debris created to the ignore so we don't hit it in other rounds
					LoopKill = true --look for fresh targets since we blew a hole somewhere
				else
					ACF_KEShove(Tar, Hitpos, Table.Vec, PowerFraction * 33.3 * (GetConVarNumber("acf_hepush") or 1) ) --Assuming about 1/30th of the explosive energy goes to propelling the target prop (Power in KJ * 1000 to get J then divided by 33)
				end
			end
			PowerSpent = PowerSpent + PowerFraction*BlastRes.Loss/2--Removing the energy spent killing props
			
		end
		Power = math.max(Power - PowerSpent,0)	
	end
		
end

function ACF_Spall( HitPos , HitVec , HitMask , KE , Caliber , Armour , Inflictor )
	
	--if(!ACF.Spalling) then
	if true then -- Folks say it's black magic and it kills their firstborns. So I had to disable it with more powerful magic.
		return
	end
	local TotalWeight = 3.1416*(Caliber/2)^2 * Armour * 0.00079
	local Spall = math.max(math.floor(Caliber*ACF.KEtoSpall),2)
	local SpallWeight = TotalWeight/Spall
	local SpallVel = (KE*2000/SpallWeight)^0.5/Spall
	local SpallAera = (SpallWeight/7.8)^0.33 
	local SpallEnergy = ACF_Kinetic( SpallVel , SpallWeight, 600 )
	
	--print(SpallWeight)
	--print(SpallVel)
	
	for i = 1,Spall do
		local SpallTr = { }
			SpallTr.start = HitPos
			SpallTr.endpos = HitPos + (HitVec:GetNormalized()+VectorRand()/2):GetNormalized()*SpallVel
			SpallTr.filter = HitMask

			ACF_SpallTrace( HitVec , SpallTr , SpallEnergy , SpallAera , Inflictor )
	end

end

function ACF_SpallTrace( HitVec , SpallTr , SpallEnergy , SpallAera , Inflictor )

	local SpallRes = util.TraceLine(SpallTr)
	
	if SpallRes.Hit and ACF_Check( SpallRes.Entity ) then
	
		local Angle = ACF_GetHitAngle( SpallRes.HitNormal , HitVec )
		local HitRes = ACF_Damage( SpallRes.Entity , SpallEnergy , SpallAera , Angle , Inflictor, 0 )  --DAMAGE !!
		if HitRes.Kill then
			ACF_APKill( SpallRes.Entity , HitVec:GetNormalized() , SpallEnergy.Kinetic )
		end	
		if HitRes.Overkill > 0 then
			table.insert( SpallTr.filter , Target )					--"Penetrate" (Ingoring the prop for the retry trace)
			SpallEnergy.Penetration = SpallEnergy.Penetration*(1-HitRes.Loss)
			SpallEnergy.Momentum = SpallEnergy.Momentum*(1-HitRes.Loss)
			ACF_SpallTrace( HitVec , SpallTr , SpallEnergy , SpallAera , Inflictor )
		end
	end
end

--Calculates the vector of the ricochet of a round upon impact at a set angle
function ACF_RicochetVector(Flight, HitNormal)
	local Vec = Flight:GetNormalized() 

	return Vec - ( 2 * Vec:Dot(HitNormal) ) * HitNormal
end

-- Handles the impact of a round on a target
function ACF_RoundImpact( Bullet, Speed, Energy, Target, HitPos, HitNormal , Bone  )
	Bullet.Ricochets = Bullet.Ricochets or 0
	local Angle = ACF_GetHitAngle( HitNormal , Bullet["Flight"] )

	local HitRes = ACF_Damage ( --DAMAGE !!
		Target,
		Energy,
		Bullet["PenAera"],
		Angle,
		Bullet["Owner"],
		Bone,
		Bullet["Gun"],
		Bullet["Type"]
	)

	local Ricochet = 0
	if HitRes.Loss == 1 then
		-- Ricochet distribution center
		local sigmoidCenter = Bullet.DetonatorAngle or ( Bullet.Ricochet - math.abs(Speed / 39.37 - Bullet.LimitVel) / 100 )
		
		-- Ricochet probability (sigmoid distribution); up to 5% minimal ricochet probability for projectiles with caliber < 20 mm 
		local ricoProb = math.Clamp( 1 / (1 + math.exp( (Angle - sigmoidCenter) / -4) ), math.max(-0.05 * (Bullet.Caliber - 2) / 2, 0), 1 )

		-- Checking for ricochet
		if ricoProb > math.random() and Angle < 90 then
			Ricochet       = math.Clamp(Angle / 90, 0.05, 1) -- atleast 5% of energy is kept
			HitRes.Loss    = 0.25 - Ricochet
			Energy.Kinetic = Energy.Kinetic * HitRes.Loss
		end	
	end
	
	ACF_KEShove(
		Target,
		HitPos,
		Bullet["Flight"]:GetNormalized(),
		Energy.Kinetic * HitRes.Loss * 1000 * Bullet["ShovePower"] * (GetConVarNumber("acf_recoilpush") or 1)
	)
	
	if HitRes.Kill then
		local Debris = ACF_APKill( Target , (Bullet["Flight"]):GetNormalized() , Energy.Kinetic )
		table.insert( Bullet["Filter"] , Debris )
	end	
	
	HitRes.Ricochet = false
	if Ricochet > 0 and Bullet.Ricochets < 3 then
		Bullet.Ricochets = Bullet.Ricochets + 1
		Bullet["Pos"] = HitPos + HitNormal * 0.75
		Bullet.FlightTime = 0
		Bullet.Flight = (ACF_RicochetVector(Bullet.Flight, HitNormal) + VectorRand()*0.025):GetNormalized() * Speed * Ricochet
		Bullet.TraceBackComp = math.max(ACF_GetPhysicalParent(Target):GetPhysicsObject():GetVelocity():Dot(Bullet["Flight"]:GetNormalized()),0)
		HitRes.Ricochet = true
	end
	
	return HitRes
end

function ACF_PenetrateGround( Bullet, Energy, HitPos, HitNormal )
	Bullet.GroundRicos = Bullet.GroundRicos or 0
	local MaxDig = ((Energy.Penetration/Bullet.PenAera)*ACF.KEtoRHA/ACF.GroundtoRHA)/25.4
	local HitRes = {Penetrated = false, Ricochet = false}
	
	local DigTr = { }
		DigTr.start = HitPos + Bullet.Flight:GetNormalized()*0.1
		DigTr.endpos = HitPos + Bullet.Flight:GetNormalized()*(MaxDig+0.1)
		DigTr.filter = Bullet.Filter
		DigTr.mask = MASK_SOLID_BRUSHONLY
	local DigRes = util.TraceLine(DigTr)
	--print(util.GetSurfacePropName(DigRes.SurfaceProps))
	
	local loss = DigRes.FractionLeftSolid
	
	if loss == 1 or loss == 0 then --couldn't penetrate
		local Ricochet = 0
		local Speed = Bullet.Flight:Length() / ACF.VelScale
		local Angle = ACF_GetHitAngle( HitNormal, Bullet.Flight )
		local MinAngle = math.min(Bullet.Ricochet - Speed/39.37/30 + 20,89.9)	--Making the chance of a ricochet get higher as the speeds increase
		if Angle > math.random(MinAngle,90) and Angle < 89.9 then	--Checking for ricochet
			Ricochet = Angle/90*0.75
		end
		
		if Ricochet > 0 and Bullet.GroundRicos < 2 then
			Bullet.GroundRicos = Bullet.GroundRicos + 1
			Bullet.Pos = HitPos + HitNormal * 1
			Bullet.Flight = (ACF_RicochetVector(Bullet.Flight, HitNormal) + VectorRand()*0.05):GetNormalized() * Speed * Ricochet
			HitRes.Ricochet = true
		end
	else --penetrated
		Bullet.Flight = Bullet.Flight * (1 - loss)
		Bullet.Pos = DigRes.StartPos + Bullet.Flight:GetNormalized() * 0.25 --this is actually where trace left brush
		HitRes.Penetrated = true
	end
	
	return HitRes
end

function ACF_KEShove(Target, Pos, Vec, KE )
	local CanDo = hook.Run("ACF_KEShove", Target, Pos, Vec, KE )
	if CanDo == false then return end
	
	local parent = ACF_GetPhysicalParent(Target)
	local phys = parent:GetPhysicsObject()
	
	if (phys:IsValid()) then
		if(!Target.acflastupdatemass) or ((Target.acflastupdatemass + 10) < CurTime()) then
			ACF_CalcMassRatio(Target)
		end
		if not Target.acfphystotal then return end --corner case error check
		local physratio = Target.acfphystotal / Target.acftotal
		phys:ApplyForceOffset( Vec:GetNormalized() * KE * physratio, Pos )
	end
end


-- whitelist for things that can be turned into debris
ACF.Debris = {
	acf_ammo = true,
	acf_gun = true,
	acf_gearbox = true,
	acf_fueltank = true,
	acf_engine = true,
	prop_physics = true,
	prop_vehicle_prisoner_pod = true
}

-- things that should have scaledexplosion called on them instead of being turned into debris
ACF.Splosive = {
	acf_ammo = true,
	acf_fueltank = true
}

-- helper function to process children of an acf-destroyed prop
-- AP will HE-kill children props like a detonation; looks better than a directional spray of unrelated debris from the AP kill
local function ACF_KillChildProps( Entity, BlastPos, Energy )

	local count = 0
	local boom = {}
	local children = ACF_GetAllChildren(Entity)
	
	-- do an initial processing pass on children, separating out explodey things to handle last
	for _, ent in pairs( children ) do
		ent.ACF_Killed = true  -- mark that it's already processed
		local class = ent:GetClass()
		if not ACF.Debris[class] then
			children[ent] = nil -- ignoring stuff like holos
		else
			ent:SetParent(nil)
			if ACF.Splosive[class] then
				table.insert(boom, ent) -- keep track of explosives to make them boom last
				children[ent] = nil
			else
				count = count+1  -- can't use #table or :count() because of ent indexing...
			end
		end
	end
	
	-- HE kill the children of this ent, instead of disappearing them by removing parent
	if count > 0 then
		local DebrisChance = math.Clamp(ACF.ChildDebris/count, 0, 1)
		local power = Energy/math.min(count,3)

		for _, child in pairs( children ) do
			if IsValid(child) then
				if math.random() < DebrisChance then -- ignore some of the debris props to save lag
					ACF_HEKill( child, (child:GetPos() - BlastPos):GetNormalized(), power )
				else
					constraint.RemoveAll( child )
					child:Remove()
				end
			end
		end
	end
	
	-- explode stuff last, so we don't re-process all that junk again in a new explosion
	if #boom > 0 then
		for _, child in pairs( boom ) do
			if not IsValid(child) or child.Exploding then continue end
			child.Exploding = true
			ACF_ScaledExplosion( child ) -- explode any crates that are getting removed
		end
	end
	
end

-- blast pos is an optional world-pos input for flinging away children props more realistically
function ACF_HEKill( Entity , HitVector , Energy , BlastPos )

	-- if it hasn't been processed yet, check for children
	if not Entity.ACF_Killed then
		ACF_KillChildProps( Entity, BlastPos or Entity:GetPos(), Energy )
	end

	-- process this prop into debris
	local entClass = Entity:GetClass()
	local obj = Entity:GetPhysicsObject()
	local grav = true
	local mass = 25
	if obj:IsValid() then
		mass = math.max(obj:GetMass(), mass)
		if ISSITP then
			grav = obj:IsGravityEnabled()
		end
	end
	
	constraint.RemoveAll( Entity )
	Entity:Remove()

	if(Entity:BoundingRadius() < ACF.DebrisScale) then
		return nil
	end
	
	local Debris = ents.Create( "Debris" )
		Debris:SetModel( Entity:GetModel() )
		Debris:SetAngles( Entity:GetAngles() )
		Debris:SetPos( Entity:GetPos() )
		Debris:SetMaterial("models/props_wasteland/metal_tram001a")
		Debris:Spawn()
		
	if math.random() < ACF.DebrisIgniteChance then
		Debris:Ignite(math.Rand(5,45),0)
	end
	
	Debris:Activate()

	local phys = Debris:GetPhysicsObject() 
	if phys:IsValid() then
		phys:SetMass(mass)
		phys:ApplyForceOffset( HitVector:GetNormalized() * Energy * 10 , Debris:GetPos()+VectorRand()*20 ) 	-- previously energy*350
		phys:EnableGravity( grav )
	end

	return Debris
	
end

function ACF_APKill( Entity , HitVector , Power )

	-- kill the children of this ent, instead of disappearing them from removing parent
	ACF_KillChildProps( Entity, Entity:GetPos(), Power )

	constraint.RemoveAll( Entity )
	Entity:Remove()
	
	if(Entity:BoundingRadius() < ACF.DebrisScale) then
		return nil
	end

	local Debris = ents.Create( "Debris" )
		Debris:SetModel( Entity:GetModel() )
		Debris:SetAngles( Entity:GetAngles() )
		Debris:SetPos( Entity:GetPos() )
		Debris:SetMaterial(Entity:GetMaterial())
		Debris:SetColor(Color(120,120,120,255))
		Debris:Spawn()
		Debris:Activate()
		
	local BreakEffect = EffectData()				
		BreakEffect:SetOrigin( Entity:GetPos() )
		BreakEffect:SetScale( 20 )
	util.Effect( "WheelDust", BreakEffect )	
		
	local phys = Debris:GetPhysicsObject() 
	if (phys:IsValid()) then	
		phys:ApplyForceOffset( HitVector:GetNormalized() * Power * 350 ,  Debris:GetPos()+VectorRand()*20 )	
	end

	return Debris
	
end

--converts what would be multiple simultaneous cache detonations into one large explosion
function ACF_ScaledExplosion( ent )
	local Inflictor = nil
	if( ent.Inflictor ) then
		Inflictor = ent.Inflictor
	end
	
	local HEWeight
	if ent:GetClass() == "acf_fueltank" then
		HEWeight = (math.max(ent.Fuel, ent.Capacity * 0.0025) / ACF.FuelDensity[ent.FuelType]) * 0.1
	else
		local HE, Propel
		if ent.RoundType == "Refill" then
			HE = 0.001
			Propel = 0.001
		else 
			HE = ent.BulletData["FillerMass"] or 0
			Propel = ent.BulletData["PropMass"] or 0
		end
		HEWeight = (HE+Propel*(ACF.PBase/ACF.HEPower))*ent.Ammo
	end
	local Radius = HEWeight^0.33*8*39.37
	local ExplodePos = {}
	local Pos = ent:LocalToWorld(ent:OBBCenter())
	table.insert(ExplodePos, Pos)
	local LastHE = 0
	
	local Search = true
	local Filter = {ent}
	while Search do
		for key,Found in pairs(ents.FindInSphere(Pos, Radius)) do
			if Found.IsExplosive and not Found.Exploding then	
				local Hitat = Found:NearestPoint( Pos )
				
				local Occlusion = {}
					Occlusion.start = Pos
					Occlusion.endpos = Hitat
					Occlusion.filter = Filter
				local Occ = util.TraceLine( Occlusion )
				
				if ( Occ.Fraction == 0 ) then
					table.insert(Filter,Occ.Entity)
					local Occlusion = {}
						Occlusion.start = Pos
						Occlusion.endpos = Hitat
						Occlusion.filter = Filter
					Occ = util.TraceLine( Occlusion )
					--print("Ignoring nested prop")
				end
					
				if ( Occ.Hit and Occ.Entity:EntIndex() != Found.Entity:EntIndex() ) then 
						--Msg("Target Occluded\n")
				else
					local FoundHEWeight
					if Found:GetClass() == "acf_fueltank" then
						FoundHEWeight = (math.max(Found.Fuel, Found.Capacity * 0.0025) / ACF.FuelDensity[Found.FuelType]) * 0.1
					else
						local HE, Propel
						if Found.RoundType == "Refill" then
							HE = 0.001
							Propel = 0.001
						else 
							HE = Found.BulletData["FillerMass"] or 0
							Propel = Found.BulletData["PropMass"] or 0
						end
						FoundHEWeight = (HE+Propel*(ACF.PBase/ACF.HEPower))*Found.Ammo
					end
					
					table.insert(ExplodePos, Found:LocalToWorld(Found:OBBCenter()))
					HEWeight = HEWeight + FoundHEWeight
					Found.IsExplosive = false
					Found.DamageAction = false
					Found.KillAction = false
					Found.Exploding = true
					table.insert(Filter,Found)
					Found:Remove()
				end			
			end
		end	
		
		if HEWeight > LastHE then
			Search = true
			LastHE = HEWeight
			Radius = (HEWeight)^0.33*8*39.37
		else
			Search = false
		end
		
	end	

	local totalpos = Vector()
	for _, cratepos in pairs(ExplodePos) do totalpos = totalpos + cratepos end
	local AvgPos = totalpos / #ExplodePos

	ent:Remove()
	ACF_HE( AvgPos , Vector(0,0,1) , HEWeight , HEWeight*0.5 , Inflictor , ent, ent )
	
	local Flash = EffectData()
		Flash:SetOrigin( AvgPos )
		Flash:SetNormal( Vector(0,0,-1) )
		Flash:SetRadius( math.max( Radius, 1 ) )
	util.Effect( "ACF_Scaled_Explosion", Flash )
end

function ACF_GetHitAngle( HitNormal , HitVector )
	
	HitVector = HitVector*-1
	local Angle = math.min(math.deg(math.acos(HitNormal:Dot( HitVector:GetNormalized() ) ) ),89.999 )
	--Msg("Angle : " ..Angle.. "\n")
	return Angle
	
end
