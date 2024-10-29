extends Node3D

var has_target = false;
var target = null;
var target_pos = Vector3();

func _ready() -> void:
	pass;

func _physics_process( delta: float ) -> void:
	has_target = false;
	target = null;
	target_pos = global_position - global_basis.z*240.0;
	
	# get object closest to target
	var angle = -1.0;
	var dist = -1.0;
	if( !has_target ):
		for obj in $area.get_overlapping_bodies():
			if( obj.is_in_group( "enemy" ) ):
				var offset = obj.global_position - global_position;
				var a = global_basis.z.angle_to( -offset );
				if( a < angle || angle < 0.0 ):
					angle = a;
					target = obj;
					dist = offset.length();
	
	if( check_target( target ) ):
		target_pos = target.global_position;
		has_target = true;
		if( angle < deg_to_rad( 3.0 ) && dist < 50.0 && target.has_method( "on_player_target" ) ):
			target.on_player_target();


func check_target( t ):
	if( t != null ):
		for xi in range( -1, 1 ):
			for yi in range( -1, 1 ):
				var p = t.global_position + global_basis.x*xi + global_basis.y*yi;
				var r = Global.raycast_3d_body( global_position, p, [ Global.node_player, t ] );
				if( !r ):
					target = t;
					has_target = true;
					return true;
	return false;
