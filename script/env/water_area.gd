# author: applehoro
# script purpose:
# - return surface global y position (basically, parent's global y position)

extends Area3D

func get_surface_y():
	return get_parent_node_3d().global_position.y;
