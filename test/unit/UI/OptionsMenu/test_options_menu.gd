extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var options_menu


##### SETUP #####
func before_each():
	options_menu = add_child_autofree(load("res://Scenes/UI/OptionsMenu/options_menu.tscn").instantiate())


##### TESTS #####
func test_save_options():
	# given
	var runtime_config = mock_runtime_configs()
	stub(runtime_config, "save_config").to_do_nothing()
	var tree = mock_scene_tree()
	stub(tree, "change_scene_to_file").to_do_nothing()
	# when
	options_menu.back_button.pressed.emit()
	# then
	assert_called(runtime_config, "save_config")
	assert_called(tree, "change_scene_to_file", [options_menu.MAIN_MENU_PATH])


##### UTILS #####
func mock_runtime_configs():
	var runtime_config = double(load("res://Utils/Config/runtime_config.gd")).new()
	options_menu.runtime_config = runtime_config
	return runtime_config


func mock_scene_tree():
	var scene_tree = double(SceneTree).new()
	options_menu.tree = scene_tree
	return scene_tree
