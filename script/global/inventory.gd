# author: applehoro
# script purposes:
# - stores player inventory
# - handles player ammo
# - handles player health

extends Node

var health = 100.0;
var max_health = 100.0;

signal on_damage( v, t );
signal on_death();
signal on_heal( v, t );

func damage( v ):
	health = max( health - v );
	on_damage.emit( v, health );
	if( health <= 0 ):
		die();

func die():
	on_death.emit();

func heal( v ):
	if( health < max_health ):
		health = min( health + v, max_health );
		on_heal.emit( v, health );
		return true;
	return false;

var ammo = {
	"": Vector2i( 0, 0 ),
	"bullets": Vector2i( 100, 500 ),
};

func has_ammo( t ):
	if( ammo.has( t ) ):
		return ammo[ t ].x > 0;
	return false;

func give_ammo( t, v ):
	if( ammo.has( t ) ):
		if( ammo[ t ].x < ammo[ t ].y ):
			ammo[ t ].x = min( ammo[ t ].x + v, ammo[ t ].y );
			return true;
	return false;

func take_ammo( t, v ):
	if( ammo.has( t ) ):
		if( ammo[ t ].x >= v ):
			ammo[ t ].x -= v;
			return v;
		elif( ammo[ t ].x > 0 ):
			var r = ammo[ t ].x;
			ammo[ t ].x = 0;
			return r;
	return 0;

func get_ammo( t ):
	if( ammo.has( t ) ):
		return ammo[ t ].x;
	return 0;

func get_ammo_for_weapon( t ):
	if( ammo.has( magazine[ t ][ "type" ] ) ):
		return ammo[ magazine[ t ][ "type" ] ].x;
	return 0;

func get_max_ammo( t ):
	if( ammo.has( t ) ):
		return ammo[ t ].y;
	return 0;

var magazine = {
	"": { "ammo": Vector2i( 0, 0 ), "type": "" },
	"smg": { "ammo": Vector2i( 30, 30 ), "type": "bullets" },
};

func magazine_has_ammo( t ):
	if( magazine.has( t ) ):
		return magazine[ t ][ "ammo" ].x > 0;
	return false;

func magazine_has_ammo_amount( t, v ):
	if( magazine.has( t ) ):
		return magazine[ t ][ "ammo" ].x >= v;
	return false;

func magazine_take_ammo( t, v ):
	if( magazine.has( t ) ):
		if( magazine[ t ][ "ammo" ].x >= v ):
			magazine[ t ][ "ammo" ].x -= v;
			return v;
		elif( magazine[ t ][ "ammo" ].x > 0 ):
			var r = magazine[ t ][ "ammo" ].x;
			magazine[ t ][ "ammo" ].x = 0;
			return r;
	return 0;

func magazine_reload( t ):
	if( magazine.has( t ) ):
		magazine_unload( t );
		
		var a = take_ammo( magazine[ t ][ "type" ], magazine[ t ][ "ammo" ].y );
		magazine[ t ][ "ammo" ].x = a;
		return a;
	return 0;

func magazine_unload( t ):
	if( magazine.has( t ) ):
		give_ammo( magazine[ t ][ "type" ], magazine[ t ][ "ammo" ].x );
		magazine[ t ][ "ammo" ].x = 0;

func get_magazine_ammo( t ):
	if( magazine.has( t ) ):
		return magazine[ t ][ "ammo" ].x;
	return 0;

func get_magazine_capacity( t ):
	if( magazine.has( t ) ):
		return magazine[ t ][ "ammo" ].y;
	return 0;

func can_magazine_reload( t ):
	if( magazine.has( t ) ):
		return has_ammo( magazine[ t ][ "type" ] );
	return false;

func is_magazine_full( t ):
	if( magazine.has( t ) ):
		return magazine[ t ][ "ammo" ].x >= magazine[ t ][ "ammo" ].y;
	return false;

var weapons = {
	"": true,
	"smg": true,
};

var weapons_ammo_pickup = {
	"": { "ammo": 0, "type": "" },
	"smg": { "ammo": 30, "type": "bullets" },
};

func has_weapon( t ):
	if( weapons.has( t ) ):
		return weapons[ t ];
	return false;

func pickup_weapon( t ):
	if( weapons.has( t ) ):
		if( !weapons[ t ]):
			weapons[ t ] = true;
			give_ammo( weapons_ammo_pickup[ "type" ], weapons_ammo_pickup[ "ammo" ] );
			return true;
		else:
			return give_ammo( weapons_ammo_pickup[ "type" ], weapons_ammo_pickup[ "ammo" ] );
	return false;

signal on_switch_weapon( t );

func switch_weapon( t ):
	current_weapon_id = "";
	if( weapons.has( t ) ):
		if( weapons[ t ] ):
			current_weapon_id = t;
			on_switch_weapon.emit( t );
			return true;
	return false;

var current_weapon_id = "";

func cw_has_ammo():
	return has_ammo( current_weapon_id );

func cw_give_ammo( v ):
	return give_ammo( current_weapon_id, v );

func cw_take_ammo( v ):
	return take_ammo( current_weapon_id, v );

func cw_get_ammo():
	return get_ammo( current_weapon_id );

func cw_get_ammo_for_weapon():
	return get_ammo_for_weapon( current_weapon_id );

func cw_get_max_ammo():
	return get_max_ammo( current_weapon_id );

func cw_magazine_has_ammo():
	return magazine_has_ammo( current_weapon_id );

func cw_magazine_has_ammo_amount( v ):
	return magazine_has_ammo_amount( current_weapon_id, v );

func cw_magazine_take_ammo( v ):
	return magazine_take_ammo( current_weapon_id, v );

func cw_magazine_reload():
	return magazine_reload( current_weapon_id );

func cw_magazine_unload():
	return magazine_unload( current_weapon_id );

func cw_get_magazine_ammo():
	return get_magazine_ammo( current_weapon_id );

func cw_get_magazine_capacity():
	return get_magazine_capacity( current_weapon_id );

func cw_can_magazine_reload():
	return can_magazine_reload( current_weapon_id );

func cw_is_magazine_full():
	return is_magazine_full( current_weapon_id );

