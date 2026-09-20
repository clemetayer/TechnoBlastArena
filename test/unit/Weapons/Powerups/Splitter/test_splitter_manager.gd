extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var splitter_manager


##### SETUP #####
func before_each():
	splitter_manager = add_child_autofree(
		load("res://Scenes/Weapons/Powerups/Splitter/splitter_manager.tscn").instantiate()
	)


##### TESTS #####
func test_first_init_ui():
	# given
	watch_signals(splitter_manager)
	splitter_manager._init_ui_done = false
	# when
	await wait_process_frames(1)
	# then
	assert_signal_emitted(splitter_manager, "value_updated", splitter_manager.MAX_SPLITTERS_ACTIVE)


var use_params := [[true], [false]]


func test_use(params = use_parameters(use_params)):
	# given
	watch_signals(splitter_manager)
	var active = params[0]
	var game_root = mock_game_root()
	var expected_position = Vector2(randi() % 50, randi() % 50)
	splitter_manager.active = active
	splitter_manager.global_position = expected_position
	splitter_manager._actions_available = splitter_manager.MAX_ACTIONS
	# when
	splitter_manager.use()
	# then
	if active:
		assert_eq(game_root.get_child_count(), 1)
		var splitter = game_root.get_child(0)
		assert_eq(splitter.global_position, expected_position)
		assert_signal_emitted(splitter_manager.value_updated, [splitter_manager.MAX_ACTIONS - 1])
		await wait_for_signal(splitter_manager.cooldown_timer.timeout, 20.0)
		assert_signal_emitted(splitter_manager.value_updated, [splitter_manager.MAX_ACTIONS])
		assert_eq(splitter_manager._actions_available, splitter_manager.MAX_ACTIONS)
	else:
		assert_eq(game_root.get_child_count(), 0)


func test_too_many_splitters():
	# given
	var splitter_load = load("res://Scenes/Weapons/Powerups/Splitter/splitter.tscn")
	var game_root = mock_game_root()
	for splitter_idx in range(splitter_manager.MAX_SPLITTERS_ACTIVE):
		var splitter = autofree(splitter_load.instantiate())
		game_root.add_child(splitter)
	var expected_splitter_to_remove = game_root.get_child(0)
	splitter_manager.active = true
	# when
	splitter_manager.use()
	await wait_process_frames(1)
	# then
	assert_eq(game_root.get_child_count(), splitter_manager.MAX_SPLITTERS_ACTIVE)
	assert_false(is_instance_valid(expected_splitter_to_remove))


func test_no_splitters_available():
	# given
	var game_root = mock_game_root()
	splitter_manager.active = true
	splitter_manager._actions_available = 0
	# when
	splitter_manager.use()
	await wait_process_frames(1)
	# then
	assert_eq(game_root.get_child_count(), 0)


func test_reload_actions_max_reached():
	# given
	splitter_manager._actions_available = splitter_manager.MAX_ACTIONS
	# when
	splitter_manager.cooldown_timer.timeout.emit()
	# then
	assert_eq(splitter_manager._actions_available, splitter_manager.MAX_ACTIONS)


##### UTILS #####
func mock_game_root():
	var root = add_child_autofree(
		load("res://test/unit/Weapons/Powerups/Chain/mock_game_root.tscn").instantiate()
	)
	return root
