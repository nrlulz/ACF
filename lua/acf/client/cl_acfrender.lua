local Damaged = {
	CreateMaterial("ACF_Damaged1", "VertexLitGeneric", {["$basetexture"] = "damaged/damaged1"}),
	CreateMaterial("ACF_Damaged2", "VertexLitGeneric", {["$basetexture"] = "damaged/damaged2"}),
	CreateMaterial("ACF_Damaged3", "VertexLitGeneric", {["$basetexture"] = "damaged/damaged3"})
}

hook.Add("PostDrawOpaqueRenderables", "ACF_RenderDamage", function()
	if not ACF_HealthRenderList then return end
    cam.Start3D( EyePos(), EyeAngles() )
		for k,ent in pairs( ACF_HealthRenderList ) do
			--if ent:EntIndex() == 227 then print(  ent.ACF_Material ) end
			if IsValid(ent) then
				render.ModelMaterialOverride( ent.ACF_Material )
				render.SetBlend(math.Clamp(1- ent.ACF_HelathPercent,0,0.8))
				ent:DrawModel()
			elseif ACF_HealthRenderList then
				table.remove(ACF_HealthRenderList,k)
			end
		end
		render.ModelMaterialOverride()
		render.SetBlend(1)
	cam.End3D()
end)

net.Receive("ACF_RenderDamage", function()
	local Table = net.ReadTable()
	for k,v in ipairs( Table ) do
		local ent, Health, MaxHealth = ents.GetByIndex( v.ID ), v.Health, v.MaxHealth
		if not IsValid(ent) then return end
		if Health ~= MaxHealth then
			ent.ACF_Health = Health
			ent.ACF_MaxHealth = MaxHealth
			ent.ACF_HelathPercent = (Health/MaxHealth)
			if ent.ACF_HelathPercent > 0.7 then
				ent.ACF_Material = Damaged[1]
			elseif ent.ACF_HelathPercent > 0.3 then
				ent.ACF_Material = Damaged[2]
			elseif ent.ACF_HelathPercent <= 0.3 then
				ent.ACF_Material = Damaged[3]
			end
			ACF_HealthRenderList = ACF_HealthRenderList or {}
			ACF_HealthRenderList[ent:EntIndex()] = ent
		else
			if ACF_HealthRenderList then
				if #ACF_HealthRenderList<=1 then
					ACF_HealthRenderList = nil
				else
					table.remove(ACF_HealthRenderList,ent:EntIndex())
				end
				if ent.ACF then
					ent.ACF.Health = nil
					ent.ACF.MaxHealth = nil
				end
			end
		end
	end
end)

usermessage.Hook("Atest", function(msg)
	local ent = ents.GetByIndex( msg:ReadFloat() )
	local V1, V2, V3 = msg:ReadVector(), msg:ReadVector(), msg:ReadVector()
	hook.Add("HUDPaint", "AtestHook", function()
		if IsValid(ent) then
			local Vec1, Vec2, Vec3 = ent:LocalToWorld(V1):ToScreen(), ent:LocalToWorld(V2):ToScreen(), ent:LocalToWorld(V3):ToScreen()
			surface.DrawLine(Vec1.x,Vec1.y,Vec2.x,Vec2.y)
			surface.DrawLine(Vec2.x,Vec2.y,Vec3.x,Vec3.y)
			surface.DrawLine(Vec3.x,Vec3.y,Vec1.x,Vec1.y)
		else
			hook.Remove("AtestHook")
		end
	end)
end)