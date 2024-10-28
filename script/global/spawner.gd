# author: applehoro
# script purposes:
# - store objects loaded to memory (for now preloaded, but later should be change to dynamic loading at start of gameplay)
# - spawn objects at specific world coordinates as childs of wolrd node

extends Node

var assets = {
	"bullet": preload( "res://objects/proj/bullet.tscn" ),
	"bullet_smg": preload( "res://objects/proj/bullet_smg.tscn" ),
	"bullet_machine_gun": preload( "res://objects/proj/bullet_machine_gun.tscn" ),
	"bullet_flak": preload( "res://objects/proj/bullet_flak.tscn" ),
	"bullet_flak_alt": preload( "res://objects/proj/bullet_flak_alt.tscn" ),
	"flak_explosion": preload( "res://objects/proj/flak_explosion.tscn" ),
	"bullet_frag": preload( "res://objects/proj/bullet_frag.tscn" ),
	
	"explosion": preload( "res://objects/proj/explosion.tscn" ),
	
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
