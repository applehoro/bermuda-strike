extends Area3D

var is_underwater = false;
var depth = 0.0;


func _process( _delta: float ) -> void:
	is_underwater = false;
	for a in get_overlapping_areas():
		if( a.has_meta( "is_water" ) ):
			if( a.get_meta( "is_water" ) ):
				is_underwater = true;
				
				# determine depth of submersion
				depth = a.get_surface_y() - global_position.y;
