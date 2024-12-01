# author: applehoro
# script purposes:
# - store references to some nodes (player and world)
# - store game settings and send signal on their change
# - hande 3d raycasting by code

extends Node

var node_world = null;
var node_map = null;

var node_player = null;
var player_pos = Vector3();

var menu_open = false;

var settings = {
	"mouse_sensitivity": 0.005,
	
	"vsync": true,
	"aa": true,
	"render_distance": 2000.0,
	"fov": 60.0,
	"smoke_trails": true,
	"water_effects": true,
	"outline": true,
	"lens_flare": true,
	"special_effects": true,
	"view_bob": 1.0,
	"viewport_scale": 1.0,
	
	"auto_aim": true,
};

signal on_update_settings();

@export_flags_3d_physics var water_layer = 0b00000000_00000000_00000000_00000010;
@export_flags_3d_physics var all_layers = 0b00000000_00000000_00000000_00000011;

var messages = [];

func _ready() -> void:
	update_settings();

func message( t ):
	messages.push_back( { "text": t, "time": 5.0 } );
	while( messages.size() > 4 ):
		messages.pop_front();

func get_messages():
	var r = [ "", "", "", "" ];
	for i in range( messages.size() ):
		r[ i ] = messages[ i ][ "text" ];
	return r;

func _process(delta: float) -> void:
	if( messages.size() > 0 ):
		messages[ 0 ][ "time" ] -= delta;
		if( messages[ 0 ][ "time" ] <= 0.0 ):
			messages.pop_front();

# raycasting
func raycast_3d_body( from, to, exclude = [], mask = 0xFFFFFFFF ):
	var space_state = node_world.get_world_3d().direct_space_state;
	var query = PhysicsRayQueryParameters3D.create( from, to );
	query.exclude = exclude;
	query.collision_mask = mask;
	query.collide_with_areas = false;
	query.collide_with_bodies = true;
	query.hit_from_inside = true;
	return space_state.intersect_ray( query );

func raycast_3d_area( from, to, exclude = [], mask = 0xFFFFFFFF ):
	var space_state = node_world.get_world_3d().direct_space_state;
	var query = PhysicsRayQueryParameters3D.create( from, to );
	query.exclude = exclude;
	query.collision_mask = mask;
	query.collide_with_areas = true;
	query.collide_with_bodies = false;
	query.hit_from_inside = true;
	return space_state.intersect_ray( query );

func raycast_3d_any( from, to, exclude = [], mask = 0xFFFFFFFF ):
	var space_state = node_world.get_world_3d().direct_space_state;
	var query = PhysicsRayQueryParameters3D.create( from, to );
	query.exclude = exclude;
	query.collision_mask = mask;
	query.collide_with_areas = true;
	query.collide_with_bodies = true;
	query.hit_from_inside = true;
	return space_state.intersect_ray( query );

# settings
func update_settings():
	settings = {
		"mouse_sensitivity": Config.get_config( "InputSettings", "MouseSensitivity", 0.6 )*0.01,
		
		"vsync": Config.get_config( "VideoSettings", "VSync", true ),
		"aa": Config.get_config( "VideoSettings", "Aa", true ),
		"render_distance": 2000.0 + Config.get_config( "VideoSettings", "RenderDistance", 0.1 )*8000.0,
		"fov": 60.0 + Config.get_config( "VideoSettings", "Fov", 0.15 )*20.0,
		"smoke_trails": Config.get_config( "VideoSettings", "SmokeTrails", true ),
		"water_effects": Config.get_config( "VideoSettings", "WaterEffects", true ),
		"outline": Config.get_config( "VideoSettings", "Outline", true ),
		"lens_flare": Config.get_config( "VideoSettings", "LensFlare", true ),
		"special_effects": Config.get_config( "VideoSettings", "SpecialEffects", true ),
		"view_bob": Config.get_config( "VideoSettings", "ViewBob", 0.5 ),
		"viewport_scale": Config.get_config( "VideoSettings", "ViewportScale", 1.0 ),
		
		"auto_aim": Config.get_config( "GameSettings", "AutoAim", false ),
	};
	
	
	if( settings[ "aa" ] ):
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA;
	else:
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED;
	
	if( settings[ "vsync" ] ):
		DisplayServer.window_set_vsync_mode( DisplayServer.VSYNC_ENABLED );
	else:
		DisplayServer.window_set_vsync_mode( DisplayServer.VSYNC_DISABLED );
	
	get_window().scaling_3d_scale = 0.25 + settings[ "viewport_scale" ]*0.75;
	
	on_update_settings.emit();

func normalize_transform( t ):
	return Transform3D( t.basis.x, t.basis.y, t.basis.z, t.origin );
