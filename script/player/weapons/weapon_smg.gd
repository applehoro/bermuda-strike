extends PlayerWeaponBase

var projectile_id = "bullet_9mm";

func shoot():
	shoot_projectile( 1, projectile_id, 0.8 );

func alt_shoot():
	shoot_projectile( 3, projectile_id, 3.5 );
