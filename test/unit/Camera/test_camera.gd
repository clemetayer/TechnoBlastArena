extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var camera: Camera2D


##### SETUP #####
func before_each():
	camera = load("res://Scenes/Camera/camera.gd").new()


##### TEARDOWN #####
func after_each():
	camera.free()


##### TESTS #####
func test_ready():
	# given
	var camera_scene = load("res://Scenes/Camera/camera.tscn").instantiate()
	# when
	add_child_autofree(camera_scene)
	# then
	assert_true(CameraEffects.is_connected("start_camera_impact", camera_scene._on_start_camera_impact))
	assert_true(CameraEffects.is_connected("focus_on", camera_scene._on_focus_on))


func test_start_camera_impact():
	# given
	var mock_shake_manager = double(load("res://Scenes/Camera/camera_shake_manager.gd")).new()
	var mock_zoom_manager = double(load("res://Scenes/Camera/camera_zoom_manager.gd")).new()
	var mock_effect_manager = double(load("res://Scenes/Camera/camera_effects_manager.gd")).new()
	stub(mock_shake_manager, "start_camera_shake").to_do_nothing()
	stub(mock_shake_manager, "start_camera_tilt").to_do_nothing()
	stub(mock_zoom_manager, "start_fast_zoom").to_do_nothing()
	stub(mock_effect_manager, "start_chromatic_aberration").to_do_nothing()
	camera.onready_paths.shake_manager = mock_shake_manager
	camera.onready_paths.zoom_manager = mock_zoom_manager
	camera.onready_paths.effect_manager = mock_effect_manager
	# when
	camera._start_camera_impact(0.5, CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM, CameraEffects.CAMERA_IMPACT_PRIORITY.MEDIUM)
	# then
	assert_called(mock_shake_manager, "start_camera_shake", [0.5, CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM])
	assert_called(mock_shake_manager, "start_camera_tilt", [0.5, CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM])
	assert_called(mock_zoom_manager, "start_fast_zoom", [0.5, CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM])
	assert_called(mock_effect_manager, "start_chromatic_aberration", [0.5, CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM])


func test_start_camera_impact_higher_priority():
	# given
	var mock_shake_manager = double(load("res://Scenes/Camera/camera_shake_manager.gd")).new()
	var mock_zoom_manager = double(load("res://Scenes/Camera/camera_zoom_manager.gd")).new()
	var mock_effect_manager = double(load("res://Scenes/Camera/camera_effects_manager.gd")).new()
	stub(mock_shake_manager, "start_camera_shake").to_do_nothing()
	stub(mock_shake_manager, "start_camera_tilt").to_do_nothing()
	stub(mock_zoom_manager, "start_fast_zoom").to_do_nothing()
	stub(mock_effect_manager, "start_chromatic_aberration").to_do_nothing()
	camera.onready_paths.shake_manager = mock_shake_manager
	camera.onready_paths.zoom_manager = mock_zoom_manager
	camera.onready_paths.effect_manager = mock_effect_manager
	camera._current_impact_priority = CameraEffects.CAMERA_IMPACT_PRIORITY.MEDIUM
	# when
	camera._start_camera_impact(0.5, CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH, CameraEffects.CAMERA_IMPACT_PRIORITY.HIGH)
	# then
	assert_called(mock_shake_manager, "start_camera_shake", [0.5, CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH])
	assert_called(mock_shake_manager, "start_camera_tilt", [0.5, CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH])
	assert_called(mock_zoom_manager, "start_fast_zoom", [0.5, CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH])
	assert_called(mock_effect_manager, "start_chromatic_aberration", [0.5, CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH])


func test_start_camera_impact_lower_priority():
	# given
	var mock_shake_manager = double(load("res://Scenes/Camera/camera_shake_manager.gd")).new()
	var mock_zoom_manager = double(load("res://Scenes/Camera/camera_zoom_manager.gd")).new()
	var mock_effect_manager = double(load("res://Scenes/Camera/camera_effects_manager.gd")).new()
	stub(mock_shake_manager, "start_camera_shake").to_do_nothing()
	stub(mock_shake_manager, "start_camera_tilt").to_do_nothing()
	stub(mock_zoom_manager, "start_fast_zoom").to_do_nothing()
	stub(mock_effect_manager, "start_chromatic_aberration").to_do_nothing()
	camera.onready_paths.shake_manager = mock_shake_manager
	camera.onready_paths.zoom_manager = mock_zoom_manager
	camera.onready_paths.effect_manager = mock_effect_manager
	camera._current_impact_priority = CameraEffects.CAMERA_IMPACT_PRIORITY.MEDIUM
	# when
	camera._start_camera_impact(0.5, CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH, CameraEffects.CAMERA_IMPACT_PRIORITY.LOW)
	# then
	assert_not_called(mock_shake_manager, "start_camera_shake")
	assert_not_called(mock_shake_manager, "start_camera_tilt")
	assert_not_called(mock_zoom_manager, "start_fast_zoom")
	assert_not_called(mock_effect_manager, "start_chromatic_aberration")


func test_on_focus_on():
	# given
	camera._focus_on = null
	var mock_timer = double(Timer).new()
	camera.onready_paths.focus_on_timer = mock_timer
	stub(camera.onready_paths.focus_on_timer, "start").to_do_nothing()
	# when
	camera._on_focus_on(Vector2.ONE, 0.33, 0.25, 0.1)
	# then
	assert_eq(camera._focus_on.position, Vector2.ONE)
	assert_eq(camera._focus_on.zoom, 0.33)
	assert_eq(camera._focus_on.time_to_focus, 0.25)
	assert_called(camera.onready_paths.focus_on_timer, "start", [0.1])


func test_on_shaker_shake_finished():
	# given
	camera._current_impact_priority = CameraEffects.CAMERA_IMPACT_PRIORITY.HIGH
	# when
	camera._on_shaker_shake_finished()
	# then
	assert_eq(camera._current_impact_priority, CameraEffects.CAMERA_IMPACT_PRIORITY.NONE)


func test_on_focus_on_timer_timeout():
	# given
	camera._focus_on = { }
	# when
	camera._on_focus_on_timer_timeout()
	# then
	assert_null(camera._focus_on)


func test_process_with_focus_on():
	# given
	var delta = 0.016
	camera._focus_on = {
		"position": Vector2(100, 100),
		"zoom": 0.5,
		"time_to_focus": 2.0,
	}
	camera.global_position = Vector2.ZERO
	camera.zoom = Vector2.ONE
	# when
	camera._process(delta)
	# then
	var expected_movement = Vector2.ZERO.move_toward(Vector2(100, 100), delta * 2.0 * 600)
	assert_eq(camera.global_position, expected_movement)
	var expected_zoom_change = Vector2.ONE.move_toward(Vector2.ONE * 0.5, delta * 2.0)
	assert_eq(camera.zoom, expected_zoom_change)


func test_process_without_focus_on():
	# given
	var delta = 0.016
	camera._focus_on = null
	var mock_position_manager = double(load("res://Scenes/Camera/camera_position_manager.gd")).new()
	var mock_zoom_manager = double(load("res://Scenes/Camera/camera_zoom_manager.gd")).new()
	var mock_players_node = Node.new()
	var player1 = Node2D.new()
	var player2 = Node2D.new()
	mock_players_node.add_child(player1)
	mock_players_node.add_child(player2)
	camera.onready_paths.position_manager = mock_position_manager
	camera.onready_paths.zoom_manager = mock_zoom_manager
	camera.add_child(mock_players_node)
	var expected_position = Vector2(50, 50)
	var expected_zoom = 0.75
	mock_zoom_manager.zoom_multiplier = 1.0
	stub(mock_position_manager, "get_average_position").to_return(expected_position)
	stub(mock_zoom_manager, "get_best_zoom").to_return(expected_zoom)
	stub(mock_zoom_manager, "get_zoom_damping").to_return(5.0)
	camera.PLAYERS_ROOT_PATH = camera.get_path_to(mock_players_node)
	camera.global_position = Vector2.ZERO
	camera.zoom = Vector2.ONE
	# when
	camera._process(delta)
	# then
	assert_called(mock_position_manager, "get_average_position", [mock_players_node.get_children()])
	assert_called(mock_zoom_manager, "get_best_zoom", [mock_players_node.get_children()])
	assert_eq(camera.global_position, expected_position)
	var expected_zoom_vector = Vector2.ONE.move_toward(
		Vector2.ONE * expected_zoom * mock_zoom_manager.zoom_multiplier,
		delta * 5.0,
	)
	assert_eq(camera.zoom, expected_zoom_vector)
	# cleanup
	mock_players_node.free()
