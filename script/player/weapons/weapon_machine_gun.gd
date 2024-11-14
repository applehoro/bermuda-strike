extends PlayerWeaponBase

var projectile_id = "bullet_machine_gun";

func shoot():
	shoot_projectile( 1, projectile_id, 0.3 );
