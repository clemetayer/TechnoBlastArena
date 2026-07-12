extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var camera_zoom_manager: Node


##### SETUP #####
func before_each():
	camera_zoom_manager = load("res://Scenes/Camera/camera_zoom_manager.gd").new()


##### TEARDOWN #####
func after_each():
	camera_zoom_manager.free()


##### TESTS #####
func test_get_best_zoom_with_empty_array():
	# given
	var players = []
	# when
	var result = camera_zoom_manager.get_best_zoom(players)
	# then
	assert_eq(result, camera_zoom_manager.ZOOM_BASE_MULTIPLIER)


func test_get_best_zoom_with_single_player():
	# given
	var player = Node2D.new()
	player.global_position = Vector2(100, 100)
	var players = [player]
	# when
	var result = camera_zoom_manager.get_best_zoom(players)
	# then
	assert_eq(result, camera_zoom_manager.ZOOM_BASE_MULTIPLIER)
	# cleanup
	player.free()


func test_get_best_zoom_with_multiple_players():
	# given
	var player1 = Node2D.new()
	player1.global_position = Vector2(0, 0)
	var player2 = Node2D.new()
	player2.global_position = Vector2(1000, 0)
	var players = [player1, player2]
	var offseted_zoom = DisplayServer.screen_get_size() - camera_zoom_manager.ZOOM_OFFSET
	var best_zoom = 1000.0 / (offseted_zoom.x / 2.0)
	# when
	var result = camera_zoom_manager.get_best_zoom(players)
	# then
	assert_almost_eq(result, 1 / best_zoom, 0.01)
	# cleanup
	player1.free()
	player2.free()


func test_get_best_zoom_with_vertical_distance():
	# given
	var player1 = Node2D.new()
	player1.global_position = Vector2(0, 0)
	var player2 = Node2D.new()
	player2.global_position = Vector2(0, 800)
	var players = [player1, player2]
	var offseted_zoom = DisplayServer.screen_get_size() - camera_zoom_manager.ZOOM_OFFSET
	var best_zoom = 800.0 / (offseted_zoom.y / 2.0)
	# when
	var result = camera_zoom_manager.get_best_zoom(players)
	# then
	assert_almost_eq(result, 1 / best_zoom, 0.01)
	# cleanup
	player1.free()
	player2.free()


func test_get_best_zoom_with_three_players():
	# given
	var player1 = Node2D.new()
	player1.global_position = Vector2(0, 0)
	var player2 = Node2D.new()
	player2.global_position = Vector2(1000, 0)
	var player3 = Node2D.new()
	player3.global_position = Vector2(-500, 800)
	var players = [player1, player2, player3]
	var offseted_zoom = DisplayServer.screen_get_size() - camera_zoom_manager.ZOOM_OFFSET
	var best_zoom = Vector2(1500.0 / (offseted_zoom.x / 2.0), 800.0 / (offseted_zoom.y / 2.0))
	# when
	var result = camera_zoom_manager.get_best_zoom(players)
	# then
	assert_almost_eq(result, 1 / max(best_zoom.x, best_zoom.y), 0.01)
	# cleanup
	player1.free()
	player2.free()
	player3.free()


func test_start_fast_zoom_light_intensity():
	# given
	var duration = 1.0
	var intensity = CameraEffects.CAMERA_IMPACT_INTENSITY.LIGHT
	var mocked_camera_zoom = partial_double(load("res://Scenes/Camera/camera_zoom_manager.gd")).new()
	stub(mocked_camera_zoom, "_fast_zoom").to_do_nothing()
	var preset = RuntimeConfig.get_current_camera_effects_intensity_preset()
	# when
	mocked_camera_zoom.start_fast_zoom(duration, intensity)
	# then
	var expected_zoom = camera_zoom_manager.ZOOM_BASE_MULTIPLIER * preset.LOW_FINAL_ZOOM_MULTIPLIER
	var expected_divider = preset.LOW_ZOOM_DURATION_DIVIDER
	assert_called(mocked_camera_zoom, "_fast_zoom", [expected_zoom, duration, expected_divider])


func test_start_fast_zoom_medium_intensity():
	# given
	var duration = 1.0
	var intensity = CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM
	var mocked_camera_zoom = partial_double(load("res://Scenes/Camera/camera_zoom_manager.gd")).new()
	stub(mocked_camera_zoom, "_fast_zoom").to_do_nothing()
	var preset = RuntimeConfig.get_current_camera_effects_intensity_preset()
	# when
	mocked_camera_zoom.start_fast_zoom(duration, intensity)
	# then
	var expected_zoom = camera_zoom_manager.ZOOM_BASE_MULTIPLIER * preset.MID_FINAL_ZOOM_MULTIPLIER
	var expected_divider = preset.MID_ZOOM_DURATION_DIVIDER
	assert_called(mocked_camera_zoom, "_fast_zoom", [expected_zoom, duration, expected_divider])


func test_start_fast_zoom_high_intensity():
	# given
	var duration = 1.0
	var intensity = CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH
	var mocked_camera_zoom = partial_double(load("res://Scenes/Camera/camera_zoom_manager.gd")).new()
	stub(mocked_camera_zoom, "_fast_zoom").to_do_nothing()
	var preset = RuntimeConfig.get_current_camera_effects_intensity_preset()
	# when
	mocked_camera_zoom.start_fast_zoom(duration, intensity)
	# then
	var expected_zoom = camera_zoom_manager.ZOOM_BASE_MULTIPLIER * preset.HIGH_FINAL_ZOOM_MULTIPLIER
	var expected_divider = preset.HIGH_ZOOM_DURATION_DIVIDER
	assert_called(mocked_camera_zoom, "_fast_zoom", [expected_zoom, duration, expected_divider])


func test_get_zoom_damping():
	# given
	# when
	var res = camera_zoom_manager.get_zoom_damping()
	# then
	assert_eq(res, camera_zoom_manager.ZOOM_DAMPING)
