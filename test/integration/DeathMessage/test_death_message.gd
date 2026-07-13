extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const PLAYER_1_DEFAULT_CONFIG_PATH := "res://test/integration/DeathMessage/player_1.tres"
const PLAYER_2_DEFAULT_CONFIG_PATH := "res://test/integration/DeathMessage/player_2.tres"
const DEFAULT_LEVEL_CONFIG_PATH := "res://test/integration/DeathMessage/level_default.tres"

#---- VARIABLES -----
var scene
var _sender = InputSender.new(Input)


##### SETUP #####
func before_each():
	scene = load("res://test/integration/DeathMessage/scene_death_message.tscn").instantiate()
	add_child_autofree(scene)
	await wait_process_frames(5)


##### TEARDOWN #####
func after_each():
	_sender.release_all()
	_sender.clear()


##### TESTS #####
func test_death_message():
	# given
	var default_level = load(DEFAULT_LEVEL_CONFIG_PATH)
	var player_1_config = load(PLAYER_1_DEFAULT_CONFIG_PATH)
	var player_2_config = load(PLAYER_2_DEFAULT_CONFIG_PATH)
	scene.set_level_data(default_level)
	scene.set_player_data(1, player_1_config)
	scene.set_player_data(2, player_2_config)
	scene.init_players_data()
	scene.init_level_data()
	scene.add_game_elements()
	scene.init_game_elements()
	scene.disable_player_mouse_input(1)
	await wait_seconds(1)
	scene.toggle_truce(false)
	assert_eq(scene.get_game_message(), "Ready ?")
	await wait_seconds(5)
	_sender.action_down("fire").hold_for(.1)
	await _sender.idle
	await wait_seconds(0.5)
	scene.get_player(2).kill()
	await wait_seconds(0.5)
	assert_eq(scene.get_game_message(), "test player 1")
