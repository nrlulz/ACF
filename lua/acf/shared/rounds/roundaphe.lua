
AddCSLuaFile()

ACF.AmmoBlacklist.APHE = { "MO", "MG" }

local Round = {}

Round.type = "Ammo" --Tells the spawn menu what entity to spawn
Round.name = "Armour Piercing Explosive (APHE)" --Human readable name
Round.model = "models/munitions/round_100mm_shot.mdl" --Shell flight model
Round.desc = "An armour piercing round with a cavity for High explosives. Less capable of defeating armour than plain Armour Piercing, but will explode after penetration"
Round.netid = 5 --Unique ammotype ID for network transmission

function Round.create( Gun, BulletData )
	
	ACF_CreateBullet( BulletData )
	
end
		
-- Function to convert the player's slider data into the complete round data
function Round.convert( Crate, PlayerData )
	
	local Data = {}
	local ServerData = {}
	local GUIData = {}
	
	if not PlayerData.PropLength then PlayerData.PropLength = 0 end
	if not PlayerData.ProjLength then PlayerData.ProjLength = 0 end
	if not PlayerData.Data5 then PlayerData.Data5 = 0 end
	if not PlayerData.Data10 then PlayerData.Data10 = 0 end
	
	PlayerData, Data, ServerData, GUIData = ACF_RoundBaseGunpowder( PlayerData, Data, ServerData, GUIData )
	
	--Shell sturdiness calcs
	Data.ProjMass = math.max(GUIData.ProjVolume-PlayerData.Data5,0)*7.9/1000 + math.min(PlayerData.Data5,GUIData.ProjVolume)*ACF.HEDensity/1000--Volume of the projectile as a cylinder - Volume of the filler * density of steel + Volume of the filler * density of TNT
	Data.MuzzleVel = ACF_MuzzleVelocity( Data.PropMass, Data.ProjMass, Data.Caliber )
	local Energy = ACF_Kinetic( Data.MuzzleVel*39.37 , Data.ProjMass, Data.LimitVel )
		
	local MaxVol = ACF_RoundShellCapacity( Energy.Momentum, Data.FrAera, Data.Caliber, Data.ProjLength )
	GUIData.MinFillerVol = 0
	GUIData.MaxFillerVol = math.min(GUIData.ProjVolume,MaxVol*0.9)
	GUIData.FillerVol = math.min(PlayerData.Data5,GUIData.MaxFillerVol)
	Data.FillerMass = GUIData.FillerVol * ACF.HEDensity/1000
	
	Data.ProjMass = math.max(GUIData.ProjVolume-GUIData.FillerVol,0)*7.9/1000 + Data.FillerMass
	Data.MuzzleVel = ACF_MuzzleVelocity( Data.PropMass, Data.ProjMass, Data.Caliber )
	
	--Random bullshit left
	Data.ShovePower = 0.1
	Data.PenAera = Data.FrAera^ACF.PenAreaMod
	Data.DragCoef = ((Data.FrAera/10000)/Data.ProjMass)
	Data.LimitVel = 700										--Most efficient penetration speed in m/s
	Data.KETransfert = 0.1									--Kinetic energy transfert to the target for movement purposes
	Data.Ricochet = 75										--Base ricochet angle
	
	Data.BoomPower = Data.PropMass + Data.FillerMass

	if SERVER then --Only the crates need this part
		ServerData.Id = PlayerData.Id
		ServerData.Type = PlayerData.Type
		return table.Merge(Data,ServerData)
	end
	
	if CLIENT then --Only tthe GUI needs this part
		GUIData = table.Merge(GUIData, Round.getDisplayData(Data))
		return table.Merge(Data,GUIData)
	end
	
end


function Round.getDisplayData(Data)
	local GUIData = {}
	local Energy = ACF_Kinetic( Data.MuzzleVel*39.37 , Data.ProjMass - Data.FillerMass, Data.LimitVel )
	GUIData.MaxPen = (Energy.Penetration/Data.PenAera)*ACF.KEtoRHA
	
	GUIData.BlastRadius = (Data.FillerMass)^0.33*8
	local FragMass = Data.ProjMass - Data.FillerMass
	GUIData.Fragments = math.max(math.floor((Data.FillerMass/FragMass)*ACF.HEFrag),2)
	GUIData.FragMass = FragMass/GUIData.Fragments
	GUIData.FragVel = (Data.FillerMass*ACF.HEPower*1000/GUIData.FragMass/GUIData.Fragments)^0.5
	return GUIData
end


function Round.network( Crate, BulletData )

	Crate:SetNetworkedString( "AmmoType", "APHE" )
	Crate:SetNetworkedString( "AmmoID", BulletData.Id )
	Crate:SetNetworkedInt( "Caliber", BulletData.Caliber )
	Crate:SetNetworkedInt( "ProjMass", BulletData.ProjMass )
	Crate:SetNetworkedInt( "FillerMass", BulletData.FillerMass )
	Crate:SetNetworkedInt( "PropMass", BulletData.PropMass )
	Crate:SetNetworkedInt( "DragCoef", BulletData.DragCoef )
	Crate:SetNetworkedInt( "MuzzleVel", BulletData.MuzzleVel )
	Crate:SetNetworkedInt( "Tracer", BulletData.Tracer )

end

function Round.cratetxt( BulletData )
	
	local DData = Round.getDisplayData(BulletData)
	
	local str = 
	{
		"Muzzle Velocity: ", math.Round(BulletData.MuzzleVel, 1), " m/s\n",
		"Max Penetration: ", math.floor(DData.MaxPen), " mm\n",
		"Blast Radius: ", math.Round(DData.BlastRadius, 1), " m\n",
		"Blast Energy: ", math.floor((BulletData.FillerMass) * ACF.HEPower), " KJ"
	}
	
	return table.concat(str)
	
end

function Round.propimpact( Index, Bullet, Target, HitNormal, HitPos, Bone )
	
	if ACF_Check( Target ) then
	
		local Speed = Bullet.Flight:Length() / ACF.VelScale
		local Energy = ACF_Kinetic( Speed , Bullet.ProjMass - Bullet.FillerMass, Bullet.LimitVel )
		local HitRes = ACF_RoundImpact( Bullet, Speed, Energy, Target, HitPos, HitNormal , Bone )
		
		if HitRes.Overkill > 0 then
			table.insert( Bullet.Filter , Target )					--"Penetrate" (Ingoring the prop for the retry trace)
			ACF_Spall( HitPos , Bullet.Flight , Bullet.Filter , Energy.Kinetic*HitRes.Loss , Bullet.Caliber , Target.ACF.Armour , Bullet.Owner ) --Do some spalling
			Bullet.Flight = Bullet.Flight:GetNormalized() * (Energy.Kinetic*(1-HitRes.Loss)*2000/Bullet.ProjMass)^0.5 * 39.37
			return "Penetrated"
		elseif HitRes.Ricochet then
			return "Ricochet"
		else
			return false
		end
	else 
		table.insert( Bullet.Filter , Target )
	return "Penetrated" end
	
end

function Round.worldimpact( Index, Bullet, HitPos, HitNormal )
	
	local Energy = ACF_Kinetic( Bullet.Flight:Length() / ACF.VelScale, Bullet.ProjMass - Bullet.FillerMass, Bullet.LimitVel )
	if ACF_PenetrateGround( Bullet, Energy, HitPos ) then
		return "Penetrated"
	else
		return false
	end

end

function Round.endflight( Index, Bullet, HitPos, HitNormal )
	
	ACF_HE( HitPos - Bullet.Flight:GetNormalized()*3 , HitNormal , Bullet.FillerMass , Bullet.ProjMass - Bullet.FillerMass , Bullet.Owner )
	ACF_RemoveBullet( Index )
	
end

function Round.endeffect( Effect, Bullet )
	
	local Radius = (Bullet.FillerMass)^0.33*8*39.37
	local Flash = EffectData()
		Flash:SetOrigin( Bullet.SimPos )
		Flash:SetNormal( Bullet.SimFlight:GetNormalized() )
		Flash:SetRadius( math.max( Radius, 1 ) )
	util.Effect( "ACF_Scaled_Explosion", Flash )
	
end

function Round.pierceeffect( Effect, Bullet )
	
	local Spall = EffectData()
		Spall:SetEntity( Bullet.Crate )
		Spall:SetOrigin( Bullet.SimPos )
		Spall:SetNormal( (Bullet.SimFlight):GetNormalized() )
		Spall:SetScale( Bullet.SimFlight:Length() )
		Spall:SetMagnitude( Bullet.RoundMass )
	util.Effect( "ACF_AP_Penetration", Spall )
	
end

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
	
	acfmenupanel:AmmoSelect( ACF.AmmoBlacklist.APHE )

	acfmenupanel:CPanelText("Desc", "")	--Description (Name, Desc)
	acfmenupanel:CPanelText("LengthDisplay", "")	--Total round length (Name, Desc)
	
	acfmenupanel:AmmoSlider("PropLength",0,0,1000,3, "Propellant Length", "")	--Propellant Length Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("ProjLength",0,0,1000,3, "Projectile Length", "")	--Projectile Length Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("FillerVol",0,0,1000,3, "HE Filler", "")--Hollow Point Cavity Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	
	acfmenupanel:AmmoCheckbox("Tracer", "Tracer", "")			--Tracer checkbox (Name, Title, Desc)
	
	acfmenupanel:CPanelText("VelocityDisplay", "")	--Proj muzzle velocity (Name, Desc)
	acfmenupanel:CPanelText("PenetrationDisplay", "")	--Proj muzzle penetration (Name, Desc)
	acfmenupanel:CPanelText("BlastDisplay", "")	--HE Blast data (Name, Desc)
	acfmenupanel:CPanelText("FragDisplay", "")	--HE Fragmentation data (Name, Desc)
	
	Round.guiupdate( Panel, Table )
	
end

function Round.guiupdate( Panel, Table )
	
	local PlayerData = {}
		PlayerData.Id = acfmenupanel.AmmoData.Data.id			--AmmoSelect GUI
		PlayerData.Type = "APHE"										--Hardcoded, match ACFRoundTypes table index
		PlayerData.PropLength = acfmenupanel.AmmoData.PropLength	--PropLength slider
		PlayerData.ProjLength = acfmenupanel.AmmoData.ProjLength	--ProjLength slider
		PlayerData.Data5 = acfmenupanel.AmmoData.FillerVol
		local Tracer = 0
		if acfmenupanel.AmmoData.Tracer then Tracer = 1 end
		PlayerData.Data10 = Tracer				--Tracer
	
	local Data = Round.convert( Panel, PlayerData )
	
	RunConsoleCommand( "acfmenu_data1", acfmenupanel.AmmoData.Data.id )
	RunConsoleCommand( "acfmenu_data2", PlayerData.Type )
	RunConsoleCommand( "acfmenu_data3", Data.PropLength )		--For Gun ammo, Data3 should always be Propellant
	RunConsoleCommand( "acfmenu_data4", Data.ProjLength )		--And Data4 total round mass
	RunConsoleCommand( "acfmenu_data5", Data.FillerVol )
	RunConsoleCommand( "acfmenu_data10", Data.Tracer )
	
	acfmenupanel:AmmoSlider("PropLength",Data.PropLength,Data.MinPropLength,Data.MaxTotalLength,3, "Propellant Length", "Propellant Mass : "..(math.floor(Data.PropMass*1000)).." g" )	--Propellant Length Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("ProjLength",Data.ProjLength,Data.MinProjLength,Data.MaxTotalLength,3, "Projectile Length", "Projectile Mass : "..(math.floor(Data.ProjMass*1000)).." g")	--Projectile Length Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("FillerVol",Data.FillerVol,Data.MinFillerVol,Data.MaxFillerVol,3, "HE Filler Volume", "HE Filler Mass : "..(math.floor(Data.FillerMass*1000)).." g")	--HE Filler Slider (Name, Min, Max, Decimals, Title, Desc)
	
	acfmenupanel:AmmoCheckbox("Tracer", "Tracer : "..(math.floor(Data.Tracer*10)/10).."cm\n", "" )			--Tracer checkbox (Name, Title, Desc)

	acfmenupanel:CPanelText("Desc", ACF.RoundTypes[PlayerData.Type].desc)	--Description (Name, Desc)
	acfmenupanel:CPanelText("LengthDisplay", "Round Length : "..(math.floor((Data.PropLength+Data.ProjLength+Data.Tracer)*100)/100).."/"..(Data.MaxTotalLength).." cm")	--Total round length (Name, Desc)
	acfmenupanel:CPanelText("VelocityDisplay", "Muzzle Velocity : "..math.floor(Data.MuzzleVel*ACF.VelScale).." m/s")	--Proj muzzle velocity (Name, Desc)	
	acfmenupanel:CPanelText("PenetrationDisplay", "Maximum Penetration : "..math.floor(Data.MaxPen).." mm RHA")	--Proj muzzle penetration (Name, Desc)
	acfmenupanel:CPanelText("BlastDisplay", "Blast Radius : "..(math.floor(Data.BlastRadius*100)/100).." m")	--Proj muzzle velocity (Name, Desc)
	acfmenupanel:CPanelText("FragDisplay", "Fragments : "..(Data.Fragments).."\n Average Fragment Weight : "..(math.floor(Data.FragMass*10000)/10).." g \n Average Fragment Velocity : "..math.floor(Data.FragVel).." m/s")	--Proj muzzle penetration (Name, Desc)
	
end

list.Set( "ACFRoundTypes", "APHE", Round )  --Set the round properties
list.Set( "ACFIdRounds", Round.netid, "APHE" ) --Index must equal the ID entry in the table above, Data must equal the index of the table above
