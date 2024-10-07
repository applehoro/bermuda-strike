# author: applehoro

# script purpose:
# - testing weapon mechanics
# - later would be rewritten as parent class for different weapons, and some code would be moved to weapon_projectile script

extends Node3D

var trigger = false;

# cooldown
var cd = 0.0;
@export var shoot_cd = 0.07;

# projectile spread
@export var spread_range = Vector2( 0.5, 15.0 );
var spread = 0.5;
@export var spread_increase = 0.65;
@export var spread_decrease = 26.0;

@export var projectile_id = "bullet";

@export var node_muzzle: NodePath;

func _physics_process( delta: float ) -> void:
	trigger = Input.is_action_pressed( "shoot" );
	
	# cooldown
	if( cd > 0.0 ):
		cd -= delta;
	
	# triggered
	elif( trigger ):
		shoot();
		cd = shoot_cd;
		spread = min( spread + spread_increase, spread_range.y );
		$anim.stop();
		$anim.play( "shoot" );
	
	# not triggered
	else:
		spread = max( spread - spread_decrease*delta, spread_range.x );

# handle projectile spawning
func shoot():
	var c = Global.spawn( projectile_id, get_node( node_muzzle ).global_position, get_node( node_muzzle ).global_rotation );
	c.add_exclude( Global.node_player );
	c.global_rotate( c.global_basis.y, randf_range( -deg_to_rad( spread ), deg_to_rad( spread ) ) );
	c.global_rotate( c.global_basis.x, randf_range( -deg_to_rad( spread ), deg_to_rad( spread ) ) );
