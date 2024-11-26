extends Node3D

@export var spawn_id = "";

func on_load( v ):
	if( v ):
		Spawner.spawn( spawn_id, global_position, global_rotation );
	queue_free();
