extends "res://addons/gut/test.gd"

##### VARIABLES #####
var camera_effects_manager


##### SETUP #####
func before_each():
	camera_effects_manager = load("res://Scenes/Camera/camera_effects_manager.gd").new()


##### TEARDOWN #####
func after_each():
	camera_effects_manager.free()

##### TESTS #####
var parameters = [
	[CameraEffects.CAMERA_IMPACT_INTENSITY.LIGHT],
	[CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM],
	[CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH],
]


func test_start_chromatic_aberration(params = use_parameters(parameters)):
	# given
	camera_effects_manager._full_screen_effects = double(load("res://Scenes/Camera/FullScreenEffects/full_screen_effects.gd")).new()
	stub(camera_effects_manager._full_screen_effects, "chromatic_aberration").to_do_nothing()
	var duration = 2.0
	var intensity = params[0]
	var preset: CameraEffectsIntensityPresets = RuntimeConfig.get_current_camera_effects_intensity_preset()
	var chromatic_strength
	var chromatic_duration_divider
	match intensity:
		CameraEffects.CAMERA_IMPACT_INTENSITY.LIGHT:
			chromatic_strength = preset.LOW_CHROMATIC_ABERRATION_STRENGTH
			chromatic_duration_divider = preset.LOW_CHROMATIC_ABERRATION_DURATION_DIVIDER
		CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM:
			chromatic_strength = preset.MID_CHROMATIC_ABERRATION_STRENGTH
			chromatic_duration_divider = preset.MID_CHROMATIC_ABERRATION_DURATION_DIVIDER
		CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH:
			chromatic_strength = preset.HIGH_CHROMATIC_ABERRATION_STRENGTH
			chromatic_duration_divider = preset.HIGH_CHROMATIC_ABERRATION_DURATION_DIVIDER
	# when
	camera_effects_manager.start_chromatic_aberration(duration, intensity)
	# then
	assert_called(
		camera_effects_manager._full_screen_effects,
		"chromatic_aberration",
		[
			chromatic_strength,
			duration,
			chromatic_duration_divider,
		],
	)
