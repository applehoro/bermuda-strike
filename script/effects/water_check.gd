# author: applehoro

# script purposes:
# - interact with water areas
# - hande visual water effects

extends Node3D

var is_over_water = false;
var is_underwater = false;
var depth = 0.0;

func _ready() -> void:
	update_settings();
	Global.connect( "on_update_settings", self.update_settings );

func update_settings():

	# enable or disable water effects by settings
	if( Global.settings[ "water_effects" ] ):
		$splash.visible = true;
		$rings.visible = true;
#		$raycast.enabled = true;
#		set_process( true );
	else:
		$splash.visible = false;
		$splash.emitting = false;
		$rings.visible = false;
		$rings.emitting = false;
#		$raycast.enabled = false;
#		set_process( false );

func _process( delta: float ) -> void:
	is_over_water = false;
	is_underwater = false;
	if( $raycast.is_colliding() ):
	
		# determine depth of submersion
		depth = $raycast.get_collider().get_surface_y() - global_position.y;
		if( depth > 0.0 ):
			is_underwater = true;
		else:
			is_over_water = true;
		
		# enable water effects if over water
		if( is_over_water ):
			$rings.global_position = global_position;
			$rings.global_position.y = $raycast.get_collider().get_surface_y();
			$rings.emitting = true;
			if( depth > -10.0 ):
				$splash.global_position = global_position;
				$splash.global_position.y = $raycast.get_collider().get_surface_y();
				$splash.emitting = true;
		
		# disable water effects if underwater
		else:
			$rings.emitting = false;
			$splash.emitting = false;
