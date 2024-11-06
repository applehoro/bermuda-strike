extends Terrain3D

func _ready() -> void:
	set_meta( "is_terrain", true );
	call_deferred( "populate" );

func populate():
	for r in data.get_regions_active():
		#print( str( r.location ) );
		for xi in range( region_size ):
			for yi in range( region_size ):
				#var p = r.location*region_size + Vector2i( xi, yi );
				var p = Vector3( r.location.x*region_size + xi, 0.0, r.location.y*region_size + yi );
				var id = data.get_control_base_id( p );
				if( id == 1 && randi()%1000 <= 1 ):
					var c = Spawner.spawn( "palm_1", Vector3( p.x, data.get_height( p ) + randf_range( 0.5, -1.0 ), p.z ), Vector3( deg_to_rad( randf_range( -5.0, 5.0 ) ), randf_range( 0.0, PI*2.0 ), deg_to_rad( randf_range( -5.0, 5.0 ) ) ) );
					#add_child( c );

func get_surface_y( pos ):
	return data.get_height( pos );

func mark_damage( p ):
	Spawner.spawn( "dust_burst", p, Vector3() );
