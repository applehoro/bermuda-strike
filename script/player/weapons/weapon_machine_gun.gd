extends PlayerWeaponBase

var projectile_id = "bullet_223";

func shoot():
	shoot_projectile( 1, projectile_id, 0.3 );
