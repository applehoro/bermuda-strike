extends VideoOptionsMenu

func _on_smoke_trails_control_setting_changed(value: Variant) -> void:
	Global.update_settings();

func _on_water_effects_control_setting_changed(value: Variant) -> void:
	Global.update_settings();

func _on_outline_control_setting_changed(value: Variant) -> void:
	Global.update_settings();

func _on_lens_flare_control_setting_changed(value: Variant) -> void:
	Global.update_settings();

func _on_special_effects_control_setting_changed(value: Variant) -> void:
	Global.update_settings();

func _on_render_distance_control_setting_changed(value: Variant) -> void:
	Global.update_settings();

func _on_fov_control_setting_changed(value: Variant) -> void:
	Global.update_settings();

func _on_aa_control_setting_changed(value: Variant) -> void:
	Global.update_settings();

func _on_v_sync_control_setting_changed(value: Variant) -> void:
	Global.update_settings();

func _on_view_bob_control_setting_changed(value: Variant) -> void:
	Global.update_settings();
