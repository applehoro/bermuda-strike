# author: applehoro

# script purpose:
# - set reference to itself in Global at init and remove it on destroy

extends Node3D

func _ready() -> void:
	Global.node_world = self;
	Spawner.fill_pool();

func _exit_tree() -> void:
	Global.node_world = null;
	Spawner.clear_pool();

