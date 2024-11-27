extends Node3D

@export var spawn_num = 32;
@export var spawn_id = "frag";

@export var explosion_radius = 3.6;
@export var explosion_damage = Vector2( 60.0, 120.0 );
@export var explosion_push = 100.0;

func _ready() -> void:
	global_position -= global_basis.z*0.1;
	call_deferred( "activate" );

func activate():
	var e = Spawner.spawn( "explosion", global_position + Vector3( 0, 0.5, 0 ), Vector3() );
	e.radius = explosion_radius;
	e.damage = explosion_damage;
	e.push = explosion_push;
	
	for i in range( spawn_num ):
		var c = Spawner.spawn( spawn_id, global_position + Vector3( 0, 0.5, 0 ), Vector3() );
		c.global_rotate( c.global_basis.y, randf_range( 0, PI*2.0 ) );
		c.global_rotate( c.global_basis.x, randf_range( 0, PI*2.0 ) );
		
		var nt = c.global_transform.looking_at( c.global_position + Vector3( 0.0, 1.0, 0.0 ), c.global_basis.x );
		c.global_transform = c.global_transform.interpolate_with( nt, 0.5 );
		
	queue_free();
