extends CharacterBody3D

var motion = Vector3();
var motion_avoid = Vector3();
var avoid_cd = 0.0;

var fly_vel = 16.0;

var targeted_cd = 0.0;

func _ready() -> void:
	pass;

func _physics_process(delta: float) -> void:
	# cooldowns
	targeted_cd = max( targeted_cd - delta,  0.0 );
	avoid_cd = max( avoid_cd - delta,  0.0 );
	
	# avoid logic
	motion_avoid *= 1.0 - delta*0.5;
	if( is_targeted() && avoid_cd <= 0.0 ):
		var dir = global_basis.x;
		if( randi()%100 > 75 ):
			dir = global_basis.y;
		if( randi()%100 > 50 ):
			dir *= -1.0;
		
		motion_avoid = dir*fly_vel;
		avoid_cd = randf_range( 8.0, 12.0 );
	
	# motion update
	motion *= 1.0 - delta*8.0;
	
	# apply avoid motion
	if( avoid_cd > 0.0 ):
		motion += motion_avoid*8.0*delta;
	
	velocity = motion;
	move_and_slide();

func on_player_target():
	targeted_cd = 0.1;

func is_targeted():
	return targeted_cd > 0.0;
