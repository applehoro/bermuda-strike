extends RigidBody3D

var is_lock_on = false;

func _ready() -> void:
	update_settings();
	Global.connect( "on_update_settings", self.update_settings );

func set_vel( v ):
	linear_velocity = v;
	linear_velocity.y += randf_range( 12, 22 );
	angular_velocity += global_basis.z*v.dot( global_basis.x );
	angular_velocity += global_basis.x*v.dot( global_basis.z );

func update_settings():
	$camera/outline.visible = Global.settings[ "outline" ];
	$camera.far = Global.settings[ "render_distance" ];
	$camera.fov = Global.settings[ "fov" ];

func _process(delta: float) -> void:
	$gui/damage_overlay_mix.modulate.a = max( $gui/damage_overlay_mix.modulate.a - delta, 0.0 );
	$gui/darkness.color.a = min( $gui/darkness.color.a + delta/12.0, 1.0 );

func _physics_process(delta: float) -> void:
	Global.player_pos = global_position;
