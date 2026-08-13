extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var menu
var scene_tree


##### SETUP #####
func before_each():
	menu = add_child_autofree(load("res://Scenes/UI/PauseMenu/pause_menu.tscn").instantiate())
	scene_tree = double(SceneTree).new()
	stub(scene_tree, "change_scene_to_file").to_do_nothing()
	stub(scene_tree, "set_pause").to_do_nothing()
	menu.tree = scene_tree


##### TESTS #####
func test_pause():
	# given
	menu.visible = false
	# when
	menu.pause()
	# then
	assert_called(scene_tree, "set_pause", [true])


func test_resume():
	# given
	menu.visible = true
	# when
	menu.resume_button.pressed.emit()
	# then
	assert_called(scene_tree, "set_pause", [false])
	assert_false(menu.visible)


func test_options_emit_open_options():
	# given
	watch_signals(menu)
	# when
	menu.options_button.pressed.emit()
	# then
	assert_signal_emitted(menu.options_triggered)


func test_quit():
	# given
	# when
	menu.quit_button.pressed.emit()
	# then
	assert_called(scene_tree, "set_pause", [false])
	assert_called(scene_tree, "change_scene_to_file", [menu.MULTIPLAYER_MENU_PATH])
