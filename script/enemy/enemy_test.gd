extends CharacterBody3D

@export var node_anim : AnimationPlayer;

@export var max_health = 40.0;
@onready var health = max_health;

@export_category( "Cooldown" )
@export var idle_cooldown = Vector2( 0.1, 0.4 );
@export var chase_cooldown = Vector2( 0.5, 0.9 );
@export var dodge_cooldown = Vector2( 0.3, 0.6 );
@export var block_cooldown = Vector2( 0.4, 0.7 );
@export var flinch_cooldown = Vector2( 0.6, 0.7 );
@export var attack_cooldown = Vector2( 1.2, 1.8 );

@export_category( "Flinch" )
@export var flinch_chance = 50;

@export_category( "Dodge" )
var motion_dodge = Vector3();
var dodge_cd = 0.0;
@export var can_dodge = true;
@export var dodge_vel = 32.0;
@export var dodge_chance = 15;
@export var dodge_delay = Vector2( 6.0, 9.0 );
@export var dodge_damp = 6.0;

@export_category( "Block" )
var block_cd = 0.0;
@export var can_block = true;
@export var block_chance = 15;
@export var block_delay = Vector2( 8.0, 12.0 );
@export var block_mul = 0.25;
var is_grounded = true;

@export_category( "Attack" )
var attack_cd = 0.0;
@export var attack_chance = 50;
@export var attack_refire_chance = 70;

@export_category( "Motion" )
var motion = Vector3();
@export var move_vel = 24.0;
@export var motion_damp = 8.0;
@export var move_offset_angle = 45.0;
var move_offset = 0.0;
var push_vel = Vector3();
@export var push_mul = 0.05;

var targeted_cd = 0.0;
var look_pos = Vector2();

var ai_state = "idle";
var ai_state_cd = 0.0;

var saw_player = false;
var player_yaw_angle = 0.0;
var player_pitch_angle = 0.0;
var player_dist = 0.0;


func _ready() -> void:
	look_at_pos( global_position - global_basis.z );
	$radar_mark.visible = true;
	set_ai_state( ai_state );

func _physics_process(delta: float) -> void:
	
	# motion damping
	motion *= 1.0 - delta*motion_damp;
	push_vel *= 1.0 - delta*motion_damp;
	motion_dodge *= 1.0 - delta*dodge_damp;
	
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
	motion += push_vel;
	velocity = motion;
	move_and_slide();

func check_player():
	if( Global.node_player != null ):
		var offset = Global.player_pos - global_position;
		player_dist = global_position.distance_to( Global.player_pos );
		player_yaw_angle = global_basis.z.signed_angle_to( -offset, global_basis.y );
		player_pitch_angle = $pitch.global_basis.z.signed_angle_to( -offset, $pitch.global_basis.x );
		
		if( player_dist < 120.0 && abs( player_yaw_angle ) < PI/2.0 && abs( player_pitch_angle ) < PI/2.0 ):
			for xi in range( -1, 1 ):
				for yi in range( -1, 1 ):
					var p = Global.player_pos + $pitch.global_basis.x*xi + $pitch.global_basis.y*yi;
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
	rotation.y = look_pos.x;
	$pitch.rotation.x = look_pos.y;

func look_at_pos( pos ):
	var offset = pos - global_position;
	var hz_a = global_basis.z.signed_angle_to( -offset, global_basis.y );
	var vt_a = $pitch.global_basis.z.signed_angle_to( -offset, $pitch.global_basis.x );
	set_look( look_pos + Vector2( hz_a, vt_a ) );

func slow_look_at_pos( pos, delta ):
	var offset = pos - global_position;
	var hz_a = global_basis.z.signed_angle_to( -offset, global_basis.y );
	var vt_a = $pitch.global_basis.z.signed_angle_to( -offset, $pitch.global_basis.x );
	
	if( abs( hz_a ) > 0.05 ):
		look_pos.x = lerp( look_pos.x, look_pos.x + hz_a, delta + abs( hz_a )/10.0 );
		rotation.y = look_pos.x;
	else:
		look_at( pos, global_basis.y );
	
	if( abs( vt_a ) > 0.05 ):
		look_pos.y = lerp( look_pos.y, look_pos.y + vt_a, delta + abs( vt_a )/10.0 );
		look_pos.y = clamp( look_pos.y, -PI/2.0, PI/2.0 );
		$pitch.rotation.x = look_pos.y;
	else:
		$pitch.look_at( pos, global_basis.y );

func can_attack():
	return attack_cd <= 0.0;

func ai_state_cooldown( delta ):
	ai_state_cd = max( ai_state_cd - delta, 0.0 );
	if( ai_state_cd <= 0.0 ):
		if( ai_state == "attack" && randi()%100 < attack_refire_chance ):
			set_ai_state( "attack" );
		
		elif( can_attack() && saw_player && randi()%100 < attack_chance ):
			set_ai_state( "attack" );
		
		elif( is_targeted() && block_cd <= 0.0 && saw_player && can_block && randi()%100 < dodge_chance ):
			set_ai_state( "block" );
		
		elif( is_targeted() && dodge_cd <= 0.0 && saw_player && can_dodge && randi()%100 < block_chance ):
			set_ai_state( "dodge" );
		
		elif( saw_player ):
			set_ai_state( "chase" );
		
		else:
			set_ai_state( "idle" );

func ai_state_update( delta ):
	if( ai_state == "idle" ):
		if( check_player() ):
			set_ai_state( "chase" );
	
	elif( ai_state == "chase" ):
		var offset = Global.player_pos - global_position;
		player_dist = global_position.distance_to( Global.player_pos );
		player_yaw_angle = global_basis.z.signed_angle_to( -offset, global_basis.y );
		player_pitch_angle = $pitch.global_basis.z.signed_angle_to( -offset, $pitch.global_basis.x );
		if( player_dist > 4.0 ):
			motion += Vector3( offset.x, 0.0, offset.z ).normalized().rotated( Vector3.UP, deg_to_rad( move_offset*move_offset_angle ) )*move_vel*delta;
		look_at_pos( global_position - Vector3( motion.x, 0.0, motion.z ) );
	
	elif( ai_state == "dodge" ):
		slow_look_at_pos( Global.player_pos, delta/1.5 );
	
	elif( ai_state == "block" ):
		slow_look_at_pos( Global.player_pos, delta/3.0 );
	
	elif( ai_state == "attack" ):
		attack_update( delta );

func set_ai_state( s ):
	ai_state = s;
	match( ai_state ):
		"idle":
			ai_state_cd = randf_range( idle_cooldown.x, idle_cooldown.y );
		
		"chase":
			ai_state_cd = randf_range( idle_cooldown.x, idle_cooldown.y );
			move_offset = randf_range( -1.0, 1.0 );
			saw_player = true;
		
		"attack":
			attack_cd = randf_range( attack_cooldown.x, attack_cooldown.y );
			ai_state_cd = attack_cd;
			on_attack();
		
		"block":
			ai_state_cd = randf_range( block_cooldown.x, block_cooldown.y );
			block_cd = randf_range( block_delay.x, block_delay.y );
		
		"dodge":
			ai_state_cd = randf_range( dodge_cooldown.x, dodge_cooldown.y );
			dodge_cd = randf_range( dodge_delay.x, dodge_delay.y );
			
			var dir = global_basis.x;
			if( randi()%100 > 75 ):
				dir = global_basis.y;
			if( randi()%100 > 50 ):
				dir *= -1.0;
			motion_dodge = dir*dodge_vel;
		
		"flinch":
			ai_state_cd = randf_range( flinch_cooldown.x, flinch_cooldown.y );
			saw_player = true;

func on_attack():
	ai_state_cd = 0.3;
	look_at_pos( Global.player_pos );
	$pitch/muzzle.look_at( Global.player_pos );
	var off = Vector2( deg_to_rad( randf_range( 0, 30 ) ), 0.0 ).rotated( randf_range( 0.0, PI*2.0 ) );
	$pitch/muzzle.rotate( $pitch/muzzle.global_basis.y, off.x );
	$pitch/muzzle.rotate( $pitch/muzzle.global_basis.x, off.y );
	var c = Spawner.spawn_t( "bullet_223", $pitch/muzzle.global_transform );
	c.add_exclude( self );

func attack_update( delta ):
	look_at_pos( Global.player_pos );


func push( v ):
	push_vel += v*push_mul;

func damage( d ):
	if( block_cd > 0.0 ):
		health -= d*block_mul;
	else:
		health -= d;
	
	if( health <= 0.0 ):
		die();
	elif( randi()%100 < flinch_chance ):
		set_ai_state( "flinch" );

func die():
	queue_free();


