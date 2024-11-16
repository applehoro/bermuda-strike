# author: applehoro
# script purposes:
# - store objects loaded to memory (for now preloaded, but later should be change to dynamic loading at start of gameplay)
# - spawn objects at specific world coordinates as childs of wolrd node

extends Node

var assets = {
	"bullet": preload( "res://objects/proj/bullet.tscn" ),
	"bullet_9mm": preload( "res://objects/proj/bullet_9mm.tscn" ),
	"bullet_223": preload( "res://objects/proj/bullet_223.tscn" ),
	"flak": preload( "res://objects/proj/flak.tscn" ),
	"flak_alt": preload( "res://objects/proj/flak_alt.tscn" ),
	"flak_explosion": preload( "res://objects/proj/flak_explosion.tscn" ),
	"grenade": preload( "res://objects/proj/grenade.tscn" ),
	"grenade_explosion": preload( "res://objects/proj/grenade_explosion.tscn" ),
	"rocket": preload( "res://objects/proj/rocket.tscn" ),
	"rocket_explosion": preload( "res://objects/proj/rocket_explosion.tscn" ),
	
	"frag": preload( "res://objects/proj/frag.tscn" ),
	"explosion": preload( "res://objects/proj/explosion.tscn" ),
	
	"hit_mark": preload( "res://objects/effects/hit_mark.tscn" ),
	"water_splash": preload( "res://objects/effects/water_splash.tscn" ),
	"dust_burst": preload( "res://objects/effects/dust_burst.tscn" ),
	
	"grass_1": preload( "res://objects/foliage/grass_1.tscn" ),
	"palm_1": preload( "res://objects/foliage/palm_1.tscn" ),
	"palm_1_lod": preload( "res://objects/foliage/lods/palm_1_lod.tscn" ),
};

var pool_assets = {
	"bullet": 5,
	"bullet_9mm": 10,
	"bullet_223": 20,
	"flak": 30,
	"flak_alt": 2,
	"grenade": 6,
	"rocket": 4,
	"frag": 50,
	
	"hit_mark": 16,
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
	
	var c = assets[ id ].instantiate();
	Global.node_world.add_child( c );
	return c;

# spawning
func spawn( id, pos, rot ):
	if( Global.node_world != null && assets.has( id ) ):
		var c = find_free( id );
		c.global_position = pos;
		c.global_rotation = rot;
		if( c.has_method( "setup" ) ):
			c.setup();
		return c;
	return null;

func spawn_t( id, t ):
	if( Global.node_world != null && assets.has( id ) ):
		var c = find_free( id );
		c.global_transform = t;
		if( c.has_method( "setup" ) ):
			c.setup();
		return c;
	return null;
