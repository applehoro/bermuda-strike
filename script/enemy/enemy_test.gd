extends CharacterBody3D

var motion = Vector3();
var motion_avoid = Vector3();
var avoid_cd = 0.0;

var fly_vel = 16.0;

var targeted_cd = 0.0;

var look_pos = Vector2();

func _ready() -> void:
	look_at_pos( global_position - $yaw.global_basis.z );

func _physics_process(delta: float) -> void:
	# cooldowns
	targeted_cd = max( targeted_cd - delta,  0.0 );
	avoid_cd = max( avoid_cd - delta,  0.0 );
	
	# avoid logic
	motion_avoid *= 1.0 - delta*1.5;
	if( is_targeted() && avoid_cd <= 0.0 ):
		var dir = $yaw.global_basis.x;
		if( randi()%100 > 75 ):
			dir = $yaw.global_basis.y;
		if( randi()%100 > 50 ):
			dir *= -1.0;
		
		motion_avoid = dir*fly_vel*2.0;
		avoid_cd = randf_range( 6.0, 9.0 );
	
	# motion update
	motion *= 1.0 - delta*8.0;
	
	# apply avoid motion
	if( avoid_cd > 0.0 ):
		motion += motion_avoid*8.0*delta;
	
	velocity = motion;
	move_and_slide();
	
	slow_look_at_pos( Global.node_player.global_position, delta*8.0 );

func on_player_target():
	targeted_cd = 0.1;

func is_targeted():
	return targeted_cd > 0.0;

func set_look( v ):
	look_pos = v;
	look_pos.y = clamp( look_pos.y, -PI/2, PI/2 );
	$yaw.rotation.y = look_pos.x;
	$yaw/pitch.rotation.x = look_pos.y;

func look_at_pos( pos ):
	var offset = pos - global_position;
	var hz_a = $yaw.global_basis.z.signed_angle_to( -offset, $yaw.global_basis.y );
	var vt_a = $yaw/pitch.global_basis.z.signed_angle_to( -offset, $yaw/pitch.global_basis.x );
	set_look( look_pos + Vector2( hz_a, vt_a ) );

func slow_look_at_pos( pos, delta ):
	var offset = pos - global_position;
	var hz_a = $yaw.global_basis.z.signed_angle_to( -offset, $yaw.global_basis.y );
	var vt_a = $yaw/pitch.global_basis.z.signed_angle_to( -offset, $yaw/pitch.global_basis.x );
	
	if( abs( hz_a ) > 0.05 ):
		look_pos.x = lerp( look_pos.x, look_pos.x + hz_a, delta + abs( hz_a )/10.0 );
		$yaw.rotation.y = look_pos.x;
	else:
		$yaw.look_at( pos, $yaw.global_basis.y );
	
	if( abs( vt_a ) > 0.05 ):
		look_pos.y = lerp( look_pos.y, look_pos.y + vt_a, delta + abs( vt_a )/10.0 );
		look_pos.y = clamp( look_pos.y, -PI/2, PI/2 );
		$yaw/pitch.rotation.x = look_pos.y;
	else:
		$yaw/pitch.look_at( pos, $yaw.global_basis.y );
