extends Node

# Handles the camera effects
##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====
var _full_screen_effects := FullScreenEffects


##### PUBLIC METHODS #####
func start_chromatic_aberration(duration: float, intensity: CameraEffects.CAMERA_IMPACT_INTENSITY) -> void:
	var strength = 0.0
	var duration_divider = 1.0
	var preset = RuntimeConfig.get_current_camera_effects_intensity_preset()
	match intensity:
		CameraEffects.CAMERA_IMPACT_INTENSITY.LIGHT:
			strength = preset.LOW_CHROMATIC_ABERRATION_STRENGTH
			duration_divider = preset.LOW_CHROMATIC_ABERRATION_DURATION_DIVIDER
		CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM:
			strength = preset.MID_CHROMATIC_ABERRATION_STRENGTH
			duration_divider = preset.MID_CHROMATIC_ABERRATION_DURATION_DIVIDER
		CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH:
			strength = preset.HIGH_CHROMATIC_ABERRATION_STRENGTH
			duration_divider = preset.HIGH_CHROMATIC_ABERRATION_DURATION_DIVIDER
	_full_screen_effects.chromatic_aberration(strength, duration, duration_divider)
