# author: applehoro
# script purposes:
# - handle projectile motion
# - deal damage to objects
# - handle water splash effect

extends Node3D

@export var velocity = 480.0;
@export var lifetime = 4.0;
var life = 0.0;
@export var damage = Vector2( 5.0, 8.0 );
@export var dive = 0.04;
@export var spawn_on_hit = "";
@export var spawn_on_lifetime_end = "";
@export var push_vel = 200.0;

var exclude = [];

var hit_water = false;

var live = false;
var is_in_pool = false;

var target = null;
@export var target_speed = 1.0;

var shot_by_player = false;

func _ready() -> void:
	pass;

func add_exclude( obj ):
	exclude.push_back( obj );

func _physics_process(delta: float) -> void:
	var np = global_position - global_basis.z*velocity*delta;
	
	# water splashes
	if( !hit_water ):
		var rw = Global.raycast_3d_area( global_position, np, [], Global.water_layer );
		if( rw ):
			if( rw[ "collider" ].has_meta( "is_water" ) ):
				if( rw[ "collider" ].get_meta( "is_water" ) ):
					Spawner.spawn( "water_splash", rw[ "position" ], Vector3() );
					hit_water = true;
	
	# hit something
	var r = Global.raycast_3d_body( global_position, np, exclude, 1 );
	if( r ):
		var obj = r[ "collider" ];
		if( obj.has_method( "damage" ) ):
			var d = randf_range( damage.x, damage.y );
			obj.damage( d );
		if( obj.has_method( "mark_damage" ) ):
			obj.mark_damage( r[ "position" ] );
		if( obj.has_method( "push" ) ):
			obj.push( -global_basis.z*push_vel );
		if( spawn_on_hit != "" ):
			var c = Spawner.spawn( spawn_on_hit, r[ "position" ], global_rotation );
			c.set( "shot_by_player", shot_by_player );
		if( shot_by_player && obj.has_method( "alarm" ) ):
			obj.alarm();
		Spawner.spawn( "hit_mark", r[ "position" ], Vector3() );
		die();
	else:
		global_position -= global_basis.z*velocity*delta;
	
	# dive
	global_transform = global_transform.looking_at( global_position - global_basis.z - Vector3( 0, dive, 0 )*delta );
	
	if( target != null ):
		var t = global_transform.looking_at( target.global_position, global_basis.y );
		global_transform = global_transform.interpolate_with( t, delta*target_speed );
	
	# lifetime
	life -= delta;
	if( life <= 0 ):
		if( spawn_on_lifetime_end != "" ):
			Spawner.spawn( spawn_on_lifetime_end, global_position, global_rotation );
		die();

# visual update
func _process( delta: float ) -> void:
	#$mesh.scale.z = 1.0 + velocity*delta;
	#$mesh.position.z = -0.5 - $mesh.scale.z*0.5;
	if( live ):
		visible = true;

func die():
	if( is_in_pool ):
		set_process( false );
		set_physics_process( false );
		visible = false;
		live = false;
		shot_by_player = false;
	else:
		queue_free();

func setup():
	live = true;
	life = lifetime;
	set_process( true );
	set_physics_process( true );
	visible = false;
	shot_by_player = false;
	
	hit_water = false;
	var rw = Global.raycast_3d_area( global_position, global_position - global_basis.z*0.05, [], Global.water_layer );
	if( rw ):
		if( rw[ "collider" ].has_meta( "is_water" ) ):
			if( rw[ "collider" ].get_meta( "is_water" ) ):
				hit_water = true;
