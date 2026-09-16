extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var splitter_manager
var value_updated_times_called := 0
var value_updated_args := []


##### SETUP #####
func before_each():
	splitter_manager = load("res://Scenes/Weapons/Powerups/Splitter/splitter_manager.gd").new()
	value_updated_times_called = 0
	value_updated_args = []


##### TEARDOWN #####
func after_each():
	splitter_manager.free()


##### TESTS #####
var process_params := [[true], [false]]


func test_process(params = use_parameters(process_params)):
	# given
	var init_ui_done = params[0]
	splitter_manager._init_ui_done = init_ui_done
	splitter_manager.connect("value_updated", _on_value_updated)
	# when
	splitter_manager._process(1.0 / 60.0)
	# then
	if not init_ui_done:
		assert_eq(value_updated_times_called, 1)
		assert_eq(value_updated_args, [[1.0]])
	else:
		assert_eq(value_updated_times_called, 0)


var use_params := [
	[true, true, 2],
	[false, true, 2],
	[true, false, 2],
	[true, true, 2],
	[true, true, 4],
]


func test_use(params = use_parameters(use_params)):
	# given
	var can_use_powerup = params[0]
	var active = params[1]
	var splitters_active = params[2]
	var splitter_manager_mock = partial_double(
		load("res://Scenes/Weapons/Powerups/Splitter/splitter_manager.gd")
	).new()
	stub(splitter_manager_mock, "_remove_last_splitter").to_do_nothing()
	stub(splitter_manager_mock, "_start_update_value_tween").to_do_nothing()
	var runtime_utils = double(load("res://Utils/runtime_utils.gd")).new()
	var mock_game_root = double(load("res://Scenes/Game/game.gd"), DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	stub(mock_game_root, "spawn_powerup").to_do_nothing()
	stub(runtime_utils, "get_game_root").to_return(mock_game_root)
	splitter_manager_mock._runtime_utils = runtime_utils
	splitter_manager_mock._can_use_powerup = can_use_powerup
	splitter_manager_mock.active = active
	var cooldown_timer = double(Timer).new()
	stub(cooldown_timer, "start").to_do_nothing()
	splitter_manager_mock.onready_paths.cooldown_timer = cooldown_timer
	var splitter_load = load(splitter_manager.SPLITTER_PATH)
	splitter_manager_mock._splitter_load = splitter_load
	for i in range(splitters_active):
		splitter_manager_mock._splitters_active.push_front(Node2D.new())
	# when
	splitter_manager_mock.use()
	# then
	if can_use_powerup and active:
		if splitters_active >= splitter_manager.MAX_SPLITTERS_ACTIVE:
			assert_called(splitter_manager_mock, "_remove_last_splitter")
		else:
			assert_not_called(splitter_manager_mock, "_remove_last_splitter")
		assert_called(mock_game_root, "spawn_powerup")
		assert_eq(splitter_manager_mock._splitters_active.size(), splitters_active + 1)
		assert_false(splitter_manager_mock._can_use_powerup)
		assert_called(cooldown_timer, "start", [splitter_manager_mock.COOLDOWN_TIMER])
		assert_called(splitter_manager_mock, "_start_update_value_tween")
	else:
		assert_not_called(splitter_manager_mock, "_remove_last_splitter")
		assert_not_called(mock_game_root, "spawn_powerup")
		assert_eq(splitter_manager_mock._splitters_active.size(), splitters_active)
		assert_eq(splitter_manager_mock._can_use_powerup, can_use_powerup)
		assert_not_called(cooldown_timer, "start")
		assert_not_called(splitter_manager_mock, "_start_update_value_tween")
	# cleanup
	for splitter in splitter_manager._splitters_active:
		splitter.free()


func test_remove_last_splitter():
	# given
	splitter_manager._splitters_active = [Node2D.new(), Node2D.new()]
	# when
	splitter_manager._remove_last_splitter()
	# then
	assert_eq(splitter_manager._splitters_active.size(), 1)
	# cleanup
	for splitter in splitter_manager._splitters_active:
		splitter.free()


func test_start_update_value_tween():
	# given
	# when
	splitter_manager._start_update_value_tween()
	# then
	assert_not_null(splitter_manager._splitter_cooldown_tween)


func test_on_cooldown_timer_timeout():
	# given
	splitter_manager._can_use_powerup = false
	# when
	splitter_manager._on_cooldown_timer_timeout()
	# then
	assert_true(splitter_manager._can_use_powerup)


func test_on_splitter_destroyed():
	# given
	var splitter = Node2D.new()
	splitter_manager._splitters_active = [splitter]
	# when
	splitter_manager._on_splitter_destroyed(splitter)
	# then
	assert_eq(splitter_manager._splitters_active.size(), 0)
	# cleanup
	splitter.free()


##### UTILS #####
func _on_value_updated(value) -> void:
	value_updated_times_called += 1
	value_updated_args.append([value])
