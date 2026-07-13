extends Node

# Handles the camera zoom

##### VARIABLES #####
#---- CONSTANTS -----
const ZOOM_OFFSET := Vector2i.ONE * 100
const ZOOM_BASE_MULTIPLIER := 0.5 # change this to correct the zoom or dezoom
const ZOOM_DAMPING := 1.0 # to keep the game relatively clear and avoid too harsh camera movements

#---- STANDARD -----
#==== PUBLIC ====
var zoom_multiplier := ZOOM_BASE_MULTIPLIER

#==== PRIVATE ====
var _zoom_tween: Tween


##### PUBLIC METHODS #####
func get_zoom_damping() -> float:
	return ZOOM_DAMPING


func get_best_zoom(players: Array) -> float:
	if players.size() >= 2:
		var min_max_pos = _get_global_min_max_pos(players)
		var min_pos = min_max_pos.min
		var max_pos = min_max_pos.max
		var screen_size_offset = DisplayServer.screen_get_size() - ZOOM_OFFSET
		var best_zoom := Vector2.ZERO
		best_zoom.x = max(abs(min_pos.x - max_pos.x) / (screen_size_offset.x / 2), ZOOM_BASE_MULTIPLIER)
		best_zoom.y = max(abs(min_pos.y - max_pos.y) / (screen_size_offset.y / 2), ZOOM_BASE_MULTIPLIER)
		return 1 / max(best_zoom.x, best_zoom.y)
	return ZOOM_BASE_MULTIPLIER


func start_fast_zoom(duration: float, intensity: CameraEffects.CAMERA_IMPACT_INTENSITY) -> void:
	var final_zoom_val = ZOOM_BASE_MULTIPLIER
	var duration_divider = 1.0
	var preset = RuntimeConfig.get_current_camera_effects_intensity_preset()
	match intensity:
		CameraEffects.CAMERA_IMPACT_INTENSITY.LIGHT:
			final_zoom_val = ZOOM_BASE_MULTIPLIER * preset.LOW_FINAL_ZOOM_MULTIPLIER
			duration_divider = preset.LOW_ZOOM_DURATION_DIVIDER
		CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM:
			final_zoom_val = ZOOM_BASE_MULTIPLIER * preset.MID_FINAL_ZOOM_MULTIPLIER
			duration_divider = preset.MID_ZOOM_DURATION_DIVIDER
		CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH:
			final_zoom_val = ZOOM_BASE_MULTIPLIER * preset.HIGH_FINAL_ZOOM_MULTIPLIER
			duration_divider = preset.HIGH_ZOOM_DURATION_DIVIDER
	_fast_zoom(final_zoom_val, duration, duration_divider)


##### PROTECTED METHODS #####
func _get_global_min_max_pos(players: Array) -> Dictionary:
	var min_pos := Vector2.INF
	var max_pos := Vector2.ZERO
	if players != null:
		for player in players:
			if player.global_position.x < min_pos.x:
				min_pos.x = player.global_position.x
			if player.global_position.y < min_pos.y:
				min_pos.y = player.global_position.y
			if player.global_position.x > max_pos.x:
				max_pos.x = player.global_position.x
			if player.global_position.y > max_pos.y:
				max_pos.y = player.global_position.y
	return {
		"min": min_pos,
		"max": max_pos,
	}


func _fast_zoom(final_zoom_amount: float, duration: float, duration_divider: float) -> void:
	if _zoom_tween:
		_zoom_tween.kill() # Abort the previous animation.
	_zoom_tween = create_tween()
	zoom_multiplier = ZOOM_BASE_MULTIPLIER
	_zoom_tween.tween_property(self, "zoom_multiplier", final_zoom_amount, duration / duration_divider)
	await _zoom_tween.finished
	_zoom_tween.stop()
	_zoom_tween.tween_property(self, "zoom_multiplier", ZOOM_BASE_MULTIPLIER, duration - duration / duration_divider)
	_zoom_tween.play()
	await _zoom_tween.finished
	zoom_multiplier = ZOOM_BASE_MULTIPLIER
