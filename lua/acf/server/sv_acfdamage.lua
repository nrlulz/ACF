-- This file is meant for the advanced damage functions used by the Armored Combat Framework

local util_ScreenShake = util.ScreenShake
local util_TraceLine = util.TraceLine
local math_Max = math.Max
local math_Min = math.Min
local math_floor = math.floor
local ents_FindInSphere = ents.FindInSphere
local math_random = math.random

function ACF_HE( Hitpos , HitNormal , FillerMass, FragMass , Inflictor, NoOcc, Ammo )	--HitPos = Detonation center, FillerMass = mass of TNT being detonated in KG, FragMass = Mass of the round casing for fragmentation purposes, Inflictor owner of said TNT
	local Power = FillerMass * ACF.HEPower					--Power in KiloJoules of the filler mass of  TNT 
	local Radius = (FillerMass)^0.33*8*39.37				--Scalling law found on the net, based on 1PSI overpressure from 1 kg of TNT at 15m
	local MaxSphere = (4 * 3.1415 * (Radius*2.54 )^2) 		--Surface Area of the sphere at maximum radius
	local Amp = math_Min(Power/2000,50)
	util_ScreenShake( Hitpos, Amp, Amp, Amp/15, Radius*10 )  
	--debugoverlay.Sphere(Hitpos, Radius, 15, Color(255,0,0,32), 1) --developer 1   in console to see
	
	local Targets = ents_FindInSphere( Hitpos, Radius )
	
	local Fragments = math_Max(math_floor((FillerMass/FragMass)*ACF.HEFrag),2)
	local FragWeight = FragMass/Fragments
	local FragVel = (Power*50000/FragWeight/Fragments)^0.5
	local FragArea = (FragWeight/7.8)^0.33
	
	local OccFilter = { NoOcc }
	local LoopKill = true
	
	while LoopKill and Power > 0 do
		LoopKill = false
		local PowerSpent = 0
		local Iterations = 0
		local Damage = {}
		local TotalArea = 0
		for i,Tar in pairs(Targets) do
			Iterations = i
			if ( Tar ~= nil and Power > 0 and not Tar.Exploding ) then
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
					
					--see if we have a clean view to victim prop
					local Occlusion = {}
						Occlusion.start = Hitpos
						Occlusion.endpos = Hitat + (Hitat-Hitpos):GetNormalized()*100
						Occlusion.filter = OccFilter
						Occlusion.mask = MASK_SOLID
					local Occ = util_TraceLine( Occlusion )	
					
					--[[
					--retry for prop center if no hits at all, might have whiffed through bounding box and missed phys hull
					--nearestpoint uses intersect of bbox from source point to origin (getpos), this is effectively just redoing the same thing
					if ( !Occ.Hit and Hitpos ~= Hitat ) then
						local Hitat = Tar:GetPos()
						local Occlusion = {}
							Occlusion.start = Hitpos
							Occlusion.endpos = Hitat + (Hitat-Hitpos):GetNormalized()*100
							Occlusion.filter = OccFilter
							Occlusion.mask = MASK_SOLID
						Occ = util_TraceLine( Occlusion )	
					end
					--]]
					
					if ( !Occ.Hit ) then
						--no hit
					elseif ( Occ.Hit and Occ.Entity:EntIndex() ~= Tar:EntIndex() ) then
						--occluded, no hit
					else
						Targets[i] = nil	--Remove the thing we just hit from the table so we don't hit it again in the next round
						local Table = {}
							Table.Ent = Tar
							if Tar:GetClass() == "acf_engine" or Tar:GetClass() == "acf_ammo" or Tar:GetClass() == "acf_fueltank" then
								Table.LocalHitpos = WorldToLocal(Hitpos, Angle(0,0,0), Tar:GetPos(), Tar:GetAngles())
							end
							Table.Dist = Hitpos:Distance(Tar:GetPos())
							Table.Vec = (Tar:GetPos() - Hitpos):GetNormal()
							local Sphere = math_Max(4 * 3.1415 * (Table.Dist*2.54 )^2,1) --Surface Area of the sphere at the range of that prop
							local AreaAdjusted = Tar.ACF.Area
							Table.Area = math_Min(AreaAdjusted/Sphere,0.5)*MaxSphere --Project the aera of the prop to the aera of the shadow it projects at the explosion max radius
						Damage[#Damage+1] = Table	--Add it to the Damage table so we know to damage it once we tallied everything
						TotalArea = TotalArea + Table.Area
					end
				else
					Targets[i] = nil	--Target was invalid, so let's ignore it
					OccFilter[#OccFilter+1] = Tar
				end	
			end
		end
		
		for i, Table in pairs(Damage) do
			
			local Tar = Table.Ent
			local Feathering = (1-math_Min(1,Table.Dist/Radius)) ^ ACF.HEFeatherExp
			local AreaFraction = Table.Area/TotalArea
			local PowerFraction = Power * AreaFraction	--How much of the total power goes to that prop
			local AreaAdjusted = (Tar.ACF.Area / ACF.Threshold) * Feathering
			
			local BlastRes
			local Blast = {
				--Momentum = PowerFraction/(math_Max(1,Table.Dist/200)^0.05), --not used for anything
				Penetration = PowerFraction^ACF.HEBlastPen*AreaAdjusted
			}
			
			local FragRes
			local FragHit = Fragments * AreaFraction
			local FragVel = math_Max(FragVel - ( (Table.Dist/FragVel) * FragVel^2 * FragWeight^0.33/10000 )/ACF.DragDiv,0)
			local FragKE = ACF_Kinetic( FragVel , FragWeight*FragHit, 1500 )
			if FragHit < 0 then 
				if math.Rand(0,1) > FragHit then FragHit = 1 else FragHit = 0 end
			end
			
			-- erroneous HE penetration bug workaround; retries trace on crit ents after a short delay to ensure a hit.
			-- we only care about hits on critical ents, saves on processing power
			if Tar:GetClass() == "acf_engine" or Tar:GetClass() == "acf_ammo" or Tar:GetClass() == "acf_fueltank" then
				timer.Simple(0.015*4, function() 
					if not IsValid(Tar) then return end
					
					--recreate the hitpos and hitat, add slight jitter to hitpos and move it away some (local pos *2 is intentional)
					local NewHitpos = LocalToWorld(Table.LocalHitpos*2, Angle(math_random(),math_random(),math_random()), Tar:GetPos(), Tar:GetAngles())
					local NewHitat = Tar:NearestPoint( NewHitpos )
					
					local Occlusion = {
						start = NewHitpos,
						endpos = NewHitat + (NewHitat-NewHitpos):GetNormalized()*100,
						filter = NoOcc,
						mask = MASK_SOLID
					}
					local Occ = util_TraceLine( Occlusion )	
					
					if ( !Occ.Hit and NewHitpos ~= NewHitat ) then
						local NewHitat = Tar:GetPos()
						local Occlusion = {
							start = NewHitpos,
							endpos = NewHitat + (NewHitat-NewHitpos):GetNormalized()*100,
							filter = NoOcc,
							mask = MASK_SOLID
						}
						Occ = util_TraceLine( Occlusion )	
					end
					
					if ( Occ.Hit and Occ.Entity:EntIndex() ~= Tar:EntIndex() ) then
						--occluded, confirmed HE bug
						--print("HE bug on "..Tar:GetClass()..", occluded by "..(Occ.Entity:GetModel()))
						--debugoverlay.Sphere(Hitpos, 4, 20, Color(16,16,16,32), 1)
						--debugoverlay.Sphere(NewHitpos,3,20,Color(0,255,0,32), true)
						--debugoverlay.Sphere(NewHitat,3,20,Color(0,0,255,32), true)
					elseif ( !Occ.Hit and NewHitpos ~= NewHitat ) then
						--no hit, confirmed HE bug
						--print("HE bug on "..Tar:GetClass())
					else
						--confirmed proper hit, apply damage
						--print("No HE bug on "..Tar:GetClass())
						BlastRes = ACF_Damage ( Tar , Blast , AreaAdjusted , 0 , Inflictor ,0 , Ammo, "HE" )
						FragRes = ACF_Damage ( Tar , FragKE , FragArea*FragHit , 0 , Inflictor , 0, Ammo, "Frag" )
						
						if (BlastRes and BlastRes.Kill) or (FragRes and FragRes.Kill) then
							local Debris = ACF_HEKill( Tar, (Tar:GetPos() - NewHitpos):GetNormal(), PowerFraction )
						else
							ACF_KEShove(Tar, NewHitpos, (Tar:GetPos() - NewHitpos):GetNormal(), PowerFraction * 33.3 * (GetConVarNumber("acf_hepush") or 1) )
						end
					end
				end)
				
				--calculate damage that would be applied (without applying it), so HE deals correct damage to other props
				BlastRes = ACF_CalcDamage( Tar, Blast, AreaAdjusted, 0 )
				--FragRes = ACF_CalcDamage( Tar , FragKE , FragArea*FragHit , 0 ) --not used for anything in this case
			else
				BlastRes = ACF_Damage ( Tar , Blast , AreaAdjusted , 0 , Inflictor ,0 , Ammo, "HE" )
				FragRes = ACF_Damage ( Tar , FragKE , FragArea*FragHit , 0 , Inflictor , 0, Ammo, "Frag" )
			
				if (BlastRes and BlastRes.Kill) or (FragRes and FragRes.Kill) then
					local Debris = ACF_HEKill( Tar , Table.Vec , PowerFraction )
					table.insert( OccFilter , Debris )						--Add the debris created to the ignore so we don't hit it in other rounds
					LoopKill = true --look for fresh targets since we blew a hole somewhere
				else
					ACF_KEShove(Tar, Hitpos, Table.Vec, PowerFraction * 33.3 * (GetConVarNumber("acf_hepush") or 1) ) --Assuming about 1/30th of the explosive energy goes to propelling the target prop (Power in KJ * 1000 to get J then divided by 33)
				end
			end
			PowerSpent = PowerSpent + PowerFraction*BlastRes.Loss/2--Removing the energy spent killing props
			
		end
		Power = math_Max(Power - PowerSpent,0)	
	end
		
end

function ACF_Spall( HitPos , HitVec , HitMask , KE , Caliber , Armour , Inflictor )
	
	if not ACF.Spalling then return end

	local TotalWeight = 3.1416*(Caliber/2)^2 * Armour * 0.00079
	local Spall = math_Max(math_floor(Caliber*ACF.KEtoSpall),2)
	local SpallWeight = TotalWeight/Spall
	local SpallVel = (KE*2000/SpallWeight)^0.5/Spall
	local SpallArea = (SpallWeight/7.8)^0.33
	local SpallEnergy = ACF_Kinetic( SpallVel , SpallWeight, 600 )
	
	--print(SpallWeight)
	--print(SpallVel)
	local SpallTr = {}
		SpallTr.start = HitPos
		SpallTr.filter = HitMask

	for i = 1, Spall do
		SpallTr.endpos = HitPos + (HitVec:GetNormalized()+VectorRand()/2):GetNormalized()*SpallVel
		ACF_SpallTrace( HitVec , SpallTr , SpallEnergy , SpallArea , Inflictor )

		--debugoverlay.Line( SpallTr.start, SpallTr.endpos, 10, Color( 255, 255, 255 ), false )
	end

end

function ACF_SpallTrace( HitVec , SpallTr , SpallEnergy , SpallArea , Inflictor )

	local SpallRes = util_TraceLine(SpallTr)
	
	if SpallRes.Hit and ACF_Check( SpallRes.Entity ) then
	
		local Angle = ACF_GetHitAngle( SpallRes.HitNormal , HitVec )
		local HitRes = ACF_Damage( SpallRes.Entity , SpallEnergy , SpallArea , Angle , Inflictor, 0 )  --DAMAGE !!
		if HitRes.Kill then
			ACF_APKill( SpallRes.Entity , HitVec:GetNormalized() , SpallEnergy.Kinetic )
		end	
		if HitRes.Overkill > 0 then
			SpallTr.filter[#SpallTr.filter+1] = Target					--"Penetrate" (Ingoring the prop for the retry trace)
			
			SpallEnergy.Penetration = SpallEnergy.Penetration*(1-HitRes.Loss)
			SpallEnergy.Momentum = SpallEnergy.Momentum*(1-HitRes.Loss)
			
			ACF_SpallTrace( HitVec , SpallTr , SpallEnergy , SpallArea , Inflictor )
		end
		
	end
	
end

function ACF_RoundImpact( Bullet, Speed, Energy, Target, HitPos, HitNormal , Bone  )	--Simulate a round impacting on a prop
	--if (Bullet.Type == "HEAT") then print("Pen: "..((Energy.Penetration / Bullet["PenArea"]) * ACF.KEtoRHA)) end
	local Angle = ACF_GetHitAngle( HitNormal , Bullet["Velocity"] )
		
	local Ricochet = 0
	local MinAngle = math_Min(Bullet["Ricochet"] - Speed/39.37/15,89)	--Making the chance of a ricochet get higher as the speeds increase
	if Angle > math_random(MinAngle, 90) and Angle < 89.9 then	--Checking for ricochet
		Ricochet = (Angle/100)			--If ricocheting, calculate how much of the energy is dumped into the plate and how much is carried by the ricochet
		Energy.Penetration = Energy.Penetration - Energy.Penetration*Ricochet/4 --Ricocheting can save plates that would theorically get penetrated, can add up to 1/4 rating
	end
	local HitRes = ACF_Damage ( Target , Energy , Bullet["PenArea"] , Angle , Bullet["Owner"] , Bone, Bullet["Gun"], Bullet["Type"] )  --DAMAGE !!
	
	ACF_KEShove(Target, HitPos, Bullet["Velocity"]:GetNormal(), Energy.Kinetic*HitRes.Loss*1000*Bullet["ShovePower"]*(GetConVarNumber("acf_recoilpush") or 1) )
	
	if HitRes.Kill then
		Bullet.Filter[#Bullet.Filter + 1] = ACF_APKill( Target , (Bullet["Velocity"]):GetNormalized() , Energy.Kinetic )
	end	
	
	HitRes.Ricochet = false
	if Ricochet > 0 then
		Bullet["Pos"] = HitPos
		Bullet["Velocity"] = (Bullet["Velocity"]:GetNormalized() + HitNormal*(1-Ricochet+0.05) + VectorRand()*0.05):GetNormalized() * Speed * Ricochet
		
		HitRes.Ricochet = true
	end
	
	return HitRes
end

function ACF_PenetrateGround( Bullet, Energy, HitPos, HitNormal )
	Bullet.GroundRicos = Bullet.GroundRicos or 0
	local MaxDig = ((Energy.Penetration/Bullet.PenArea)*ACF.KEtoRHA/ACF.GroundtoRHA)/25.4
	local HitRes = {Penetrated = false, Ricochet = false}
	
	local DigTr = { }
		DigTr.start = HitPos + Bullet.Velocity:GetNormalized()*0.1
		DigTr.endpos = HitPos + Bullet.Velocity:GetNormalized()*(MaxDig+0.1)
		DigTr.filter = Bullet.Filter
		DigTr.mask = MASK_SOLID_BRUSHONLY
	local DigRes = util_TraceLine(DigTr)
	--print(util.GetSurfacePropName(DigRes.SurfaceProps))
	
	local loss = DigRes.FractionLeftSolid
	 
	if loss == 1 or loss == 0 then --couldn't penetrate
		local Ricochet = 0
		local Speed = Bullet.Velocity:Length()
		local Angle = ACF_GetHitAngle( HitNormal, Bullet.Velocity )
		local MinAngle = math_Min(Bullet.Ricochet - Speed/39.37/30 + 25, 89.9)	--Making the chance of a ricochet get higher as the speeds increase
		if Angle > math_random(MinAngle,90) and Angle < 89.9 and math_random(0, 1) == 1 then	--Checking for ricochet
			Ricochet = Angle/90*0.75
		end
		
		if Ricochet > 0 and Bullet.GroundRicos < 2 then
			Bullet.GroundRicos = Bullet.GroundRicos + 1
			local Vec = Bullet.Velocity:GetNormalized()
			--bit of maths shamelessly stolen from wiremod to rotate a vector around an axis
			local x,y,z = HitNormal[1], HitNormal[2], HitNormal[3]
			local length = (x*x+y*y+z*z)^0.5
			x,y,z = x/length, y/length, z/length
			local Rotated = -Vector((-1 + (x^2)*2) * Vec[1] + (x*y*2) * Vec[2] + (x*z*2) * Vec[3],
			(y*x*2) * Vec[1] + (-1 + (y^2)*2) * Vec[2] + (y*z*2) * Vec[3],
			(z*x*2) * Vec[1] + (z*y*2) * Vec[2] + (-1 + (z^2)*2) * Vec[3])
			
			Bullet.Pos = HitPos
			Bullet.Velocity = (Rotated + VectorRand()*0.025):GetNormalized() * Speed * Ricochet
			HitRes.Ricochet = true
		end
	else --penetrated
		Bullet.Velocity = Bullet.Velocity * ( 1 - loss )
		Bullet.Pos = DigRes.StartPos + Bullet.Velocity:GetNormalized() * 0.25 --this is actually where trace left brush
		HitRes.Penetrated = true
	end
	
	return HitRes
end

function ACF_KEShove(Target, Pos, Vec, KE )
	local CanDo = hook.Run("ACF_KEShove", Target, Pos, Vec, KE )
	if CanDo == false then return end
	
	local phys = ACF_GetAncestor(Target):GetPhysicsObject()
	
	if IsValid(phys) then
		if not Target.acflastupdatemass or Target.acflastupdatemass + 10 < CurTime() then
			ACF_CalcMassRatio(Target)
		end

		if not Target.acfphystotal then return end --corner case error check

		phys:ApplyForceOffset( Vec:GetNormal() * KE * Target.acfphystotal / Target.acftotal, Pos )
	end
end


ACF.IgniteDebris = 
{
	acf_ammo = true,
	acf_gun = true,
	acf_gearbox = true,
	acf_fueltank = true,
	acf_engine = true
}


function ACF_HEKill( Entity , HitVector , Energy )
	--print("ACF_HEKill ent: ".. Entity:GetModel() or "unknown")
	--print("ACF_HEKill Energy "..Energy or "nill")
	
	local obj = Entity:GetPhysicsObject()
	local grav = true
	local mass = nil
	if IsValid(obj) and ISSITP then
		grav = obj:IsGravityEnabled()
		mass = obj:GetMass()
	end
	constraint.RemoveAll( Entity )
	
	local entClass = Entity:GetClass()
	
	Entity:Remove()
	
	if Entity:BoundingRadius() < ACF.DebrisScale then
		return nil
	end
	
	local Debris = ents.Create( "Debris" )
		Debris:SetModel( Entity:GetModel() )
		Debris:SetAngles( Entity:GetAngles() )
		Debris:SetPos( Entity:GetPos() )
		Debris:SetMaterial("models/props_wasteland/metal_tram001a")
		Debris:Spawn()
		
		if ACF.IgniteDebris[entClass] then
			Debris:Ignite(60,0)
		end
		
		Debris:Activate()

	local phys = Debris:GetPhysicsObject() 
	if IsValid(phys) then
		phys:ApplyForceOffset( HitVector:GetNormal() * Energy * 350 , Debris:GetPos()+VectorRand()*20 ) 	
		phys:EnableGravity( grav )
		
		if mass then phys:SetMass(mass) end
	end

	return Debris
	
end

function ACF_APKill( Entity , HitVector , Power )

	constraint.RemoveAll( Entity )
	Entity:Remove()
	
	if Entity:BoundingRadius() < ACF.DebrisScale then
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
	if IsValid(phys) then	
		phys:ApplyForceOffset( HitVector:GetNormal() * Power * 350 ,  Debris:GetPos()+VectorRand()*20 )	
	end

	return Debris
	
end

--converts what would be multiple simultaneous cache detonations into one large explosion
function ACF_ScaledExplosion( ent )
	local Inflictor = nil
	if ent.Inflictor then
		Inflictor = ent.Inflictor
	end
	
	local HEWeight
	if ent:GetClass() == "acf_fueltank" then
		HEWeight = (math_Max(ent.Fuel, ent.Capacity * 0.0025) / ACF.FuelDensity[ent.FuelType]) * 0.1
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
	local Pos = ent:GetPos()
	local LastHE = 0
	
	local Search = true
	local Filter = {ent}
	while Search do
		for key,Found in pairs(ents_FindInSphere(Pos, Radius)) do
			if Found.IsExplosive and not Found.Exploding then	
				local Hitat = Found:NearestPoint( Pos )
				
				local Occlusion = {}
					Occlusion.start = Pos
					Occlusion.endpos = Hitat
					Occlusion.filter = Filter
				local Occ = util_TraceLine( Occlusion )
				
				if Occ.Fraction == 0 then
					Filter[#Filter + 1] = Occ.Entity
					local Occlusion = {}
						Occlusion.start = Pos
						Occlusion.endpos = Hitat
						Occlusion.filter = Filter
					Occ = util_TraceLine( Occlusion )
					--print("Ignoring nested prop")
				end
					
				if Occ.Hit and Occ.Entity:EntIndex() ~= Found.Entity:EntIndex() then 
						--Msg("Target Occluded\n")
				else
					local FoundHEWeight
					if Found:GetClass() == "acf_fueltank" then
						FoundHEWeight = (math_Max(Found.Fuel, Found.Capacity * 0.0025) / ACF.FuelDensity[Found.FuelType]) * 0.1
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
	
					HEWeight = HEWeight + FoundHEWeight
					Found.IsExplosive = false
					Found.DamageAction = false
					Found.KillAction = false
					Found.Exploding = true
					
					Filter[#Filter + 1] = Found
					
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
	
	ent:Remove()
	ACF_HE( Pos , Vector(0,0,1) , HEWeight , HEWeight*0.5 , Inflictor , ent, ent )
	
	local Flash = EffectData()
		Flash:SetOrigin( Pos )
		Flash:SetNormal( Vector(0,0,-1) )
		Flash:SetRadius( math_Max( Radius, 1 ) )
	util.Effect( "ACF_Scaled_Explosion", Flash )
end

function ACF_GetHitAngle( HitNormal , HitVector )
	HitVector = HitVector*-1
	
	return math_Min(math.deg(math.acos(HitNormal:Dot(HitVector:GetNormal()))), 89.999)
end
