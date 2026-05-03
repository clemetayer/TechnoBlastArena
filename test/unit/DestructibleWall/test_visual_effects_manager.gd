extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const TEST_BOUNCE_DIRECTION := Vector2.RIGHT

#---- VARIABLES -----
var visual_effects_manager: Node2D


##### SETUP #####
func before_each():
	visual_effects_manager = load("res://Scenes/DestructibleWalls/visual_effects_manager.gd").new()


##### TEARDOWN #####
func after_each():
	visual_effects_manager.free()


##### TESTS #####
func test_init():
	# given
	var bounce_direction = TEST_BOUNCE_DIRECTION
	var mock_wall = _mock_wall()
	var mock_particles = _mock_particles()
	var mock_cracks = _mock_cracks()
	var mock_gradient = _mock_gradient()
	stub(mock_cracks.material, "set_shader_parameter").to_do_nothing()
	stub(mock_particles, "set_color").to_do_nothing()
	# when
	visual_effects_manager.init(bounce_direction)
	# then
	var gradient_full_health_color = mock_gradient.get_color(1)
	assert_eq(visual_effects_manager._bounce_back_direction, bounce_direction)
	assert_eq(mock_wall.modulate, gradient_full_health_color)
	assert_called(mock_particles, "set_color", [gradient_full_health_color])
	assert_called(mock_cracks.material, "set_shader_parameter", ["destruction_amount", 0.0])
	# cleanup
	mock_wall.free()
	mock_cracks.free()


func test_update_visuals_tween():
	# given
	# when
	visual_effects_manager.update_visuals_tween(60.0, 100.0, 100.0)
	# then
	assert_not_null(visual_effects_manager._update_visuals_tween)
	var tween = visual_effects_manager._update_visuals_tween
	assert_true(tween.is_valid())
	assert_true(tween.is_running())
	# cleanup
	tween.stop()


func test_play_spawn_animation():
	# given
	visual_effects_manager._bounce_back_direction = TEST_BOUNCE_DIRECTION
	var mock_spawn_animation = _mock_spawn_animation()
	# when
	visual_effects_manager.play_spawn_animation()
	# then
	assert_called(mock_spawn_animation, "play_spawn_animation", [TEST_BOUNCE_DIRECTION])


func test_play_break_animation():
	# given
	var mock_fullscreen_effects = _mock_full_screen_effects()
	stub(mock_fullscreen_effects, "monochrome").to_do_nothing()
	stub(mock_fullscreen_effects, "pincushion").to_do_nothing()
	var mock_camera_effects = _mock_camera_effects()
	stub(mock_camera_effects, "emit_signal_start_camera_impact").to_do_nothing()
	# when
	var hit_position = Vector2(100, 200)
	visual_effects_manager.play_break_animation(hit_position)
	# then
	assert_called(mock_fullscreen_effects, "monochrome", [2.0])
	assert_called(mock_fullscreen_effects, "pincushion", [2.0])
	assert_called(mock_camera_effects, "emit_signal_start_camera_impact", [1.0, CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH, CameraEffects.CAMERA_IMPACT_PRIORITY.HIGH])


var test_camera_shake_by_velocity_params := [
	[1500, CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM],
	[3500, CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH],
]


func test_shake_camera_by_velocity(params = use_parameters(test_camera_shake_by_velocity_params)):
	# given
	var velocity = params[0]
	var camera_effects = _mock_camera_effects()
	stub(camera_effects, "emit_signal_start_camera_impact").to_do_nothing()
	# when
	visual_effects_manager.shake_camera_by_velocity(velocity)
	# then
	assert_called(camera_effects, "emit_signal_start_camera_impact", [1.0, params[1], CameraEffects.CAMERA_IMPACT_PRIORITY.HIGH])


func test_shake_camera():
	# given
	var mock_camera_effects = _mock_camera_effects()
	stub(mock_camera_effects, "emit_signal_start_camera_impact").to_do_nothing()
	# when
	visual_effects_manager.shake_camera(CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM)
	# then
	assert_called(mock_camera_effects, "emit_signal_start_camera_impact", [1.0, CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM, CameraEffects.CAMERA_IMPACT_PRIORITY.HIGH])


var update_visuals_parameters = [
	[1.0, Color.GREEN, 0.0],
	[0.5, Color(0.5, 0.5, 0.0), 0.25],
	[0.0, Color.RED, 0.5],
]


func test_update_visuals(params = use_parameters(update_visuals_parameters)):
	# given
	var health_ratio = params[0]
	var expected_color = params[1]
	var expected_destruction = params[2]
	var mock_wall = _mock_wall()
	var mock_particles = _mock_particles()
	var mock_cracks = _mock_cracks()
	stub(mock_cracks.material, "set_shader_parameter").to_do_nothing()
	_mock_gradient()
	# when
	visual_effects_manager.update_visuals(health_ratio)
	# then
	assert_eq(mock_wall.modulate, expected_color)
	assert_called(mock_particles, "set_color", [expected_color])
	assert_called(mock_cracks.material, "set_shader_parameter", ["destruction_amount", expected_destruction])
	# cleanup
	mock_wall.free()
	mock_cracks.free()


func test_get_shake_type_by_velocity_medium():
	# given
	var velocity = visual_effects_manager.DAMAGE_WALL_TRESHOLD_EFFECT * 0.5
	# when
	var result = visual_effects_manager._get_shake_type_by_velocity(velocity)
	# then
	assert_eq(result, CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM)


func test_get_shake_type_by_velocity_high():
	# given
	var velocity = visual_effects_manager.DAMAGE_WALL_TRESHOLD_EFFECT * 2
	# when
	var result = visual_effects_manager._get_shake_type_by_velocity(velocity)
	# then
	assert_eq(result, CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH)


##### UTILS #####
func _mock_wall():
	var wall = Node2D.new()
	visual_effects_manager.onready_paths.wall = wall
	return wall


func _mock_cracks():
	var cracks = Node2D.new()
	cracks.material = double(ShaderMaterial).new()
	visual_effects_manager.onready_paths.cracks = cracks
	return cracks


func _mock_particles():
	var particles = double(load("res://Scenes/DestructibleWalls/particles.gd")).new()
	visual_effects_manager.onready_paths.particles = particles
	return particles


func _mock_spawn_animation():
	var spawn_animation = double(load("res://Scenes/DestructibleWalls/spawn_animation.gd")).new()
	visual_effects_manager.onready_paths.spawn_animation = spawn_animation
	return spawn_animation


func _mock_gradient():
	var gradient = Gradient.new()
	gradient.remove_point(0)
	gradient.add_point(0, Color.RED)
	gradient.add_point(1, Color.GREEN)
	gradient.remove_point(0)
	visual_effects_manager.wall_gradient = gradient
	return gradient


func _mock_full_screen_effects():
	var fullscreen_effects = double(load("res://Scenes/Camera/FullScreenEffects/full_screen_effects.gd")).new()
	visual_effects_manager._full_screen_effects = fullscreen_effects
	return fullscreen_effects


func _mock_camera_effects():
	var camera_effects = double(load("res://Scenes/Camera/camera_effects.gd")).new()
	visual_effects_manager._camera_effects = camera_effects
	return camera_effects
