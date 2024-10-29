# author: applehoro
# script purpose:
# - handle visual effects, also switch them on and off depending on settings
# - handle GUI

extends CanvasLayer

var target_pos = Vector2();
var has_target = false;
var _had_target = false;

func _ready() -> void:
	update_settings();
	Global.connect( "on_update_settings", self.update_settings );
	get_viewport().connect( "size_changed", self.update_settings );

func _process(_delta: float) -> void:
	if( ( get_parent().is_over_water || get_parent().is_underwater ) && Global.settings[ "special_effects" ] ):
		$water_horizon.visible = true;
		$water_horizon.color.a = ease( max( 1.2 - abs( get_parent().y_offset ), 0.0 ), 0.25 );
		$water_distortion.visible = false;
		if( get_parent().is_underwater ):
			$water_distortion.visible = get_parent().y_offset > 0.0;
			
	else:
		$water_horizon.visible = false;
		$water_distortion.visible = false;
	
	$speed_lines.visible = get_parent().motion_type == get_parent().MOTION_TYPE_GLIDE && Input.is_action_pressed( "overdrive" ) && Global.settings[ "special_effects" ];
	
	# gui
	$fps.text = "FPS: " + str( Engine.get_frames_per_second() );
	$overheat.text = "Overheat: " + str( int( get_parent().overdrive_heat*100.0 ) ) + "%";
	$velocity.text = str( snappedf( get_parent().velocity.length(), 1.0 ) ) + " m/s";
	$velocity.visible = get_parent().motion_type != get_parent().MOTION_TYPE_WALK;
	
	if( Inventory.health <= 0.0 ):
		$health.text = "+0";
	elif( Inventory.health < 1.0 ):
		$health.text = "+1";
	else:
		$health.text = "+" + str( int( Inventory.health ) );
	
	$ammo_magazine.text = str( Inventory.cw_get_magazine_ammo() ) + "/" + str( Inventory.cw_get_magazine_capacity() );
	$ammo_magazine.visible = Inventory.current_weapon_id != "";
	$ammo_inventory.text = str( Inventory.cw_get_ammo_for_weapon() );
	$ammo_inventory.visible = Inventory.current_weapon_id != "";
	
	$crosshair/circle.scale = Vector2( 0.8, 0.8 )*Inventory.crosshair_scale;
	$crosshair/center.scale = Vector2( 1.0, 1.0 )*( 0.3 + Inventory.crosshair_scale*0.7 );
	
	$target.position = target_pos;
	if( has_target != _had_target ):
		if( has_target ):
			$target/animation_player.play( "on" );
		else:
			$target/animation_player.play( "off" );
	_had_target = has_target;

func update_settings():
	$lens_flare.visible = Global.settings[ "lens_flare" ];
	$crosshair.position = get_viewport().get_visible_rect().size/2.0;
