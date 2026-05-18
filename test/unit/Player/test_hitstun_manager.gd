extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var hitstun_manager


##### SETUP #####
func before_each():
	hitstun_manager = autofree(load("res://Scenes/Player/hitstun_manager.gd").new())


##### TESTS #####
func test_stop_hitstun():
	# given
	var mock_hitstun_manager = partial_double(load("res://Scenes/Player/hitstun_manager.gd")).new()
	stub(mock_hitstun_manager, "_on_hitstun_timeout").to_do_nothing()
	var hitstun_timer = double(Timer).new()
	stub(hitstun_timer, "stop")
	mock_hitstun_manager.hitstunned = true
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	paths.hitstun_timer = hitstun_timer
	mock_hitstun_manager.paths = paths
	# when
	mock_hitstun_manager.stop_hitstun()
	# then
	assert_called(hitstun_timer, "stop")
	assert_called(mock_hitstun_manager, "_on_hitstun_timeout")


func test_set_trail_color():
	# given
	var particles = _create_particles_mock()
	var expected_color = Color.CYAN
	expected_color.s = 0.5
	# when
	hitstun_manager.set_trail_color(Color.CYAN)
	# then
	assert_eq(particles.modulate, expected_color)


func test_on_player_damage_received():
	# given
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var hitstun_timer = double(Timer).new()
	stub(hitstun_timer, "start").to_do_nothing()
	paths.hitstun_timer = hitstun_timer
	var animation_player = double(AnimationPlayer).new()
	stub(animation_player, "play").to_do_nothing()
	paths.animation_player = animation_player
	var bounce_area = double(load("res://Scenes/Player/bounce_area.gd")).new()
	stub(bounce_area, "toggle_active").to_do_nothing()
	paths.bounce_area = bounce_area
	hitstun_manager.paths = paths
	var particles = _create_particles_mock()
	particles.emitting = false
	# when
	hitstun_manager._on_player_damage_received(100.0, 123.0, Vector2.ONE)
	# then
	assert_called(hitstun_timer, "start")
	assert_called(animation_player, "play", ["hitstun", null, null, null])
	assert_called(bounce_area, "toggle_active", [true])
	assert_true(hitstun_manager.hitstunned)
	assert_true(particles.emitting)


func test_on_hitstun_timeout():
	# given
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var animation_player = double(AnimationPlayer).new()
	stub(animation_player, "stop").to_do_nothing()
	stub(animation_player, "play").to_do_nothing()
	paths.animation_player = animation_player
	var bounce_area = double(load("res://Scenes/Player/bounce_area.gd")).new()
	stub(bounce_area, "toggle_active").to_do_nothing()
	paths.bounce_area = bounce_area
	hitstun_manager.paths = paths
	var particles = _create_particles_mock()
	particles.emitting = true
	# when
	hitstun_manager._on_hitstun_timeout()
	# then
	assert_called(animation_player, "stop")
	assert_called(animation_player, "play", ["RESET", null, null, null])
	assert_called(bounce_area, "toggle_active", [false])
	assert_false(hitstun_manager.hitstunned)
	assert_false(particles.emitting)


##### UTILS #####
func _create_particles_mock() -> GPUParticles2D:
	var particles = autofree(GPUParticles2D.new())
	particles.process_material = ParticleProcessMaterial.new()
	hitstun_manager.particles = particles
	return particles
