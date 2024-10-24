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
var walk_vel = 24.0;
var gravity_vel = 300.0;
var jump_vel = 40.0;

var physics_push_velocity = Vector3();

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
		set_look_pos( look_pos - event.relative*Global.settings[ "mouse_sensitivity" ] );
		if( motion_type == MOTION_TYPE_GLIDE ):
			camera_roll -= event.relative.x*Global.settings[ "mouse_sensitivity" ]*control_glide*0.5;

func set_look_pos( v ):
	look_pos = v;
	look_pos.y = clamp( look_pos.y, -PI/2, PI/2 );
	$yaw.rotation.y = look_pos.x;
	$yaw/pitch.rotation.x = look_pos.y;

func physics_push( v ):
	physics_push_velocity += v;

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
	is_on_ground = is_on_floor() || ( is_on_ground && abs( y_offset ) < 2.0 );
	
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
	
	# overdrive
	if( Input.is_action_pressed( "overdrive" ) && motion_type == MOTION_TYPE_GLIDE ):
		overdrive_heat = min( overdrive_heat + delta/20.0, 1.0 );
	else:
		overdrive_heat = max( overdrive_heat - delta/30.0, 0.0 );
	overdrive_boost = 1.0 - overdrive_heat*0.95;
	
	# damping
	if( motion_type == MOTION_TYPE_WALK ):
		motion *= 1.0 - delta*4.0;
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
			elif( Input.is_action_pressed( "move_up" ) ):
				control_glide = min( control_glide + delta*8.0, 1.0 );
			elif( Input.is_action_pressed( "move_dn" ) ):
				control_glide = max( control_glide - delta*8.0, 0.25 );
			else:
				control_glide = lerp( control_glide, 0.5, delta*8.0 );
			
			motion -= $yaw/pitch.global_basis.z*control_glide*delta*glide_vel;
			motion += $yaw/pitch.global_basis.x*control.x*delta*hover_vel;
			motion -= $yaw/pitch.global_basis.y*control.z*delta*hover_vel;
			camera_roll -= control.x*delta*0.3;
		
		# walk motion
		MOTION_TYPE_WALK:
			motion += $yaw.global_basis.x*control.x*delta*walk_vel;
			camera_roll -= control.x*delta*0.12;
			
			# swimming
			if( is_underwater || ( is_over_water && y_offset > -3.0 ) ):
				motion += $yaw/pitch.global_basis.z*control.z*delta*walk_vel;
				if( Input.is_action_pressed( "move_dn" ) ):
					motion -= $yaw.global_basis.y*walk_vel*delta;
				if( Input.is_action_pressed( "overdrive" ) ):
					motion += $yaw.global_basis.y*walk_vel*delta;
			
			# walking on ground
			else:
				motion += $yaw.global_basis.z*control.z*delta*walk_vel;
				if( is_on_ground ):
					motion.y = max( motion.y, 0.0 );
					if( Input.is_action_just_pressed( "overdrive" ) ):
						motion.y = jump_vel;
	
	# apply motion to velocity
	velocity *= 1.0 - delta*8.0;
	velocity += motion*delta*16.0;
	
	physics_push_velocity *= 1.0 - delta*4.0;
	velocity += physics_push_velocity*delta;
	
	# water physics
	if( motion_type == MOTION_TYPE_WALK ):
		
		# push from under the water
		if( is_underwater ):
			velocity.y += ( 0.5 + 0.5*abs( y_offset ) )*delta;
		elif( is_over_water && y_offset > -3 ):
			velocity.y += 0.5*delta;
		
		# apply gravity if in the air
		elif( !is_on_floor() ):
			velocity.y -= gravity_vel*gravity_scale*delta;
	
	else:
		if( is_underwater ):
			velocity.y += ( 8.0 + 4.0*abs( y_offset ) )*delta;
		elif( is_over_water && y_offset > -3 ):
			velocity.y += 8.0*delta;
		
		if( motion_type == MOTION_TYPE_HOVER && is_over_ground && y_offset > -4 ):
			velocity.y += 120.0*delta;
	
	move_and_slide();

func damage( d ):
	Inventory.damage( d );
	heal_cd = 5.0;

func die():
	Global.node_player = null;
	queue_free();
