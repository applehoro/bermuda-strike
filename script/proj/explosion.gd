extends Area3D

@export var damage = Vector2( 30.0, 60.0 );
@export var push = 30.0;
@export var radius = 1.2;

func _ready() -> void:
	$col.shape.radius = radius;

func _physics_process(delta: float) -> void:
	activate();
	queue_free();

func activate():
	for obj in get_overlapping_bodies():
		var r = Global.raycast_3d_body( global_position, obj.global_position );
		
		if( r ):
			if( r[ "collider" ] == obj ):
				var dist = global_position.distance_to( obj.global_position );
				var fo = max( radius - dist, 0.0 )/radius;
				if( obj.has_method( "damage" ) ):
					var d = randf_range( damage.x, damage.y )*fo;
					obj.damage( d );
				if( obj.has_method( "push" ) ):
					var offset = obj.global_position - global_position;
					obj.push( offset*push*fo );
