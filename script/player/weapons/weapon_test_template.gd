extends PlayerWeaponBase

var projectile_id = "bullet";

func shoot():
	shoot_projectile( 1, projectile_id, 0.3 );
