extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const PLAYER_1_DEFAULT_CONFIG_PATH := "res://test/integration/UI/PauseMenu/player_1.tres"
const PLAYER_2_DEFAULT_CONFIG_PATH := "res://test/integration/UI/PauseMenu/player_2.tres"
const DEFAULT_LEVEL_CONFIG_PATH := "res://test/integration/UI/PauseMenu/level_default.tres"

#---- VARIABLES -----
var scene
var tree
var default_level
var player_1_config
var player_2_config
var sender = InputSender.new(Input)


##### SETUP #####
func before_each():
	scene = add_child_autofree(
		load("res://test/integration/UI/PauseMenu/scene_pause_menu.tscn").instantiate()
	)
	tree = double(SceneTree).new()
	stub(tree, "change_scene_to_file").to_do_nothing()
	stub(tree, "set_pause").to_do_nothing()
	scene.get_pause_menu().tree = tree


##### TEARDOWN #####
func after_each():
	sender.release_all()
	sender.clear()


##### TESTS #####
func test_pause_resume():
	# given
	_common_init()
	await wait_seconds(0.5)
	# then
	assert_false(scene.get_pause_menu().visible)
	# when
	sender.action_down("pause").hold_for(0.5)
	await sender.idle
	sender.release_all()
	# then
	assert_true(scene.get_pause_menu().visible)
	assert_called(tree, "set_pause", [true])
	# when
	scene.get_pause_menu().resume_button.pressed.emit()
	# then
	assert_false(scene.get_pause_menu().visible)
	assert_called(tree, "set_pause", [false])


func test_pause_options():
	# given
	_common_init()
	await wait_seconds(0.5)
	# when
	sender.action_down("pause").hold_for(0.5)
	await sender.idle
	sender.release_all()
	# then
	assert_false(scene.get_pause_option_menu().visible)
	# when
	scene.get_pause_menu().options_button.pressed.emit()
	# then
	assert_false(scene.get_pause_menu().visible)
	assert_true(scene.get_pause_option_menu().visible)
	# when
	scene.get_pause_option_menu().return_triggered.emit()
	# then
	assert_true(scene.get_pause_menu().visible)
	assert_false(scene.get_pause_option_menu().visible)


func test_pause_quit():
	# given
	_common_init()
	await wait_seconds(0.5)
	# when
	sender.action_down("pause").hold_for(0.5)
	await sender.idle
	sender.release_all()
	scene.get_pause_menu().quit_button.pressed.emit()
	# then
	assert_called(tree, "change_scene_to_file", [scene.get_pause_menu().MULTIPLAYER_MENU_PATH])
	assert_called(tree, "set_pause", [false])


##### UTILS #####
func _common_init() -> void:
	default_level = load(DEFAULT_LEVEL_CONFIG_PATH)
	player_1_config = load(PLAYER_1_DEFAULT_CONFIG_PATH)
	player_2_config = load(PLAYER_2_DEFAULT_CONFIG_PATH)
	scene.set_level_data(default_level)
	scene.set_player_data(1, player_1_config)
	scene.set_player_data(2, player_2_config)
	scene.init_players_data()
	scene.init_level_data()
	scene.add_game_elements()
	scene.init_game_elements()
