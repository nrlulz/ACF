AddCSLuaFile()

ACF.AmmoBlacklist["FL"] = { "AC", "RAC", "MG", "HMG", "GL", "SL" }

local Round = {}

Round.type = "Ammo" --Tells the spawn menu what entity to spawn
Round.name = "Flechette (FL)" --Human readable name
Round.model = "models/munitions/dart_100mm.mdl" --Shell flight model
Round.desc = "Flechette rounds contain several long thin steel spikes, functioning as a shotgun shell for cannons.  While it seems like the spikes would penetrate well, they tend to tumble in flight and impact at less than ideal angles, causing only minor penetration and structural damage.  They are best used against infantry or lightly armored mobile targets such as aircraft or light tanks, since flechettes trade brute damage for a better chance to hit."
Round.netid = 8 --Unique ammotype ID for network transmission

function Round.create( Gun, BulletData )
	
	--setup flechettes
	local FlechetteData = {}
	FlechetteData["Caliber"] = math.Round( BulletData["FlechetteRadius"]*0.2 ,2)
	FlechetteData["Id"] = BulletData["Id"]
	FlechetteData["Type"] = "AP" --BulletData["Type"]
	FlechetteData["Owner"] = BulletData["Owner"]
	FlechetteData["Crate"] = BulletData["Crate"]
	FlechetteData["Gun"] = BulletData["Gun"]
	FlechetteData["Pos"] = BulletData["Pos"]
	FlechetteData["FrAera"] = BulletData["FlechetteArea"]
	FlechetteData["ProjMass"] = BulletData["FlechetteMass"]
	FlechetteData["DragCoef"] = BulletData["FlechetteDragCoef"]
	FlechetteData["Tracer"] = BulletData["Tracer"]
	FlechetteData["LimitVel"] = BulletData["LimitVel"]
	FlechetteData["Ricochet"] = BulletData["Ricochet"]
	FlechetteData["PenAera"] = BulletData["FlechettePenArea"]
	FlechetteData["ShovePower"] = BulletData["ShovePower"]
	FlechetteData["KETransfert"] = BulletData["KETransfert"]

	local I=1
	local MuzzleVec
	
	if Gun:GetClass() == "acf_ammo" then --if ammo is cooking off, shoot in random direction
		local Inaccuracy
		MuzzleVec = VectorRand()
		for I = 1, BulletData["Flechettes"] do
			Inaccuracy = VectorRand() / 360 * ((Gun.Inaccuracy or 0) + BulletData["FlechetteSpread"])
			FlechetteData["Flight"] = (MuzzleVec+Inaccuracy):GetNormalized() * BulletData["MuzzleVel"] * 39.37 + Gun:GetVelocity()
			ACF_CreateBullet( FlechetteData )
		end
	else
		local BaseInaccuracy = math.tan(math.rad(Gun:GetInaccuracy()))
		local AddInaccuracy = math.tan(math.rad(BulletData["FlechetteSpread"]))
		MuzzleVec = Gun:GetForward()
		for I = 1, BulletData["Flechettes"] do
			BaseSpread = BaseInaccuracy * (math.random() ^ (1 / math.Clamp(ACF.GunInaccuracyBias, 0.5, 4))) * (Gun:GetUp() * (2 * math.random() - 1) + Gun:GetRight() * (2 * math.random() - 1)):GetNormalized()
			AddSpread = AddInaccuracy * (math.random() ^ (1 / math.Clamp(ACF.GunInaccuracyBias, 0.5, 4))) * (Gun:GetUp() * (2 * math.random() - 1) + Gun:GetRight() * (2 * math.random() - 1)):GetNormalized()
			FlechetteData["Flight"] = (MuzzleVec+BaseSpread+AddSpread):GetNormalized() * BulletData["MuzzleVel"] * 39.37 + Gun:GetVelocity()
			ACF_CreateBullet( FlechetteData )
		end
	end
	
end

-- Function to convert the player's slider data into the complete round data
function Round.convert( Crate, PlayerData )

	local Data = {}
	local ServerData = {}
	local GUIData = {}

	GUIData["LengthAdj"] = 0.5
	if not PlayerData["PropLength"] then PlayerData["PropLength"] = 0 end
	if not PlayerData["ProjLength"] then PlayerData["ProjLength"] = 0 end
	if not PlayerData["Data5"] then PlayerData["Data5"] = 3 end --flechette count
	if not PlayerData["Data6"] then PlayerData["Data6"] = 5 end --flechette spread
	if not PlayerData["Data10"] then PlayerData["Data10"] = 0 end --tracer
	PlayerData, Data, ServerData, GUIData = ACF_RoundBaseGunpowder( PlayerData, Data, ServerData, GUIData )

	--pbn(Data)
	
	Data["Flechettes"] = math.floor(PlayerData["Data5"])  --number of flechettes
	Data["FlechetteSpread"] = PlayerData["Data6"]
	local PenAdj = 0.8 --higher means lower pen, but more structure (hp) damage (old: 2.35, 2.85)
	local RadiusAdj = 1.0 -- lower means less structure (hp) damage, but higher pen (old: 1.0, 0.8)
	local PackRatio = 0.0025*Data["Flechettes"]+0.69 --how efficiently flechettes are packed into shell
	Data["FlechetteRadius"] = math.sqrt( ( (PackRatio*RadiusAdj*Data["Caliber"]/2)^2 ) / Data["Flechettes"] ) -- max radius flechette can be, to fit number of flechettes in a shell
	Data["FlechetteArea"] = 3.1416 * Data["FlechetteRadius"]^2 -- area of a single flechette
	Data["FlechetteMass"] = Data["FlechetteArea"] * (Data["ProjLength"]*7.9/1000) -- volume of single flechette * density of steel
	Data["FlechettePenArea"] = (PenAdj*Data["FlechetteArea"])^ACF.PenAreaMod
	Data["FlechetteDragCoef"] = (Data["FlechetteArea"]/10000)/Data["FlechetteMass"]

	Data["ProjMass"] = Data["Flechettes"] * Data["FlechetteMass"] -- total mass of all flechettes
	Data["PropMass"] = Data["PropMass"]
	Data["ShovePower"] = 0.2
	Data["PenAera"] = Data["FrAera"]^ACF.PenAreaMod
	Data["DragCoef"] = ((Data["FrAera"]/10000)/Data["ProjMass"])
	Data["LimitVel"] = 500										--Most efficient penetration speed in m/s
	Data["KETransfert"] = 0.1									--Kinetic energy transfert to the target for movement purposes
	Data["Ricochet"] = 75										--Base ricochet angle
	Data["MuzzleVel"] = ACF_MuzzleVelocity( Data["PropMass"], Data["ProjMass"], Data["Caliber"] )

	Data["BoomPower"] = Data["PropMass"]

	if SERVER then --Only the crates need this part
		ServerData["Id"] = PlayerData["Id"]
		ServerData["Type"] = PlayerData["Type"]
		return table.Merge(Data,ServerData)
	end

	if CLIENT then --Only the GUI needs this part
		GUIData = table.Merge(GUIData, Round.getDisplayData(Data, PlayerData))
		return table.Merge(Data,GUIData)
	end

end


function Round.getDisplayData(Data, PlayerData)
	local GUIData = {}
	local GunClass = ACF.Weapons["Guns"][(Data["Id"] or PlayerData["Id"])]["gunclass"]
	if GunClass == "SA" then
		GUIData["MaxFlechettes"] = math.Clamp(math.floor(Data["Caliber"]*3-4.5),1,32)
	elseif GunClass == "MO" then
		GUIData["MaxFlechettes"] = math.Clamp(math.floor(Data["Caliber"]*4)-12,1,32)
	elseif GunClass == "HW" then
		GUIData["MaxFlechettes"] = math.Clamp(math.floor(Data["Caliber"]*4)-10,1,32)
	else
		GUIData["MaxFlechettes"] = math.Clamp(math.floor(Data["Caliber"]*4)-8,1,32)
	end
	GUIData["MinFlechettes"] = math.min(6,GUIData["MaxFlechettes"]) --force bigger guns to have higher min count
	GUIData["MinSpread"] = 1
	GUIData["MaxSpread"] = 30
	local Energy = ACF_Kinetic( Data["MuzzleVel"]*39.37 , Data["FlechetteMass"], Data["LimitVel"] )
	GUIData["MaxPen"] = (Energy.Penetration/Data["FlechettePenArea"])*ACF.KEtoRHA
	return GUIData
end


function Round.network( Crate, BulletData )

	Crate:SetNetworkedString("AmmoType","FL")
	Crate:SetNetworkedString("AmmoID",BulletData["Id"])
	Crate:SetNetworkedInt("PropMass",BulletData["PropMass"])
	Crate:SetNetworkedInt("MuzzleVel",BulletData["MuzzleVel"])
	Crate:SetNetworkedInt("Tracer",BulletData["Tracer"])
	-- bullet effects use networked data, so set these to the flechette stats
	Crate:SetNetworkedInt("Caliber",math.Round( BulletData["FlechetteRadius"]*0.2 ,2))
	Crate:SetNetworkedInt("ProjMass",BulletData["FlechetteMass"])
	Crate:SetNetworkedInt("DragCoef",BulletData["FlechetteDragCoef"])
	--Crate:SetNetworkedInt("Caliber",BulletData["Caliber"])
	--Crate:SetNetworkedInt("ProjMass",BulletData["ProjMass"])
	--Crate:SetNetworkedInt("DragCoef",BulletData["DragCoef"])
	
end

function Round.cratetxt( BulletData )

	local DData = Round.getDisplayData(BulletData)
	
	local inaccuracy = 0
	local Gun = list.Get("ACFEnts").Guns[BulletData.Id]
	
	if Gun then
		local Classes = list.Get("ACFClasses")
		inaccuracy = (Classes.GunClass[Gun.gunclass] or {spread = 0}).spread
	end
	
	local coneAng = inaccuracy * ACF.GunInaccuracyScale
	
	local str = 
	{
		"Muzzle Velocity: ", math.Round(BulletData.MuzzleVel, 1), " m/s\n",
		"Max Penetration: ", math.floor(DData.MaxPen), " mm\n",
		"Max Spread: ", math.ceil((BulletData.FlechetteSpread + coneAng) * 10) / 10, " deg"
	}
	
	return table.concat(str)
	
end

function Round.propimpact( Index, Bullet, Target, HitNormal, HitPos, Bone )

	if ACF_Check( Target ) then

		local Speed = Bullet["Flight"]:Length() / ACF.VelScale
		local Energy = ACF_Kinetic( Speed , Bullet["ProjMass"], Bullet["LimitVel"] )
		local HitRes = ACF_RoundImpact( Bullet, Speed, Energy, Target, HitPos, HitNormal , Bone )

		if HitRes.Overkill > 0 then
			table.insert( Bullet["Filter"] , Target )					--"Penetrate" (Ingoring the prop for the retry trace)
			ACF_Spall( HitPos , Bullet["Flight"] , Bullet["Filter"] , Energy.Kinetic*HitRes.Loss , Bullet["Caliber"] , Target.ACF.Armour , Bullet["Owner"] ) --Do some spalling
			Bullet["Flight"] = Bullet["Flight"]:GetNormalized() * (Energy.Kinetic*(1-HitRes.Loss)*2000/Bullet["ProjMass"])^0.5 * 39.37
			return "Penetrated"
		elseif HitRes.Ricochet then
			return "Ricochet"
		else
			return false
		end
	else
		table.insert( Bullet["Filter"] , Target )
	return "Penetrated" end
	
end

function Round.worldimpact( Index, Bullet, HitPos, HitNormal )

	local Energy = ACF_Kinetic( Bullet["Flight"]:Length() / ACF.VelScale, Bullet["ProjMass"], Bullet["LimitVel"] )
	local Retry = ACF_PenetrateGround( Bullet, Energy, HitPos )
	if Retry then
		return "Penetrated"
	else
		return false
	end

end

function Round.endflight( Index, Bullet, HitPos )
	
	ACF_RemoveBullet( Index )
	
end

-- Bullet stops here
function Round.endeffect( Effect, Bullet )
	
	local Spall = EffectData()
		Spall:SetEntity( Bullet.Crate )
		Spall:SetOrigin( Bullet.SimPos )
		Spall:SetNormal( (Bullet.SimFlight):GetNormalized() )
		Spall:SetScale( Bullet.SimFlight:Length() )
		Spall:SetMagnitude( Bullet.RoundMass )
	util.Effect( "ACF_AP_Impact", Spall )

end

-- Bullet penetrated something
function Round.pierceeffect( Effect, Bullet )

	local Spall = EffectData()
		Spall:SetEntity( Bullet.Crate )
		Spall:SetOrigin( Bullet.SimPos )
		Spall:SetNormal( (Bullet.SimFlight):GetNormalized() )
		Spall:SetScale( Bullet.SimFlight:Length() )
		Spall:SetMagnitude( Bullet.RoundMass )
	util.Effect( "ACF_AP_Penetration", Spall )

end

-- Bullet ricocheted off something
function Round.ricocheteffect( Effect, Bullet )

	local Spall = EffectData()
		Spall:SetEntity( Bullet.Crate )
		Spall:SetOrigin( Bullet.SimPos )
		Spall:SetNormal( (Bullet.SimFlight):GetNormalized() )
		Spall:SetScale( Bullet.SimFlight:Length() )
		Spall:SetMagnitude( Bullet.RoundMass )
	util.Effect( "ACF_AP_Ricochet", Spall )
	
end

function Round.guicreate( Panel, Table )

	acfmenupanel:AmmoSelect( ACF.AmmoBlacklist["FL"] )

	acfmenupanel:CPanelText("Desc", "")	--Description (Name, Desc)
	acfmenupanel:CPanelText("LengthDisplay", "")	--Total round length (Name, Desc)

	acfmenupanel:AmmoSlider("PropLength",0,0,1000,3, "Propellant Length", "")	--Propellant Length Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("ProjLength",0,0,1000,3, "Projectile Length", "")	--Projectile Length Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("Flechettes",3,3,32,0, "Flechettes", "")	--flechette count Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("FlechetteSpread",10,5,60,1, "Flechette Spread", "")	--flechette spread Slider (Name, Value, Min, Max, Decimals, Title, Desc)

	acfmenupanel:AmmoCheckbox("Tracer", "Tracer", "")			--Tracer checkbox (Name, Title, Desc)

	acfmenupanel:CPanelText("VelocityDisplay", "")	--Proj muzzle velocity (Name, Desc)
	acfmenupanel:CPanelText("PenetrationDisplay", "")	--Proj muzzle penetration (Name, Desc)

	Round.guiupdate( Panel, Table )

end

function Round.guiupdate( Panel, Table )

	local PlayerData = {}
		PlayerData["Id"] = acfmenupanel.AmmoData["Data"]["id"]			--AmmoSelect GUI
		PlayerData["Type"] = "FL"										--Hardcoded, match ACFRoundTypes table index
		PlayerData["PropLength"] = acfmenupanel.AmmoData["PropLength"]	--PropLength slider
		PlayerData["ProjLength"] = acfmenupanel.AmmoData["ProjLength"]	--ProjLength slider
		PlayerData["Data5"] = acfmenupanel.AmmoData["Flechettes"]		--Flechette count slider
		PlayerData["Data6"] = acfmenupanel.AmmoData["FlechetteSpread"]		--flechette spread slider
		--PlayerData["Data7"] = acfmenupanel.AmmoData[Name]		--Not used
		--PlayerData["Data8"] = acfmenupanel.AmmoData[Name]		--Not used
		--PlayerData["Data9"] = acfmenupanel.AmmoData[Name]		--Not used
		local Tracer = 0
		if acfmenupanel.AmmoData["Tracer"] then Tracer = 1 end
		PlayerData["Data10"] = Tracer				--Tracer

	local Data = Round.convert( Panel, PlayerData )

	RunConsoleCommand( "acfmenu_data1", acfmenupanel.AmmoData["Data"]["id"] )
	RunConsoleCommand( "acfmenu_data2", PlayerData["Type"] )
	RunConsoleCommand( "acfmenu_data3", Data.PropLength )		--For Gun ammo, Data3 should always be Propellant
	RunConsoleCommand( "acfmenu_data4", Data.ProjLength )		--And Data4 total round mass
	RunConsoleCommand( "acfmenu_data5", Data.Flechettes )
	RunConsoleCommand( "acfmenu_data6", Data.FlechetteSpread )
	RunConsoleCommand( "acfmenu_data10", Data.Tracer )

	acfmenupanel:AmmoSlider("PropLength",Data.PropLength,Data.MinPropLength,Data["MaxTotalLength"],3, "Propellant Length", "Propellant Mass : "..(math.floor(Data.PropMass*1000)).." g" )	--Propellant Length Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("ProjLength",Data.ProjLength,Data.MinProjLength,Data["MaxTotalLength"],3, "Projectile Length", "Projectile Mass : "..(math.floor(Data.ProjMass*1000)).." g")	--Projectile Length Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("Flechettes",Data.Flechettes,Data.MinFlechettes,Data.MaxFlechettes,0, "Flechettes", "Flechette Radius: "..math.Round(Data["FlechetteRadius"]*10,2).." mm")
	acfmenupanel:AmmoSlider("FlechetteSpread",Data.FlechetteSpread,Data.MinSpread,Data.MaxSpread,1, "Flechette Spread", "")

	acfmenupanel:AmmoCheckbox("Tracer", "Tracer : "..(math.floor(Data.Tracer*10)/10).."cm\n", "" )			--Tracer checkbox (Name, Title, Desc)

	acfmenupanel:CPanelText("Desc", ACF.RoundTypes[PlayerData["Type"]]["desc"])	--Description (Name, Desc)
	acfmenupanel:CPanelText("LengthDisplay", "Round Length : "..(math.floor((Data.PropLength+Data.ProjLength+Data.Tracer)*100)/100).."/"..(Data.MaxTotalLength).." cm")	--Total round length (Name, Desc)
	acfmenupanel:CPanelText("VelocityDisplay", "Muzzle Velocity : "..math.floor(Data.MuzzleVel*ACF.VelScale).." m\\s")	--Proj muzzle velocity (Name, Desc)
	acfmenupanel:CPanelText("PenetrationDisplay", "Maximum Flechette Penetration : "..math.Round(Data.MaxPen,1).." mm RHA")	--Proj muzzle penetration (Name, Desc)

end

list.Set( "ACFRoundTypes", "FL", Round )  --Set the round properties
list.Set( "ACFIdRounds", Round.netid , "FL" ) --Index must equal the ID entry in the table above, Data must equal the index of the table above
