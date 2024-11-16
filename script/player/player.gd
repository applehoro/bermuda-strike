# author: applehoro
# script purpose:
# - handle player movement
# - handle visual effects, also switch them on and off depending on settings

extends CharacterBody3D

var look_pos = Vector2();

enum {
	MOTION_TYPE_HOVER = 0,
	MOTION_TYPE_GLIDE = 1,
	MOTION_TYPE_WALK = 2,
};
var motion_type = MOTION_TYPE_HOVER;

var motion = Vector3();
var control_glide = 0.5;
var overdrive_boost = 1.0;
var overdrive_heat = 0.0;

var hover_vel = 64.0;
var glide_vel = 180.0;
var walk_vel = 20.0;
var sprint_vel = 40.0;
var gravity_vel = 9.8*4.0;
var jump_vel = 6.0;

var sprint_switch = false;

var push_vel = Vector3();

var camera_roll = 0.0;
var camera_roll_max = 30.0;

var is_over_water = false;
var is_underwater = false;
var is_over_ground = false;
var is_on_ground = false;
var y_offset = 0.0;

var gravity_scale = 0.0;

var heal_cd = 0.0;
var heal_margin = 50.0;

var is_lock_on = false;
var lock_on_target = null;

var zoom_mul = 1.0;
var target_zoom = 1.0;
var zoom = false;

var block_mul = 0.5;
var block = false;

func _ready() -> void:
	Global.node_player = self;
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	update_settings();
	Global.connect( "on_update_settings", self.update_settings );
	Inventory.connect( "on_death", self.die );

func update_settings():
	$yaw/pitch/camera/outline.visible = Global.settings[ "outline" ];
	$yaw/pitch/camera.far = Global.settings[ "render_distance" ];
	$yaw/pitch/camera.fov = Global.settings[ "fov" ];

func _exit_tree() -> void:
	Global.node_player = null;

func _input( event: InputEvent ) -> void:
	
	# mouse motion
	if( event is InputEventMouseMotion ):
		set_look( look_pos - event.relative*Global.settings[ "mouse_sensitivity" ] );
		if( motion_type == MOTION_TYPE_GLIDE ):
			camera_roll -= event.relative.x*Global.settings[ "mouse_sensitivity" ]*control_glide*0.5;

func set_motion_type( v ):
	motion_type = v;
	$ground_check.jet_enabled = motion_type != MOTION_TYPE_WALK;
	if( motion_type == MOTION_TYPE_WALK ):
		motion_mode = MOTION_MODE_GROUNDED;
	else:
		motion_mode = MOTION_MODE_FLOATING;

func _process( delta: float ) -> void:
	
	# camera roll
	camera_roll *= 1.0 - delta*2.0;
	camera_roll = clamp( camera_roll, deg_to_rad( -camera_roll_max ), deg_to_rad( camera_roll_max ) );
	$yaw/pitch/camera.rotation.z = camera_roll*Global.settings[ "view_bob" ];
	
	# visual effects
	$yaw/smoke_trail.emitting = motion.length() > 0.5 && Global.settings[ "smoke_trails" ] && !is_underwater && motion_type != MOTION_TYPE_WALK;
	
	$gui.has_target = false;
	lock_on_target = null;
	if( $yaw/pitch/target.has_target ):
		lock_on_target = $yaw/pitch/target.target;
		var p = $yaw/pitch/camera.unproject_position( $yaw/pitch/target.target_pos );
		$gui.has_target = true;
		$gui.target_pos = p;

func _physics_process( delta: float ) -> void:
	if( heal_cd > 0.0 ):
		heal_cd -= delta;
	elif( Inventory.health < heal_margin ):
		Inventory.heal( 1 );
		heal_cd = 0.1;
	
	is_over_water = $ground_check.is_over_water;
	is_underwater = $ground_check.is_underwater;
	is_over_ground = $ground_check.is_over_ground;
	y_offset = $ground_check.y_offset;
	var was_on_ground = is_on_ground;
	is_on_ground = is_on_floor(); # || ( is_on_ground && abs( y_offset ) < 2.0 );
	var is_colliding = $ground_check.is_colliding;
	
	# update control
	var control = Vector3();
	if( Input.is_action_pressed( "move_lt" ) ):
		control.x -= 1;
	if( Input.is_action_pressed( "move_rt" ) ):
		control.x += 1;
	if( Input.is_action_pressed( "move_dn" ) ):
		control.y -= 1;
	if( Input.is_action_pressed( "move_up" ) ):
		control.y += 1;
	if( Input.is_action_pressed( "move_fw" ) ):
		control.z -= 1;
	if( Input.is_action_pressed( "move_bw" ) ):
		control.z += 1;
	
	# switch motion type
	if( Input.is_action_just_pressed( "jet_mode_glide" ) ):
		set_motion_type( MOTION_TYPE_GLIDE );
	if( Input.is_action_just_pressed( "jet_mode_hover" ) ):
		set_motion_type( MOTION_TYPE_HOVER );
	if( Input.is_action_just_pressed( "jet_mode_off" ) ):
		set_motion_type( MOTION_TYPE_WALK);
	
	# sprint
	if( Input.is_action_just_pressed( "sprint_switch" ) ):
		sprint_switch = !sprint_switch;
	
	# overdrive
	if( Input.is_action_pressed( "overdrive" ) && motion_type == MOTION_TYPE_GLIDE ):
		overdrive_heat = min( overdrive_heat + delta/20.0, 1.0 );
	else:
		overdrive_heat = max( overdrive_heat - delta/30.0, 0.0 );
	overdrive_boost = 1.0 - overdrive_heat*0.8;
	
	# damping
	if( motion_type == MOTION_TYPE_WALK ):
		motion *= 1.0 - delta*6.0;
		if( is_underwater ):
			motion *= 1.0 - delta*5.0;
	else:
		motion *= 1.0 - delta*8.0;
		if( is_underwater ):
			motion *= 1.0 - delta*8.0;
	
	# update gravity scale
	if( motion_type == MOTION_TYPE_WALK ):
		if( is_underwater ):
			if( y_offset > 0.0 ):
				gravity_scale = max( gravity_scale - delta/0.7, -0.01 );
			else:
				gravity_scale = min( gravity_scale + delta/0.7, 0.01 );
		
		else:
			gravity_scale = min( gravity_scale + delta/0.7, 1.0 );
	else:
		gravity_scale = max( gravity_scale - delta/0.7, 0.0 );
	
	match( motion_type ):
		
		# hover motion
		MOTION_TYPE_HOVER:
			motion += $yaw.global_basis.x*control.x*delta*hover_vel;
			motion += $yaw.global_basis.y*control.y*delta*hover_vel;
			motion += $yaw.global_basis.z*control.z*delta*hover_vel;
			camera_roll -= control.x*delta*0.3;
		
		# glide motion
		MOTION_TYPE_GLIDE:
			if( Input.is_action_pressed( "overdrive" ) ):
				control_glide = min( control_glide + delta*8.0, 1.0 + overdrive_boost );
			else:
				control_glide = lerp( control_glide, 0.5, delta*8.0 );
			
			motion -= $yaw/pitch.global_basis.z*control_glide*delta*glide_vel;
			motion += $yaw/pitch.global_basis.x*control.x*delta*hover_vel;
			motion -= $yaw/pitch.global_basis.y*control.z*delta*hover_vel;
			camera_roll -= control.x*delta*0.3;
		
		# walk motion
		MOTION_TYPE_WALK:
			var vel = walk_vel;
			if( Input.is_action_pressed( "sprint" ) || sprint_switch ):
				vel = sprint_vel;
			
			motion += $yaw.global_basis.x*control.x*delta*vel;
			camera_roll -= control.x*delta*0.12;
			
			# swimming
			if( is_underwater || ( is_over_water && y_offset > -3.0 ) ):
				motion += $yaw/pitch.global_basis.z*control.z*delta*vel;
				if( Input.is_action_pressed( "move_dn" ) ):
					motion -= $yaw.global_basis.y*vel*delta;
				if( Input.is_action_pressed( "move_up" ) ):
					motion += $yaw.global_basis.y*vel*delta;
			
			# walking on ground
			else:
				motion += $yaw.global_basis.z*control.z*delta*vel;
				if( is_on_ground ):
					motion.y = max( motion.y, 0.0 );
				if( Input.is_action_just_pressed( "jump" ) && ( is_on_ground || was_on_ground ) ):
					motion.y = jump_vel;
					#gravity_scale = 0.0;
	
	# apply motion to velocity
	if( motion_type == MOTION_TYPE_WALK ):
		velocity.x *= 1.0 - delta*8.0;
		velocity.z *= 1.0 - delta*8.0;
	else:
		velocity *= 1.0 - delta*8.0;
	velocity += motion*delta*16.0;
	
	push_vel *= 1.0 - delta*4.0;
	velocity += push_vel*delta;
	
	# water physics
	if( motion_type == MOTION_TYPE_WALK ):
		
		# push from under the water
		if( is_underwater ):
			velocity.y += ( 0.5 + 0.5*abs( y_offset ) )*delta;
		elif( is_over_water && y_offset > -3 ):
			velocity.y += 0.5*delta;
		
		# apply gravity if in the air
		elif( is_on_ground ):
			velocity.y = max( velocity.y, 0.0 );
		else:
			velocity.y -= gravity_vel*gravity_scale*delta;
	
	if( !is_colliding ):
		velocity.y -= gravity_vel*delta*8.0;
	
	else:
		if( is_underwater ):
			velocity.y += ( 8.0 + 4.0*abs( y_offset ) )*delta;
		elif( is_over_water && y_offset > -3 ):
			velocity.y += 8.0*delta;
		
		if( motion_type == MOTION_TYPE_HOVER && is_over_ground && y_offset > -4 ):
			velocity.y += 120.0*delta;
	
	move_and_slide();

func push( v ):
	push_vel += v;

func damage( d ):
	Inventory.damage( d );
	heal_cd = 5.0;

func die():
	Global.node_player = null;
	queue_free();

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
