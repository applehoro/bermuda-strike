extends CharacterBody3D

var motion = Vector3();

var motion_dodge = Vector3();
var dodge_cd = 0.0;
var can_dodge = true;
var dodge_vel = 32.0;

var block_cd = 0.0;
var can_block = false;

var is_grounded = true;

var move_vel = 24.0;
var move_offset = 0.0;

var targeted_cd = 0.0;

var look_pos = Vector2();

var ai_state = "idle";
var ai_state_cd = 0.0;

var saw_player = false;
var player_yaw_angle = 0.0;
var player_pitch_angle = 0.0;
var player_dist = 0.0;

var attack_list = {};
var attack_cd = 0.0;

func _ready() -> void:
	look_at_pos( global_position - $yaw.global_basis.z );
	$radar_mark.visible = true;
	set_ai_state( ai_state );

func _physics_process(delta: float) -> void:
	
	# motion damping
	motion *= 1.0 - delta*8.0;
	motion_dodge *= 1.0 - delta*1.5;
	
	# cooldowns
	targeted_cd = max( targeted_cd - delta,  0.0 );
	dodge_cd = max( dodge_cd - delta,  0.0 );
	block_cd = max( block_cd - delta,  0.0 );
	attack_cd = max( attack_cd - delta,  0.0 );
	
	# AI
	ai_state_cooldown( delta );
	ai_state_update( delta )
	
	# motion update
	motion += motion_dodge*8.0*delta;
	if( is_grounded ):
		if( is_on_floor() ):
			motion.y = 0.0;
		else:
			motion.y = min( motion.y - delta*120.0, 0.0 );
	velocity = motion;
	move_and_slide();

func check_player():
	if( Global.node_player != null ):
		var offset = Global.node_player.global_position - global_position;
		player_dist = global_position.distance_to( Global.node_player.global_position );
		player_yaw_angle = $yaw.global_basis.z.signed_angle_to( -offset, $yaw.global_basis.y );
		player_pitch_angle = $yaw/pitch.global_basis.z.signed_angle_to( -offset, $yaw/pitch.global_basis.x );
		
		if( player_dist < 120.0 && abs( player_yaw_angle ) < PI/2.0 && abs( player_pitch_angle ) < PI/2.0 ):
			for xi in range( -1, 1 ):
				for yi in range( -1, 1 ):
					var p = Global.node_player.global_position + $yaw/pitch.global_basis.x*xi + $yaw/pitch.global_basis.y*yi;
					var r = Global.raycast_3d_body( global_position, p, [ self, Global.node_player ] );
					if( !r ):
						saw_player = true;
						return true;
	return false;

func on_player_target():
	targeted_cd = 0.1;

func is_targeted():
	return targeted_cd > 0.0;

func set_look( v ):
	look_pos = v;
	look_pos.y = clamp( look_pos.y, -PI/2.0, PI/2.0 );
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
		look_pos.y = clamp( look_pos.y, -PI/2.0, PI/2.0 );
		$yaw/pitch.rotation.x = look_pos.y;
	else:
		$yaw/pitch.look_at( pos, $yaw.global_basis.y );

func register_attack( id, dist_range, cd_range, anim_name ):
	attack_list[ id ] = {
		"dist_range": dist_range,
		"cd_range": cd_range,
		"anim_name": anim_name,
	};

func can_attack():
	return !attack_list.is_empty() && attack_cd <= 0.0;

func ai_state_cooldown( delta ):
	ai_state_cd = max( ai_state_cd - delta, 0.0 );
	if( ai_state_cd <= 0.0 ):
		if( can_attack() && saw_player && randi()%100 < 50 ):
			set_ai_state( "attack" );
		
		elif( is_targeted() && block_cd <= 0.0 && saw_player && can_block && randi()%100 < 15 ):
			set_ai_state( "block" );
		
		elif( is_targeted() && dodge_cd <= 0.0 && saw_player && can_dodge && randi()%100 < 15 ):
			set_ai_state( "dodge" );
		
		elif( saw_player ):
			set_ai_state( "chase" );
		
		else:
			set_ai_state( "idle" );

func ai_state_update( delta ):
	match( ai_state ):
		"idle":
			if( check_player() ):
				set_ai_state( "chase" );
		
		"chase":
			slow_look_at_pos( Global.node_player.global_position, delta*2.0 );
			var offset = Global.node_player.global_position - global_position;
			player_dist = global_position.distance_to( Global.node_player.global_position );
			player_yaw_angle = $yaw.global_basis.z.signed_angle_to( -offset, $yaw.global_basis.y );
			player_pitch_angle = $yaw/pitch.global_basis.z.signed_angle_to( -offset, $yaw/pitch.global_basis.x );
			if( player_dist > 4.0 ):
				motion -= $yaw/pitch.global_basis.z.rotated( Vector3.UP, deg_to_rad( move_offset*40.0 ) )*move_vel*delta;
		
		"dodge":
			slow_look_at_pos( Global.node_player.global_position, delta/1.5 );
		
		"block":
			slow_look_at_pos( Global.node_player.global_position, delta/3.0 );

func set_ai_state( s ):
	ai_state = s;
	match( ai_state ):
		"idle":
			ai_state_cd = randf_range( 0.1, 0.4 );
		
		"chase":
			ai_state_cd = randf_range( 0.5, 0.9 );
			move_offset = randf_range( -1.0, 1.0 );
		
		"attack":
			var i = randi()%attack_list.keys().size();
			var id = attack_list.keys()[ i ];
			attack_cd = randf_range( attack_list[ i ][ "cd_range" ].x, attack_list[ i ][ "cd_range" ].y );
			ai_state_cd = attack_cd;
		
		"block":
			ai_state_cd = randf_range( 0.4, 0.7 );
			block_cd = randf_range( 8.0, 12.0 );
		
		"dodge":
			ai_state_cd = randf_range( 0.3, 0.6 );
			var dir = $yaw.global_basis.x;
			if( randi()%100 > 75 ):
				dir = $yaw.global_basis.y;
			if( randi()%100 > 50 ):
				dir *= -1.0;
			motion_dodge = dir*dodge_vel;
			dodge_cd = randf_range( 6.0, 9.0 );
