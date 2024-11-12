@tool
extends Node3D
 
# Original script by devmar
# (https://pastebin.com/zSgkTkHb)

@export var gen_id = "gen_forest";
@export var instance_amount : int = 100;  # Number of instances to generate
@export var generate_colliders: bool = false;
@export var collider_coverage_dist : float = 50;

@export var pos_randomize : float = 0;  # Amount of randomization for x and z positions
@export_range(0,50) var instance_min_scale: float = 1;
@export var instance_height: float = 1;
@export var instance_width: float = 1;
@export var instance_spacing: int = 10;

@export_range(0,10) var scale_randomize : float = 0.0;  # Amount of randomization for uniform scale
@export_range(0,PI) var instance_Y_rot : float = 0.0;  # Amount of randomization for X rotation
@export_range(0,PI) var instance_X_rot : float = 0.0;  # Amount of randomization for Y rotation 
@export_range(0,PI) var instance_Z_rot : float = 0.0;  # Amount of randomization for Z rotation 

@export var rot_y_randomize : float = 0.0;  # Amount of randomization for Y rotation 
@export var rot_x_randomize : float = 0.0;  # Amount of randomization for X rotation 
@export var rot_z_randomize : float = 0.0;  # Amount of randomization for Z rotation 

@export var instance_mesh : Mesh;   # Mesh resource for each instance
@export var instance_collision : Shape3D;

@export var update_frequency: float = 0.01;

@onready var instance_rows: int;
@onready var offset: float;
@onready var rand_x : float;
@onready var rand_z : float;

@onready var multi_mesh_instance;
@onready var multi_mesh;

#var h_scale: float = 1;
#var v_scale: float = 1;

@onready var timer;
@onready var collision_parent;
@onready var colliders: Array;
@onready var colliders_to_spawn: Array;
@onready var last_pos: Vector3;
@onready var first_update = true;
 
func _ready():
	call_deferred( "create_multimesh" );
	#create_multimesh();

func create_multimesh():
	
	# Create a MultiMeshInstance3D and set its MultiMesh
	multi_mesh_instance = MultiMeshInstance3D.new();
	multi_mesh_instance.top_level = true;
	multi_mesh = MultiMesh.new();
	multi_mesh.transform_format = MultiMesh.TRANSFORM_3D;
	multi_mesh.instance_count = instance_amount;
	multi_mesh.mesh = instance_mesh;
	instance_rows = sqrt(instance_amount); #rounded down to integer
	offset = round(instance_amount/instance_rows); #rounded up/down to nearest integer
	 
	# Add the MultiMeshInstance3D as a child of the instancer
	add_child(multi_mesh_instance);
	
	#Add timer for updates
	timer = Timer.new();
	add_child(timer);
	timer.timeout.connect(_update);
	timer.wait_time = update_frequency;
	_update();
 
func _update():
	#on each update, move the center to player
	self.global_position = Vector3( Global.node_player.global_position.x, 0.0, Global.node_player.global_position.z ).snapped( Vector3( 1, 0, 1 ) );
	multi_mesh_instance.multimesh = distribute_meshes();
	timer.wait_time = update_frequency;
	timer.start();
 
func distribute_meshes():
	randomize();
	for i in range(instance_amount):
		
		# Generate positions on X and Z axes    
		var pos = global_position;
		pos.z = i;
		pos.x = (int(pos.z) % instance_rows);
		pos.z = int((pos.z - pos.x) / instance_rows);
		
		#center this
		pos.x -= offset/2;
		pos.z -= offset/2;
		
		#apply spacing (snap to integer to keep instances in place)
		pos *= instance_spacing;
		pos.x += int(global_position.x) - (int(global_position.x) % instance_spacing);
		pos.z += int(global_position.z) - (int(global_position.z) % instance_spacing);
		
		#add randomization  
		var x;
		var z;
		pos.x += random(pos.x,pos.z) * pos_randomize;
		pos.z += random(pos.x,pos.z) * pos_randomize;
		pos.x -= pos_randomize * random(pos.x,pos.z);
		pos.z -= pos_randomize * random(pos.x,pos.z);
		
		x = pos.x;
		z = pos.z;
		
		# Sample the heightmap texture to determine the Y position
		var y = get_heightmap_y( pos )
		if( !get_parent().is_gen_id( pos, gen_id ) ):
			y = -4096.0;
		
		var ori = Vector3( x, y, z );
		var sc = Vector3( instance_min_scale+scale_randomize * random(x,z) + instance_width,
								instance_min_scale+scale_randomize * random(x,z) + instance_height,
								instance_min_scale+scale_randomize * random(x,z)+ instance_width
								);
		
		# Randomize rotations
		var rot = Vector3(0,0,0);
		rot.x += instance_X_rot + (random(x,z) * rot_x_randomize);
		rot.y += instance_Y_rot + (random(x,z) * rot_y_randomize);
		rot.z += instance_Z_rot + (random(x,z) * rot_z_randomize);
		
		var t;
		t = Transform3D();
		t.origin = ori;
		
		t = t.rotated_local(t.basis.x.normalized(),rot.x);
		t = t.rotated_local(t.basis.y.normalized(),rot.y);
		t = t.rotated_local(t.basis.z.normalized(),rot.z);
		
		# Set the instance data
		multi_mesh.set_instance_transform(i, t.scaled_local(sc));
		
		#Collisions
		if generate_colliders:
				if first_update:
					if i == instance_amount-1:
						first_update = false;
						generate_subset();
				else:   
					if !colliders[i] == null:
						colliders[i].global_transform = t.scaled_local(sc);
	
	last_pos = global_position
	return multi_mesh

func get_heightmap_y( p ):
	return get_parent().get_surface_y( p );

func random(x,z):
	var r = fposmod(sin(Vector2(x,z).dot(Vector2(12.9898,78.233)) * 43758.5453123),1.0);
	return r;

func spawn_colliders():
	collision_parent = StaticBody3D.new();
	add_child(collision_parent);
	collision_parent.set_as_top_level(true);
	#var c_shape = instance_collision;
	
	for i in range(instance_amount):
		if colliders_to_spawn.has(i):
				var collider = CollisionShape3D.new();
				collision_parent.add_child(collider);
				collider.set_shape(instance_collision);
				colliders.append(collider);
		else:
				colliders.append(null); 

func generate_subset():
	for i in range(instance_amount):
		var t = multi_mesh.get_instance_transform(i);
		if t.origin.distance_squared_to( Vector3( Global.node_player.global_position.x, t.origin.y, Global.node_player.global_position.z ) ) < pow(collider_coverage_dist,2):
				colliders_to_spawn.append(i);
		if i==instance_amount-1:
				spawn_colliders();
