extends Node3D

@export var spawn_num = 32;
@export var spawn_id = "bullet_frag";

func _ready() -> void:
	call_deferred( "activate" );

func activate():
	for i in range( spawn_num ):
		var r = Vector3( randf_range( 0.0, PI*2.0 ), randf_range( 0.0, PI*2.0 ), randf_range( 0.0, PI*2.0 ) );
		Spawner.spawn( spawn_id, global_position, r );
	queue_free();
