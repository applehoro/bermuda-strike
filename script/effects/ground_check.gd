# author: applehoro

# script purposes:
# - interact with water areas
# - handle visual water effects

extends Node3D

var is_over_water = false;
var is_underwater = false;
var is_over_ground = false;
var is_colliding = false;
var y_offset = 0.0;

var jet_enabled = true;

func _ready() -> void:
	update_settings();
	Global.connect( "on_update_settings", self.update_settings );

func update_settings():
	# enable or disable water effects by settings
	if( Global.settings[ "water_effects" ] ):
		$splash.visible = true;
		$rings.visible = true;
	else:
		$splash.visible = false;
		$splash.emitting = false;
		$rings.visible = false;
		$rings.emitting = false;

func _process( _delta: float ) -> void:
	is_over_water = false;
	is_underwater = false;
	is_over_ground = false;
	is_colliding = $raycast.is_colliding();
	
	if( $raycast.is_colliding() ):
		var obj = $raycast.get_collider();
		
		# check for water
		if( obj.has_meta( "is_water" ) ):
			if( obj.get_meta( "is_water" ) ):
				# determine depth of submersion
				y_offset = obj.get_surface_y() - global_position.y;
				
				if( y_offset > 0.0 ):
					is_underwater = true;
				else:
					is_over_water = true;
		
		# check for ground
		elif( obj.has_meta( "is_terrain" ) ):
			if( obj.get_meta( "is_terrain" ) ):
				# determine the altitude
				y_offset = obj.get_surface_y( global_position ) - global_position.y;
				
				is_over_ground = true;
		
		else:
			# determine the altitude
			y_offset = $raycast.get_collision_point().y - global_position.y;
			is_over_ground = true;
		
		# enable water effects if over water
		if( is_over_water && y_offset > -20.0 ):
			if( jet_enabled ):
				$rings.global_position = global_position;
				$rings.global_position.y = obj.get_surface_y();
				$rings.emitting = true;
				
				if( y_offset > -10.0 ):
					$splash.global_position = global_position;
					$splash.global_position.y = obj.get_surface_y();
					$splash.emitting = true;
		
		# disable water effects if underwater or far away from water
		else:
			$rings.emitting = false;
			$splash.emitting = false;
