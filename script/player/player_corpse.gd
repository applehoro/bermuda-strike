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

func _physics_process(delta: float) -> void:
	Global.player_pos = global_position;
	
	#var ax = global_basis.z.signed_angle_to( -Vector3.UP, global_basis.x );
	#var ay = global_basis.z.signed_angle_to( -Vector3.UP, global_basis.y );
	#angular_velocity += global_basis.x*ax*delta*0.1;
	#angular_velocity += global_basis.y*ay*delta*0.1;
	#rotate_x( ax*delta*0.01 );
	#rotate_y( ay*delta*0.01 );
