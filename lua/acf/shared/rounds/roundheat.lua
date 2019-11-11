
AddCSLuaFile()

ACF.AmmoBlacklist.HEAT = { "MG", "HMG", "RAC", "AC", "SL" , "SB" }

local Round = {}

Round.type = "Ammo" --Tells the spawn menu what entity to spawn
Round.name = "High Explosive Anti-Tank (HEAT)" --Human readable name
Round.model = "models/munitions/round_100mm_shot.mdl" --Shell flight model
Round.desc = "A shell with a shaped charge.  When the round detonates, the explosive energy is focused into driving a small molten metal penetrator into the victim with extreme force, though this results in reduced damage from the explosion itself.  Multiple layers of armor will dissipate the penetrator quickly."
Round.netid = 4 --Unique ammotype ID for network transmission

function Round.create( Gun, BulletData )
	
	ACF_CreateBullet( BulletData )
	
end

function Round.ConeCalc( ConeAngle, Radius, Length )
	
	local ConeLength = math.tan(math.rad(ConeAngle))*Radius
	local ConeAera = 3.1416 * Radius * (Radius^2 + ConeLength^2)^0.5
	local ConeVol = (3.1416 * Radius^2 * ConeLength)/3

	return ConeLength, ConeAera, ConeVol
	
end

-- calculates conversion of filler from powering HEAT jet to raw HE based on crush vel
-- above a threshold vel, HEAT jet doesn't have time to form properly, converting to raw HE proportionally
-- Vel needs to be in m/s (gmu*0.0254)
function Round.CrushCalc( Vel, FillerMass )
	local Crushed = math.Clamp( (Vel - ACF.HEATMinCrush) / (ACF.HEATMaxCrush - ACF.HEATMinCrush), 0,1)
	local HE_Filler = Lerp(Crushed, FillerMass*ACF.HEATBoomConvert, FillerMass)
	local HEAT_Filler = Lerp(Crushed, FillerMass, 0)
	--local HE_Filler = FillerMass * ACF.HEATBoomConvert + Crushed * FillerMass * (1-ACF.HEATBoomConvert)
	--local HEAT_Filler = (1-Crushed) * FillerMass
	return Crushed, HEAT_Filler, HE_Filler
end

-- coneang now required for slug recalculation at detonation, defaults to 55 if not present
function Round.CalcSlugMV( Data, HEATFillerMass )
	--keep fillermass/2 so that penetrator stays the same.
	return ( HEATFillerMass/2 * ACF.HEPower * math.sin(math.rad(10+(Data.ConeAng or 55))/2) /Data.SlugMass)^ACF.HEATMVScale
end

-- Function to convert the player's slider data into the complete round data
function Round.convert( Crate, PlayerData )
	
	local Data = {}
	local ServerData = {}
	local GUIData = {}
	
	if not PlayerData.PropLength then PlayerData.PropLength = 0 end
	if not PlayerData.ProjLength then PlayerData.ProjLength = 0 end
	PlayerData.Data5 = math.max(PlayerData.Data5 or 0, 0)
	if not PlayerData.Data6 then PlayerData.Data6 = 0 end
	if not PlayerData.Data7 then PlayerData.Data7 = 0 end
	if not PlayerData.Data10 then PlayerData.Data10 = 0 end
	
	PlayerData, Data, ServerData, GUIData = ACF_RoundBaseGunpowder( PlayerData, Data, ServerData, GUIData )

	local ConeThick = Data.Caliber/50
	local ConeLength = 0
	local ConeAera = 0
	local AirVol = 0
	ConeLength, ConeAera, AirVol = Round.ConeCalc( PlayerData.Data6, Data.Caliber/2, PlayerData.ProjLength )
	Data.ProjMass = math.max(GUIData.ProjVolume-PlayerData.Data5,0)*7.9/1000 + math.min(PlayerData.Data5,GUIData.ProjVolume)*ACF.HEDensity/1000 + ConeAera*ConeThick*7.9/1000 --Volume of the projectile as a cylinder - Volume of the filler - Volume of the crush cone * density of steel + Volume of the filler * density of TNT + Aera of the cone * thickness * density of steel
	Data.MuzzleVel = ACF_MuzzleVelocity( Data.PropMass, Data.ProjMass, Data.Caliber )
	local Energy = ACF_Kinetic( Data.MuzzleVel*39.37 , Data.ProjMass, Data.LimitVel )
	
	local MaxVol = 0
	local MaxLength = 0
	local MaxRadius = 0
	MaxVol, MaxLength, MaxRadius = ACF_RoundShellCapacity( Energy.Momentum, Data.FrAera, Data.Caliber, Data.ProjLength )
		
	GUIData.MinConeAng = 0
	GUIData.MaxConeAng = math.deg( math.atan((Data.ProjLength - ConeThick )/(Data.Caliber/2)) )
	Data.ConeAng = math.Clamp(PlayerData.Data6*1, GUIData.MinConeAng, GUIData.MaxConeAng)
	ConeLength, ConeAera, AirVol = Round.ConeCalc( Data.ConeAng, Data.Caliber/2, Data.ProjLength )
	local ConeVol = ConeAera * ConeThick
		
	GUIData.MinFillerVol = 0
	GUIData.MaxFillerVol = math.max(MaxVol -  AirVol - ConeVol,GUIData.MinFillerVol)
	GUIData.FillerVol = math.Clamp(PlayerData.Data5*1,GUIData.MinFillerVol,GUIData.MaxFillerVol)

	-- fillermass used for shell mass calcs
	-- heatfillermass is how much fillermass is used to power heat jet
	-- boomfillermass is how much fillermass creates HE damage on detonation. technically get 1/3 extra fillermass free as HE with no crushing, but screw trying to rebalance heat pen to properly use 1/3 of filler for HE and 2/3 for jet
	-- distribution of heat and boom fillermass is calculated at detonation, or for GUI stuff
	
	Data.FillerMass = GUIData.FillerVol * ACF.HEDensity/1450
	Data.ProjMass = math.max(GUIData.ProjVolume-GUIData.FillerVol- AirVol-ConeVol,0)*7.9/1000 + Data.FillerMass + ConeVol*7.9/1000
	Data.MuzzleVel = ACF_MuzzleVelocity( Data.PropMass, Data.ProjMass, Data.Caliber )
	local Energy = ACF_Kinetic( Data.MuzzleVel*39.37 , Data.ProjMass, Data.LimitVel )
	
	--Let's calculate the actual HEAT slug
	Data.SlugMass = ConeVol*7.9/1000
	local Rad = math.rad(Data.ConeAng/2)
	Data.SlugCaliber =  Data.Caliber - Data.Caliber * (math.sin(Rad)*0.5+math.cos(Rad)*1.5)/2
	
	local SlugFrAera = 3.1416 * (Data.SlugCaliber/2)^2
	Data.SlugPenAera = SlugFrAera^ACF.PenAreaMod
	Data.SlugDragCoef = ((SlugFrAera/10000)/Data.SlugMass)
	Data.SlugRicochet = 	500									--Base ricochet angle (The HEAT slug shouldn't ricochet at all)
	
	-- these are only for compatibility with other stuff. it's recalculated when the round is detonated
	local crush, heatfiller, boomfiller = Round.CrushCalc(Data.MuzzleVel, Data.FillerMass)
	Data.BoomFillerMass = boomfiller
	Data.SlugMV = Round.CalcSlugMV( Data, heatfiller )
	
	--Random bullshit left
	Data.CasingMass = Data.ProjMass - Data.FillerMass - ConeVol*7.9/1000
	Data.ShovePower = 0.1
	Data.PenAera = Data.FrAera^ACF.PenAreaMod
	Data.DragCoef = ((Data.FrAera/10000)/Data.ProjMass)
	Data.LimitVel = 100										--Most efficient penetration speed in m/s
	Data.KETransfert = 0.1									--Kinetic energy transfert to the target for movement purposes
	Data.Ricochet = 60										--Base ricochet angle
	Data.DetonatorAngle = 75
	
	Data.Detonated = false
	Data.NotFirstPen = false
	Data.BoomPower = Data.PropMass + Data.FillerMass -- for when a crate is cooking off

	if SERVER then --Only the crates need this part
		ServerData.Id = PlayerData.Id
		ServerData.Type = PlayerData.Type
		return table.Merge(Data,ServerData)
	end
	
	if CLIENT then --Only the GUI needs this part	
		GUIData = table.Merge(GUIData, Round.getDisplayData(Data))
		return table.Merge(Data, GUIData)
	end
	
end


function Round.getDisplayData(Data)
	local GUIData = {}

	-- these are only GUI info, it's recalculated when the round is detonated since it's vel dependent
	GUIData.Crushed, GUIData.HEATFillerMass, GUIData.BoomFillerMass = Round.CrushCalc(Data.MuzzleVel, Data.FillerMass)
	GUIData.SlugMV = Round.CalcSlugMV( Data, GUIData.HEATFillerMass ) * (Data.SlugPenMul or 1) -- slugpenmul is a missiles thing
	GUIData.SlugMassUsed = Data.SlugMass * (1-GUIData.Crushed)

	local SlugEnergy = ACF_Kinetic( Data.MuzzleVel*39.37 + GUIData.SlugMV*39.37 ,GUIData.SlugMassUsed , 999999 )
	GUIData.MaxPen = (SlugEnergy.Penetration/Data.SlugPenAera)*ACF.KEtoRHA

	GUIData.TotalFragMass = Data.CasingMass + Data.SlugMass * GUIData.Crushed
	GUIData.BlastRadius = (GUIData.BoomFillerMass)^0.33*8--*39.37
	GUIData.Fragments = math.max(math.floor((GUIData.BoomFillerMass/GUIData.TotalFragMass)*ACF.HEFrag),2)
	GUIData.FragMass = GUIData.TotalFragMass / GUIData.Fragments
	GUIData.FragVel = (GUIData.BoomFillerMass*ACF.HEPower*1000/GUIData.TotalFragMass)^0.5
	
	return GUIData
end


function Round.network( Crate, BulletData )

	Crate:SetNWString( "AmmoType", "HEAT" )
	Crate:SetNWString( "AmmoID", BulletData.Id )
	Crate:SetNWFloat( "Caliber", BulletData.Caliber )
	Crate:SetNWFloat( "ProjMass", BulletData.ProjMass )
	Crate:SetNWFloat( "FillerMass", BulletData.FillerMass )
	Crate:SetNWFloat( "PropMass", BulletData.PropMass )
	Crate:SetNWFloat( "DragCoef", BulletData.DragCoef )
	Crate:SetNWFloat( "SlugMass", BulletData.SlugMass )
	Crate:SetNWFloat( "SlugCaliber", BulletData.SlugCaliber )
	Crate:SetNWFloat( "SlugDragCoef", BulletData.SlugDragCoef )
	Crate:SetNWFloat( "MuzzleVel", BulletData.MuzzleVel )
	Crate:SetNWFloat( "Tracer", BulletData.Tracer )

end


--local fakeent = {ACF = {Armour = 0}}
--local fakepen = {Penetration = 999999999}
function Round.cratetxt( BulletData, builtFullData )
	
	local DData = Round.getDisplayData(BulletData)
	
	local str = 
	{
		"Muzzle Velocity: ", math.Round(BulletData.MuzzleVel, 1), " m/s\n",
		"Max Penetration: ", math.floor(DData.MaxPen), " mm\n",
		"Blast Radius: ", math.Round(DData.BlastRadius, 1), " m\n",
		"Blast Energy: ", math.floor((DData.BoomFillerMass) * ACF.HEPower), " KJ"
	}
	
	return table.concat(str)
	
end

function Round.detonate( Index, Bullet, HitPos, HitNormal )

	local Crushed, HEATFillerMass, BoomFillerMass = Round.CrushCalc(Bullet.Flight:Length()*0.0254, Bullet.FillerMass)

	ACF_HE( HitPos - Bullet.Flight:GetNormalized()*3, HitNormal, BoomFillerMass, Bullet.CasingMass + Bullet.SlugMass * Crushed, Bullet.Owner, nil, Bullet.Gun )

	if Crushed == 1 then return false end -- no HEAT jet to fire off, it was all converted to HE

	local SlugMV = Round.CalcSlugMV( Bullet, HEATFillerMass )

	Bullet.Detonated = true
	Bullet.InitTime = SysTime()
	Bullet.Flight = Bullet.Flight + Bullet.Flight:GetNormalized() * Round.CalcSlugMV( Bullet, HEATFillerMass ) * 39.37
	Bullet.FuseLength = 0.005 + 40/(Bullet.Flight:Length()*0.0254)
	Bullet.Pos = HitPos
	Bullet.DragCoef = Bullet.SlugDragCoef
	Bullet.ProjMass = Bullet.SlugMass * (1-Crushed)
	Bullet.Caliber = Bullet.SlugCaliber
	Bullet.PenAera = Bullet.SlugPenAera
	Bullet.Ricochet = Bullet.SlugRicochet
	
	local DeltaTime = SysTime() - Bullet.LastThink
	Bullet.StartTrace = Bullet.Pos - Bullet.Flight:GetNormalized()*math.min(ACF.PhysMaxVel*DeltaTime,Bullet.FlightTime*Bullet.Flight:Length())
	Bullet.NextPos = Bullet.Pos + (Bullet.Flight * ACF.VelScale * DeltaTime)		--Calculates the next shell position
	
	return true
end

function Round.propimpact( Index, Bullet, Target, HitNormal, HitPos, Bone )
	
	if ACF_Check( Target ) then
			
		if Bullet.Detonated then
			Bullet.NotFirstPen = true
			
			local Speed = Bullet.Flight:Length() / ACF.VelScale
			local Energy = ACF_Kinetic( Speed , Bullet.ProjMass, 999999 )
			local HitRes = ACF_RoundImpact( Bullet, Speed, Energy, Target, HitPos, HitNormal , Bone )
			
			if HitRes.Overkill > 0 then
				table.insert( Bullet.Filter , Target )					--"Penetrate" (Ingoring the prop for the retry trace)
				ACF_Spall( HitPos , Bullet.Flight , Bullet.Filter , Energy.Kinetic*HitRes.Loss , Bullet.Caliber , Target.ACF.Armour , Bullet.Owner ) --Do some spalling
				Bullet.Flight = Bullet.Flight:GetNormalized() * math.sqrt(Energy.Kinetic * (1 - HitRes.Loss) * ((Bullet.NotFirstPen and ACF.HEATPenLayerMul) or 1) * 2000 / Bullet.ProjMass) * 39.37 
				
				return "Penetrated"
			else
				return false
			end
	
		else
			
			local Speed = Bullet.Flight:Length() / ACF.VelScale
			local Energy = ACF_Kinetic( Speed , Bullet.ProjMass - Bullet.FillerMass, Bullet.LimitVel )
			local HitRes = ACF_RoundImpact( Bullet, Speed, Energy, Target, HitPos, HitNormal , Bone )
			
			if HitRes.Ricochet then
				return "Ricochet"
			else
				local jet = Round.detonate( Index, Bullet, HitPos, HitNormal )
				if jet then 
					return "Penetrated"
				else
					return false
				end
			end
			
		end
	else
		table.insert( Bullet.Filter , Target )
		return "Penetrated"
	end
	
	return false
	
end

function Round.worldimpact( Index, Bullet, HitPos, HitNormal )

	if not Bullet.Detonated then	
		local jet = Round.detonate( Index, Bullet, HitPos, HitNormal )
		if jet then 
			return "Penetrated"
		else
			return false
		end
	end
	
	local Energy = ACF_Kinetic( Bullet.Flight:Length() / ACF.VelScale, Bullet.ProjMass, 999999 )
	local HitRes = ACF_PenetrateGround( Bullet, Energy, HitPos, HitNormal )
	if HitRes.Penetrated then
		return "Penetrated"
	--elseif HitRes.Ricochet then  --penetrator won't ricochet
	--	return "Ricochet"
	else
		return false
	end
	
end

function Round.endflight( Index, Bullet, HitPos, HitNormal )
	
	ACF_RemoveBullet( Index )
	
end

function Round.endeffect( Effect, Bullet )
	
	local Impact = EffectData()
		Impact:SetEntity( Bullet.Crate )
		Impact:SetOrigin( Bullet.SimPos )
		Impact:SetNormal( (Bullet.SimFlight):GetNormalized() )
		Impact:SetScale( Bullet.SimFlight:Length() )
		Impact:SetMagnitude( Bullet.RoundMass )
	util.Effect( "ACF_AP_Impact", Impact )
	
end

function Round.pierceeffect( Effect, Bullet )
	
	if Bullet.Detonated then
	
		local Spall = EffectData()
			Spall:SetEntity( Bullet.Crate )
			Spall:SetOrigin( Bullet.SimPos )
			Spall:SetNormal( (Bullet.SimFlight):GetNormalized() )
			Spall:SetScale( Bullet.SimFlight:Length() )
			Spall:SetMagnitude( Bullet.RoundMass )
		util.Effect( "ACF_AP_Penetration", Spall )
	
	else
		
		local Crushed, HEATFillerMass, BoomFillerMass = Round.CrushCalc(Bullet.SimFlight:Length()*0.0254, Bullet.FillerMass)
		local Radius = (BoomFillerMass)^0.33*8*39.37
		local Flash = EffectData()
			Flash:SetOrigin( Bullet.SimPos )
			Flash:SetNormal( Bullet.SimFlight:GetNormalized() )
			Flash:SetRadius( math.max( Radius, 1 ) )
		util.Effect( "ACF_HEAT_Explosion", Flash )
		
		Bullet.Detonated = true
		Effect:SetModel("models/Gibs/wood_gib01e.mdl")
	
	end
	
end

function Round.ricocheteffect( Effect, Bullet )
	
	local Spall = EffectData()
		Spall:SetEntity( Bullet.Gun )
		Spall:SetOrigin( Bullet.SimPos )
		Spall:SetNormal( (Bullet.SimFlight):GetNormalized() )
		Spall:SetScale( Bullet.SimFlight:Length() )
		Spall:SetMagnitude( Bullet.RoundMass )
	util.Effect( "ACF_AP_Ricochet", Spall )
	
end

function Round.guicreate( Panel, Table )

	acfmenupanel:AmmoSelect( ACF.AmmoBlacklist.HEAT )
	
	acfmenupanel:CPanelText("BonusDisplay", "")
	
	acfmenupanel:CPanelText("Desc", "")	--Description (Name, Desc)
	acfmenupanel:CPanelText("LengthDisplay", "")	--Total round length (Name, Desc)
	
	--Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("PropLength",0,0,1000,3, "Propellant Length", "")	
	acfmenupanel:AmmoSlider("ProjLength",0,0,1000,3, "Projectile Length", "")	
	acfmenupanel:AmmoSlider("ConeAng",0,0,1000,3, "HEAT Cone Angle", "")
	acfmenupanel:AmmoSlider("FillerVol",0,0,1000,3, "Total HEAT Warhead volume", "")
	
	acfmenupanel:AmmoCheckbox("Tracer", "Tracer", "")			--Tracer checkbox (Name, Title, Desc)
	
	acfmenupanel:CPanelText("VelocityDisplay", "")	--Proj muzzle velocity (Name, Desc)
	acfmenupanel:CPanelText("BlastDisplay", "")	--HE Blast data (Name, Desc)
	acfmenupanel:CPanelText("FragDisplay", "")	--HE Fragmentation data (Name, Desc)
	
	--acfmenupanel:CPanelText("RicoDisplay", "")	--estimated rico chance
	acfmenupanel:CPanelText("SlugDisplay", "")	--HEAT Slug data (Name, Desc)
	
	Round.guiupdate( Panel, Table )
	
end

function Round.guiupdate( Panel, Table )
	
	local PlayerData = {}
		PlayerData.Id = acfmenupanel.AmmoData.Data.id			--AmmoSelect GUI
		PlayerData.Type = "HEAT"										--Hardcoded, match ACFRoundTypes table index
		PlayerData.PropLength = acfmenupanel.AmmoData.PropLength	--PropLength slider
		PlayerData.ProjLength = acfmenupanel.AmmoData.ProjLength	--ProjLength slider
		PlayerData.Data5 = acfmenupanel.AmmoData.FillerVol
		PlayerData.Data6 = acfmenupanel.AmmoData.ConeAng
		local Tracer = 0
		if acfmenupanel.AmmoData.Tracer then Tracer = 1 end
		PlayerData.Data10 = Tracer				--Tracer
	
	local Data = Round.convert( Panel, PlayerData )
	
	RunConsoleCommand( "acfmenu_data1", acfmenupanel.AmmoData.Data.id )
	RunConsoleCommand( "acfmenu_data2", PlayerData.Type )
	RunConsoleCommand( "acfmenu_data3", Data.PropLength )		--For Gun ammo, Data3 should always be Propellant
	RunConsoleCommand( "acfmenu_data4", Data.ProjLength )
	RunConsoleCommand( "acfmenu_data5", Data.FillerVol )
	RunConsoleCommand( "acfmenu_data6", Data.ConeAng )
	RunConsoleCommand( "acfmenu_data10", Data.Tracer )
	
	local vol = ACF.Weapons.Ammo[acfmenupanel.AmmoData["Id"]].volume
	local Cap, CapMul, RoFMul = ACF_CalcCrateStats( vol, Data.RoundVolume )
	
	acfmenupanel:CPanelText("BonusDisplay", "Crate info: +"..(math.Round((CapMul-1)*100,1)).."% capacity, +"..(math.Round((RoFMul-1)*-100,1)).."% RoF\nContains "..Cap.." rounds")
	
	acfmenupanel:AmmoSlider("PropLength",Data.PropLength,Data.MinPropLength,Data.MaxTotalLength,3, "Propellant Length", "Propellant Mass : "..(math.floor(Data.PropMass*1000)).." g" )	--Propellant Length Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("ProjLength",Data.ProjLength,Data.MinProjLength,Data.MaxTotalLength,3, "Projectile Length", "Projectile Mass : "..(math.floor(Data.ProjMass*1000)).." g")	--Projectile Length Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("ConeAng",Data.ConeAng,Data.MinConeAng,Data.MaxConeAng,0, "Crush Cone Angle", "")	--HE Filler Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("FillerVol",Data.FillerVol,Data.MinFillerVol,Data.MaxFillerVol,3, "HE Filler Volume", "HE Filler Mass : "..(math.floor(Data.FillerMass*1000)).." g")	--HE Filler Slider (Name, Min, Max, Decimals, Title, Desc)
	
	acfmenupanel:AmmoCheckbox("Tracer", "Tracer : "..(math.floor(Data.Tracer*10)/10).."cm\n", "" )			--Tracer checkbox (Name, Title, Desc)

	acfmenupanel:CPanelText("Desc", ACF.RoundTypes[PlayerData.Type].desc)	--Description (Name, Desc)
	acfmenupanel:CPanelText("LengthDisplay", "Round Length : "..(math.floor((Data.PropLength+Data.ProjLength+Data.Tracer)*100)/100).."/"..(Data.MaxTotalLength).." cm")	--Total round length (Name, Desc)
	acfmenupanel:CPanelText("VelocityDisplay", "Muzzle Velocity : "..math.floor(Data.MuzzleVel*ACF.VelScale).." m/s")	--Proj muzzle velocity (Name, Desc)	
	acfmenupanel:CPanelText("BlastDisplay", "Blast Radius : "..(math.floor(Data.BlastRadius*100)/100).." m")	--Proj muzzle velocity (Name, Desc)
	acfmenupanel:CPanelText("FragDisplay", "Fragments : "..(Data.Fragments).."\n Average Fragment Weight : "..(math.floor(Data.FragMass*10000)/10).." g \n Average Fragment Velocity : "..math.floor(Data.FragVel).." m/s")	--Proj muzzle penetration (Name, Desc)
	
	--local RicoAngs = ACF_RicoProbability( Data.Ricochet, Data.MuzzleVel*ACF.VelScale )
	--acfmenupanel:CPanelText("RicoDisplay", "Ricochet probability vs impact angle:\n".."    0% @ "..RicoAngs.Min.." degrees\n  50% @ "..RicoAngs.Mean.." degrees\n100% @ "..RicoAngs.Max.." degrees")
	
	local R1V, R1P = ACF_PenRanging( Data.MuzzleVel, Data.DragCoef, Data.ProjMass, Data.PenAera, Data.LimitVel, 300 )
	R1P = (ACF_Kinetic( (R1V + Data.SlugMV) * 39.37, Data.SlugMassUsed, 999999 ).Penetration/Data.SlugPenAera)*ACF.KEtoRHA
	local R2V, R2P = ACF_PenRanging( Data.MuzzleVel, Data.DragCoef, Data.ProjMass, Data.PenAera, Data.LimitVel, 800 )
	R2P = (ACF_Kinetic( (R2V + Data.SlugMV) * 39.37, Data.SlugMassUsed, 999999 ).Penetration/Data.SlugPenAera)*ACF.KEtoRHA
	
	acfmenupanel:CPanelText("SlugDisplay", "Penetrator Mass : "..(math.floor(Data.SlugMassUsed*10000)/10).." g \n Penetrator Caliber : "..(math.floor(Data.SlugCaliber*100)/10).." mm \n Penetrator Velocity : "..math.floor(Data.MuzzleVel + Data.SlugMV).." m/s \n Penetrator Maximum Penetration : "..math.floor(Data.MaxPen).." mm RHA\n\n300m pen: "..math.Round(R1P,0).."mm @ "..math.Round(R1V,0).." m\\s\n800m pen: "..math.Round(R2P,0).."mm @ "..math.Round(R2V,0).." m\\s\n\nThe range data is an approximation and may not be entirely accurate.")	--Proj muzzle penetration (Name, Desc)
	
end

list.Set( "ACFRoundTypes", "HEAT", Round )  --Set the round properties
list.Set( "ACFIdRounds", Round.netid, "HEAT" ) --Index must equal the ID entry in the table above, Data must equal the index of the table above
