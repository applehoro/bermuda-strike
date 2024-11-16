extends PlayerWeaponBase

var projectile_id = "flak";
var alt_projectile_id = "flak_alt";

func shoot():
	shoot_projectile( 12, projectile_id, 5.0 );

func alt_shoot():
	shoot_projectile( 1, alt_projectile_id, 2.2 );
