extends Node3D

var cd = 0.0;

func _process(delta: float) -> void:
	if( cd > 0.0 ):
		cd -= delta;
	else:
		if( Global.node_player != null ):
			var pos = Global.node_player.global_position;
			pos = pos.snappedf( 512 );
			pos.y = 0;
			global_position = pos;
		cd = 4.0;
