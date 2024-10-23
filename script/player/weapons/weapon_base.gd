extends Node3D
class_name PlayerWeaponBase

@export_category( "Trigger Mechanics" )
var trigger = false;
var alt_trigger = false;
@export_enum( "one-shot", "hold" ) var trigger_mechanic = 0;
@export_enum( "one-shot", "hold" ) var alt_trigger_mechanic = 0;
var cd = 0.0;
@export var attack_cd = 0.07;
@export var alt_attack_cd = 0.07;

@export_category( "Inventory" )
@export var weapon_id = "";
@export var ammo_usage_per_attack = 0;
@export var ammo_usage_per_alt_attack = 0;

@export_category( "Spread" )
@export var spread_range_degrees = Vector2( 0.5, 15.0 );
@export var spread_increase = 0.65;
@export var spread_alt_increase = 2.0;
@export var spread_decrease = 26.0;
var spread = 0.0;


@export_category( "Node Paths" )
@export var node_muzzle: NodePath;
@export var node_anim: NodePath;
@export var node_anim_add: NodePath;

@export_category( "Animations" )
var state_machine;
@export var anim_name_equip = "equip";
@export var anim_name_idle = "idle";
@export var anim_name_reload = "reload";
@export var anim_queue_attack = [ "attack" ];
var anim_queue_attack_id = 0;
@export var anim_queue_alt_attack = [ "attack" ];
var anim_queue_alt_attack_id = 0;

func _ready() -> void:
	if( !get_node( node_anim ).is_connected( "animation_finished", _on_animation_finished ) ):
		get_node( node_anim ).connect( "animation_finished", _on_animation_finished );
	#state_machine = get_node( node_anim_tree ).get("parameters/playback")

func _process( _delta: float ) -> void:
	Inventory.crosshair_scale = 1.0 + spread/spread_range_degrees.y;

func _physics_process( delta: float ) -> void:
	spread = max( spread - spread_decrease*delta, spread_range_degrees.x );
	
	if( Input.is_action_just_pressed( "attack" ) ):
		trigger = true;
		on_trigger_pressed();
	elif( Input.is_action_just_released( "attack" ) ):
		trigger = false;
		on_trigger_released();
	
	if( Input.is_action_just_pressed( "alt_attack" ) ):
		alt_trigger = true;
		on_alt_trigger_pressed();
	elif( Input.is_action_just_released( "alt_attack" ) ):
		alt_trigger = false;
		on_alt_trigger_released();
	
	if( cd > 0.0 ):
		cd -= delta;
	
	elif( trigger ):
		if( attack() ):
			cd = attack_cd;
		else:
			reload();
		
		if( trigger_mechanic == 0 ):
			trigger = false;
	
	elif( alt_trigger ):
		if( alt_attack() ):
			cd = alt_attack_cd;
		else:
			reload();
		
		if( alt_trigger_mechanic == 0 ):
			alt_trigger = false;
	
	elif( Input.is_action_just_pressed( "reload" ) ):
		reload();

func attack():
	if( Inventory.cw_magazine_has_ammo_amount( ammo_usage_per_attack ) ):
		Inventory.cw_magazine_take_ammo( ammo_usage_per_attack );
		shoot();
		play_next_attack_anim();
		spread = min( spread + spread_increase, spread_range_degrees.y );
		return true;
	return false;

func alt_attack():
	if( Inventory.cw_magazine_has_ammo_amount( ammo_usage_per_alt_attack ) ):
		Inventory.cw_magazine_take_ammo( ammo_usage_per_alt_attack );
		alt_shoot();
		play_next_alt_attack_anim();
		spread = min( spread + spread_alt_increase, spread_range_degrees.y );
		return true;
	return false;

func equip():
	get_node( node_anim ).play( anim_name_equip );
	get_node( node_anim_add ).play( anim_name_equip );
	#state_machine.travel( anim_name_equip );
	cd = get_node( node_anim ).get_current_animation_length();
	Inventory.switch_weapon( weapon_id );

func reload():
	if( Inventory.cw_can_magazine_reload() && !Inventory.cw_is_magazine_full() ):
		Inventory.cw_magazine_unload();
		get_node( node_anim ).play( anim_name_reload );
		get_node( node_anim_add ).play( anim_name_reload );
		#state_machine.travel( anim_name_reload );
		cd = get_node( node_anim ).get_current_animation_length() + 0.1;
		trigger = false;

func play_next_attack_anim():
	get_node( node_anim ).stop();
	if( !anim_queue_attack.is_empty() ):
		anim_queue_attack_id += 1;
		if( anim_queue_attack_id >= anim_queue_attack.size() ):
			anim_queue_attack_id = 0;
		#state_machine.travel( anim_queue_attack[ anim_queue_attack_id ] );
		get_node( node_anim ).play( anim_queue_attack[ anim_queue_attack_id ] );
		get_node( node_anim_add ).play( anim_queue_attack[ anim_queue_attack_id ] );

func play_next_alt_attack_anim():
	get_node( node_anim ).stop();
	if( !anim_queue_alt_attack.is_empty() ):
		anim_queue_alt_attack_id += 1;
		if( anim_queue_alt_attack_id >= anim_queue_alt_attack.size() ):
			anim_queue_alt_attack_id = 0;
		#state_machine.travel( anim_queue_alt_attack[ anim_queue_alt_attack_id ] );
		get_node( node_anim ).play( anim_queue_alt_attack[ anim_queue_alt_attack_id ] );
		get_node( node_anim_add ).play( anim_queue_alt_attack[ anim_queue_alt_attack_id ] );

func _on_animation_finished( anim_name ):
	match( anim_name ):
		anim_name_reload:
			Inventory.cw_magazine_reload();
		
		_:
			get_node( node_anim ).play( anim_name_idle );
			get_node( node_anim_add ).play( anim_name_idle );

func shoot():
	pass;

func alt_shoot():
	pass;

# handle raycasting
func shoot_raycast( ignore_player = true, raycast_num = 1, raycast_spread = 0.0, raycast_length = 200.0, raycast_layers = Global.all_layers, raycast_damage = Vector2( 0.0, 1.0 ) ):
	var exclude = [];
	if( ignore_player ):
		exclude.push_back( Global.node_player );
	
	for i in range( raycast_num ):
		var sp = get_node( node_muzzle ).global_position;
		var sd = -get_node( node_muzzle ).global_basis.z;
		sd = sd.rotated( get_node( node_muzzle ).global_basis.y, randf_range( -deg_to_rad( spread ), deg_to_rad( spread ) ) );
		sd = sd.rotated( get_node( node_muzzle ).global_basis.x, randf_range( -deg_to_rad( spread ), deg_to_rad( spread ) ) );
		sd = sd.rotated( get_node( node_muzzle ).global_basis.y, randf_range( -deg_to_rad( raycast_spread ), deg_to_rad( raycast_spread ) ) );
		sd = sd.rotated( get_node( node_muzzle ).global_basis.x, randf_range( -deg_to_rad( raycast_spread ), deg_to_rad( raycast_spread ) ) );
		var dp = sp + sd*raycast_length;

		# hit something
		var r = Global.raycast_3d_body( sp, dp, exclude, raycast_layers );
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
				if( rw[ "collider" ].has_meta( "is_water" ) ):
					if( rw[ "collider" ].get_meta( "is_water" ) ):
						Spawner.spawn( "water_splash", rw[ "position" ], Vector3() );

# handle projectile spawning
func shoot_projectile( projectile_num = 1, projectile_id = "", projectile_spread = 0.0 ):
	for i in range( projectile_num ):
		var c = Spawner.spawn( projectile_id, get_node( node_muzzle ).global_position, global_rotation );
		c.add_exclude( Global.node_player );
		c.global_rotate( c.global_basis.y, randf_range( -deg_to_rad( spread ), deg_to_rad( spread ) ) );
		c.global_rotate( c.global_basis.x, randf_range( -deg_to_rad( spread ), deg_to_rad( spread ) ) );
		c.global_rotate( c.global_basis.y, randf_range( -deg_to_rad( projectile_spread ), deg_to_rad( projectile_spread ) ) );
		c.global_rotate( c.global_basis.x, randf_range( -deg_to_rad( projectile_spread ), deg_to_rad( projectile_spread ) ) );

func on_trigger_pressed():
	pass;

func on_trigger_released():
	pass;

func on_alt_trigger_pressed():
	pass;

func on_alt_trigger_released():
	pass;
