extends Node3D

@export var door_front_l: NodePath;
@export var door_front_r: NodePath;
var door_front_l_pos = Vector3();
var door_front_r_pos = Vector3();
@export var area_front_in: NodePath;
@export var area_front_out: NodePath;
@export var door_front_movement = 1.0;
var is_door_front_closed = true;
var is_player_inside = false;

@export var door_back_l: NodePath;
@export var door_back_r: NodePath;
var door_back_l_pos = Vector3();
var door_back_r_pos = Vector3();
@export var area_back_in: NodePath;
@export var area_back_out: NodePath;
@export var door_back_movement = 1.0;

@export var disable_sun_on_enter = true;
var sun_def_energy = 1.0;
var sun_def_sky = 0.9;

func _ready() -> void:
	door_front_l_pos = get_node( door_front_l ).position;
	door_front_r_pos = get_node( door_front_r ).position;
	door_back_l_pos = get_node( door_back_l ).position;
	door_back_r_pos = get_node( door_back_r ).position;
	
	for c in get_tree().get_nodes_in_group( "sun" ):
		sun_def_energy = c.light_energy;
	for c in get_tree().get_nodes_in_group( "env" ):
		sun_def_sky = c.environment.ambient_light_sky_contribution 

func _process( delta: float ) -> void:
	var door_front_closed = false;
	var f_open = is_player_in_area( area_front_in ) || is_player_in_area( area_front_out );
	if( f_open ):
		interpolate_door( door_front_l, door_front_l_pos, -door_front_movement, delta/0.4 );
		interpolate_door( door_front_r, door_front_r_pos, door_front_movement, delta/0.4 );
		is_door_front_closed = false;
	else:
		interpolate_door( door_front_l, door_front_l_pos, 0.0, delta/0.07 );
		if( interpolate_door( door_front_r, door_front_r_pos, 0.0, delta/0.07 ) ):
			is_door_front_closed = true;
	
	var b_open = is_player_in_area( area_back_in ) || is_player_in_area( area_back_out );
	if( b_open ):
		interpolate_door( door_back_l, door_back_l_pos, door_back_movement, delta/0.4 );
		interpolate_door( door_back_r, door_back_r_pos, -door_back_movement, delta/0.4 );
	else:
		interpolate_door( door_back_l, door_back_l_pos, 0.0, delta/0.07 );
		interpolate_door( door_back_r, door_back_r_pos, 0.0, delta/0.07 );
	
	if( is_player_in_area( area_front_out ) ):
		is_player_inside = false;
	if( is_player_in_area( area_front_in ) ):
		is_player_inside = true;
	
	if( is_door_front_closed && is_player_inside ):
		set_sun_enabled( false, delta/0.05 );
	else:
		set_sun_enabled( true, delta/0.05 );

func interpolate_door( node_path, pos, offset, delta ):
	var n = get_node( node_path );
	var cp = n.position;
	var tp = pos + Vector3( offset, 0, 0 );
	if( cp.distance_to( tp ) < 0.02 ):
		n.position = tp;
		return true;
	else:
		n.position = lerp( cp, tp, delta );
		return false;

func is_player_in_area( node_path ):
	for obj in get_node( node_path ).get_overlapping_bodies():
		if( obj.is_in_group( "player" ) ):
			return true;
	return false;

func set_sun_enabled( v, delta ):
	for c in get_tree().get_nodes_in_group( "sun" ):
		if( v ):
			c.light_energy = lerp( c.light_energy, 1.0, delta );
		else:
			c.light_energy = lerp( c.light_energy, 0.0, delta );
	
	for c in get_tree().get_nodes_in_group( "env" ):
		if( v ):
			c.environment.ambient_light_sky_contribution = lerp( c.environment.ambient_light_sky_contribution, 0.9, delta );
			c.environment.background_mode = c.environment.BG_SKY;
		else:
			c.environment.ambient_light_sky_contribution = lerp( c.environment.ambient_light_sky_contribution, 0.05, delta );
			if( c.environment.ambient_light_sky_contribution < 0.06 ):
				c.environment.background_mode = c.environment.BG_CLEAR_COLOR;
			else:
				c.environment.background_mode = c.environment.BG_SKY;
