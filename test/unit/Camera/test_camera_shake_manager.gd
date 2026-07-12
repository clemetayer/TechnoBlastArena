extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var camera_shake_manager: Node
var mock_shaker: Node


##### SETUP #####
func before_each():
	# Create a basic scene structure
	mock_shaker = double(load("res://addons/shaker/src/Vector2/shaker_component2D.gd")).new()
	camera_shake_manager = load("res://Scenes/Camera/camera_shake_manager.gd").new()
	camera_shake_manager.shaker = mock_shaker


##### TEARDOWN #####
func after_each():
	camera_shake_manager.free()

##### TESTS #####
var camera_shakes_parameters = [
	[CameraEffects.CAMERA_IMPACT_INTENSITY.LIGHT],
	[CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM],
	[CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH],
]


func test_start_camera_shake(params = use_parameters(camera_shakes_parameters)):
	# given
	var duration = 1.0
	var intensity = params[0]
	mock_shaker.is_playing = true
	stub(mock_shaker, "force_stop_shake").to_do_nothing()
	stub(mock_shaker, "set_duration").to_do_nothing()
	stub(mock_shaker, "set_shaker_preset").to_do_nothing()
	stub(mock_shaker, "play_shake").to_do_nothing()
	var preset: CameraEffectsIntensityPresets = RuntimeConfig.get_current_camera_effects_intensity_preset()
	var shake
	match intensity:
		CameraEffects.CAMERA_IMPACT_INTENSITY.LIGHT:
			shake = preset.SHAKE_LOW
		CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM:
			shake = preset.SHAKE_MID
		CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH:
			shake = preset.SHAKE_HIGH
	# when
	camera_shake_manager.start_camera_shake(duration, intensity)
	# then
	assert_called(mock_shaker, "force_stop_shake")
	assert_called(mock_shaker, "set_duration", [duration])
	assert_called(mock_shaker, "set_shaker_preset", [shake])
	assert_called(mock_shaker, "play_shake")


var camera_tilts_parameters = [
	[CameraEffects.CAMERA_IMPACT_INTENSITY.LIGHT],
	[CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM],
	[CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH],
]


func test_start_camera_tilt(params = use_parameters(camera_tilts_parameters)):
	# given
	var duration = 1.0
	var intensity = params[0]
	var mock_shake_manager = partial_double(load("res://Scenes/Camera/camera_shake_manager.gd")).new()
	stub(mock_shake_manager, "_tilt_camera").to_do_nothing()
	var preset: CameraEffectsIntensityPresets = RuntimeConfig.get_current_camera_effects_intensity_preset()
	var tilt_angle
	var tilt_duration_divider
	match intensity:
		CameraEffects.CAMERA_IMPACT_INTENSITY.LIGHT:
			tilt_angle = preset.LOW_TILT_ROTATION_ANGLE
			tilt_duration_divider = preset.LOW_TILT_DURATION_DIVIDER
		CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM:
			tilt_angle = preset.MID_TILT_ROTATION_ANGLE
			tilt_duration_divider = preset.MID_TILT_DURATION_DIVIDER
		CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH:
			tilt_angle = preset.HIGH_TILT_ROTATION_ANGLE
			tilt_duration_divider = preset.HIGH_TILT_DURATION_DIVIDER
	# when
	mock_shake_manager.start_camera_tilt(duration, intensity)
	# then
	assert_called(mock_shake_manager, "_tilt_camera")
	var call_params = get_call_parameters(mock_shake_manager, "_tilt_camera")
	# Check the absolute angle value is correct
	assert_almost_eq(abs(call_params[0]), tilt_angle, 0.001)
	assert_eq(call_params[1], duration)
	assert_eq(call_params[2], tilt_duration_divider)
