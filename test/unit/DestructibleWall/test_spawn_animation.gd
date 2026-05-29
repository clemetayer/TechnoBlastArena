extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var spawn_animation


##### SETUP #####
func before_each():
	spawn_animation = load("res://Scenes/DestructibleWalls/spawn_animation.gd").new()
	add_child_autofree(spawn_animation)


##### TESTS #####
func test_play_spawn_animation():
	# given
	var mock_root = double(Node2D).new()
	var mock_particles = double(load("res://Scenes/DestructibleWalls/particles.gd")).new()
	var mock_audio = double(AudioStreamPlayer).new()
	var direction = Vector2.RIGHT
	stub(mock_audio, "play").to_do_nothing()
	stub(mock_particles, "toggle_emit").to_do_nothing()
	spawn_animation.root = mock_root
	spawn_animation.onready_paths.particles = mock_particles
	spawn_animation.onready_paths.audio = mock_audio
	# when
	spawn_animation.play_spawn_animation(direction)
	# then
	assert_called(mock_audio, "play")
	assert_eq(mock_root.position, -direction * spawn_animation.BASE_OFFSET)
	assert_not_null(spawn_animation._animation_tween)
	var tween_prop = spawn_animation._animation_tween.get_total_elapsed_time()
	assert_eq(tween_prop, 0.0)
	spawn_animation._animation_tween.emit_signal("finished")
	await wait_frames(1)
	assert_called(mock_particles, "toggle_emit", [true])


func test_on_sparks_timer_timeout():
	# given
	var mock_particles = double(load("res://Scenes/DestructibleWalls/particles.gd")).new()
	stub(mock_particles, "toggle_emit").to_do_nothing()
	spawn_animation.onready_paths.particles = mock_particles
	# when
	spawn_animation._on_sparks_timer_timeout()
	# then
	assert_called(mock_particles, "toggle_emit", [false])
