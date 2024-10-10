# author: applehoro
# script purposes:
# - handle projectile motion
# - deal damage to objects
# - handle water splash effect

extends Node3D

@export var velocity = 480.0;
@export var lifetime = 4.0;
@export var damage = Vector2( 5.0, 8.0 );
@export var dive = 0.04;
@export var spawn_on_hit = "";
@export var spawn_on_lifetime_end = "";

var exclude = [];

func _ready() -> void:
	#$mesh.scale.z = 0.01;
	$mesh.position.z = -$mesh.mesh.size.z*2.0;
	#$mesh.visible = false;

func add_exclude( obj ):
	exclude.push_back( obj );

func _physics_process(delta: float) -> void:
	var np = global_position - global_basis.z*velocity*delta;
	
	# water splashes
	var rw = Global.raycast_3d_area( global_position, np, [], Global.water_layer );
	if( rw ):
		Spawner.spawn( "water_splash", rw[ "position" ], Vector3() );
	
	
	# hit something
	var r = Global.raycast_3d( global_position, np, exclude, 1 );
	if( r ):
		var obj = r[ "collider" ];
		if( obj.has_method( "damage" ) ):
			var d = randf_range( damage.x, damage.y );
			obj.damage( d );
		if( obj.has_method( "mark_damage" ) ):
			obj.mark_damage( r[ "position" ] );
		if( spawn_on_hit != "" ):
			Spawner.spawn( spawn_on_hit, r[ "position" ], global_rotation );
		Spawner.spawn( "hit_mark", r[ "position" ], Vector3() );
		die();
	else:
		global_position -= global_basis.z*velocity*delta;
	
	# dive
	global_transform = global_transform.looking_at( global_position - global_basis.z - Vector3( 0, dive, 0 )*delta );
	
	# lifetime
	lifetime -= delta;
	if( lifetime <= 0 ):
		if( spawn_on_lifetime_end != "" ):
			Spawner.spawn( spawn_on_lifetime_end, global_position, global_rotation );
		die();

# visual update
func _process( delta: float ) -> void:
	$mesh.scale.z = 1.0 + velocity*delta;
	$mesh.position.z = -0.5 - $mesh.mesh.size.z*$mesh.scale.z*0.5;
	#$mesh.visible = true;

func die():
	queue_free();