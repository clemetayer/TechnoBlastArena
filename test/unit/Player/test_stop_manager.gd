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

var toggle_stop_params := [
	[true],
	[false],
]


func test_toggle_stop(params = use_parameters(toggle_stop_params)):
	# given
	var active = params[0]
	var player = mock_player()
	# when
	manager.toggle_stop(active)
	# then
	assert_called(player, "toggle_movement", [not active])
	assert_called(player, "toggle_damage", [not active])
	assert_called(player, "toggle_abilities", [not active])


func test_stop_for_duration():
	# given
	var stop_duration = 5.0 / 60.0
	var player = mock_player()
	# when
	manager.stop_for_duration(stop_duration)
	# then
	assert_called(player, "toggle_movement", [false])
	assert_called(player, "toggle_damage", [false])
	assert_called(player, "toggle_abilities", [false])
	await wait_seconds(stop_duration)
	await wait_process_frames(1)
	assert_called(player, "toggle_movement", [true])
	assert_called(player, "toggle_damage", [true])
	assert_called(player, "toggle_abilities", [true])


func test_dont_add_stops_if_not_over():
	# given
	var stop_duration = 10.0 / 60.0
	var player = mock_player()
	# when
	manager.stop_for_duration(stop_duration)
	await wait_process_frames(2)
	manager.stop_for_duration(stop_duration)
	# then
	assert_called_count(player.toggle_movement.bind(false), 1)
	assert_called_count(player.toggle_damage.bind(false), 1)
	assert_called_count(player.toggle_abilities.bind(false), 1)
	await wait_seconds(2 * stop_duration)
	await wait_process_frames(1)
	assert_called_count(player.toggle_movement.bind(true), 1)
	assert_called_count(player.toggle_damage.bind(true), 1)
	assert_called_count(player.toggle_abilities.bind(true), 1)


##### UTILS #####
func mock_player() -> Node:
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var player = double(load("res://Scenes/Player/player.gd")).new()
	stub(player, "toggle_movement").to_do_nothing()
	stub(player, "toggle_damage").to_do_nothing()
	stub(player, "toggle_abilities").to_do_nothing()
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
