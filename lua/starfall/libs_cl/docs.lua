-- Load Docs, nothing else
-- Sadly we cant have it in the fancy helper but it will work in the old one and syntax highlighting

table.Merge(SF.Docs, {["classes"]={[1]="Entity";["Entity"]={["class"]="class";["classForced"]=true;["description"]="\
Entity type";["fields"]={};["methods"]={[1]="acfAmmoCount";[10]="acfClutch";[11]="acfClutchLeft";[12]="acfClutchRight";[13]="acfDragCoef";[14]="acfFLSpikeMass";[15]="acfFLSpikeRadius";[16]="acfFLSpikes";[17]="acfFinalRatio";[18]="acfFire";[19]="acfFireRate";[2]="acfAmmoType";[20]="acfFlyInertia";[21]="acfFlyMass";[22]="acfFuel";[23]="acfFuelLevel";[24]="acfFuelRequired";[25]="acfFuelUse";[26]="acfGear";[27]="acfGearRatio";[28]="acfGetActive";[29]="acfGetLinkedWheels";[3]="acfBlastRadius";[30]="acfGetThrottle";[31]="acfHitClip";[32]="acfHoldGear";[33]="acfIdleRPM";[34]="acfInGear";[35]="acfInPowerband";[36]="acfIsAmmo";[37]="acfIsDual";[38]="acfIsElectric";[39]="acfIsEngine";[4]="acfBrake";[40]="acfIsFuel";[41]="acfIsGearbox";[42]="acfIsGun";[43]="acfIsInfoRestricted";[44]="acfIsReloading";[45]="acfLinkTo";[46]="acfLinks";[47]="acfMagReloadTime";[48]="acfMagRounds";[49]="acfMagSize";[5]="acfBrakeLeft";[50]="acfMaxPower";[51]="acfMaxPowerWithFuel";[52]="acfMaxTorque";[53]="acfMaxTorqueWithFuel";[54]="acfMuzzleVel";[55]="acfName";[56]="acfNameShort";[57]="acfNumGears";[58]="acfPeakFuelUse";[59]="acfPenetration";[6]="acfBrakeRight";[60]="acfPower";[61]="acfPowerband";[62]="acfPowerbandMax";[63]="acfPowerbandMin";[64]="acfProjectileMass";[65]="acfPropArmor";[66]="acfPropArmorMax";[67]="acfPropDuctility";[68]="acfPropHealth";[69]="acfPropHealthMax";[7]="acfCVTRatio";[70]="acfRPM";[71]="acfReady";[72]="acfRedline";[73]="acfRefuelDuty";[74]="acfReload";[75]="acfReloadProgress";[76]="acfReloadTime";[77]="acfRoundType";[78]="acfRounds";[79]="acfSetActive";[8]="acfCaliber";[80]="acfSetThrottle";[81]="acfShift";[82]="acfShiftDown";[83]="acfShiftPointScale";[84]="acfShiftTime";[85]="acfShiftUp";[86]="acfSpread";[87]="acfSteerRate";[88]="acfTorque";[89]="acfTorqueOut";[9]="acfCapacity";[90]="acfTorqueRating";[91]="acfTotalAmmoCount";[92]="acfTotalRatio";[93]="acfType";[94]="acfUnlinkFrom";[95]="acfUnload";["acfAmmoCount"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the number of rounds in active ammo crates linked to an ACF weapon";["fname"]="acfAmmoCount";["name"]="ents_methods:acfAmmoCount";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the number of rounds in active ammo crates linked to an ACF weapon ";};["acfAmmoType"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the type of ammo in a crate or gun";["fname"]="acfAmmoType";["name"]="ents_methods:acfAmmoType";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the type of ammo in a crate or gun ";};["acfBlastRadius"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the blast radius of an HE, APHE, or HEAT round";["fname"]="acfBlastRadius";["name"]="ents_methods:acfBlastRadius";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the blast radius of an HE, APHE, or HEAT round ";};["acfBrake"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the brakes for an ACF gearbox";["fname"]="acfBrake";["name"]="ents_methods:acfBrake";["param"]={[1]="brake";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the brakes for an ACF gearbox ";};["acfBrakeLeft"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the left brakes for an ACF gearbox";["fname"]="acfBrakeLeft";["name"]="ents_methods:acfBrakeLeft";["param"]={[1]="brake";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the left brakes for an ACF gearbox ";};["acfBrakeRight"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the right brakes for an ACF gearbox";["fname"]="acfBrakeRight";["name"]="ents_methods:acfBrakeRight";["param"]={[1]="brake";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the right brakes for an ACF gearbox ";};["acfCVTRatio"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the gear ratio of a CVT, set to 0 to use built-in algorithm";["fname"]="acfCVTRatio";["name"]="ents_methods:acfCVTRatio";["param"]={[1]="ratio";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the gear ratio of a CVT, set to 0 to use built-in algorithm ";};["acfCaliber"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the caliber of an ammo or gun";["fname"]="acfCaliber";["name"]="ents_methods:acfCaliber";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the caliber of an ammo or gun ";};["acfCapacity"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the capacity of an acf ammo crate or fuel tank";["fname"]="acfCapacity";["name"]="ents_methods:acfCapacity";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the capacity of an acf ammo crate or fuel tank ";};["acfClutch"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the clutch for an ACF gearbox";["fname"]="acfClutch";["name"]="ents_methods:acfClutch";["param"]={[1]="clutch";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the clutch for an ACF gearbox ";};["acfClutchLeft"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the left clutch for an ACF gearbox";["fname"]="acfClutchLeft";["name"]="ents_methods:acfClutchLeft";["param"]={[1]="clutch";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the left clutch for an ACF gearbox ";};["acfClutchRight"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the right clutch for an ACF gearbox";["fname"]="acfClutchRight";["name"]="ents_methods:acfClutchRight";["param"]={[1]="clutch";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the right clutch for an ACF gearbox ";};["acfDragCoef"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the drag coef of the ammo in a crate or gun";["fname"]="acfDragCoef";["name"]="ents_methods:acfDragCoef";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the drag coef of the ammo in a crate or gun ";};["acfFLSpikeMass"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the mass of a single spike in a FL round in a crate or gun";["fname"]="acfFLSpikeMass";["name"]="ents_methods:acfFLSpikeMass";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the mass of a single spike in a FL round in a crate or gun ";};["acfFLSpikeRadius"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the radius of the spikes in a flechette round in mm";["fname"]="acfFLSpikeRadius";["name"]="ents_methods:acfFLSpikeRadius";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the radius of the spikes in a flechette round in mm ";};["acfFLSpikes"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the number of projectiles in a flechette round";["fname"]="acfFLSpikes";["name"]="ents_methods:acfFLSpikes";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the number of projectiles in a flechette round ";};["acfFinalRatio"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the final ratio for an ACF gearbox";["fname"]="acfFinalRatio";["name"]="ents_methods:acfFinalRatio";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the final ratio for an ACF gearbox ";};["acfFire"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the firing state of an ACF weapon";["fname"]="acfFire";["name"]="ents_methods:acfFire";["param"]={[1]="fire";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the firing state of an ACF weapon ";};["acfFireRate"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the rate of fire of an acf gun";["fname"]="acfFireRate";["name"]="ents_methods:acfFireRate";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the rate of fire of an acf gun ";};["acfFlyInertia"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the inertia of an ACF engine's flywheel";["fname"]="acfFlyInertia";["name"]="ents_methods:acfFlyInertia";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the inertia of an ACF engine's flywheel ";};["acfFlyMass"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the mass of an ACF engine's flywheel";["fname"]="acfFlyMass";["name"]="ents_methods:acfFlyMass";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the mass of an ACF engine's flywheel ";};["acfFuel"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the remaining liters or kilowatt hours of fuel in an ACF fuel tank or engine";["fname"]="acfFuel";["name"]="ents_methods:acfFuel";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the remaining liters or kilowatt hours of fuel in an ACF fuel tank or engine ";};["acfFuelLevel"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the amount of fuel in an ACF fuel tank or linked to engine as a percentage of capacity";["fname"]="acfFuelLevel";["name"]="ents_methods:acfFuelLevel";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the amount of fuel in an ACF fuel tank or linked to engine as a percentage of capacity ";};["acfFuelRequired"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns true if the current engine requires fuel to run";["fname"]="acfFuelRequired";["name"]="ents_methods:acfFuelRequired";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns true if the current engine requires fuel to run ";};["acfFuelUse"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the current fuel consumption in liters per minute or kilowatts of an engine";["fname"]="acfFuelUse";["name"]="ents_methods:acfFuelUse";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the current fuel consumption in liters per minute or kilowatts of an engine ";};["acfGear"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the current gear for an ACF gearbox";["fname"]="acfGear";["name"]="ents_methods:acfGear";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the current gear for an ACF gearbox ";};["acfGearRatio"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the ratio for a specified gear of an ACF gearbox";["fname"]="acfGearRatio";["name"]="ents_methods:acfGearRatio";["param"]={[1]="gear";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the ratio for a specified gear of an ACF gearbox ";};["acfGetActive"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns true if the acf engine, fuel tank, or ammo crate is active";["fname"]="acfGetActive";["name"]="ents_methods:acfGetActive";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns true if the acf engine, fuel tank, or ammo crate is active ";};["acfGetLinkedWheels"]={["class"]="function";["classlib"]="Entity";["description"]="\
returns any wheels linked to this engine/gearbox or child gearboxes";["fname"]="acfGetLinkedWheels";["name"]="ents_methods:acfGetLinkedWheels";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
returns any wheels linked to this engine/gearbox or child gearboxes ";};["acfGetThrottle"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the throttle value";["fname"]="acfGetThrottle";["name"]="ents_methods:acfGetThrottle";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the throttle value ";};["acfHitClip"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns true if hitpos is on a clipped part of prop";["fname"]="acfHitClip";["name"]="ents_methods:acfHitClip";["param"]={[1]="hitpos";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns true if hitpos is on a clipped part of prop ";};["acfHoldGear"]={["class"]="function";["classlib"]="Entity";["description"]="\
Applies gear hold for an automatic ACF gearbox";["fname"]="acfHoldGear";["name"]="ents_methods:acfHoldGear";["param"]={[1]="hold";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Applies gear hold for an automatic ACF gearbox ";};["acfIdleRPM"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the idle rpm of an ACF engine";["fname"]="acfIdleRPM";["name"]="ents_methods:acfIdleRPM";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the idle rpm of an ACF engine ";};["acfInGear"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns true if an ACF gearbox is in gear";["fname"]="acfInGear";["name"]="ents_methods:acfInGear";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns true if an ACF gearbox is in gear ";};["acfInPowerband"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns true if the RPM of an ACF engine is inside the powerband";["fname"]="acfInPowerband";["name"]="ents_methods:acfInPowerband";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns true if the RPM of an ACF engine is inside the powerband ";};["acfIsAmmo"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns true if the entity is an ACF ammo crate";["fname"]="acfIsAmmo";["name"]="ents_methods:acfIsAmmo";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns true if the entity is an ACF ammo crate ";};["acfIsDual"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns whether an ACF gearbox is dual clutch";["fname"]="acfIsDual";["name"]="ents_methods:acfIsDual";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns whether an ACF gearbox is dual clutch ";};["acfIsElectric"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns true if an ACF engine is electric";["fname"]="acfIsElectric";["name"]="ents_methods:acfIsElectric";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns true if an ACF engine is electric ";};["acfIsEngine"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns true if the entity is an ACF engine";["fname"]="acfIsEngine";["name"]="ents_methods:acfIsEngine";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns true if the entity is an ACF engine ";};["acfIsFuel"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns true if the entity is an ACF fuel tank";["fname"]="acfIsFuel";["name"]="ents_methods:acfIsFuel";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns true if the entity is an ACF fuel tank ";};["acfIsGearbox"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns true if the entity is an ACF gearbox";["fname"]="acfIsGearbox";["name"]="ents_methods:acfIsGearbox";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns true if the entity is an ACF gearbox ";};["acfIsGun"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns true if the entity is an ACF gun";["fname"]="acfIsGun";["name"]="ents_methods:acfIsGun";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns true if the entity is an ACF gun ";};["acfIsInfoRestricted"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns true if this entity contains sensitive info and is not accessable to us";["fname"]="acfIsInfoRestricted";["name"]="ents_methods:acfIsInfoRestricted";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns true if this entity contains sensitive info and is not accessable to us ";};["acfIsReloading"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns true if an ACF gun is reloading";["fname"]="acfIsReloading";["name"]="ents_methods:acfIsReloading";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns true if an ACF gun is reloading ";};["acfLinkTo"]={["class"]="function";["classlib"]="Entity";["description"]="\
Perform ACF links";["fname"]="acfLinkTo";["name"]="ents_methods:acfLinkTo";["param"]={[1]="target";[2]="notify";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Perform ACF links ";};["acfLinks"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the ACF links associated with the entity";["fname"]="acfLinks";["name"]="ents_methods:acfLinks";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the ACF links associated with the entity ";};["acfMagReloadTime"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns time it takes for an ACF weapon to reload magazine";["fname"]="acfMagReloadTime";["name"]="ents_methods:acfMagReloadTime";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns time it takes for an ACF weapon to reload magazine ";};["acfMagRounds"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the number of rounds left in a magazine for an ACF gun";["fname"]="acfMagRounds";["name"]="ents_methods:acfMagRounds";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the number of rounds left in a magazine for an ACF gun ";};["acfMagSize"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the magazine size for an ACF gun";["fname"]="acfMagSize";["name"]="ents_methods:acfMagSize";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the magazine size for an ACF gun ";};["acfMaxPower"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the power in kW of an ACF engine";["fname"]="acfMaxPower";["name"]="ents_methods:acfMaxPower";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the power in kW of an ACF engine ";};["acfMaxPowerWithFuel"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the power in kW of an ACF engine with fuel";["fname"]="acfMaxPowerWithFuel";["name"]="ents_methods:acfMaxPowerWithFuel";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the power in kW of an ACF engine with fuel ";};["acfMaxTorque"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the torque in N/m of an ACF engine";["fname"]="acfMaxTorque";["name"]="ents_methods:acfMaxTorque";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the torque in N/m of an ACF engine ";};["acfMaxTorqueWithFuel"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the torque in N/m of an ACF engine with fuel";["fname"]="acfMaxTorqueWithFuel";["name"]="ents_methods:acfMaxTorqueWithFuel";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the torque in N/m of an ACF engine with fuel ";};["acfMuzzleVel"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the muzzle velocity of the ammo in a crate or gun";["fname"]="acfMuzzleVel";["name"]="ents_methods:acfMuzzleVel";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the muzzle velocity of the ammo in a crate or gun ";};["acfName"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the full name of an ACF entity";["fname"]="acfName";["name"]="ents_methods:acfName";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the full name of an ACF entity ";};["acfNameShort"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the short name of an ACF entity";["fname"]="acfNameShort";["name"]="ents_methods:acfNameShort";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the short name of an ACF entity ";};["acfNumGears"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the number of gears for an ACF gearbox";["fname"]="acfNumGears";["name"]="ents_methods:acfNumGears";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the number of gears for an ACF gearbox ";};["acfPeakFuelUse"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the peak fuel consumption in liters per minute or kilowatts of an engine at powerband max, for the current fuel type the engine is using";["fname"]="acfPeakFuelUse";["name"]="ents_methods:acfPeakFuelUse";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the peak fuel consumption in liters per minute or kilowatts of an engine at powerband max, for the current fuel type the engine is using ";};["acfPenetration"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the penetration of an AP, APHE, or HEAT round";["fname"]="acfPenetration";["name"]="ents_methods:acfPenetration";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the penetration of an AP, APHE, or HEAT round ";};["acfPower"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the current power of an ACF engine";["fname"]="acfPower";["name"]="ents_methods:acfPower";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the current power of an ACF engine ";};["acfPowerband"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the powerband min and max of an ACF Engine";["fname"]="acfPowerband";["name"]="ents_methods:acfPowerband";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the powerband min and max of an ACF Engine ";};["acfPowerbandMax"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the powerband max of an ACF engine";["fname"]="acfPowerbandMax";["name"]="ents_methods:acfPowerbandMax";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the powerband max of an ACF engine ";};["acfPowerbandMin"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the powerband min of an ACF engine";["fname"]="acfPowerbandMin";["name"]="ents_methods:acfPowerbandMin";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the powerband min of an ACF engine ";};["acfProjectileMass"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the mass of the projectile in a crate or gun";["fname"]="acfProjectileMass";["name"]="ents_methods:acfProjectileMass";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the mass of the projectile in a crate or gun ";};["acfPropArmor"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the current armor of an entity";["fname"]="acfPropArmor";["name"]="ents_methods:acfPropArmor";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the current armor of an entity ";};["acfPropArmorMax"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the max armor of an entity";["fname"]="acfPropArmorMax";["name"]="ents_methods:acfPropArmorMax";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the max armor of an entity ";};["acfPropDuctility"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the ductility of an entity";["fname"]="acfPropDuctility";["name"]="ents_methods:acfPropDuctility";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the ductility of an entity ";};["acfPropHealth"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the current health of an entity";["fname"]="acfPropHealth";["name"]="ents_methods:acfPropHealth";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the current health of an entity ";};["acfPropHealthMax"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the max health of an entity";["fname"]="acfPropHealthMax";["name"]="ents_methods:acfPropHealthMax";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the max health of an entity ";};["acfRPM"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the current rpm of an ACF engine";["fname"]="acfRPM";["name"]="ents_methods:acfRPM";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the current rpm of an ACF engine ";};["acfReady"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns true if the ACF gun is ready to fire";["fname"]="acfReady";["name"]="ents_methods:acfReady";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns true if the ACF gun is ready to fire ";};["acfRedline"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the redline rpm of an ACF engine";["fname"]="acfRedline";["name"]="ents_methods:acfRedline";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the redline rpm of an ACF engine ";};["acfRefuelDuty"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the ACF fuel tank refuel duty status, which supplies fuel to other fuel tanks";["fname"]="acfRefuelDuty";["name"]="ents_methods:acfRefuelDuty";["param"]={[1]="on";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the ACF fuel tank refuel duty status, which supplies fuel to other fuel tanks ";};["acfReload"]={["class"]="function";["classlib"]="Entity";["description"]="\
Causes an ACF weapon to reload";["fname"]="acfReload";["name"]="ents_methods:acfReload";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Causes an ACF weapon to reload ";};["acfReloadProgress"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns number between 0 and 1 which represents reloading progress of an ACF weapon. Useful for progress bars";["fname"]="acfReloadProgress";["name"]="ents_methods:acfReloadProgress";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns number between 0 and 1 which represents reloading progress of an ACF weapon.";};["acfReloadTime"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns time to next shot of an ACF weapon";["fname"]="acfReloadTime";["name"]="ents_methods:acfReloadTime";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns time to next shot of an ACF weapon ";};["acfRoundType"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the type of weapon the ammo in an ACF ammo crate loads into";["fname"]="acfRoundType";["name"]="ents_methods:acfRoundType";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the type of weapon the ammo in an ACF ammo crate loads into ";};["acfRounds"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the rounds left in an acf ammo crate";["fname"]="acfRounds";["name"]="ents_methods:acfRounds";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the rounds left in an acf ammo crate ";};["acfSetActive"]={["class"]="function";["classlib"]="Entity";["description"]="\
Turns an ACF engine, ammo crate, or fuel tank on or off";["fname"]="acfSetActive";["name"]="ents_methods:acfSetActive";["param"]={[1]="on";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Turns an ACF engine, ammo crate, or fuel tank on or off ";};["acfSetThrottle"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the throttle value for an ACF engine";["fname"]="acfSetThrottle";["name"]="ents_methods:acfSetThrottle";["param"]={[1]="throttle";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the throttle value for an ACF engine ";};["acfShift"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the current gear for an ACF gearbox";["fname"]="acfShift";["name"]="ents_methods:acfShift";["param"]={[1]="gear";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the current gear for an ACF gearbox ";};["acfShiftDown"]={["class"]="function";["classlib"]="Entity";["description"]="\
Cause an ACF gearbox to shift down";["fname"]="acfShiftDown";["name"]="ents_methods:acfShiftDown";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Cause an ACF gearbox to shift down ";};["acfShiftPointScale"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the shift point scaling for an automatic ACF gearbox";["fname"]="acfShiftPointScale";["name"]="ents_methods:acfShiftPointScale";["param"]={[1]="scale";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the shift point scaling for an automatic ACF gearbox ";};["acfShiftTime"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the time in ms an ACF gearbox takes to change gears";["fname"]="acfShiftTime";["name"]="ents_methods:acfShiftTime";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the time in ms an ACF gearbox takes to change gears ";};["acfShiftUp"]={["class"]="function";["classlib"]="Entity";["description"]="\
Cause an ACF gearbox to shift up";["fname"]="acfShiftUp";["name"]="ents_methods:acfShiftUp";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Cause an ACF gearbox to shift up ";};["acfSpread"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the spread for an ACF gun or flechette ammo";["fname"]="acfSpread";["name"]="ents_methods:acfSpread";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the spread for an ACF gun or flechette ammo ";};["acfSteerRate"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the steer ratio for an ACF gearbox";["fname"]="acfSteerRate";["name"]="ents_methods:acfSteerRate";["param"]={[1]="rate";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the steer ratio for an ACF gearbox ";};["acfTorque"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the current torque of an ACF engine";["fname"]="acfTorque";["name"]="ents_methods:acfTorque";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the current torque of an ACF engine ";};["acfTorqueOut"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the current torque output for an ACF gearbox";["fname"]="acfTorqueOut";["name"]="ents_methods:acfTorqueOut";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the current torque output for an ACF gearbox ";};["acfTorqueRating"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the max torque for an ACF gearbox";["fname"]="acfTorqueRating";["name"]="ents_methods:acfTorqueRating";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the max torque for an ACF gearbox ";};["acfTotalAmmoCount"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the number of rounds in all ammo crates linked to an ACF weapon";["fname"]="acfTotalAmmoCount";["name"]="ents_methods:acfTotalAmmoCount";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the number of rounds in all ammo crates linked to an ACF weapon ";};["acfTotalRatio"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the total ratio (current gear * final) for an ACF gearbox";["fname"]="acfTotalRatio";["name"]="ents_methods:acfTotalRatio";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the total ratio (current gear * final) for an ACF gearbox ";};["acfType"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the type of ACF entity";["fname"]="acfType";["name"]="ents_methods:acfType";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Returns the type of ACF entity ";};["acfUnlinkFrom"]={["class"]="function";["classlib"]="Entity";["description"]="\
Perform ACF unlinks";["fname"]="acfUnlinkFrom";["name"]="ents_methods:acfUnlinkFrom";["param"]={[1]="target";[2]="notify";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Perform ACF unlinks ";};["acfUnload"]={["class"]="function";["classlib"]="Entity";["description"]="\
Causes an ACF weapon to unload";["fname"]="acfUnload";["name"]="ents_methods:acfUnload";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Causes an ACF weapon to unload ";};};["name"]="Entity";["param"]={};["summary"]="\
Entity type ";["typtbl"]="ents_methods";};};["directives"]={};["hooks"]={};["libraries"]={[1]="acf";["acf"]={["class"]="library";["description"]="\
 \
ACF Library";["fields"]={};["functions"]={[1]="createAmmo";[10]="getAllFuelTanks";[11]="getAllGearboxes";[12]="getAllGuns";[13]="getAllMobility";[14]="getAmmoSpecs";[15]="getFuelTankSpecs";[16]="getGunSpecs";[17]="getMobilitySpecs";[18]="infoRestricted";[2]="createFuelTank";[3]="createGun";[4]="createMobility";[5]="dragDivisor";[6]="effectiveArmor";[7]="getAllAmmo";[8]="getAllAmmoBoxes";[9]="getAllEngines";["createAmmo"]={["class"]="function";["description"]="\
Creates a ammo box given the id";["fname"]="createAmmo";["library"]="acf";["name"]="acf_library.createAmmo";["param"]={[1]="pos";[2]="ang";[3]="id";[4]="gun_id";[5]="ammo_id";[6]="frozen";[7]="ammo_data";["ammo_data"]="the ammo data";["ammo_id"]="id of the ammo";["ang"]="Angle of created ammo box";["frozen"]="True to spawn frozen";["gun_id"]="id of the gun";["id"]="id of the ammo box to create";["pos"]="Position of created ammo box";};["private"]=false;["realm"]="sv";["ret"]="The created ammo box";["server"]=true;["summary"]="\
Creates a ammo box given the id ";["usage"]="\
If ammo_data isn't provided default values will be used (same as in the ACF menu) \
Possible values for ammo_data corresponding to ammo_id: \
 \
AP: \
- propellantLength (number) \
- projectileLength (number) \
- tracer (bool) \
 \
APHE: \
- propellantLength (number) \
- projectileLength (number) \
- heFillerVolume (number) \
- tracer (bool) \
 \
FL: \
- propellantLength (number) \
- projectileLength (number) \
- flechettes (number) \
- flechettesSpread (number) \
- tracer (bool) \
 \
HE: \
- propellantLength (number) \
- projectileLength (number) \
- heFillerVolume (number) \
- tracer (bool) \
 \
HEAT: \
- propellantLength (number) \
- projectileLength (number) \
- heFillerVolume (number) \
- crushConeAngle (number) \
- tracer (bool) \
 \
HP: \
- propellantLength (number) \
- projectileLength (number) \
- heFillerVolume (number) \
- hollowPointCavityVolume (number) \
- tracer (bool) \
 \
SM: \
- propellantLength (number) \
- projectileLength (number) \
- smokeFillerVolume (number) \
- wpFillerVolume (number) \
- fuseTime (number) \
- tracer (bool) \
 \
Refil: \
";};["createFuelTank"]={["class"]="function";["description"]="\
Creates a fuel tank given the id";["fname"]="createFuelTank";["library"]="acf";["name"]="acf_library.createFuelTank";["param"]={[1]="pos";[2]="ang";[3]="id";[4]="fueltype";[5]="frozen";["ang"]="Angle of created fuel tank";["frozen"]="True to spawn frozen";["fueltype"]="The type of fuel to use (Diesel, Electric, Petrol)";["id"]="id of the fuel tank to create";["pos"]="Position of created fuel tank";};["private"]=false;["realm"]="sv";["ret"]="The created fuel tank";["server"]=true;["summary"]="\
Creates a fuel tank given the id ";};["createGun"]={["class"]="function";["description"]="\
Creates a fun given the id or name";["fname"]="createGun";["library"]="acf";["name"]="acf_library.createGun";["param"]={[1]="pos";[2]="ang";[3]="id";[4]="frozen";["ang"]="Angle of created gun";["frozen"]="True to spawn frozen";["id"]="id or name of the gun to create";["pos"]="Position of created gun";};["private"]=false;["realm"]="sv";["ret"]="The created gun";["server"]=true;["summary"]="\
Creates a fun given the id or name ";};["createMobility"]={["class"]="function";["description"]="\
Creates a engine or gearbox given the id or name";["fname"]="createMobility";["library"]="acf";["name"]="acf_library.createMobility";["param"]={[1]="pos";[2]="ang";[3]="id";[4]="frozen";[5]="gear_ratio";["ang"]="Angle of created engine or gearbox";["frozen"]="True to spawn frozen";["gear_ratio"]="A table containing the gear ratios, only applied if the mobility is a gearbox. -1 is final drive";["id"]="id or name of the engine or gearbox to create";["pos"]="Position of created engine or gearbox";};["private"]=false;["realm"]="sv";["ret"]="The created engine or gearbox";["server"]=true;["summary"]="\
Creates a engine or gearbox given the id or name ";};["dragDivisor"]={["class"]="function";["description"]="\
Returns current ACF drag divisor";["fname"]="dragDivisor";["library"]="acf";["name"]="acf_library.dragDivisor";["param"]={};["private"]=false;["realm"]="sv";["ret"]="The current drag divisor";["server"]=true;["summary"]="\
Returns current ACF drag divisor ";};["effectiveArmor"]={["class"]="function";["description"]="\
Returns the effective armor given an armor value and hit angle";["fname"]="effectiveArmor";["library"]="acf";["name"]="acf_library.effectiveArmor";["param"]={[1]="armor";[2]="angle";};["private"]=false;["realm"]="sv";["ret"]="The effective armor";["server"]=true;["summary"]="\
Returns the effective armor given an armor value and hit angle ";};["getAllAmmo"]={["class"]="function";["description"]="\
Returns a list of all ammo types";["fname"]="getAllAmmo";["library"]="acf";["name"]="acf_library.getAllAmmo";["param"]={};["private"]=false;["realm"]="sv";["ret"]="The ammo list";["server"]=true;["summary"]="\
Returns a list of all ammo types ";};["getAllAmmoBoxes"]={["class"]="function";["description"]="\
Returns a list of all ammo boxes";["fname"]="getAllAmmoBoxes";["library"]="acf";["name"]="acf_library.getAllAmmoBoxes";["param"]={};["private"]=false;["realm"]="sv";["ret"]="The ammo box list";["server"]=true;["summary"]="\
Returns a list of all ammo boxes ";};["getAllEngines"]={["class"]="function";["description"]="\
Returns a list of all engines";["fname"]="getAllEngines";["library"]="acf";["name"]="acf_library.getAllEngines";["param"]={};["private"]=false;["realm"]="sv";["ret"]="The engine list";["server"]=true;["summary"]="\
Returns a list of all engines ";};["getAllFuelTanks"]={["class"]="function";["description"]="\
Returns a list of all fuel tanks";["fname"]="getAllFuelTanks";["library"]="acf";["name"]="acf_library.getAllFuelTanks";["param"]={};["private"]=false;["realm"]="sv";["ret"]="The fuel tank list";["server"]=true;["summary"]="\
Returns a list of all fuel tanks ";};["getAllGearboxes"]={["class"]="function";["description"]="\
Returns a list of all gearboxes";["fname"]="getAllGearboxes";["library"]="acf";["name"]="acf_library.getAllGearboxes";["param"]={};["private"]=false;["realm"]="sv";["ret"]="The gearbox list";["server"]=true;["summary"]="\
Returns a list of all gearboxes ";};["getAllGuns"]={["class"]="function";["description"]="\
Returns a list of all guns";["fname"]="getAllGuns";["library"]="acf";["name"]="acf_library.getAllGuns";["param"]={};["private"]=false;["realm"]="sv";["ret"]="The guns list";["server"]=true;["summary"]="\
Returns a list of all guns ";};["getAllMobility"]={["class"]="function";["description"]="\
Returns a list of all mobility components";["fname"]="getAllMobility";["library"]="acf";["name"]="acf_library.getAllMobility";["param"]={};["private"]=false;["realm"]="sv";["ret"]="The mobility component list";["server"]=true;["summary"]="\
Returns a list of all mobility components ";};["getAmmoSpecs"]={["class"]="function";["description"]="\
Returns the specs of the ammo";["fname"]="getAmmoSpecs";["library"]="acf";["name"]="acf_library.getAmmoSpecs";["param"]={[1]="id";["id"]="id of the ammo";};["private"]=false;["realm"]="sv";["ret"]="The specs table";["server"]=true;["summary"]="\
Returns the specs of the ammo ";};["getFuelTankSpecs"]={["class"]="function";["description"]="\
Returns the specs of the fuel tank";["fname"]="getFuelTankSpecs";["library"]="acf";["name"]="acf_library.getFuelTankSpecs";["param"]={[1]="id";["id"]="id of the engine or gearbox";};["private"]=false;["realm"]="sv";["ret"]="The specs table";["server"]=true;["summary"]="\
Returns the specs of the fuel tank ";};["getGunSpecs"]={["class"]="function";["description"]="\
Returns the specs of gun";["fname"]="getGunSpecs";["library"]="acf";["name"]="acf_library.getGunSpecs";["param"]={[1]="id";["id"]="id or name of the gun";};["private"]=false;["realm"]="sv";["ret"]="The specs table";["server"]=true;["summary"]="\
Returns the specs of gun ";};["getMobilitySpecs"]={["class"]="function";["description"]="\
Returns the specs of the engine or gearbox";["fname"]="getMobilitySpecs";["library"]="acf";["name"]="acf_library.getMobilitySpecs";["param"]={[1]="id";["id"]="id or name of the engine or gearbox";};["private"]=false;["realm"]="sv";["ret"]="The specs table";["server"]=true;["summary"]="\
Returns the specs of the engine or gearbox ";};["infoRestricted"]={["class"]="function";["description"]="\
Returns true if functions returning sensitive info are restricted to owned props";["fname"]="infoRestricted";["library"]="acf";["name"]="acf_library.infoRestricted";["param"]={};["private"]=false;["realm"]="sv";["ret"]="True if restriced, False if not";["server"]=true;["summary"]="\
Returns true if functions returning sensitive info are restricted to owned props ";};};["libtbl"]="acf_library";["name"]="acf";["summary"]="\
 \
ACF Library ";["tables"]={};};};})