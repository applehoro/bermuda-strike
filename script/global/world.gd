# author: applehoro

# script purpose:
# - set reference to itself in Global at init and remove it on destroy

extends Node3D

var maps = {
	"test_map": "res://maps/test_map.tscn",
	"test_map_2": "res://maps/test_map_2.tscn",
};

func switch_map( n ):
	if( Global.node_map != null ):
		Global.node_map.queue_free();
		Global.node_map = null;
	
	Global.node_map = load( maps[ n ] ).instantiate();
	add_child( Global.node_map );

func _ready() -> void:
	Global.node_world = self;
	Spawner.fill_pool();
	switch_map( "test_map_2" );

func _exit_tree() -> void:
	Global.node_world = null;
	Spawner.clear_pool();

