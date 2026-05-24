extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var manager


##### SETUP #####
func before_each():
	var parent = _create_parent_arborescence()
	manager = load("res://Scenes/Player/stop_manager.tscn").instantiate()
	parent.add_child(manager)


##### TESTS #####
func test_stop_locks_movement_for_duration():
	# given
	var freeze_duration = 5.0 / 60.0
	var player = mock_player()
	stub(player, "toggle_movement").to_do_nothing()
	# when
	manager.stop(freeze_duration)
	# then
	assert_called(player, "toggle_movement", [false])
	await wait_seconds(freeze_duration)
	await wait_process_frames(1)
	assert_called(player, "toggle_movement", [true])


func test_stop_disables_damage_for_duration():
	# given
	var freeze_duration = 5.0 / 60.0
	var player = mock_player()
	stub(player, "toggle_damage").to_do_nothing()
	# when
	manager.stop(freeze_duration)
	# then
	assert_called(player, "toggle_damage", [false])
	await wait_seconds(freeze_duration)
	await wait_process_frames(1)
	assert_called(player, "toggle_damage", [true])


func test_stop_disables_abilities():
	# given
	var freeze_duration = 5.0 / 60.0
	var player = mock_player()
	stub(player, "toggle_abilities").to_do_nothing()
	# when
	manager.stop(freeze_duration)
	# then
	assert_called(player, "toggle_abilities", [false])
	await wait_seconds(freeze_duration)
	await wait_process_frames(1)
	assert_called(player, "toggle_abilities", [true])


##### UTILS #####
func mock_player() -> Node:
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var player = double(load("res://Scenes/Player/player.gd")).new()
	paths.player_root = player
	manager.paths = paths
	return player


func _create_parent_arborescence() -> Node2D:
	var parent := Node2D.new()
	var paths = autofree(Node2D.new())
	paths.name = "Paths"
	parent.add_child(paths)
	add_child_autofree(parent)
	return parent
