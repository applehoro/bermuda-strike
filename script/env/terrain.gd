extends Terrain3D

var gen_list = {
	"gen_forest": [ "palm_1" ],
	"gen_grass": [ "grass_1" ],
};

var gen_limit = {
	"gen_forest": 1000,
	"gen_grass": 2400,
};
var gen_nodes = {};
var gen_nodes_i = {};
var gen_ids = {};

var gen_dist = {
	"gen_forest": 500.0,
	"gen_grass": 150.0,
};

var lod_list = {
	"gen_forest": [ "palm_1_lod" ],
};

var lod_limit = {
	"gen_forest": 1000,
};

var lod_nodes = {};
var lod_nodes_i = {};
var lod_ids = {};

var lod_dist = {
	"gen_forest": Vector2( 300.0, 1000.0 ),
}

func _ready() -> void:
	set_meta( "is_terrain", true );
	call_deferred( "populate" );

func populate():
	gen_ids = {};
	for gk in gen_nodes:
		for c in gen_nodes[ gk ]:
			c.queue_free();
	gen_nodes = {};
	gen_nodes_i = {};
	
	for li in lod_nodes:
		for c in lod_nodes[ li ]:
			c.queue_free();
	lod_nodes = {};
	lod_nodes_i = {};
	
	for t in assets.texture_list:
		var nd = t.name.split( "-" );
		for n in nd:
			for gn in gen_list.keys():
				if( !gen_ids.has( gn ) ):
					gen_ids[ gn ] = [];
				if( !gen_nodes.has( gn ) ):
					gen_nodes[ gn ] = [];
				if( !gen_nodes_i.has( gn ) ):
					gen_nodes_i[ gn ] = 0;
				if( n == gn ):
					gen_ids[ gn ].push_back( t.id );
			
			for li in lod_list.keys():
				if( !lod_ids.has( li ) ):
					lod_ids[ li ] = [];
				if( !lod_nodes.has( li ) ):
					lod_nodes[ li ] = [];
				if( !lod_nodes_i.has( li ) ):
					lod_nodes_i[ li ] = 0;
				if( n == li ):
					lod_ids[ li ].push_back( t.id );
	
	for gi in gen_list.keys():
		for i in range( gen_limit[ gi ] ):
			var tries = 100
			while( tries > 0 ):
				tries -= 1;
				var p = Vector3( randf_range( 0.0, gen_dist[ gi ] ), 0.0, 0.0 ).rotated( Vector3.UP, randf_range( 0.0, PI*2.0 ) );
				var id = data.get_control_base_id( p );
				if( gen_ids[ gi ].has( id ) ):
					var sid = gen_list[ gi ][ randi()%gen_list[ gi ].size() ];
					var c = Spawner.spawn( sid, Vector3( p.x, data.get_height( p ), p.z ), Vector3( deg_to_rad( randf_range( -5.0, 5.0 ) ), randf_range( 0.0, PI*2.0 ), deg_to_rad( randf_range( -5.0, 5.0 ) ) ) );
					c.reparent( self );
					gen_nodes[ gi ].push_back( c );
					tries = -1;
			
			if( tries == 0 ):
				var sid = gen_list[ gi ][ randi()%gen_list[ gi ].size() ];
				var c = Spawner.spawn( sid, Vector3( 0, -1000.0, 0.0 ), Vector3( deg_to_rad( randf_range( -5.0, 5.0 ) ), randf_range( 0.0, PI*2.0 ), deg_to_rad( randf_range( -5.0, 5.0 ) ) ) );
				c.reparent( self );
				gen_nodes[ gi ].push_back( c );
	
	for li in lod_list.keys():
		for i in range( lod_limit[ li ] ):
			var tries = 100
			while( tries > 0 ):
				tries -= 1;
				var p = Vector3( randf_range( lod_dist[ li ].x, lod_dist[ li ].y ), 0.0, 0.0 ).rotated( Vector3.UP, randf_range( 0.0, PI*2.0 ) );
				var id = data.get_control_base_id( p );
				if( lod_ids[ li ].has( id ) ):
					var sid = lod_list[ li ][ randi()%lod_list[ li ].size() ];
					var c = Spawner.spawn( sid, Vector3( p.x, data.get_height( p ), p.z ), Vector3( deg_to_rad( randf_range( -5.0, 5.0 ) ), randf_range( 0.0, PI*2.0 ), deg_to_rad( randf_range( -5.0, 5.0 ) ) ) );
					c.reparent( self );
					lod_nodes[ li ].push_back( c );
					tries = -1;
			
			if( tries == 0 ):
				var sid = lod_list[ li ][ randi()%lod_list[ li ].size() ];
				var c = Spawner.spawn( sid, Vector3( 0, -1000.0, 0.0 ), Vector3( deg_to_rad( randf_range( -5.0, 5.0 ) ), randf_range( 0.0, PI*2.0 ), deg_to_rad( randf_range( -5.0, 5.0 ) ) ) );
				c.reparent( self );
				lod_nodes[ li ].push_back( c );

func get_surface_y( pos ):
	return data.get_height( pos );

func mark_damage( p ):
	Spawner.spawn( "dust_burst", p, Vector3() );

func _process( delta: float ) -> void:
	var pp = Vector2( Global.node_player.global_position.x, Global.node_player.global_position.z );
	
	for gn in gen_list.keys():
		var i = gen_nodes_i[ gn ];
		for j in range( 50 ):
			i += 1;
			if( i > gen_nodes[ gn ].size() - 1 ):
				i = 0;
			
			var c = gen_nodes[ gn ][ i ];
			var cp = Vector2( c.global_position.x, c.global_position.z );
			var dist = cp.distance_to( pp );
			if( dist > gen_dist[ gn ] + 8.0 ):
				var tries = 10
				while( tries > 0 ):
					tries -= 1;
					var np = Global.node_player.global_position + Vector3( gen_dist[ gn ] - 1.0, 0.0, 0.0 ).rotated( Vector3.UP, randf_range( 0.0, PI*2.0 ) );
					var id = data.get_control_base_id( np );
					if( gen_ids[ gn ].has( id ) ):
						c.global_position = Vector3( np.x, data.get_height( np ), np.z );
						tries = 0;
		
		gen_nodes_i[ gn ] = i;
	
	
	for li in lod_list.keys():
		var i = lod_nodes_i[ li ];
		for j in range( 50 ):
			i += 1;
			if( i > lod_nodes[ li ].size() - 1 ):
				i = 0;
			
			var c = lod_nodes[ li ][ i ];
			var cp = Vector2( c.global_position.x, c.global_position.z );
			var dist = cp.distance_to( pp );
			if( dist < lod_dist[ li ].x - 8.0 || dist > lod_dist[ li ].y + 8.0 ):
				var tries = 10
				while( tries > 0 ):
					tries -= 1;
					var np = Global.node_player.global_position + Vector3( randf_range( lod_dist[ li ].y - 8.0, lod_dist[ li ].y ), 0.0, 0.0 ).rotated( Vector3.UP, randf_range( 0.0, PI*2.0 ) );
					var id = data.get_control_base_id( np );
					if( lod_ids[ li ].has( id ) ):
						c.global_position = Vector3( np.x, data.get_height( np ), np.z );
						tries = 0;
		
		lod_nodes_i[ li ] = i;
