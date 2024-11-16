# author: applehoro
# script purposes:
# - handles weapon switching

extends Node3D

var node_weapon = null;

var assets = {
	"smg": preload( "res://objects/player/weapons/weapon_smg.tscn" ),
	"machine_gun": preload( "res://objects/player/weapons/weapon_machine_gun.tscn" ),
	"flak": preload( "res://objects/player/weapons/weapon_flak.tscn" ),
	"grenade_launcher": preload( "res://objects/player/weapons/weapon_grenade_launcher.tscn" ),
	"rocket_launcher": preload( "res://objects/player/weapons/weapon_rocket_launcher.tscn" ),
};

var action_to_weapon = {
	"weapon_1": 1,
	"weapon_2": 2,
	"weapon_3": 3,
	"weapon_4": 4,
	"weapon_5": 5,
	"weapon_6": 6,
	"weapon_7": 7,
	"weapon_8": 8,
	"weapon_9": 9,
	"weapon_0": 0,
};

var current_weapon = "";

func _ready() -> void:
	switch_weapon( Inventory.weapons_in_slots[ Inventory.current_slot ] );

func _process( _delta: float ) -> void:
	for a in action_to_weapon:
		if( Input.is_action_just_pressed( a ) ):
			switch_weapon( Inventory.weapons_in_slots[ action_to_weapon[ a ] ] );

func switch_weapon( id ):
	if( current_weapon != id ):
		if( assets.has( id ) ):
			if( node_weapon != null ):
				node_weapon.queue_free();
				node_weapon = null;
				current_weapon = "";
				Inventory.switch_weapon( "" );
			
			node_weapon = assets[ id ].instantiate();
			add_child( node_weapon );
			node_weapon.equip();
			current_weapon = id;
			return true;
	return false;
