extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var main_menu
var scene_tree


##### SETUP #####
func before_each():
	main_menu = add_child_autofree((load("res://Scenes/UI/MainMenu/main_menu.tscn").instantiate()))
	scene_tree = double(SceneTree).new()
	stub(scene_tree, "change_scene_to_file").to_do_nothing()
	main_menu.tree = scene_tree


##### TESTS #####
func test_options_redirect_to_options_menu():
	# given
	# when
	main_menu.options_button.pressed.emit()
	# then
	assert_called(scene_tree, "change_scene_to_file", [main_menu.OPTIONS_MENU_PATH])


func test_multiplayer_redirects_to_game_manager_menu():
	# given
	# when
	main_menu.multiplayer_button.pressed.emit()
	# then
	assert_called(scene_tree, "change_scene_to_file", [main_menu.MULTIPLAYER_MENU_PATH])


func test_customization_redirects_to_player_customization_menu():
	# given
	# when
	main_menu.customization_button.pressed.emit()
	# then
	assert_called(scene_tree, "change_scene_to_file", [main_menu.CUSTOMIZATION_MENU_PATH])


func test_quit():
	# given
	stub(scene_tree, "quit").to_do_nothing()
	# when
	main_menu.quit_button.pressed.emit()
	# then
	assert_called(scene_tree, "quit")
