@tool
extends Node3D

@export var size = Vector3( 0, 0, 0 );
@export var force = 10.0;

func _ready() -> void:
	$area/col.shape.size = size;
	$area.position = Vector3( 0, 0, size.z/2.0 )

func _process( delta: float ) -> void:
	DebugDraw3D.draw_arrow_ray( global_position, -global_basis.z, 1.0, Color( 1, 1, 1 ), 0.5 );
	DebugDraw3D.draw_box( global_position + global_basis.z*size.z/2.0, Quaternion( global_basis ), size, Color( 1, 1, 1 ), true );
	
	var p = Plane( global_basis.z );
	
	for obj in $area.get_overlapping_bodies():
		if( obj.has_method( "physics_push" ) ):
			var depth = p.distance_to( obj.global_position );
			obj.physics_push( -global_basis.z*depth*force*delta );
