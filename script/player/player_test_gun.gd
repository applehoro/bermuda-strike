# author: applehoro

# script purpose:
# - testing weapon mechanics
# - later would be rewritten as parent class for different weapons
# - handles shooting weapon
# - handles weapon animation

extends Node3D

# cooldown
var cd = 0.0;
@export var node_muzzle: NodePath;

@export_category( "Trigger mechanic" )
var trigger = false;
@export_enum( "auto", "semi-auto", "burst" ) var trigger_mechanic = 0;
@export var shoot_cd = 0.07;
@export var burst_shoot_cd = 0.03;
@export var shoots_in_burst = 3;
var burst_queue = 0;

@export_category( "Inventory" )
@export var weapon_id = "smg";
@export var ammo_per_shot = 1;

@export_category( "Spread" )
@export var spread_range = Vector2( 0.5, 15.0 );
var spread = 0.5;
@export var spread_increase = 0.65;
@export var spread_decrease = 26.0;

@export_category( "Shooting mechanic" )
@export_enum( "spawn_projectile", "raycast" ) var shoot_type = 0;

@export var projectile_id = "bullet";

@export var raycast_length = 1024.0;
@export_flags_3d_physics var raycast_layers = 1;
@export var raycast_ignore_player = true;
@export var raycast_damage = Vector2( 5.0, 8.0 );

func _physics_process( delta: float ) -> void:
	match( trigger_mechanic ):
		0:
			trigger = Input.is_action_pressed( "shoot" );
		
		1:
			if( Input.is_action_just_pressed( "shoot" ) ):
				trigger = true;
		
		2:
			if( cd <= 0.0 ):
				if( Input.is_action_just_pressed( "shoot" ) ):
					burst_queue = shoots_in_burst;
				if( burst_queue > 0 ):
					burst_queue -= 1;
					trigger = true;
	
	# cooldown
	if( cd > 0.0 ):
		cd -= delta;
	
	# triggered
	elif( trigger ):
		if( Inventory.cw_magazine_has_ammo_amount( ammo_per_shot ) ):
			match( shoot_type ):
				0:
					shoot_projectile();
				1:
					shoot_raycast();
			
			if( trigger_mechanic == 2 ):
				if( burst_queue > 0 ):
					cd = burst_shoot_cd;
				else:
					cd = shoot_cd;
			else:
				cd = shoot_cd;
			
			spread = min( spread + spread_increase, spread_range.y );
			$anim.stop();
			$anim.play( "shoot" );
			
			if( trigger_mechanic == 1 || trigger_mechanic == 2 ):
				trigger = false;
			
			Inventory.cw_magazine_take_ammo( ammo_per_shot );
		
		else:
			reload();
	
	# not triggered
	else:
		
		spread = max( spread - spread_decrease*delta, spread_range.x );
		if( Input.is_action_just_pressed( "reload" ) ):
			reload();

func equip():
	$anim.play( "equip" );
	cd = $anim.get_current_animation_length();
	Inventory.switch_weapon( weapon_id );

func unequip():
	$anim.play( "unequip" );
	cd = $anim.get_current_animation_length();

func reload():
	if( Inventory.cw_can_magazine_reload() && !Inventory.cw_is_magazine_full() ):
			Inventory.cw_magazine_unload();
			$anim.play( "reload" );
			cd = $anim.get_current_animation_length();
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

func _on_anim_animation_finished(anim_name: StringName) -> void:
	match( anim_name ):
		"reload":
			Inventory.cw_magazine_reload();
		
		"unequip":
			queue_free();
