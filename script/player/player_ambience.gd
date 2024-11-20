extends Node

var mix_walk = 0.0;
var mix_hover = 0.0;
var mix_glide = 0.0;
var mix_overdrive = 0.0;

func _ready() -> void:
	$walk.play();
	$hover.play();
	$glide.play();
	$overdrive.play();
	
	$walk.volume_db = -30.0 + 30.0*mix_walk;
	$hover.volume_db = -30.0 + 30.0*mix_hover;
	$glide.volume_db = -30.0 + 27.0*mix_glide;
	$overdrive.volume_db = -30.0 + 25.0*mix_overdrive;

func _process(delta: float) -> void:
	mix_walk = max( mix_walk - delta/1.0, 0.0 );
	mix_hover = max( mix_hover - delta/1.0, 0.0 );
	mix_glide = max( mix_glide - delta/1.0, 0.0 );
	mix_overdrive = max( mix_overdrive - delta/1.0, 0.0 );
	
	if( get_parent().motion_type == get_parent().MOTION_TYPE_GLIDE ):
		if( Input.is_action_pressed( "overdrive" ) ):
			mix_overdrive = min( mix_overdrive + delta/0.5, 1.0 );
		mix_glide = min( mix_glide + delta/0.5, 1.0 );
	elif( get_parent().motion_type == get_parent().MOTION_TYPE_HOVER ):
		mix_hover = min( mix_hover + delta/0.5, 1.0 );
	else:
		mix_walk = min( mix_walk + delta/0.5, 1.0 );
	
	$walk.volume_db = -30.0 + 30.0*mix_walk;
	$hover.volume_db = -30.0 + 30.0*mix_hover;
	$glide.volume_db = -30.0 + 27.0*mix_glide;
	$overdrive.volume_db = -30.0 + 25.0*mix_overdrive;
	
	$hover.pitch_scale = 0.9 + 0.2*get_parent().velocity.length()/22.0;
	$glide.pitch_scale = 0.8 + 0.3*get_parent().velocity.length()/88.0;
	$overdrive.pitch_scale = 0.6 + 0.5*get_parent().velocity.length()/88.0;
