------------------
-- INSTALLATION --
------------------

- If you are updating a previous installation of ACF and you're having issues with 
  vanilla particles (fire, blood) not showing up, delete your garrysmod/particles/
  directory.

- It is not necessary to copy the scripts or particles directories anymore.


---------------------------------------------------------------
-- IF YOU WANT ACF POWERED STUFF TO GO MORE REALISTIC SPEEDS --
---------------------------------------------------------------

Put these two lines in your server.cfg:

lua_run local tbl = physenv.GetPerformanceSettings() tbl.MaxAngularVelocity = 30000 physenv.SetPerformanceSettings(tbl)
lua_run local tbl = physenv.GetPerformanceSettings() tbl.MaxVelocity = 20000 physenv.SetPerformanceSettings(tbl)

This will raise the angular velocity limit (wheels spinning) and forward speed limit.


--------------------
-- FOR DEVELOPERS --
--------------------

Frankess has added some handy hooks that can be used to limit damage and explosions
and such. They are as follows:

ACF_BulletsFlight( Index, Bullet )
	Return false to skip checking if the bullet hit something
	Args:
	- Index (number): the bullet's index
	- Bullet (BulletData): the bullet object
	
ACF_BulletDamage( Type, Entity, Energy, Area, Angle, Inflictor, Bone, Gun, IsFromAmmo )
	Return false to prevent damage
	Args:
	- Type (string): the ACF entity type (prop/vehicle/squishy)
	- Entity (entity): the entity being hit
	- Energy (table): kinetic energy
	- Area (number): area in cm^2
	- Angle (number): angle of bullet to armor
	- Inflictor (player): owner of bullet
	- Bone (number): the bone being hit
	- Gun (entity): the gun that fired the bullet
	- IsFromAmmo (boolean): true if this is from an ammo explosion (don't think this is implemented yet)
	
ACF_FireShell( Gun, Bullet )
	Return false to prevent gun from firing
	Args:
	- Gun (entity): the gun in question
	- Bullet (BulletData): the bullet that would be fired
	
ACF_AmmoExplode( Ammo, Bullet )
	Return false to prevent ammo crate from exploding
	Args:
	- Ammo (entity): the ammo crate in question
	- Bullet (BulletData): the bullet that would be fired
	
ACF_FuelExplode( Tank )
	Return false to prevent fuel tank from exploding
	Args:
	- Tank (entity): the fuel tank in question
	
ACF_CanRefill( Refill, Ammo )
	Return false to prevent ammo crate from being refilled (not yet implemented)
	
	
	
------------------------
Damage Protection hooks:

ACF_PlayerChangedZone
	This hook is called whenever a player moves between the battlefield and a safezone, or between safezones.
	This hook is called regardless of damage protection mode e.g. during build mode where safezones are irrelevant.
Args;
	ply		Player:	The player who has just transitioned from one zone to another.
	zone	String:	The name of the zone which the player has moved into (or nil if moved into battlefield)
	oldzone	String:	The name of the zone which the player has exited (or nil if exited battlefield)


ACF_ProtectionModeChanged
	This hook is called whenever the damage protection mode is altered.
	This hook is also called once at startup, when the damage protection mode is initialized to "default" (oldmode = nil during this run).
Args;
	mode	String:	The name of the newly activated damage protection mode.
	oldmode	String:	The name of the damage protection mode which has just been deactivated.
	
	

-----------------------
Bullet table callbacks:

For the argument list (Index, Bullet, FlightRes):
	Index: Index of the bullet in the bullet-list.
	Bullet: The bullet data table.
	FlightRes: The results of the bullet trace.
- - - - - -

OnEndFlight(Index, Bullet, FlightRes)
	called when a bullet ends its flight (explodes etc)
	
OnPenetrated(Index, Bullet, FlightRes)
	when a bullet pierces the world or an entity

OnRicochet(Index, Bullet, FlightRes)
	when a bullet bounces off an entity

PreCalcFlight(Bullet)
	just before the bullet performs a flight step

PostCalcFlight(Bullet)
	just after the bullet performs a flight step

HandlesOwnIteration 
	this is just a key: put it into the bullet table to prevent ACF from iterating the bullet.  You can then iterate it yourself in different places.