extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const PLAYER_1_DEFAULT_CONFIG_PATH := "res://test/integration/GameOutro/player_1.tres"
const PLAYER_2_DEFAULT_CONFIG_PATH := "res://test/integration/GameOutro/player_2.tres"
const DEFAULT_LEVEL_CONFIG_PATH := "res://test/integration/GameOutro/level_default.tres"

#---- VARIABLES -----
var scene
var default_level
var player_1_config
var player_2_config


##### SETUP #####
func before_each():
	scene = load("res://test/integration/GameOutro/scene_game_outro.tscn").instantiate()
	add_child_autofree(scene)
	await wait_process_frames(5)


##### TESTS #####
func test_outro():
	# given
	watch_signals(scene.get_game())
	default_level = load(DEFAULT_LEVEL_CONFIG_PATH)
	player_1_config = load(PLAYER_1_DEFAULT_CONFIG_PATH)
	player_2_config = load(PLAYER_2_DEFAULT_CONFIG_PATH)
	scene.set_level_data(default_level)
	scene.set_player_data(1, player_1_config)
	scene.set_player_data(2, player_2_config)
	scene.init_players_data()
	scene.init_level_data()
	# when
	scene.add_game_elements()
	scene.init_game_elements()
	await wait_seconds(6)
	# then
	scene.get_player(2).kill()
	await wait_seconds(4)
	scene.get_player(2).kill()
	await wait_seconds(4)
	scene.get_player(2).kill()
	await wait_seconds(2.5)
	assert_true(scene.get_game_message().contains("Game !"))
	await wait_seconds(5)
	assert_signal_emitted(scene.get_game().game_over)
