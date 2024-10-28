extends Node3D

var is_lock_on = false;
var target = null;

var target_pos = Vector3();

func _ready() -> void:
	pass;

func _physics_process( delta: float ) -> void:
	is_lock_on = false;
	target = null;
	target_pos = global_position - global_basis.z*240.0;
	
	var angle = -1.0;
	
	if( !is_lock_on ):
		for obj in $area.get_overlapping_bodies():
			if( obj.is_in_group( "enemy" ) ):
				var r = Global.raycast_3d_body( global_position, obj.global_position, [ Global.node_player, obj ] );
				if( !r ):
					var offset = obj.global_position - global_position;
					var a = global_basis.z.angle_to( -offset );
					if( a < angle || angle < 0.0 ):
						target = obj;
						is_lock_on = true;
						angle = a;
	
	if( target != null ):
		$lock_on.global_position = target.global_position;
		target_pos = target.global_position;
	$lock_on.visible = is_lock_on;
