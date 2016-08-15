local UpdateIndex = 0
function ACF_UpdateVisualHealth(Entity)
	if Entity.ACF.PrHealth == Entity.ACF.Health then return end
	if not ACF_HealthUpdateList then
		ACF_HealthUpdateList = {}
		timer.Create("ACF_HealthUpdateList", 1, 1, function() // We should send things slowly to not overload traffic.
			local Table = {}
			for k,v in pairs(ACF_HealthUpdateList) do
				if IsValid( v ) then
					table.insert(Table,{ID = v:EntIndex(), Health = v.ACF.Health, MaxHealth = v.ACF.MaxHealth})
				end
			end
			net.Start("ACF_RenderDamage")
				net.WriteTable(Table)
			net.Broadcast()
			ACF_HealthUpdateList = nil
		end)
	end
	table.insert(ACF_HealthUpdateList, Entity)
end

function ACF_Activate ( Entity , Recalc )

	--Density of steel = 7.8g cm3 so 7.8kg for a 1mx1m plate 1m thick
	if Entity.SpecialHealth then
		Entity:ACF_Activate( Recalc )
		return
	end
	Entity.ACF = Entity.ACF or {} 
	
	local Count
	local PhysObj = Entity:GetPhysicsObject()
	if PhysObj:GetMesh() then Count = #PhysObj:GetMesh() end
	if IsValid(PhysObj) and Count and Count>100 then

		if not Entity.ACF.Area then
			Entity.ACF.Area = (PhysObj:GetSurfaceArea() * 6.45) * 0.52505066107
		end
		--if not Entity.ACF.Volume then
		--	Entity.ACF.Volume = (PhysObj:GetVolume() * 16.38)
		--end
	else
		local Size = Entity.OBBMaxs(Entity) - Entity.OBBMins(Entity)
		if not Entity.ACF.Area then
			Entity.ACF.Area = ((Size.x * Size.y)+(Size.x * Size.z)+(Size.y * Size.z)) * 6.45
		end
		--if not Entity.ACF.Volume then
		--	Entity.ACF.Volume = Size.x * Size.y * Size.z * 16.38
		--end
	end
	
	Entity.ACF.Ductility = Entity.ACF.Ductility or 0
	--local Area = (Entity.ACF.Area+Entity.ACF.Area*math.Clamp(Entity.ACF.Ductility,-0.8,0.8))
	local Area = Entity.ACF.Area
	local Ductility = math.Clamp( Entity.ACF.Ductility, -0.8, 0.8 )
	local Armour = ACF_CalcArmor( Area, Ductility, Entity:GetPhysicsObject():GetMass() ) -- So we get the equivalent thickness of that prop in mm if all its weight was a steel plate
	local Health = ( Area / ACF.Threshold ) * ( 1 + Ductility ) -- Setting the threshold of the prop aera gone
	
	local Percent = 1 
	
	if Recalc and Entity.ACF.Health and Entity.ACF.MaxHealth then
		Percent = Entity.ACF.Health/Entity.ACF.MaxHealth
	end
	
	Entity.ACF.Health = Health * Percent
	Entity.ACF.MaxHealth = Health
	Entity.ACF.Armour = Armour * (0.5 + Percent/2)
	Entity.ACF.MaxArmour = Armour * ACF.ArmorMod
	Entity.ACF.Type = nil
	Entity.ACF.Mass = PhysObj:GetMass()
	--Entity.ACF.Density = (PhysObj:GetMass()*1000)/Entity.ACF.Volume
	
	if Entity:IsPlayer() or Entity:IsNPC() then
		Entity.ACF.Type = "Squishy"
	elseif Entity:IsVehicle() then
		Entity.ACF.Type = "Vehicle"
	else
		Entity.ACF.Type = "Prop"
	end
	--print(Entity.ACF.Health)
end

local GlobalFilter = {}
local Invalid = {
	gmod_ghost = true,
	debris = true,
	prop_ragdoll = true,
	func_ = true
}

function ACF_Check ( Entity )
	if not GlobalFilter[Entity] and IsValid(Entity) and IsValid(Entity:GetPhysicsObject()) and not Entity:IsWorld() and not Entity:IsWeapon() then
		local Class = Entity:GetClass()
		if not Invalid[Class] and not Invalid[string.sub(Class, 1, 5)] then
			if not Entity.ACF then 
				ACF_Activate( Entity )
			elseif Entity.ACF.Mass ~= Entity:GetPhysicsObject():GetMass() then
				ACF_Activate( Entity , true )
			end
			--print("ACF_Check "..Entity.ACF.Type)
			return Entity.ACF.Type	
		end	
	end

	if not GlobalFilter[Entity] then GlobalFilter[Entity] = true end
	return false
end

function ACF_Damage ( Entity , Energy , FrArea , Angle , Inflictor , Bone, Gun, Type ) 
	
	local Activated = ACF_Check( Entity )
	if hook.Run("ACF_BulletDamage", Activated, Entity, Energy, FrArea, Angle, Inflictor, Bone, Gun ) == false then
		return { Damage = 0, Overkill = 0, Loss = 0, Kill = false }		
	end
	
	if Entity.SpecialDamage then
		return Entity:ACF_OnDamage( Entity , Energy , FrArea , Angle , Inflictor , Bone, Type )
	elseif Activated == "Prop" then	
		
		return ACF_PropDamage( Entity , Energy , FrArea , Angle , Inflictor , Bone )
		
	elseif Activated == "Vehicle" then
	
		return ACF_VehicleDamage( Entity , Energy , FrArea , Angle , Inflictor , Bone, Gun )
		
	elseif Activated == "Squishy" then
	
		return ACF_SquishyDamage( Entity , Energy , FrArea , Angle , Inflictor , Bone, Gun )
		
	end
	
end

function ACF_CalcDamage( Entity , Energy , FrArea , Angle )

	local Armour = Entity.ACF.Armour/math.abs( math.cos(math.rad(Angle)) ) --Calculate Line Of Sight thickness of the armour
	local Structure = Entity.ACF.Density --Structural strengh of the material, derived from prop density, denser stuff is more vulnerable (Density is different than armour, calculated off real volume)
	
	local MaxPenetration = (Energy.Penetration / FrArea) * ACF.KEtoRHA							--Let's see how deep the projectile penetrates ( Energy = Kinetic Energy, FrArea = Frontal aera in cm2 )
	local Penetration = math.min( MaxPenetration , Armour )			--Clamp penetration to the armour thickness
	
	local HitRes = {}
	
	HitRes.Damage = (Penetration/Armour)^2 * FrArea --/math.abs( math.cos(math.rad(Angle/1.25)) )	-- This is the volume of the hole caused by our projectile, with area adjusted by slope
	HitRes.Overkill = (MaxPenetration - Penetration)
	HitRes.Loss = Penetration/MaxPenetration
	
	return HitRes
end

function ACF_PropDamage( Entity , Energy , FrArea , Angle , Inflictor , Bone )

	local HitRes = ACF_CalcDamage( Entity , Energy , FrArea , Angle )
	
	HitRes.Kill = false
	if HitRes.Damage >= Entity.ACF.Health then
		HitRes.Kill = true 
	else
		Entity.ACF.Health = Entity.ACF.Health - HitRes.Damage
		Entity.ACF.Armour = Entity.ACF.MaxArmour * (0.5 + Entity.ACF.Health/Entity.ACF.MaxHealth/2) --Simulating the plate weakening after a hit
		
		if Entity.ACF.PrHealth then
			ACF_UpdateVisualHealth(Entity)
		end
		Entity.ACF.PrHealth = Entity.ACF.Health
	end
	
	return HitRes
	
end

function ACF_VehicleDamage( Entity , Energy , FrArea , Angle , Inflictor , Bone, Gun )

	local HitRes = ACF_CalcDamage( Entity , Energy , FrArea , Angle )
	
	if IsValid(Entity:GetDriver()) then
		ACF_SquishyDamage(Entity:GetDriver() , Energy , FrArea , Angle , Inflictor , 2, Gun) -- Deal torso damage
	end

	HitRes.Kill = false
	if HitRes.Damage >= Entity.ACF.Health then
		HitRes.Kill = true 
	else
		Entity.ACF.Health = Entity.ACF.Health - HitRes.Damage
		Entity.ACF.Armour = Entity.ACF.Armour * (0.5 + Entity.ACF.Health/Entity.ACF.MaxHealth/2) --Simulating the plate weakening after a hit
	end
		
	return HitRes
end

function ACF_SquishyDamage( Entity , Energy , FrArea , Angle , Inflictor , Bone, Gun)
	
	local Size = Entity:BoundingRadius()
	local Mass = Entity:GetPhysicsObject():GetMass()
	local HitRes = {}
	local Damage = 0
	local Target = {ACF = {Armour = 0.1}}		--We create a dummy table to pass armour values to the calc function
	if (Bone) then
		
		if ( Bone == 1 ) then		--This means we hit the head
			Target.ACF.Armour = Mass*0.02	--Set the skull thickness as a percentage of Squishy weight, this gives us 2mm for a player, about 22mm for an Antlion Guard. Seems about right
			HitRes = ACF_CalcDamage( Target , Energy , FrArea , Angle )		--This is hard bone, so still sensitive to impact angle
			Damage = HitRes.Damage*20
			if HitRes.Overkill > 0 then									--If we manage to penetrate the skull, then MASSIVE DAMAGE
				Target.ACF.Armour = Size*0.25*0.01						--A quarter the bounding radius seems about right for most critters head size
				HitRes = ACF_CalcDamage( Target , Energy , FrArea , 0 )
				Damage = Damage + HitRes.Damage*100
			end
			Target.ACF.Armour = Mass*0.065	--Then to check if we can get out of the other side, 2x skull + 1x brains
			HitRes = ACF_CalcDamage( Target , Energy , FrArea , Angle )	
			Damage = Damage + HitRes.Damage*20				
			
		elseif ( Bone == 0 or Bone == 2 or Bone == 3 ) then		--This means we hit the torso. We are assuming body armour/tough exoskeleton/zombie don't give fuck here, so it's tough
			Target.ACF.Armour = Mass*0.08	--Set the armour thickness as a percentage of Squishy weight, this gives us 8mm for a player, about 90mm for an Antlion Guard. Seems about right
			HitRes = ACF_CalcDamage( Target , Energy , FrArea , Angle )		--Armour plate,, so sensitive to impact angle
			Damage = HitRes.Damage*5
			if HitRes.Overkill > 0 then
				Target.ACF.Armour = Size*0.5*0.02							--Half the bounding radius seems about right for most critters torso size
				HitRes = ACF_CalcDamage( Target , Energy , FrArea , 0 )		
				Damage = Damage + HitRes.Damage*50							--If we penetrate the armour then we get into the important bits inside, so DAMAGE
			end
			Target.ACF.Armour = Mass*0.185	--Then to check if we can get out of the other side, 2x armour + 1x guts
			HitRes = ACF_CalcDamage( Target , Energy , FrArea , Angle )
			
		elseif ( Bone == 4 or Bone == 5 ) then 		--This means we hit an arm or appendage, so ormal damage, no armour
		
			Target.ACF.Armour = Size*0.2*0.02							--A fitht the bounding radius seems about right for most critters appendages
			HitRes = ACF_CalcDamage( Target , Energy , FrArea , 0 )		--This is flesh, angle doesn't matter
			Damage = HitRes.Damage*30							--Limbs are somewhat less important
		
		elseif ( Bone == 6 or Bone == 7 ) then
		
			Target.ACF.Armour = Size*0.2*0.02							--A fitht the bounding radius seems about right for most critters appendages
			HitRes = ACF_CalcDamage( Target , Energy , FrArea , 0 )		--This is flesh, angle doesn't matter
			Damage = HitRes.Damage*30							--Limbs are somewhat less important
			
		elseif ( Bone == 10 ) then					--This means we hit a backpack or something
		
			Target.ACF.Armour = Size*0.1*0.02							--Arbitrary size, most of the gear carried is pretty small
			HitRes = ACF_CalcDamage( Target , Energy , FrArea , 0 )		--This is random junk, angle doesn't matter
			Damage = HitRes.Damage*2								--Damage is going to be fright and shrapnel, nothing much		

		else 										--Just in case we hit something not standard
		
			Target.ACF.Armour = Size*0.2*0.02						
			HitRes = ACF_CalcDamage( Target , Energy , FrArea , 0 )
			Damage = HitRes.Damage*30	
			
		end
		
	else 										--Just in case we hit something not standard
	
		Target.ACF.Armour = Size*0.2*0.02						
		HitRes = ACF_CalcDamage( Target , Energy , FrArea , 0 )
		Damage = HitRes.Damage*10	
	
	end
	

	Entity:TakeDamage( Damage * 2.5, Inflictor, Gun )
	
	HitRes.Kill = false
	--print(Damage)
	--print(Bone)
		
	return HitRes
end

----------------------------------------------------------
-- Returns a table of all physically connected entities
-- ignoring ents attached by only nocollides
----------------------------------------------------------
function ACF_GetAllPhysicalConstraints( ent, ResultTable )
	if not IsValid( ent ) then return end
	
	local ResultTable = ResultTable or {}

	if ResultTable[ ent ] then return end
	ResultTable[ ent ] = ent
	
	local ConTable = constraint.GetTable( ent )
	
	for k, con in ipairs( ConTable ) do
		-- skip shit that is attached by a nocollide
		if con.Type ~= "NoCollide" then
			for EntNum, Ent in pairs( con.Entity ) do
				ACF_GetAllPhysicalConstraints( Ent.Entity, ResultTable )
			end
		end
	
	end

	return ResultTable
	
end

-- for those extra sneaky bastards
function ACF_GetAllChildren( ent, ResultTable )
	
	if not ent.GetChildren or not IsValid( ent ) then return end
	
	local ResultTable = ResultTable or {}
	
	if ResultTable[ ent ] then return end
	
	ResultTable[ ent ] = ent

	for k, v in pairs( ent:GetChildren() or {} ) do
		ACF_GetAllChildren( v, ResultTable )
	end
	
	return ResultTable
	
end

function ACF_GetAncestor( Ent )
	local Parent = Ent:GetParent()
	if not IsValid(Parent) then return Ent end
	
	while IsValid(Parent:GetParent()) do Parent = Parent:GetParent() end
	
	return Parent
end