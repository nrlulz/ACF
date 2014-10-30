
AddCSLuaFile()

local Round = {}

Round.type = "Ammo" --Tells the spawn menu what entity to spawn
Round.name = "Refill" --Human readable name
Round.model = "models/munitions/round_100mm_shot.mdl" --Shell flight model
Round.desc = "Ammo Refill"

-- Function to convert the player's slider data into the complete round data
function Round.convert( Crate, PlayerData )
	
	local BulletData = {}
		BulletData.Id = PlayerData.Id or "12.7mmMG"
		BulletData.Type = PlayerData.Type or "AP"
		
		BulletData.Caliber = ACF.Weapons.Guns[PlayerData.Id].caliber
		BulletData.ProjMass = 2*7.9/100 --Volume of the projectile as a cylinder * streamline factor (Data5) * density of steel
		BulletData.PropMass = 2*ACF.PDensity/1000 --Volume of the case as a cylinder * Powder density converted from g to kg
		BulletData.FillerMass = BulletData.FillerMass or 0
		BulletData.DragCoef = BulletData.DragCoef or 0
		BulletData.Tracer = BulletData.Tracer or 0
		BulletData.MuzzleVel = BulletData.MuzzleVel or 0
		BulletData.RoundVolume = 1
			
	return BulletData
	
end


function Round.getDisplayData(Data)
	return {}
end


function Round.network( Crate, BulletData )
	
	Crate:SetNetworkedString( "AmmoType", "Refill" )
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
	
	return ""
	
end

function Round.guicreate( Panel, Table )

	acfmenupanel:AmmoSelect()
	acfmenupanel:CPanelText("Desc", "")	--Description (Name, Desc)		
	Round.guiupdate( Panel, Table )

end

function Round.guiupdate( Panel, Table )
		
	RunConsoleCommand( "acfmenu_data1", acfmenupanel.CData.AmmoId )
	RunConsoleCommand( "acfmenu_data2", "Refill")
		
	acfmenupanel.CustomDisplay:PerformLayout()
	
end

list.Set( "ACFRoundTypes", "Refill", Round )  --Set the round properties
