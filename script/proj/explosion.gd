extends Area3D

@export var damage = Vector2( 30.0, 60.0 );
@export var push = 30.0;
@export var radius = 1.2;

var shot_by_player = false;

func _ready() -> void:
	pass;

func _physics_process(delta: float) -> void:
	call_deferred( "activate" );

func activate():
	for obj in get_overlapping_bodies():
		
		var dist = global_position.distance_to( obj.global_position );
		if( dist <= radius ):
			
			var r = Global.raycast_3d_body( global_position, obj.global_position );
			if( r ):
				if( r[ "collider" ] == obj ):
					var fo = max( radius - dist, 0.0 )/radius;
					
					if( obj.has_method( "push" ) ):
						var offset = obj.global_position - global_position;
						obj.push( offset*push*fo );
					
					if( obj.has_method( "damage" ) ):
						var d = randf_range( damage.x, damage.y )*fo;
						obj.damage( d );
					
					if( obj.has_method( "alarm" ) && shot_by_player ):
						obj.alarm();
		
		if( dist <= radius*4.0 ):
			if( obj.has_method( "alarm" ) && shot_by_player ):
				obj.alarm();
	
	for i in range( pow( radius, 1.5 ) ):
		var p = Vector3( randf_range( 0.0, radius ), 0.0, 0.0 );
		p = p.rotated( Vector3.LEFT, randf_range( 0.0, PI*2.0 ) );
		p = p.rotated( Vector3.UP, randf_range( 0.0, PI*2.0 ) );
		p = p.rotated( Vector3.FORWARD, randf_range( 0.0, PI*2.0 ) );
		Spawner.spawn( "flame_burst", global_position + p + Vector3( 0.0, 0.5, 0.0 ), Vector3() );
	
	queue_free();
