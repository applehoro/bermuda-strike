extends Terrain3D

var gen_list = {
	"gen_forest": [ "palm_1" ],
	"gen_grass": [ "grass_1" ],
};

var gen_limit = {
	"gen_forest": 500,
	"gen_grass": 1600,
};
var gen_nodes = {};
var gen_nodes_i = {};
var gen_ids = {};

var gen_dist = {
	"gen_forest": 300.0,
	"gen_grass": 80.0,
};

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
