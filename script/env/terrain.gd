extends Terrain3D

var gen_list = {
	"gen_forest": [ "palm_1" ],
	"gen_grass": [ "grass_1" ],
};

var gen_limit = {
	"gen_forest": 1000,
	"gen_grass": 1400,
};
var gen_nodes = {};
var gen_nodes_i = {};
var gen_ids = {};

var gen_dist = {
	"gen_forest": 400.0,
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
	#"gen_forest": Vector2( 300.0, 1000.0 ),
	"gen_forest": 800.0,
}

func _ready() -> void:
	set_meta( "is_terrain", true );
	clear_data();
	fill_ids();
	#call_deferred( "populate" );

func clear_data():
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

func fill_ids():
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

func generate_instances():
	for gi in gen_list.keys():
		for i in range( gen_limit[ gi ] ):
			var p = Global.node_player.global_position + Vector3( randf_range( -gen_dist[ gi ], gen_dist[ gi ] ), 0.0, randf_range( -gen_dist[ gi ], gen_dist[ gi ] ) );
			var id = data.get_control_base_id( p );
			
			var sid = gen_list[ gi ][ randi()%gen_list[ gi ].size() ];
			var c = Spawner.spawn( sid, Vector3( p.x, data.get_height( p ), p.z ), Vector3( deg_to_rad( randf_range( -5.0, 5.0 ) ), randf_range( 0.0, PI*2.0 ), deg_to_rad( randf_range( -5.0, 5.0 ) ) ) );
			c.reparent( self );
			gen_nodes[ gi ].push_back( c );
			if( !gen_ids[ gi ].has( id ) ):
				c.global_position.y = -4096.0;
				c.visible = false;
	
	for li in lod_list.keys():
		for i in range( lod_limit[ li ] ):
			var p = Global.node_player.global_position + Vector3( randf_range( -lod_dist[ li ], lod_dist[ li ] ), 0.0, randf_range( -lod_dist[ li ], lod_dist[ li ] ) );
			var id = data.get_control_base_id( p );
			
			var sid = lod_list[ li ][ randi()%lod_list[ li ].size() ];
			var c = Spawner.spawn( sid, Vector3( p.x, data.get_height( p ), p.z ), Vector3( deg_to_rad( randf_range( -5.0, 5.0 ) ), randf_range( 0.0, PI*2.0 ), deg_to_rad( randf_range( -5.0, 5.0 ) ) ) );
			c.reparent( self );
			lod_nodes[ li ].push_back( c );
			if( !lod_ids[ li ].has( id ) ):
				c.global_position.y = -4096.0;
				c.visible = false;

func populate():
	clear_data();
	fill_ids();
	#generate_instances();

func get_surface_y( pos ):
	return data.get_height( pos );

func mark_damage( p ):
	Spawner.spawn( "dust_burst", p, Vector3() );

func is_gen_id( pos, id ):
	var i = data.get_control_base_id( pos );
	return gen_ids[ id ].has( i );

#func _process( delta: float ) -> void:
	#var pp = Vector2( Global.node_player.global_position.x, Global.node_player.global_position.z );
	#
	#for gi in gen_list.keys():
		#var i = gen_nodes_i[ gi ];
		#for j in range( 50 ):
			#i += 1;
			#if( i > gen_nodes[ gi ].size() - 1 ):
				#i = 0;
			#
			#var c = gen_nodes[ gi ][ i ];
			#
			#var off = c.global_position - Global.node_player.global_position;
			#if( off.x < -gen_dist[ gi ] ):
				#c.global_position.x += gen_dist[ gi ]*2.0;
			#if( off.x > gen_dist[ gi ] ):
				#c.global_position.x -= gen_dist[ gi ]*2.0;
			#if( off.z < -gen_dist[ gi ] ):
				#c.global_position.z += gen_dist[ gi ]*2.0;
			#if( off.z > gen_dist[ gi ] ):
				#c.global_position.z -= gen_dist[ gi ]*2.0;
			#
			#var id = data.get_control_base_id( c.global_position );
			#if( gen_ids[ gi ].has( id ) ):
				#c.visible = true;
				#c.global_position.y = data.get_height( c.global_position );
			#else:
				#c.visible = false;
				#c.global_position.y = -4096.0;
		#
		#gen_nodes_i[ gi ] = i;
	#
	#for li in lod_list.keys():
		#var i = lod_nodes_i[ li ];
		#for j in range( 50 ):
			#i += 1;
			#if( i > lod_nodes[ li ].size() - 1 ):
				#i = 0;
			#
			#var c = lod_nodes[ li ][ i ];
			#
			#var off = c.global_position - Global.node_player.global_position;
			#if( off.x < -lod_dist[ li ] ):
				#c.global_position.x += lod_dist[ li ]*2.0;
			#if( off.x > lod_dist[ li ] ):
				#c.global_position.x -= lod_dist[ li ]*2.0;
			#if( off.z < -lod_dist[ li ] ):
				#c.global_position.z += lod_dist[ li ]*2.0;
			#if( off.z > lod_dist[ li ] ):
				#c.global_position.z -= lod_dist[ li ]*2.0;
			#
			#var id = data.get_control_base_id( c.global_position );
			#if( lod_ids[ li ].has( id ) ):
				#c.visible = true;
				#c.global_position.y = data.get_height( c.global_position );
			#else:
				#c.visible = false;
				#c.global_position.y = -4096.0;
		#
		#lod_nodes_i[ li ] = i;
