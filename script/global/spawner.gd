# author: applehoro
# script purposes:
# - store objects loaded to memory (for now preloaded, but later should be change to dynamic loading at start of gameplay)
# - spawn objects at specific world coordinates as childs of wolrd node

extends Node

var assets = {
	"bullet": preload( "res://objects/proj/bullet.tscn" ),
	
	"hit_mark": preload( "res://objects/effects/hit_mark.tscn" ),
	
	"water_splash": preload( "res://objects/effects/water_splash.tscn" ),
	"dust_burst": preload( "res://objects/effects/dust_burst.tscn" ),
};

# spawning
func spawn( id, pos, rot ):
	if( Global.node_world != null && assets.has( id ) ):
		var c = assets[ id ].instantiate();
		Global.node_world.add_child( c );
		c.global_position = pos;
		c.global_rotation = rot;
		return c;
	return null;
