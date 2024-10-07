# author: applehoro
# script purpose:
# - handle player movement
# - handle visual effects, also switch them on and off depending on settings (later should be moved to separate script for gui nodes)
# - handle GUI (later should be moved in separate script)


extends CharacterBody3D

var look_pos = Vector2();

enum {
	MOTION_TYPE_HOVER = 0,
	MOTION_TYPE_GLIDE = 1,
};
var motion_type = MOTION_TYPE_HOVER;

var motion = Vector3();
var control_glide = 0.5;
var overdrive_boost = 1.0;
var overdrive_heat = 0.0;

var hover_vel = 32.0;
var glide_vel = 180.0;

var camera_roll = 0.0;
var camera_roll_max = 30.0;

func _ready() -> void:
	Global.node_player = self;
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	update_settings();
	Global.connect( "on_update_settings", self.update_settings );
	get_viewport().connect( "size_changed", self.update_settings );

func update_settings():
	$yaw/pitch/cam/outline.visible = Global.settings[ "outline" ];
	$gui/lens_flare.visible = Global.settings[ "lens_flare" ];
	$gui/crosshair.position = get_viewport().get_visible_rect().size/2.0;
	$yaw/pitch/cam.far = Global.settings[ "render_distance" ];
	$yaw/pitch/cam.fov = Global.settings[ "fov" ];

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

func _process( delta: float ) -> void:
	
	# camera roll
	camera_roll *= 1.0 - delta*2.0;
	camera_roll = clamp( camera_roll, deg_to_rad( -camera_roll_max ), deg_to_rad( camera_roll_max ) );
	$yaw/pitch/cam.rotation.z = camera_roll;
	
	# visual effects
	$yaw/smoke_trail.emitting = motion.length() > 0.5 && Global.settings[ "smoke_trails" ] && !$water_check.is_underwater;
	
	if( ( $water_check.is_over_water || $water_check.is_underwater ) && Global.settings[ "special_effects" ] ):
		$gui/water_horizon.visible = true;
		$gui/water_horizon.color.a = ease( max( 1.2 - abs( $water_check.depth ), 0.0 ), 0.25 );
		if( $water_check.is_underwater ):
			$gui/water_distortion.visible = true;
		else:
			$gui/water_distortion.visible = false;
	else:
		$gui/water_horizon.visible = false;
		$gui/water_distortion.visible = false;
	
	$gui/speed_lines.visible = motion_type == MOTION_TYPE_GLIDE && Input.is_action_pressed( "overdrive" ) && Global.settings[ "special_effects" ];
	
	# gui
	$gui/fps.text = "FPS: " + str( Engine.get_frames_per_second() );
	$gui/overheat.text = "Overheat: " + str( int( overdrive_heat*100.0 ) ) + "%";
	$gui/velocity.text = str( snappedf( velocity.length(), 1.0 ) ) + " m/s";

func _physics_process( delta: float ) -> void:
	
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
	
	if( Input.is_action_just_pressed( "switch_motion" ) ):
		if( motion_type == MOTION_TYPE_HOVER ):
			motion_type = MOTION_TYPE_GLIDE;
		else:
			motion_type = MOTION_TYPE_HOVER;
	
	if( Input.is_action_pressed( "overdrive" ) ):
		overdrive_heat = min( overdrive_heat + delta/20.0, 1.0 );
	else:
		overdrive_heat = max( overdrive_heat - delta/30.0, 0.0 );
	overdrive_boost = 1.0 - overdrive_heat*0.95;
	
	# damping
	motion *= 1.0 - delta*8.0;
	if( $water_check.is_underwater ):
		motion *= 1.0 - delta*8.0;
	
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
	
	# apply motion to velocity
	velocity *= 1.0 - delta*4.0;
	velocity += motion*delta*8.0;
	
	# water physics
	if( $water_check.is_underwater ):
		velocity.y += ( 8.0 + 4.0*abs( $water_check.depth ) )*delta;
	elif( $water_check.is_over_water && $water_check.depth > -3 ):
		velocity.y += 8.0*delta;
	
	move_and_slide();
