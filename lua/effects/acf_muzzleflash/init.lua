
   
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
	
	local Gun = data:GetEntity()
	if not IsValid(Gun) then return end
	
	local Sound = Gun:GetNWString( "Sound" )
	--local RoundType = ACF.IdRounds[data:GetSurfaceProp()]
	local Propellant = data:GetScale()
	local ReloadTime = data:GetMagnitude()
	
	local Class = Gun:GetNWString( "Class" )
	local ClassData = list.Get("ACFClasses").GunClass[Class]
	
	if not ClassData then
		return nil
	end
	
	local Attachment = "muzzle"
	local longbarrel = ClassData.longbarrel
	if longbarrel ~= nil then
		if Gun:GetBodygroup( longbarrel.index ) == longbarrel.submodel then
			Attachment = longbarrel.newpos
		end
	end
	
	if( CLIENT and not IsValidSound( Sound ) ) then
		Sound = ClassData["sound"]
	end
		
	if Gun:IsValid() then
		if Propellant > 0 then
			local SoundPressure = (Propellant*1000)^0.5
			sound.Play( Sound, Gun:GetPos() , math.Clamp(SoundPressure,75,127), 100) --wiki documents level tops out at 180, but seems to fall off past 127
			if not ((Class == "MG") or (Class == "RAC")) then
				sound.Play( Sound, Gun:GetPos() , math.Clamp(SoundPressure,75,127), 100)
				if (SoundPressure > 127) then
					sound.Play( Sound, Gun:GetPos() , math.Clamp(SoundPressure-127,1,127), 100)
				end
			end
			--sound.Play( ACF.Classes["GunClass"][Class]["soundDistance"], Gun:GetPos() , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
			--sound.Play( ACF.Classes["GunClass"][Class]["soundNormal"], Gun:GetPos() , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
			
			local Muzzle = Gun:GetAttachment( Gun:LookupAttachment(Attachment)) or { Pos = Gun:GetPos(), Ang = Gun:GetAngles() }
			ParticleEffect( ClassData["muzzleflash"], Muzzle.Pos, Muzzle.Ang, Gun )
			Gun:Animate( Class, ReloadTime, false )
		else
			Gun:Animate( Class, ReloadTime, true )
		end
	end
	
 end 
   
   
/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
end
