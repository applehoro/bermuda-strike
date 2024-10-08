extends Terrain3D

func mark_damage( p ):
	Spawner.spawn( "dust_burst", p, Vector3() );
