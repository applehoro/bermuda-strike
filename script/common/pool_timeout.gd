extends Node3D

@export var lifetime = 1.0;
var life = 0.0;
var live = false;

var is_in_pool = false;

func _process( delta: float ) -> void:
	life -= delta;
	if( life <= 0.0 ):
		die();

#func spawn( pos, rot ):
	#global_position = pos;
	#global_rotation = rot;
	#setup();
#
#func spawn_t( t ):
	#global_transform = t;
	#setup();

func die():
	if( is_in_pool ):
		set_process( false );
		visible = false;
		live = false;
	else:
		queue_free();

func setup():
	life = lifetime;
	set_process( true );
	visible = true;
	live = true;
	if( has_node( "anim" ) ):
		$anim.stop();
		$anim.play( "startup" );
