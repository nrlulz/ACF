--[[
	Based on https://github.com/nrlulz/ACF/blob/master/lua/entities/gmod_wire_expression2/core/custom/acffunctions.lua
	Credits goes to the original authors Fervidusletum and Bubbus.
--]]

if !WireLib or !ACF then -- Also make sure ACF is actually installed.
	print("Armored Combat Framework not detected when installing EA2 ACF component, not installing!")
	return
end

local Component = EXPADV.AddComponent( "acf", true )

Component.Author = "FreeFry"
Component.Description = "Adds functions for controlling ACF sents."

Component.restrictInfo = function (ply, ent) -- Hack, this allows this function to be used from inline and prepared type functions.
	if GetConVar("sbox_acf_restrictinfo"):GetInt() != 0 then
		if EXPADV.IsOwner(ent, ply) then return false else return true end
	end
	return false
end

Component.linkTables =
{ -- link resources within each ent type.  should point to an ent: true if adding link.Ent, false to add link itself
	acf_engine 		= {GearLink = true, FuelLink = false},
	acf_gearbox		= {WheelLink = true, Master = false},
	acf_fueltank	= {Master = false},
	acf_gun			= {AmmoLink = false},
	acf_ammo		= {Master = false}
}

Component.getLinks = function(ent, enttype)
	local ret = {}
	-- find the link resources available for this ent type
	for entry, mode in pairs(Component.linkTables[enttype]) do
		if not ent[entry] then error("Couldn't find link resource " .. entry .. " for entity " .. tostring(ent)) return end

		-- find all the links inside the resources
		for _, link in pairs(ent[entry]) do
			ret[#ret+1] = mode and link.Ent or link
		end
	end

	return ret
end

Component.searchForGearboxLinks = function(ent)
	local boxes = ents.FindByClass("acf_gearbox")

	local ret = {}

	for _, box in pairs(boxes) do
		if IsValid(box) then
			for _, link in pairs(box.WheelLink) do
				if link.Ent == ent then
					ret[#ret+1] = box
					break
				end
			end
		end
	end

	return ret
end

-- [ General Functions ] --

EXPADV.ServerOperators()

Component:AddInlineFunction( "acfInfoRestricted", "", "b" , "$GetConVar('sbox_acf_restrictinfo'):GetBool() or true" )
Component:AddFunctionHelper( "acfInfoRestricted", "", "Returns true if functions returning sensitive info are restricted to owned props." )

Component:AddPreparedFunction( "acfNameShort", "e:", "s",
[[@define ret = ""
if @value 1:IsValid() then
	if @value 1:GetClass() == "acf_engine" or @value 1:GetClass() == "acf_gearbox" or @value 1:GetClass() == "acf_gun" then
		@ret = @value 1.Id
	elseif @value 1:GetClass() == "acf_ammo" then
		@ret = @value 1.RoundId
	elseif @value 1:GetClass() == "acf_fueltank" then
		@ret = @value 1.FuelType
	end
end]], "@ret" )
Component:AddFunctionHelper( "acfNameShort", "e:", "Returns the short name of an ACF entity." )

Component:AddInlineFunction( "acfCapacity", "e:", "n", "((@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and (@value 1:GetClass() == 'acf_ammo' or @value 1:GetClass() == 'acf_fueltank')) and @value 1.Capacity or 0)" )
Component:AddFunctionHelper( "acfCapacity", "e:", "Returns the capacity of an ACF ammo crate or fuel tank." )

Component:AddInlineFunction( "acfActive", "e:", "b", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and (@value 1:GetClass() == 'acf_engine' or @value 1:GetClass() == 'acf_ammo' or @value 1:GetClass() == 'acf_fueltank') and @value 1.Active or false)" )
Component:AddFunctionHelper( "acfActive", "e:", "Returns true if an ACF engine, ammo crate, or fuel tank is active." )

Component:AddPreparedFunction( "acfActive", "e:b", "",
[[if EXPADV.IsOwner(@value 1, Context.player) and (@value 1:GetClass() == "acf_engine" or @value 1:GetClass() == "acf_ammo" or @value 1:GetClass() == "acf_fueltank") then
	if @value 2 then
		@value 1:TriggerInput( "Active", 1 )
	else
		@value 1:TriggerInput( "Active", 0 )
	end
end]] )
Component:AddFunctionHelper( "acfActive", "e:b", "Sets Active (false/true) for an ACF engine, ammo crate, or fuel tank." )

Component:AddInlineFunction( "acfHitClip", "e:v", "b", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1)) and ACF_CheckClips(@value 1, @value 2)" )
Component:AddFunctionHelper( "acfHitClip", "e:v", "Returns true if hitpos is on a clipped part of prop." )

Component:AddPreparedFunction( "acfLinks", "e:", "ar",
[[@define ret = { __type = "e" }
if @value 1:IsValid() then
	if not EXPADV.Components.acf.linkTables[@value 1:GetClass()] then
		@ret = EXPADV.Components.acf.searchForGearboxLinks(@value 1)
		@ret.__type = "e"
	else
		@ret = EXPADV.Components.acf.getLinks(@value 1, @value 1:GetClass())
		@ret.__type = "e"
	end
end]], "@ret" )
Component:AddFunctionHelper( "acfLinks", "e:", "Returns all the entities which are linked to this entity through ACF." )

Component:AddPreparedFunction( "acfName", "e:", "s", 
[[@define ret = ""
if @value 1:IsValid() then
	if @value 1:GetClass() == "acf_ammo" then
		@ret = @value 1.RoundId .. " " .. @value 1.RoundType
	elseif @value 1:GetClass() == "acf_fueltank" then
		@ret = @value 1.FuelType .. " " .. @value 1.SizeId
	else
		@define acftype = ""
		if @value 1:GetClass() == "acf_engine" or @value 1:GetClass() == "acf_gearbox" then
			@acftype = "Mobility"
		elseif @value 1:GetClass() == "acf_gun" then
			@acftype = "Guns"
		end
		if @acftype ~= "" then @ret = $list.Get("ACFEnts")[@acftype][@value 1.Id]["name"] or "" end
	end
end]], "@ret" )
Component:AddFunctionHelper( "acfName", "e:", "Returns the full name of an ACF entity." )

Component:AddPreparedFunction( "acfType", "e:", "s",
[[@define ret = ""
if @value 1:IsValid() then
	if @value 1:GetClass() == "acf_engine" or @value 1:GetClass() == "acf_gearbox" then
		@ret = $list.Get("ACFEnts")["Mobility"][@value 1.Id]["category"] or ""
	elseif @value 1:GetClass() == "acf_gun" then
		@ret = $list.Get("ACFClasses")["GunClass"][@value 1.Class]["name"] or ""
	elseif @value 1:GetClass() == "acf_ammo" then
		@ret = @value 1.RoundType or ""
	elseif @value 1:GetClass() == "acf_fueltank" then
		@ret = @value 1.FuelType or ""
	end
end]], "@ret" )
Component:AddFunctionHelper( "acfType", "e:", "Returns the type of ACF entity." )

-- [ Engine Functions ] --
Component:AddInlineFunction( "acfIsEngine", "e:", "b", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_engine' or false)" )
Component:AddFunctionHelper( "acfIsEngine", "e:", "Returns true if the entity is an ACF engine." )

Component:AddInlineFunction( "acfMaxTorque", "e:", "n", "(@value 1:IsValid() and @value 1.PeakTorque or 0)")
Component:AddFunctionHelper( "acfMaxTorque", "e:", "Returns the maximum torque (in N/m) of an ACF engine." )

Component:AddPreparedFunction( "acfMaxPower", "e:", "n",
[[@define ret = 0
if @value 1:IsValid() then
	if @value 1.iselec then
		@ret = $math.floor( @value 1.PeakTorque * @value 1.LimitRPM / 38195.2 )
	else
		@ret = $math.floor( @value 1.PeakTorque * @value 1.PeakMaxRPM / 9548.8 )
	end
end]], "@ret" )
Component:AddFunctionHelper( "acfMaxPower", "e:", "Returns the maximum power (in kW) of an ACF engine." )

Component:AddInlineFunction( "acfIdleRPM", "e:", "n", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_engine' and @value 1.IdleRPM or 0)" )
Component:AddFunctionHelper( "acfIdleRPM", "e:", "Returns the idle RPM of an ACF engine." )

Component:AddInlineFunction( "acfPowerbandMin", "e:", "n", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_engine' and @value 1.PeakMinRPM or 0)" )
Component:AddFunctionHelper( "acfPowerbandMin", "e:", "Returns the powerband minimum of an ACF engine." )

Component:AddInlineFunction( "acfPowerbandMax", "e:", "n", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_engine' and @value 1.PeakMaxRPM or 0)" )
Component:AddFunctionHelper( "acfPowerbandMax", "e:", "Returns the powerband maximum of an ACF engine." )

Component:AddInlineFunction( "acfRedline", "e:", "n", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_engine' and @value 1.LimitRPM or 0)" )
Component:AddFunctionHelper( "acfRedline", "e:", "Returns the redline RPM of an ACF engine." )

Component:AddInlineFunction( "acfRPM", "e:", "n", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1:GetClass() == 'acf_engine' and $math.floor(@value 1.FlyRPM or 0))" )
Component:AddFunctionHelper( "acfRPM", "e:", "Returns the current RPM of an ACF engine." )

Component:AddInlineFunction( "acfTorque", "e:", "n", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1:GetClass() == 'acf_engine' and $math.floor(@value 1.Torque or 0))" )
Component:AddFunctionHelper( "acfTorque", "e:", "Returns the current torque (in N/m) of an ACF engine." )

Component:AddInlineFunction( "acfPower", "e:", "n", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1:GetClass() == 'acf_engine' and $math.floor((@value 1.Torque or 0) * (@value 1.FlyRPM or 0) / 9548.8))" )
Component:AddFunctionHelper( "acfPower", "e:", "Returns the current power (in kW) of an ACF engine." )

Component:AddInlineFunction( "acfInPowerband", "e:", "b", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1:GetClass() == 'acf_engine' and (@value 1.FlyRPM > @value 1.PeakMinRPM and @value 1.FlyRPM < @value 1.PeakMaxRPM))" )
Component:AddFunctionHelper( "acfInPowerband", "e:", "Returns true if the ACF engine RPM is inside the powerband." )

Component:AddInlineFunction( "acfThrottle", "e:", "n", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1:GetClass() == 'acf_engine' and (@value 1.Throttle or 0) * 100)" )
Component:AddFunctionHelper( "acfThrottle", "e:", "Returns the current throttle of an ACF engine." )

Component:AddPreparedFunction( "acfThrottle", "e:n", "", 
[[if @value 1:IsValid() and EXPADV.IsOwner(@value 1, Context.player) and @value 1:GetClass() == "acf_engine" then
	@value 1:TriggerInput( "Throttle", @value 2)
end]] )
Component:AddFunctionHelper( "acfThrottle", "e:n", "Sets the throttle of an ACF engine (0-100)." )

-- [ Gearbox Functions ] --

Component:AddInlineFunction( "acfIsGearbox", "e:", "b", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_gearbox' or false)")
Component:AddFunctionHelper( "acfIsGearbox", "e:", "Returns true if the entity is an ACF gearbox." )

Component:AddInlineFunction( "acfGear", "e:", "n", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1:GetClass() == 'acf_gearbox' and @value 1.Gear or 0)" )
Component:AddFunctionHelper( "acfGear", "e:", "Returns the current gear of an ACF gearbox." )

Component:AddInlineFunction( "acfNumGears", "e:", "n", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1:GetClass() == 'acf_gearbox' and @value 1.Gears or 0)" )
Component:AddFunctionHelper( "acfNumGears", "e:", "Returns the number of gears of an ACF gearbox." )

Component:AddInlineFunction( "acfFinalRatio", "e:", "n", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1:GetClass() == 'acf_gearbox' and @value 1.GearTable['Final'] or 0)" )
Component:AddFunctionHelper( "acfFinalRatio", "e:", "Returns the final ratio of an ACF gearbox." )

Component:AddInlineFunction( "acfTotalRatio", "e:", "n", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1:GetClass() == 'acf_gearbox' and @value 1.GearRatio or 0)" )
Component:AddFunctionHelper( "acfTotalRatio", "e:", "Returns the total ratio (current gear * final) of an ACF gearbox." )

Component:AddInlineFunction( "acfTorqueRating", "e:", "n", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_gearbox' and @value 1.MaxTorque or 0)" )
Component:AddFunctionHelper( "acfTorqueRating", "e:", "Returns the maximum torque (in N/m) an ACF gearbox can handle." )

Component:AddInlineFunction( "acfIsDual", "e:", "b", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1:GetClass() == 'acf_gearbox' and @value 1.Dual or false)" )
Component:AddFunctionHelper( "acfIsDual", "e:", "Returns true if an ACF gearbox is dual clutch." )

Component:AddInlineFunction( "acfShiftTime", "e:", "n", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_gearbox' and (@value 1.SwitchTime or 0) * 1000 or 0)" )
Component:AddFunctionHelper( "acfShiftTime", "e:", "Returns the time in ms an ACF gearbox takes to chance gears." )

Component:AddInlineFunction( "acfInGear", "e:", "b", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1:GetClass() == 'acf_gearbox' and @value 1.InGear or false)" )
Component:AddFunctionHelper( "acfInGear", "e:", "Returns true if an ACF gearbox is in gear." )

Component:AddInlineFunction( "acfGearRatio", "e:n", "n", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1:GetClass() == 'acf_gearbox' and @value 1.GearTable[$math.Clamp($math.floor(@value 2), 1, @value 1.Gears or 1)] or 0)" )
Component:AddFunctionHelper( "acfGearRatio", "e:n", "Returns the ratio of the specified gear of an ACF gearbox." )

Component:AddInlineFunction( "acfTorqueOut", "e:", "n", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1:GetClass() == 'acf_gearbox' and $math.min(@value 1.TotalReqTq or 0, @value 1.MaxTorque or 0) / (@value 1.GearRatio or 1) or 0)" )
Component:AddFunctionHelper( "acfTorqueOut", "e:", "Returns the current torque output (in N/m) of an ACF gearbox (not precise, due to how ACF applies power)." )

Component:AddPreparedFunction( "acfCVTRatio", "e:n", "",
[[if @value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1:GetClass() == 'acf_gearbox' and @value 1.CVT then
	@value 1.CVTRatio = $math.Clamp(@value 2, 0, 1)
end]] )
Component:AddFunctionHelper( "acfCVTRatio", "e:n", "Sets the gear ratio of a CVT. Passing 0 causes the CVT to resume using target min/max RPM calculation." )

Component:AddPreparedFunction( "acfShift", "e:n", "",
[[if @value 1:IsValid() and @value 1:GetClass() == "acf_gearbox" and EXPADV.IsOwner(@value 1, Context.player) then
	@value 1:TriggerInput( "Gear", @value 2 )
end]] )
Component:AddFunctionHelper( "acfShift", "e:n", "Tells an ACF gearbox to shift to the specified gear." )

Component:AddPreparedFunction( "acfShiftUp", "e:", "",
[[if @value 1:IsValid() and @value 1:GetClass() == "acf_gearbox" and EXPADV.IsOwner(@value 1, Context.player) then
	@value 1:TriggerInput( "Gear Up", 1 )
end]] )
Component:AddFunctionHelper( "acfShiftUp", "e:", "Tells an ACF gearbox to shift up." )

Component:AddPreparedFunction( "acfShiftDown", "e:", "",
[[if @value 1:IsValid() and @value 1:GetClass() == "acf_gearbox" and EXPADV.IsOwner(@value 1, Context.player) then
	@value 1:TriggerInput( "Gear Down", 1 )
end]] )
Component:AddFunctionHelper( "acfShiftDown", "e:", "Tells an ACF gearbox to shift down." )

Component:AddPreparedFunction( "acfBrake", "e:n", "",
[[if @value 1:IsValid() and @value 1:GetClass() == "acf_gearbox" and EXPADV.IsOwner(@value 1, Context.player) then
	@value 1:TriggerInput( "Brake", @value 2 )
end]] )
Component:AddFunctionHelper( "acfBrake", "e:n", "Sets the brake for an ACF gearbox. Sets both sides of a dual clutch gearbox." )

Component:AddPreparedFunction( "acfBrakeLeft", "e:n", "",
[[if @value 1:IsValid() and @value 1:GetClass() == "acf_gearbox" and EXPADV.IsOwner(@value 1, Context.player) and @value 1.Dual then
	@value 1:TriggerInput( "Left Brake", @value 2 )
end]] )
Component:AddFunctionHelper( "acfBrakeLeft", "e:n", "Sets the left brake for an ACF gearbox. Only works on a dual clutch gearbox." )

Component:AddPreparedFunction( "acfBrakeRight", "e:n", "",
[[if @value 1:IsValid() and @value 1:GetClass() == "acf_gearbox" and EXPADV.IsOwner(@value 1, Context.player) and @value 1.Dual then
	@value 1:TriggerInput( "Right Brake", @value 2 )
end]] )
Component:AddFunctionHelper( "acfBrakeRight", "e:n", "Sets the right brake for an ACF gearbox. Only works on a dual clutch gearbox." )

Component:AddPreparedFunction( "acfClutch", "e:n", "",
[[if @value 1:IsValid() and @value 1:GetClass() == "acf_gearbox" and EXPADV.IsOwner(@value 1, Context.player) then
	@value 1:TriggerInput( "Clutch", @value 2 )
end]] )
Component:AddFunctionHelper( "acfClutch", "e:n", "Sets the clutch for an ACF gearbox. Sets both sides of a dual clutch gearbox." )

Component:AddPreparedFunction( "acfClutchLeft", "e:n", "",
[[if @value 1:IsValid() and @value 1:GetClass() == "acf_gearbox" and EXPADV.IsOwner(@value 1, Context.player) and @value 1.Dual then
	@value 1:TriggerInput( "Left Clutch", @value 2 )
end]] )
Component:AddFunctionHelper( "acfClutchLeft", "e:n", "Sets the left clutch for an ACF gearbox. Only works on a dual clutch gearbox." )

Component:AddPreparedFunction( "acfClutchRight", "e:n", "",
[[if @value 1:IsValid() and @value 1:GetClass() == "acf_gearbox" and EXPADV.IsOwner(@value 1, Context.player) and @value 1.Dual then
	@value 1:TriggerInput( "Right Clutch", @value 2 )
end]] )
Component:AddFunctionHelper( "acfClutchRight", "e:n", "Sets the right clutch for an ACF gearbox. Only works on a dual clutch gearbox." )

Component:AddPreparedFunction( "acfSteerRate", "e:n", "",
[[if @value 1:IsValid() and @value 1:GetClass() == "acf_gearbox" and EXPADV.IsOwner(@value 1, Context.player) and @value 1.DoubleDiff then
	@value 1:TriggerInput( "Steer Rate", @value 2 )
end]] )
Component:AddFunctionHelper( "acfSteerRate", "e:n", "Sets the steer rate of a ACF gearbox. Only works on a dual differential." )

Component:AddPreparedFunction( "acfHoldGear", "e:n", "",
[[if @value 1:IsValid() and @value 1:GetClass() == "acf_gearbox" and EXPADV.IsOwner(@value 1, Context.player) and @value 1.Auto then
	@value 1:TriggerInput( "Hold Gear", @value 2 )
end]] )
Component:AddFunctionHelper( "acfHoldGear", "e:n", "Set to 1 to stop ACF automatic gearboxes upshifting." )

Component:AddPreparedFunction( "acfShiftPointScale", "e:n", "",
[[if @value 1:IsValid() and @value 1:GetClass() == "acf_gearbox" and EXPADV.IsOwner(@value 1, Context.player) and @value 1.Auto then
	@value 1:TriggerInput( "Shift Speed Scale", @value 2 )
end]] )
Component:AddFunctionHelper( "acfShiftPointScale", "e:n", "Sets the shift point scale for an ACF automatic gearbox." )

-- [ Gun Functions ] --

Component:AddInlineFunction( "acfIsGun", "e:", "b", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_gun' and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) or false)" )
Component:AddFunctionHelper( "acfIsGun", "e:", "Returns true if the entity is an ACF weapon." )

Component:AddInlineFunction( "acfReady", "e:", "b", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_gun' and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1.Ready or false)" )
Component:AddFunctionHelper( "acfReady", "e:", "Returns true if an ACF weapon is ready to fire." )

Component:AddInlineFunction( "acfMagSize", "e:", "n", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_gun' and @value 1.MagSize or 0)" )
Component:AddFunctionHelper( "acfMagSize", "e:", "Returns the magazine capacity of an ACF weapon." )

Component:AddPreparedFunction( "acfSpread", "e:", "n",
[[@define ret = 0
if @value 1:IsValid() and (@value 1:GetClass() == "acf_gun" or @value 1:GetClass() == "acf_ammo") and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) then
	@ret = @value 1.GetInaccuracy and @value 1:GetInaccuracy() or @value 1.Inaccuracy or 0
	if @value 1.BulletData["Type"] == "FL" then
		@ret = @ret + (@value 1.BulletData["FlechetteSpread"] or 0)
	end
end]], "@ret" )
Component:AddFunctionHelper( "acfSpread", "e:", "Returns the spread of an ACF weapon." )

Component:AddInlineFunction( "acfIsReloading", "e:", "b", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_gun' and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1.Reloading or false)" )
Component:AddFunctionHelper( "acfIsReloading", "e:", "Returns true if an ACF weapon is reloading." )

Component:AddInlineFunction( "acfFireRate", "e:", "n", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_gun' and $math.Round(@value 1.RateOfFire or 0, 3) or 0)" )
Component:AddFunctionHelper( "acfFireRate", "e:", "Returns the rate of fire of an ACF weapon." )

Component:AddPreparedFunction( "acfMagRounds", "e:", "n",
[[@define ret = 0
	if @value 1:IsValid() and @value 1:GetClass() == 'acf_gun' and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) then
		if @value 1.MagSize and @value 1.CurrentShot and @value 1.MagSize > 1 then
			@ret = (@value 1.MagSize - @value 1.CurrentShot) or 1
		else
			@ret = @value 1.Ready or 0
		end
end]], "@ret" )
Component:AddFunctionHelper( "acfMagRounds", "e:", "Returns the remaining rounds in the magazine of an ACF weapon." )

Component:AddPreparedFunction( "acfFire", "e:b", "",
[[if @value 1:IsValid() and @value 1:GetClass() == "acf_gun" and EXPADV.IsOwner(@value 1, Context.player) then
	@value 1:TriggerInput( "Fire", @value 2 and 1 or 0)
end]] )
Component:AddFunctionHelper( "acfFire", "e:b", "Sets the firing state of an ACF weapon. Kills are only attributed to gun owner. Use wire inputs on a gun if you want to properly attribute kills to driver." )

Component:AddPreparedFunction( "acfUnload", "e:", "",
[[if @value 1:IsValid() and @value 1:GetClass() == "acf_gun" and EXPADV.IsOwner(@value 1, Context.player) and @value 1.UnloadAmmo then
	@value 1:UnloadAmmo()
end]] )
Component:AddFunctionHelper( "acfUnload", "e:", "Causes an ACF weapon to unload." )

Component:AddPreparedFunction( "acfReload", "e:", "",
[[if @value 1:IsValid() and @value 1:GetClass() == "acf_gun" and EXPADV.IsOwner(@value 1, Context.player) then
	@value 1.Reloading = true
end]] )
Component:AddFunctionHelper( "acfReload", "e:", "Causes an ACF weapon to reload." )

Component:AddPreparedFunction( "acfAmmoCount", "e:", "n",
[[@define ret = 0
if @value 1:IsValid() and @value 1:GetClass() == "acf_gun" and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1.AmmoLink then
	for _, AmmoEnt in pairs(@value 1.AmmoLink) do
		if AmmoEnt and AmmoEnt:IsValid() and AmmoEnt["Load"] then
			@ret = @ret + (AmmoEnt.Ammo or 0)
		end
	end
end]], "@ret" )
Component:AddFunctionHelper( "acfAmmoCount", "e:", "Returns the number of rounds in active ammo crates linked to an ACF weapon." )

Component:AddPreparedFunction( "acfTotalAmmoCount", "e:", "n",
[[@define ret = 0
if @value 1:IsValid() and @value 1:GetClass() == "acf_gun" and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1.AmmoLink then
	for _, AmmoEnt in pairs(@value 1.AmmoLink) do
		if AmmoEnt and AmmoEnt:IsValid() then
			@ret = @ret + (AmmoEnt.Ammo or 0)
		end
	end
end]], "@ret" )
Component:AddFunctionHelper( "acfTotalAmmoCount", "e:", "Returns the number of rounds in all ammo crates linked to an ACF weapon." )

-- [ Ammo Functions ] --

Component:AddInlineFunction( "acfIsAmmo", "e:", "b", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_ammo' and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) or false)" )
Component:AddFunctionHelper( "acfIsAmmo", "e:", "Returns true if the entity is an ACF ammo crate." )

Component:AddInlineFunction( "acfRounds", "e:", "n", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_ammo' and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1.Ammo or 0)" )
Component:AddFunctionHelper( "acfRounds", "e:", "Returns the number of rounds in an ACF ammo crate." )

Component:AddInlineFunction( "acfRoundType", "e:", "s", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_ammo' and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1.RoundId or '')" )
Component:AddFunctionHelper( "acfRoundType", "e:", "Returns the type of weapon the ammo in an ACF ammo crate loads into." )

Component:AddInlineFunction( "acfAmmoType", "e:", "s", "(@value 1:IsValid() and (@value 1:GetClass() == 'acf_ammo' or @value 1:GetClass() == 'acf_gun') and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1.BulletData['Type'] or '')" )
Component:AddFunctionHelper( "acfAmmoType", "e:", "Returns the type of ammo in an ACF ammo crate or ACF weapon." )

Component:AddInlineFunction( "acfCaliber", "e:", "n", "(@value 1:IsValid() and (@value 1:GetClass() == 'acf_ammo' or @value 1:GetClass() == 'acf_gun') and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and (@value 1.Caliber or 0) * 10 or 0)" )
Component:AddFunctionHelper( "acfCaliber", "e:", "Returns the caliber of the ammo in an ACF ammo crate or weapon." )

Component:AddInlineFunction( "acfMuzzleVel", "e:", "n", "(@value 1:IsValid() and (@value 1:GetClass() == 'acf_ammo' or @value 1:GetClass() == 'acf_gun') and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and $math.Round((@value 1.BulletData['MuzzleVel'] or 0) * $ACF.VelScale, 3) or 0)" )
Component:AddFunctionHelper( "acfMuzzleVel", "e:", "Returns the muzzle velocity of the ammo in an ACF ammo crate or weapon." )

Component:AddInlineFunction( "acfProjectileMass", "e:", "n", "(@value 1:IsValid() and (@value 1:GetClass() == 'acf_ammo' or @value 1:GetClass() == 'acf_gun') and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and $math.Round(@value 1.BulletData['ProjMass'] or 0, 3) or 0)" )
Component:AddFunctionHelper( "acfProjectileMass", "e:", "Returns the mass of the projectile in an ACF ammo crate or weapon." )

Component:AddInlineFunction( "acfFLSpikes", "e:", "n", "(@value 1:IsValid() and (@value 1:GetClass() == 'acf_ammo' or @value 1:GetClass() == 'acf_gun') and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1.BulletData['Type'] == 'FL' and @value 1.BulletData['Flechettes'] or 0)" )
Component:AddFunctionHelper( "acfFLSpikes", "e:", "Returns the number of projectiles in a flechette round in an ACF ammo crate or weapon." )

Component:AddInlineFunction( "acfFLSpikeMass", "e:", "n", "(@value 1:IsValid() and (@value 1:GetClass() == 'acf_ammo' or @value 1:GetClass() == 'acf_gun') and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1.BulletData['Type'] == 'FL' and $math.Round(@value 1.BulletData['FlechetteMass'] or 0, 3) or 0)" )
Component:AddFunctionHelper( "acfFLSpikeMass", "e:", "Returns the mass of a single spike in a flechette round in an ACF ammo crate or weapon. " )

Component:AddInlineFunction( "acfFLSpikeRadius", "e:", "n", "(@value 1:IsValid() and (@value 1:GetClass() == 'acf_ammo' or @value 1:GetClass() == 'acf_gun') and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1.BulletData['Type'] == 'FL' and $math.Round((@value 1.BulletData['FlechetteRadius'] or 0), 3) * 10 or 0)" )
Component:AddFunctionHelper( "acfFLSpikeRadius", "e:", "Returns the radius (in mm) of the spikes in a flechette round in an ACF ammo crate or weapon." )

Component:AddPreparedFunction( "acfPenetration", "e:", "n",
[[@define ret = 0
if @value 1:IsValid() and (@value 1:GetClass() == 'acf_ammo' or @value 1:GetClass() == 'acf_gun') and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) then
	@define type = @value 1.BulletData["Type"] or ""
	if @type == "AP" or @type == "APHE" then
		@ret = $math.Round(( $ACF_Kinetic( @value 1.BulletData["MuzzleVel"]*39.37, @value 1.BulletData["ProjMass"] - (@value 1.BulletData["FillerMass"] or 0), @value 1.BulletData["LimitVel"] ).Penetration / @value 1.BulletData['PenAera'] ) * $ACF.KEtoRHA, 3 )
	elseif @type == "HEAT" then
		@ret = $math.Round(( $ACF_Kinetic( @value 1.BulletData["SlugMV"]*39.37, @value 1.BulletData["SlugMass"], 99999999 ).Penetration / @value 1.BulletData["SlugPenAera"] ) * $ACF.KEtoRHA, 3 )
	elseif @type == "FL" then
		@ret = $math.Round(( $ACF_Kinetic( @value 1.BulletData["MuzzleVel"]*39.37, @value 1.BulletData["FlechetteMass"], @value 1.BulletData["LimitVel"] ).Penetration / @value 1.BulletData["FlechettePenArea"] ) * $ACF.KEtoRHA, 3 )
	end
end]], "@ret" )
Component:AddFunctionHelper( "acfPenetration", "e:", "Returns the penetration of an AP, APHE, HEAT or FL round in an ACF ammo crate or weapon." )

Component:AddPreparedFunction( "acfBlastRadius", "e:", "n",
[[@define ret = 0
if @value 1:IsValid() and (@value 1:GetClass() == 'acf_ammo' or @value 1:GetClass() == 'acf_gun') and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) then
	@define type = @value 1.BulletData["Type"] or ""
	if @type == "HE" or @type == "APHE" then
		@ret = $math.Round( @value 1.BulletData["FillerMass"]^0.33*5, 3 )
	elseif @type == "HEAT" then
		@ret = $math.Round( (@value 1.BulletData["FillerMass"]/2)^0.33*5, 3 )
	end
end]], "@ret" )
Component:AddFunctionHelper( "acfBlastRadius", "e:", "Returns the blast radius of an HE, APHE or HEAT round in an ACF ammo crate or weapon." )

-- [ Armor Functions ] --

Component:AddInlineFunction( "acfPropHealth", "e:", "n", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and $ACF_Check(@value 1) and $math.Round(@value 1.ACF.Health or 0, 3) or 0)" )
Component:AddFunctionHelper( "acfPropHealth", "e:", "Returns the current health of an entity." )

Component:AddInlineFunction( "acfPropArmor", "e:", "n", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and $ACF_Check(@value 1) and $math.Round(@value 1.ACF.Armour or 0, 3) or 0)" )
Component:AddFunctionHelper( "acfPropArmor", "e:", "Returns the current armor of an entity." )

Component:AddInlineFunction( "acfPropHealthMax", "e:", "n", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and $ACF_Check(@value 1) and $math.Round(@value 1.ACF.MaxHealth or 0, 3) or 0)" )
Component:AddFunctionHelper( "acfPropHealthMax", "e:", "Returns the current max health of an entity." )

Component:AddInlineFunction( "acfPropArmorMax", "e:", "n", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and $ACF_Check(@value 1) and $math.Round(@value 1.ACF.MaxArmour or 0, 3) or 0)" )
Component:AddFunctionHelper( "acfPropArmorMax", "e:", "Returns the current max armor of an entity." )

Component:AddInlineFunction( "acfPropDuctility", "e:", "n", "(@value 1:IsValid() and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and $ACF_Check(@value 1) and (@value 1.ACF.Ductility or 0) * 100 or 0)" )
Component:AddFunctionHelper( "acfPropDuctility", "e:", "Returns the ductility of an entity." )

-- [ Fuel Functions ] --

Component:AddInlineFunction( "acfIsFuel", "e:", "b", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_fueltank' and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) or false)" )
Component:AddFunctionHelper( "acfIsFuel", "e:", "Returns true if the entity is an ACF fuel tank." )

Component:AddInlineFunction( "acfFuelRequired", "e:", "b", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_engine' and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1.RequiresFuel or false)" )
Component:AddFunctionHelper( "acfFuelRequired", "e:", "Returns true if an ACF engine requires fuel." )

Component:AddPreparedFunction( "acfRefuelDuty", "e:b", "",
[[if @value 1:IsValid() and @value 1:GetClass() == "acf_fueltank" and EXPADV.IsOwner(@value 1, Context.player) then
	@value 1:TriggerInput( "Refuel Duty", @value 2 and 1 or 0)
end]] )
Component:AddFunctionHelper( "acfRefuelDuty", "e:b", "Sets an ACF fuel tank on refuel duty, causing it to supply other fuel tanks with fuel." )

Component:AddInlineFunction( "acfRefuelDuty", "e:", "b", "(@value 1:IsValid() and @value 1:GetClass() == 'acf_fueltank' and !EXPADV.Components.acf.restrictInfo(Context.player, @value 1) and @value 1.SupplyFuel or false)" )
Component:AddFunctionHelper( "acfRefuelDuty", "e:", "Returns true if an ACF fueltank is set on refuel duty." )

Component:AddPreparedFunction( "acfFuel", "e:", "n",
[[@define ret = 0
if @value 1:IsValid() and !EXPADV.Components.acf.restrictInfo( Context.player, @value 1 ) then
	if @value 1:GetClass() == "acf_fueltank" then
		@ret = $math.Round( @value 1.Fuel or 0, 3 )
	elseif @value 1:GetClass() == "acf_engine" and @value 1.FuelLink and #@value 1.FuelLink > 0 then
		for _, tank in pairs( @value 1.FuelLink ) do
			if $IsValid( tank ) and tank.Fuel then
				@ret = @ret + tank.Fuel
			end
		end
		@ret = $math.Round( @ret, 3 )
	end
end]], "@ret" )
Component:AddFunctionHelper( "acfFuel", "e:", "Returns the remaining liters of fuel or kilowatt hours in an ACF fuel tank or available to an engine." )

Component:AddPreparedFunction( "acfFuelLevel", "e:", "n",
[[@define ret = 0
if @value 1:IsValid() and !EXPADV.Components.acf.restrictInfo( Context.player, @value 1 ) then
	if @value 1:GetClass() == "acf_fueltank" then
		@ret = $math.Round( @value 1.Fuel / @value 1.Capacity, 3 )
	elseif @value 1:GetClass() == "acf_engine" and @value 1.FuelLink and #@value 1.FuelLink > 0 then
		@define capacity = 0
		for _, tank in pairs( @value 1.FuelLink ) do
			if $IsValid( tank ) and tank.Active then
				@capacity = @capacity + tank.Capacity
				@ret = @ret + tank.Fuel
			end
		end
		@ret = $math.Round( @ret / @capacity, 3 )
	end
end]], "@ret" )
Component:AddFunctionHelper( "acfFuelLevel", "e:", "Returns the percent of remaining fuel in an ACF fuel tank or available to an engine." )

Component:AddPreparedFunction( "acfFuelUse", "e:", "n",
[[@define ret = 0
if @value 1:IsValid() and @value 1:GetClass() == "acf_engine" and @value 1.FuelLink and #@value 1.FuelLink > 0 and !EXPADV.Components.acf.restrictInfo( Context.player, @value 1 ) and @value 1.FuelType then
	if @value 1.FuelType == "Electric" then
 		@ret = 60 * ( @value 1.Torque * @value 1.FlyRPM / 9548.8 ) * @value 1.FuelUse
	elseif @value 1.FuelType == "Petrol" or @value 1.FuelType == "Diesel" then
 		@ret = 60 * ( 0.3 + @value 1.Throttle * 0.7 ) * @value 1.FuelUse * ( @value 1.FlyRPM / @value 1.PeakKwRPM ) / $ACF.FuelDensity[@value 1.FuelType]
 	else
 		@define tank = nil
		for _, fueltank in pairs( @value 1.FuelLink ) do
			if $IsValid( fueltank ) and fueltank.Fuel > 0 and fueltank.Active then
				@tank = fueltank
				break
			end
		end
		if @tank then
			if @value 1.FuelType == "Electric" then
				@ret = 60 * ( @value 1.Torque * @value 1.FlyRPM / 9548.8 ) * @value 1.FuelUse
			else
				@ret = 60 * ( 0.3 + @value 1.Throttle * 0.7 ) * @value 1.FuelUse * ( @value 1.FlyRPM / @value 1.PeakKwRPM ) / $ACF.FuelDensity[@tank.FuelType]
			end
		end
	end
	@ret = $math.Round( @ret, 3 )
end]], "@ret" )
Component:AddFunctionHelper( "acfFuelUse", "e:", "Returns the current fuel consumption of an ACF engine in liters per minute or kilowatt hours." )

Component:AddPreparedFunction( "acfPeakFuelUse", "e:", "n",
[[@define ret = 0
if @value 1:IsValid() and @value 1:GetClass() == "acf_engine" and @value 1.FuelLink and #@value 1.FuelLink > 0 and !EXPADV.Components.acf.restrictInfo( Context.player, @value 1 ) and @value 1.FuelType then
	if @value 1.FuelType == "Electric" then
 		@ret = 60 * ( @value 1.PeakTorque * @value 1.LimitRPM / ( 4*9548.8) ) * @value 1.FuelUse
	elseif @value 1.FuelType == "Petrol" or @value 1.FuelType == "Diesel" then
 		@ret = 60 * @value 1.FuelUse / $ACF.FuelDensity[@value 1.FuelType]
 	else
 		@define tank = nil
		for _, fueltank in pairs( @value 1.FuelLink ) do
			if $IsValid( fueltank ) and fueltank.Fuel > 0 and fueltank.Active then
				@tank = fueltank
				break
			end
		end
		if @tank then
			if @value 1.FuelType == "Electric" then
				@ret = 60 * ( @value 1.PeakTorque * @value 1.LimitRPM / ( 4*9548.8) ) * @value 1.FuelUse
			else
				@ret = 60 * @value 1.FuelUse / $ACF.FuelDensity[@value 1.FuelType]
			end
		end
	end
	@ret = $math.Round( @ret, 3 )
end]], "@ret" )
Component:AddFunctionHelper( "acfPeakFuelUse", "e:", "Returns the peak fuel consumption of an ACF engine in liters per minute or kilowatt hours." )

-- [ Shared Functions ] --
--EXPADV.SharedOperators()
