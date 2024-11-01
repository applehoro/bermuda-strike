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

var pool_assets = {
	"bullet": 30,
	"bullet_smg": 20,
	"bullet_machine_gun": 40,
	"bullet_flak": 30,
	"bullet_flak_alt": 4,
	"bullet_frag": 80,
	"hit_mark": 30,
	"water_splash": 16,
	"dust_burst": 16,
};

var pool = {};

func clear_pool():
	for id in pool_assets:
		if( pool.has( id ) ):
			for c in pool[ id ]:
				c.queue_free();
		pool[ id ] = [];

func fill_pool() -> void:
	for id in pool_assets:
		pool[ id ] = [];
		for i in range( pool_assets[ id ] ):
			var c = assets[ id ].instantiate();
			Global.node_world.add_child( c );
			c.is_in_pool = true;
			c.die();
			pool[ id ].push_back( c );

func find_free( id ):
	if( pool.has( id ) ):
		for c in pool[ id ]:
			if( !c.live ):
				return c;
	else:
		return assets[ id ].instantiate();

# spawning
func spawn( id, pos, rot ):
	if( Global.node_world != null && assets.has( id ) ):
		var c = find_free( id );
		Global.node_world.add_child( c );
		c.global_position = pos;
		c.global_rotation = rot;
		if( c.has_method( "setup" ) ):
			c.setup();
		return c;
	return null;

func spawn_t( id, t ):
	if( Global.node_world != null && assets.has( id ) ):
		var c = find_free( id );
		Global.node_world.add_child( c );
		c.global_transform = t;
		if( c.has_method( "setup" ) ):
			c.setup();
		return c;
	return null;
