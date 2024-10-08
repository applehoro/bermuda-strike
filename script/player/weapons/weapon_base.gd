# author: applehoro

# script purpose:
# - base weapon mechanics
# - handles shooting weapon
# - handles weapon animation

extends Node3D

# cooldown
var cd = 0.0;

@export_category( "Trigger mechanic" )
var trigger = false;
@export_enum( "auto", "semi-auto", "burst" ) var trigger_mechanic = 0;
@export var attack_cd = 0.07;
@export var burst_attack_cd = 0.03;
@export var attacks_in_burst = 3;
var burst_queue = 0;

@export_category( "Inventory" )
@export var weapon_id = "";
@export var ammo_usage_per_shot = 0;

@export_category( "Spread" )
@export var spread_range_degrees = Vector2( 0.5, 15.0 );
var spread = 0.0;
@export var spread_increase = 0.65;
@export var spread_decrease = 26.0;

@export_category( "Attack mechanic" )
@export var node_muzzle: NodePath;
@export_enum( "spawn_projectile", "raycast", "custom" ) var attack_type = 0;

@export var projectile_id = "bullet";

@export var raycast_length = 1024.0;
@export_flags_3d_physics var raycast_layers = 1;
@export var raycast_ignore_player = true;
@export var raycast_damage = Vector2( 5.0, 8.0 );

@export_category( "Animations" )
@export var node_anim: NodePath;
@export var anim_name_equip = "equip";
@export var anim_name_unequip = "unequip";
@export var anim_name_idle = "idle";
@export var anim_name_reload = "reload";
@export var anim_queue_attack = [ "attack" ];
var anim_queue_attack_id = 0;

func _ready() -> void:
	if( !get_node( node_anim ).is_connected( "animation_finished", _on_anim_animation_finished ) ):
		get_node( node_anim ).connect( "animation_finished", _on_anim_animation_finished );

func _physics_process( delta: float ) -> void:
	match( trigger_mechanic ):
		0:
			trigger = Input.is_action_pressed( "attack" );
		
		1:
			if( Input.is_action_just_pressed( "attack" ) ):
				trigger = true;
		
		2:
			if( cd <= 0.0 ):
				if( Input.is_action_just_pressed( "attack" ) ):
					burst_queue = attacks_in_burst;
				if( burst_queue > 0 ):
					burst_queue -= 1;
					trigger = true;
	
	# cooldown
	if( cd > 0.0 ):
		cd -= delta;
	
	# triggered
	elif( trigger ):
		if( Inventory.cw_magazine_has_ammo_amount( ammo_usage_per_shot ) ):
			match( attack_type ):
				0:
					shoot_projectile();
				1:
					shoot_raycast();
				2:
					shoot_custom();
			
			if( trigger_mechanic == 2 ):
				if( burst_queue > 0 ):
					cd = burst_attack_cd;
				else:
					cd = attack_cd;
			else:
				cd = attack_cd;
			
			spread = min( spread + spread_increase, spread_range_degrees.y );
			get_node( node_anim ).stop();
			if( !anim_queue_attack.is_empty() ):
				anim_queue_attack_id += 1;
				if( anim_queue_attack_id >= anim_queue_attack.size() ):
					anim_queue_attack_id = 0;
				get_node( node_anim ).play( anim_queue_attack[ anim_queue_attack_id ] );
			
			if( trigger_mechanic == 1 || trigger_mechanic == 2 ):
				trigger = false;
			
			Inventory.cw_magazine_take_ammo( ammo_usage_per_shot );
		
		else:
			reload();
	
	# not triggered
	else:
		
		spread = max( spread - spread_decrease*delta, spread_range_degrees.x );
		if( Input.is_action_just_pressed( "reload" ) ):
			reload();

func equip():
	get_node( node_anim ).play( anim_name_equip );
	cd = get_node( node_anim ).get_current_animation_length();
	Inventory.switch_weapon( weapon_id );

func unequip():
	get_node( node_anim ).play( anim_name_unequip );
	cd = get_node( node_anim ).get_current_animation_length();

func reload():
	if( Inventory.cw_can_magazine_reload() && !Inventory.cw_is_magazine_full() ):
			Inventory.cw_magazine_unload();
			get_node( node_anim ).play( anim_name_reload );
			cd = get_node( node_anim ).get_current_animation_length();
			trigger = false;
			burst_queue = 0;

# handle raycasting
func shoot_raycast():
	var sp = get_node( node_muzzle ).global_position;
	var sd = -get_node( node_muzzle ).global_basis.z;
	sd = sd.rotated( get_node( node_muzzle ).global_basis.y, randf_range( -deg_to_rad( spread ), deg_to_rad( spread ) ) );
	sd = sd.rotated( get_node( node_muzzle ).global_basis.x, randf_range( -deg_to_rad( spread ), deg_to_rad( spread ) ) );
	var dp = sp + sd*raycast_length;
	var exclude = [];
	
	if( raycast_ignore_player ):
		exclude.push_back( Global.node_player );
	
	# hit something
	var r = Global.raycast_3d( sp, dp, exclude, raycast_layers );
	if( r ):
		var obj = r[ "collider" ];
		if( obj.has_method( "damage" ) ):
			var d = randf_range( raycast_damage.x, raycast_damage.y );
			obj.damage( d );
		if( obj.has_method( "mark_damage" ) ):
			obj.mark_damage( r[ "position" ] );
		Spawner.spawn( "hit_mark", r[ "position" ], Vector3() );
		
		# water splashes
		var rw = Global.raycast_3d_area( sp, r[ "position" ], exclude, Global.water_layer );
		if( rw ):
			Spawner.spawn( "water_splash", rw[ "position" ], Vector3() );

# handle projectile spawning
func shoot_projectile():
	var c = Spawner.spawn( projectile_id, get_node( node_muzzle ).global_position, get_node( node_muzzle ).global_rotation );
	c.add_exclude( Global.node_player );
	c.global_rotate( c.global_basis.y, randf_range( -deg_to_rad( spread ), deg_to_rad( spread ) ) );
	c.global_rotate( c.global_basis.x, randf_range( -deg_to_rad( spread ), deg_to_rad( spread ) ) );

func shoot_custom():
	pass;

func _on_anim_animation_finished(anim_name: StringName) -> void:
	match( anim_name ):
		anim_name_reload:
			Inventory.cw_magazine_reload();
		
		anim_name_unequip:
			queue_free();
