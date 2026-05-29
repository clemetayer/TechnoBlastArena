extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var player_interaction_manager


##### SETUP #####
func before_each():
	player_interaction_manager = autofree(load("res://Scenes/DestructibleWalls/player_interactions_manager.gd").new())


##### TESTS #####
func test_player_hit():
	# given
	var player = double(load("res://Scenes/Player/player.gd")).new()
	stub(player, "stop_for_duration").to_do_nothing()
	var audio_manager = double(load("res://Scenes/DestructibleWalls/audio_manager.gd")).new()
	stub(audio_manager, "play_hit").to_do_nothing()
	stub(audio_manager, "play_trebble").to_do_nothing()
	player_interaction_manager.onready_paths.audio_manager = audio_manager
	var visual_effects_manager = double(load("res://Scenes/DestructibleWalls/visual_effects_manager.gd")).new()
	stub(visual_effects_manager, "shake_camera_by_velocity").to_do_nothing()
	player_interaction_manager.onready_paths.visual_effects_manager = visual_effects_manager
	var health_manager = double(load("res://Scenes/DestructibleWalls/health_manager.gd")).new()
	stub(health_manager, "get_health_ratio").to_return(0.3)
	player_interaction_manager.onready_paths.health_manager = health_manager
	var timers = add_child_autofree(Node.new())
	player_interaction_manager.onready_paths.player_wall_hit_stop_timers = timers
	# when
	player_interaction_manager.handle_player_hit(player, Vector2.LEFT * 125.0, Vector2.RIGHT, 2.0)
	# then
	assert_called(player, "stop_for_duration", [player_interaction_manager.WALL_HIT_STOP_TIME, true])
	assert_called(audio_manager, "play_hit")
	assert_called(audio_manager, "play_trebble", [0.3])
	assert_called(visual_effects_manager, "shake_camera_by_velocity", [-125.0])
	await wait_seconds(player_interaction_manager.WALL_HIT_STOP_TIME)
	await wait_process_frames(5)
	assert_called(audio_manager, "stop_trebble")
	assert_called(player, "override_velocity", [Vector2.RIGHT * 2.0])


func test_kill_player():
	# given
	var player = double(load("res://Scenes/Player/player.gd")).new()
	stub(player, "kill").to_do_nothing()
	player_interaction_manager.kill_player(player)
	# when
	# then
	assert_called(player, "kill")
