extends Node2D

var is_shown = false;
var look_pos = Vector2( 0.0, -PI/2.0 );
var zoom = 4;

func _ready() -> void:
	visible = is_shown;
	$texture.texture = $viewport.get_texture();
	$viewport/yaw/pitch/camera.position.z = 250.0*zoom;

func _process( delta: float ) -> void:
	if( Input.is_action_just_pressed( "map" ) ):
		if( Global.menu_open  ):
			is_shown = false;
		else:
			is_shown = !is_shown;
		
		if( is_shown ):
			get_tree().paused = true;
		elif( !Global.menu_open ):
			get_tree().paused = false;
		visible = is_shown;
	
	if( is_shown ):
		$viewport/yaw.global_position = Global.node_player.global_position;
		$viewport/yaw/pitch/camera.position.z = lerp( $viewport/yaw/pitch/camera.position.z, 250.0*zoom, delta*8.0 )

func _input(event: InputEvent) -> void:
	if( event is InputEventMouseMotion && is_shown ):
		set_look( look_pos - event.relative*Global.settings[ "mouse_sensitivity" ] );
	elif( event is InputEventMouseButton ):
		if( event.button_index == MOUSE_BUTTON_WHEEL_DOWN ):
			zoom = min( zoom + 1, 25 );
		if( event.button_index == MOUSE_BUTTON_WHEEL_UP ):
			zoom = max( zoom - 1, 1 );

func set_look( v ):
	look_pos = v;
	look_pos.y = clamp( look_pos.y, -PI/2.0, -PI/6.0 );
	$viewport/yaw.rotation.y = look_pos.x;
	$viewport/yaw/pitch.rotation.x = look_pos.y;
