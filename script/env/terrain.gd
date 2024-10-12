extends Terrain3D

func _ready() -> void:
	set_meta( "is_terrain", true );

func get_surface_y( pos ):
	return storage.get_height( pos );

func mark_damage( p ):
	Spawner.spawn( "dust_burst", p, Vector3() );
