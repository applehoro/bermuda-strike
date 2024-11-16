extends PlayerWeaponBase

var projectile_id = "grenade";

func shoot():
	shoot_projectile( 1, projectile_id, 0.3 );

func alt_shoot():
	shoot_projectile( 1, projectile_id, 0.3 );

