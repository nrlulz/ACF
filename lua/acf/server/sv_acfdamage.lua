-- This file is meant for the advanced damage functions used by the Armored Combat Framework
function ACF_HE( Hitpos , HitNormal , FillerMass, FragMass , Inflictor, NoOcc, Ammo )	--HitPos = Detonation center, FillerMass = mass of TNT being detonated in KG, FragMass = Mass of the round casing for fragmentation purposes, Inflictor owner of said TNT
	local Power = FillerMass * ACF.HEPower					--Power in KiloJoules of the filler mass of  TNT 
	local Radius = (FillerMass)^0.33*8*39.37				--Scalling law found on the net, based on 1PSI overpressure from 1 kg of TNT at 15m
	local MaxSphere = (4 * 3.1415 * (Radius*2.54 )^2) 		--Surface Aera of the sphere at maximum radius
	local Amp = math.min(Power/2000,50)
	util.ScreenShake( Hitpos, Amp, Amp, Amp/15, Radius*10 )  
	--local Targets = ents.FindInSphere( Hitpos, Radius )
	local Targets = ents.GetAll()
	
	for k,v in pairs (Targets) do
		local epos = v:GetPos()
		if Hitpos:Distance(epos) > Radius then
			Targets[k] = nil
		end
	end
	
	local Fragments = math.max(math.floor((FillerMass/FragMass)*ACF.HEFrag),2)
	local FragWeight = FragMass/Fragments
	local FragVel = (Power*50000/FragWeight/Fragments)^0.5
	local FragAera = (FragWeight/7.8)^0.33
	
	local OccFilter = { NoOcc }
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
					if Type == "Squishy" then 										--A little hack so it doesn't check occlusion at the feet of players
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
					
					local Occlusion = {}
						Occlusion.start = Hitpos
						Occlusion.endpos = Hitat + (Hitat-Hitpos):GetNormalized()*100
						Occlusion.filter = OccFilter
						Occlusion.mask = MASK_SOLID
					local Occ = util.TraceLine( Occlusion )	
					
					if ( !Occ.Hit and Hitpos != Hitat ) then
						local Hitat = Tar:GetPos()
						local Occlusion = {}
							Occlusion.start = Hitpos
							Occlusion.endpos = Hitat + (Hitat-Hitpos):GetNormalized()*100
							Occlusion.filter = OccFilter
							Occlusion.mask = MASK_SOLID
						Occ = util.TraceLine( Occlusion )	
					end
					
					if ( Occ.Hit and Occ.Entity:EntIndex() != Tar:EntIndex() ) then
					
						--print("Hit "..Occ.Entity:GetModel())
					elseif ( !Occ.Hit and Hitpos != Hitat ) then
						--print("No Hit "..Occ.Entity:GetModel())
						--print((Hitpos - Hitat):Length())
					else
						Targets[i] = nil								--Remove the thing we just hit from the table so we don't hit it again in the next round
						local Table = {}
							Table.Ent = Tar
							Table.Dist = Hitpos:Distance(Tar:GetPos())
							Table.Vec = (Tar:GetPos() - Hitpos):GetNormal()
							local Sphere = math.max(4 * 3.1415 * (Table.Dist*2.54 )^2,1) --Surface Aera of the sphere at the range of that prop
							Table.Aera = math.min((Tar.ACF.MaxHealth*ACF.Threshold)/Sphere,0.5)*MaxSphere --Project the aera of the prop to the aera of the shadow it projects at the explosion max radius
						table.insert(Damage, Table)						--Add it to the Damage table so we know to damage it once we tallied everything
						TotalAera = TotalAera + Table.Aera
					end
				else
					--print("INVALID: "..Tar:GetClass())
					Targets[i] = nil											--Target was invalid, so let's ignore it
					table.insert( OccFilter , Tar )
				end	
			end
		end
		--Msg("ACF_HE Damage:\n")
		--PrintTable(Damage)
		
		for i,Table in pairs(Damage) do
			
			local Tar = Table.Ent
			local AeraFraction = Table.Aera/TotalAera
			local PowerFraction = Power * AeraFraction										--How much of the total power goes to that prop
			--print("ACF_HE Target: "..Tar:GetModel() or "unknown")
			--print("ACF_HE Power: "..PowerFraction or "nill")
			
			local Blast = {}
				Blast.Momentum = PowerFraction/(math.max(1,Table.Dist/200)^0.05)
				Blast.Penetration = PowerFraction^ACF.HEBlastPen*Tar.ACF.MaxHealth
			local BlastRes = ACF_Damage ( Tar , Blast , Tar.ACF.MaxHealth , 0 , Inflictor ,0 , Ammo )--Vel is just the speed of sound in air
			PowerSpent = PowerSpent + PowerFraction*BlastRes.Loss/2--Removing the energy spent killing props
			
			local FragHit = Fragments * AeraFraction
			local FragVel = math.max(FragVel - ( (Table.Dist/FragVel) * FragVel^2 * FragWeight^0.33/10000 )/ACF.DragDiv,0)
			local FragKE = ACF_Kinetic( FragVel , FragWeight*FragHit, 1500 )
			if FragHit < 0 then 
				if math.Rand(0,1) > FragHit then FragHit = 1 else FragHit = 0 end
			end
			
			local FragRes = ACF_Damage ( Tar , FragKE , (FragWeight/7.8)^0.33*FragHit , 0 , Inflictor , 0, Ammo )
			
			if (BlastRes and BlastRes.Kill) or (FragRes and FragRes.Kill) then
				local Debris = ACF_HEKill( Tar , Table.Vec , PowerFraction )
				table.insert( OccFilter , Debris )						--Add the debris created to the ignore so we don't hit it in other rounds
				LoopKill = true
			else
				local phys = Tar:GetPhysicsObject() 
				if (phys:IsValid()) then 
					phys:ApplyForceOffset( Table.Vec * PowerFraction * 100 ,  Hitpos )	--Assuming about a tenth of the energy goes to propelling the target prop (Power in KJ * 1000 to get J then divided by 10)
				end
			end
			
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

function ACF_RoundImpact( Bullet, Speed, Energy, Target, HitPos, HitNormal , Bone  )	--Simulate a round impacting on a prop

	local Angle = ACF_GetHitAngle( HitNormal , Bullet["Flight"] )
		
	local Ricochet = 0
	local MinAngle = math.min(Bullet["Ricochet"] - Speed/39.37/15,89)	--Making the chance of a ricochet get higher as the speeds increase
	if Angle > math.random(MinAngle,90) and Angle < 89.9 then	--Checking for ricochet
		Ricochet = (Angle/100)			--If ricocheting, calculate how much of the energy is dumped into the plate and how much is carried by the ricochet
		Energy.Penetration = Energy.Penetration - Energy.Penetration*Ricochet/4 --Ricocheting can save plates that would theorically get penetrated, can add up to 1/4 rating
	end
	local HitRes = ACF_Damage ( Target , Energy , Bullet["PenAera"] , Angle , Bullet["Owner"] , Bone, Bullet["Gun"] )  --DAMAGE !!
	
	ACF_KEShove(Target, HitPos, Bullet["Flight"]:GetNormal(), Energy.Kinetic*HitRes.Loss*1000*Bullet["ShovePower"] )
	
	if HitRes.Kill then
		local Debris = ACF_APKill( Target , (Bullet["Flight"]):GetNormalized() , Energy.Kinetic )
		table.insert( Bullet["Filter"] , Debris )
	end	
	
	HitRes.Ricochet = false
	if Ricochet > 0 then
		Bullet["Pos"] = HitPos
		Bullet["Flight"] = (Bullet["Flight"]:GetNormalized() + HitNormal*(1-Ricochet+0.05) + VectorRand()*0.05):GetNormalized() * Speed * Ricochet
		HitRes.Ricochet = true
	end
	
	return HitRes
end

function ACF_PenetrateGround( Bullet, Energy, HitPos )

	local MaxDig = ((Energy.Penetration/Bullet["PenAera"])*ACF.KEtoRHA/ACF.GroundtoRHA)/25.4
	local CurDig = 0
	local DigStep = math.min(50,MaxDig)
	
	for i = 1,MaxDig/DigStep do
		--Msg("Step : ")
		--print(i)
		CurDig = DigStep*i
		local DigTr = { }
			DigTr.start = HitPos + (Bullet["Flight"]):GetNormalized()*CurDig
			DigTr.endpos = HitPos
			DigTr.filter = Bullet["Filter"]
			DigTr.mask = 16395
		local DigRes = util.TraceLine(DigTr)					--Trace to see if it will hit anything
		
		if DigRes.Hit then
			if DigRes.Fraction > 0.01 and DigRes.Fraction < 0.99 then 							
				local Powerloss = (MaxDig - (CurDig - DigStep*DigRes.Fraction))/MaxDig
				--print(Powerloss)
				Bullet["Flight"] = Bullet["Flight"] * Powerloss
				--Msg("Penetrated the wall\n")
				Bullet["Pos"] = DigRes.HitPos
				return true
			else
				return nil 
			end
		else
			--Msg("Didn't Hit\n")
		end
	end
	
	return nil 
	
end

function ACF_KEShove(Target, Pos, Vec, KE )
	
	local phys = Target:GetPhysicsObject() 
	if (Target:GetParent():IsValid()) then
		phys = Target:GetParent():GetPhysicsObject() 
	end
	if (phys:IsValid()) then	
		phys:ApplyForceOffset( Vec:GetNormal() * KE, Pos )
	end
	
end

function ACF_HEKill( Entity , HitVector , Energy )
	--print("ACF_HEKill ent: ".. Entity:GetModel() or "unknown")
	--print("ACF_HEKill Energy "..Energy or "nill")
	
	local obj = Entity:GetPhysicsObject()
	local grav = true
	local mass = nil
	if obj:IsValid() and ISSITP then
		grav = obj:IsGravityEnabled()
		mass = obj:GetMass()
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
		Debris:Ignite(60,0)
		Debris:Activate()

	local phys = Debris:GetPhysicsObject() 
	if (phys:IsValid()) then
		phys:ApplyForceOffset( HitVector:GetNormal() * Energy * 350 , Debris:GetPos()+VectorRand()*20 ) 	
		phys:EnableGravity( grav )
		if(mass != nil) then
			phys:SetMass(mass)
		end
	end

	return Debris
	
end

function ACF_APKill( Entity , HitVector , Power )

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
		phys:ApplyForceOffset( HitVector:GetNormal() * Power * 350 ,  Debris:GetPos()+VectorRand()*20 )	
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
	local Pos = ent:GetPos()
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
	
	ent:Remove()
	ACF_HE( Pos , Vector(0,0,1) , HEWeight , HEWeight*0.5 , Inflictor , ent, ent )
	
	local Flash = EffectData()
		Flash:SetOrigin( Pos )
		Flash:SetNormal( Vector(0,0,-1) )
		Flash:SetRadius( math.max( Radius, 1 ) )
	util.Effect( "ACF_Scaled_Explosion", Flash )
end

function ACF_GetHitAngle( HitNormal , HitVector )
	
	HitVector = HitVector*-1
	local Angle = math.min(math.deg(math.acos(HitNormal:Dot( HitVector:GetNormal() ) ) ),89.999 )
	--Msg("Angle : " ..Angle.. "\n")
	return Angle
	
end
