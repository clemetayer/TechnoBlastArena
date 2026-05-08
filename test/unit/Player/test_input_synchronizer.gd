extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
# const CONST := "value"

#---- VARIABLES -----
var input_synchronizer

##### SETUP #####
func before_each():
	input_synchronizer = load("res://Scenes/Player/input_synchronizer.gd").new()

##### TEARDOWN #####
func after_each():
	input_synchronizer.free()

##### TESTS #####
# kind of hard to test start_input_detection, it is somehow fairly hard to test the process mode
func test_set_action_handler():
	# given
	var paths = load("res://Scenes/Player/paths.gd").new()
	var player_root = Node2D.new()
	add_child(player_root)
	wait_for_signal(player_root.tree_entered, 0.25)
	paths.player_root = player_root
	input_synchronizer.paths = paths
	# when
	input_synchronizer.set_action_handler(StaticActionHandler.handlers.RECORD)
	# then
	assert_not_null(paths.action_handler)
	assert_true(paths.action_handler is ActionHandlerBase)
	assert_eq(paths.action_handler.name, "ActionHandler")
	assert_eq(paths.player_root.get_child_count(), 1)
	# cleanup
	player_root.free()
	paths.free()
