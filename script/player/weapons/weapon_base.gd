extends Node3D
class_name PlayerWeaponBase

enum TriggerType {
	NONE,
	SEMI_AUTO,
	AUTO,
	CHARGE,
	SHOOT_UNTIL_EMPTY,
};

enum AltTriggerType {
	NONE,
	SEMI_AUTO,
	AUTO,
	CHARGE,
	LOCK_ON,
	ZOOM,
	BLOCK,
	SHOOT_UNTIL_EMPTY,
};

@export_category( "Trigger Mechanics" )
var trigger = false;
var alt_trigger = false;
@export var trigger_mechanic : TriggerType;
@export var alt_trigger_mechanic : AltTriggerType;
var cd = 0.0;
@export var attack_cd = 0.07;
@export var alt_attack_cd = 0.07;
@export var charge_time = 1.0;
@export var alt_charge_time = 1.0;
var charge = 0.0;
var alt_charge = 0.0;
@export var zoom = 2.0;
@export var block = 0.5;
var shoot_until_empty = false;
var alt_shoot_until_empty = false;
@export var trigger_safety = false;
@export var alt_trigger_safety = false;

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
@export var node_muzzle: Node3D;
@export var node_anim: AnimationPlayer;
@export var node_anim_add: AnimationPlayer;

@export_category( "Animations" )
var state_machine;
@export var anim_name_equip = "equip";
@export var anim_name_idle = "idle";
@export var anim_name_reload = "reload";
@export var anim_name_charge = "charge";
@export var anim_queue_attack = [ "attack" ];
var anim_queue_attack_id = 0;
@export var anim_queue_alt_attack = [ "attack" ];
var anim_queue_alt_attack_id = 0;

var target_pos = Vector3();

func _ready() -> void:
	if( !node_anim.is_connected( "animation_finished", _on_animation_finished ) ):
		node_anim.connect( "animation_finished", _on_animation_finished );
	if( Input.is_action_pressed( "attack" ) && !trigger_safety ):
		on_trigger_pressed();
		trigger = true;
	if( Input.is_action_pressed( "alt_attack" ) && !alt_trigger_safety ):
		on_alt_trigger_pressed();
		alt_trigger = true;

func _process( _delta: float ) -> void:
	Inventory.crosshair_scale = 1.0 + spread/spread_range_degrees.y;

func _physics_process( delta: float ) -> void:
	spread = max( spread - spread_decrease*delta, spread_range_degrees.x );
	
	# handle input
	#trigger = Input.is_action_pressed( "attack" );
	if( Input.is_action_just_pressed( "attack" ) ):
		on_trigger_pressed();
		trigger = true;
	elif( Input.is_action_just_released( "attack" ) ):
		on_trigger_released();
		trigger = false;
	
	#alt_trigger = Input.is_action_pressed( "alt_attack" );
	if( Input.is_action_just_pressed( "alt_attack" ) ):
		on_alt_trigger_pressed();
		alt_trigger = true;
	elif( Input.is_action_just_released( "alt_attack" ) ):
		on_alt_trigger_released();
		alt_trigger = false;
	
	# targetting
	#target_pos = global_position - global_basis.z*240.0;
	#if( Global.node_player.is_lock_on || Global.settings[ "auto_aim" ] ):
		#for obj in get_tree().get_nodes_in_group( "player_target" ):
			#if( obj.has_target ):
				#target_pos = obj.target_pos;
	#node_muzzle.look_at( target_pos, global_basis.x );
	
	# cooldown
	if( cd > 0.0 ):
		cd -= delta;
	
	elif( shoot_until_empty ):
		if( attack() ):
			cd = attack_cd;
		else:
			shoot_until_empty = false;
			reload();
	
	elif( alt_shoot_until_empty ):
		if( alt_attack() ):
			cd = alt_attack_cd;
		else:
			alt_shoot_until_empty = false;
			reload();
	
	# main attack trigger
	else:
		match( trigger_mechanic ):
			TriggerType.SEMI_AUTO, TriggerType.AUTO:
				if( trigger ):
					if( has_ammo( ammo_usage_per_attack ) ):
						attack();
						cd = attack_cd;
					else:
						reload();
					
					if( trigger_mechanic == TriggerType.SEMI_AUTO ):
						trigger = false;
			
			TriggerType.CHARGE:
				if( trigger ):
					if( has_ammo( ammo_usage_per_attack ) ):
						charge = min( charge + delta/charge_time, 1.0 );
						play_anim( anim_name_charge );
					else:
						reload();
				elif( charge > 0.0 ):
					attack();
					cd = attack_cd;
					charge = 0.0;
			
			TriggerType.SHOOT_UNTIL_EMPTY:
				if( trigger && has_ammo( ammo_usage_per_attack ) ):
						shoot_until_empty = true;
		
		# alt attack trigger
		match( alt_trigger_mechanic ):
			AltTriggerType.SEMI_AUTO, AltTriggerType.AUTO:
				if( alt_trigger ):
					if( has_ammo( ammo_usage_per_alt_attack ) ):
						alt_attack();
						cd = alt_attack_cd;
					else:
						reload();
				
				if( alt_trigger_mechanic == AltTriggerType.SEMI_AUTO ):
					alt_trigger = false;
			
			AltTriggerType.CHARGE:
				if( alt_trigger ):
					if( has_ammo( ammo_usage_per_alt_attack ) ):
						alt_charge = min( alt_charge + delta/alt_charge_time, 1.0 );
						play_anim( anim_name_charge );
					else:
						reload();
				elif( alt_charge > 0.0 ):
					alt_attack();
					cd = alt_attack_cd;
					alt_charge = 0.0;
			
			AltTriggerType.SHOOT_UNTIL_EMPTY:
				if( alt_trigger && has_ammo( ammo_usage_per_alt_attack ) ):
						alt_shoot_until_empty = true;
			
			AltTriggerType.LOCK_ON:
				Global.node_player.is_lock_on = alt_trigger;
			
			AltTriggerType.ZOOM:
				Global.node_player.zoom = alt_trigger;
			
			AltTriggerType.BLOCK:
				Global.node_player.block = alt_trigger;
	
	# reload
	if( Input.is_action_just_pressed( "reload" ) && !ammo_full() ):
		reload();

func ammo_full():
	return Inventory.cw_is_magazine_full();

func has_ammo( a ):
	return Inventory.cw_magazine_has_ammo_amount( a );

func take_ammo( a ):
	if( has_ammo( a ) ):
		Inventory.cw_magazine_take_ammo( a );
		return true;
	return false;

func attack():
	if( take_ammo( ammo_usage_per_attack ) ):
		shoot();
		play_next_attack_anim();
		spread = min( spread + spread_increase, spread_range_degrees.y );
		return true;
	return false;

func alt_attack():
	if( take_ammo( ammo_usage_per_alt_attack ) ):
		alt_shoot();
		play_next_alt_attack_anim();
		spread = min( spread + spread_alt_increase, spread_range_degrees.y );
		return true;
	return false;

func equip():
	node_anim.play( anim_name_equip );
	if( node_anim_add != null ):
		if( node_anim_add.has_animation( anim_name_equip ) ):
			node_anim_add.play( anim_name_equip );
	cd = node_anim.get_current_animation_length();
	Inventory.switch_weapon( weapon_id );

func reload():
	if( Inventory.cw_can_magazine_reload() && !Inventory.cw_is_magazine_full() ):
		Inventory.cw_magazine_unload();
		node_anim.play( anim_name_reload );
		if( node_anim_add != null ):
			if( node_anim_add.has_animation( anim_name_reload ) ):
				node_anim_add.play( anim_name_reload );
		cd = node_anim.get_current_animation_length() + 0.1;
		#trigger = false;

func play_anim( a ):
	node_anim.play( a );
	if( node_anim_add != null ):
		if( node_anim_add.has_animation( a ) ):
			node_anim_add.play( a );

func play_anim_reset( a ):
	node_anim.stop();
	node_anim.play( a );
	if( node_anim_add != null ):
		if( node_anim_add.has_animation( a ) ):
			node_anim_add.stop();
			node_anim_add.play( a );

func play_next_attack_anim():
	if( !anim_queue_attack.is_empty() ):
		node_anim.stop();
		anim_queue_attack_id += 1;
		if( anim_queue_attack_id >= anim_queue_attack.size() ):
			anim_queue_attack_id = 0;
		node_anim.play( anim_queue_attack[ anim_queue_attack_id ] );
		if( node_anim_add != null ):
			if( node_anim_add.has_animation( anim_queue_attack[ anim_queue_attack_id ] ) ):
				node_anim_add.play( anim_queue_attack[ anim_queue_attack_id ] );

func play_next_alt_attack_anim():
	if( !anim_queue_alt_attack.is_empty() ):
		node_anim.stop();
		anim_queue_alt_attack_id += 1;
		if( anim_queue_alt_attack_id >= anim_queue_alt_attack.size() ):
			anim_queue_alt_attack_id = 0;
		node_anim.play( anim_queue_alt_attack[ anim_queue_alt_attack_id ] );
		if( node_anim_add != null ):
			if( node_anim_add.has_animation( anim_queue_alt_attack[ anim_queue_alt_attack_id ] ) ):
				node_anim_add.play( anim_queue_alt_attack[ anim_queue_alt_attack_id ] );

func _on_animation_finished( anim_name ):
	match( anim_name ):
		anim_name_reload:
			Inventory.cw_magazine_reload();
		
		_:
			node_anim.play( anim_name_idle );
			if( node_anim_add != null ):
				if( node_anim_add.has_animation( anim_name_idle ) ):
					node_anim_add.play( anim_name_idle );

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
		var sp = node_muzzle.global_position;
		var off = target_pos - node_muzzle.global_position;
		var sd = -off.normalized();
		sd = sd.rotated( node_muzzle.global_basis.y, randf_range( -deg_to_rad( spread ), deg_to_rad( spread ) ) );
		sd = sd.rotated( node_muzzle.global_basis.x, randf_range( -deg_to_rad( spread ), deg_to_rad( spread ) ) );
		sd = sd.rotated( node_muzzle.global_basis.y, randf_range( -deg_to_rad( raycast_spread ), deg_to_rad( raycast_spread ) ) );
		sd = sd.rotated( node_muzzle.global_basis.x, randf_range( -deg_to_rad( raycast_spread ), deg_to_rad( raycast_spread ) ) );
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
	var t = global_transform; #Global.normalize_transform( node_muzzle.global_transform );
	t.origin -= t.basis.z*0.5;
	#t = t.looking_at( target_pos, global_basis.x );
	for i in range( projectile_num ):
		#var c = Spawner.spawn( projectile_id, node_muzzle.global_position, node_muzzle.global_rotation );
		var c = Spawner.spawn_t( projectile_id, t );
		c.add_exclude( Global.node_player );
		var rot = Vector2( deg_to_rad( randf_range( -spread - projectile_spread, spread + projectile_spread ) ), 0.0 ).rotated( randf_range( 0, PI*2.0 ) );
		c.global_rotate( t.basis.y.normalized(), rot.x );
		c.global_rotate( t.basis.x.normalized(), rot.y );
		#c.global_rotate( t.basis.y.normalized(), randf_range( -deg_to_rad( spread ), deg_to_rad( spread ) ) );
		#c.global_rotate( t.basis.x.normalized(), randf_range( -deg_to_rad( spread ), deg_to_rad( spread ) ) );
		#c.global_rotate( t.basis.y.normalized(), randf_range( -deg_to_rad( projectile_spread ), deg_to_rad( projectile_spread ) ) );
		#c.global_rotate( t.basis.x.normalized(), randf_range( -deg_to_rad( projectile_spread ), deg_to_rad( projectile_spread ) ) );
		if( alt_trigger_mechanic == AltTriggerType.LOCK_ON && alt_trigger ):
			c.target = Global.node_player.lock_on_target;
		else:
			c.target = null;

func on_trigger_pressed():
	pass;

func on_trigger_released():
	pass;

func on_alt_trigger_pressed():
	pass;

func on_alt_trigger_released():
	pass;

func on_charge( v ):
	pass;

func on_alt_charge( v ):
	pass;
