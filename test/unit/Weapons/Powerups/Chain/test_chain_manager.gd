extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const CHAIN_ELEMENT := "res://Scenes/Weapons/Powerups/Chain/chain_element.tscn"

#---- VARIABLES -----
var chain_manager


##### SETUP #####
func before_each():
	chain_manager = add_child_autofree(
		load("res://Scenes/Weapons/Powerups/Chain/chain_manager.tscn").instantiate()
	)


##### TESTS #####
func test_spawn_alone():
	# given
	var root = mock_game_root()
	var input_synchronizer = mock_input_synchronizer()
	input_synchronizer.relative_aim_position = Vector2.ONE
	# when
	chain_manager.use()
	# then
	assert_eq(root.get_child_count(), 1)
	var chain_element = root.get_child(0)
	assert_eq(chain_element.idx, 0)
	assert_eq(chain_element.global_rotation, Vector2.ZERO.angle_to_point(Vector2.ONE))
	assert_almost_eq(chain_element._direction, Vector2.ONE.normalized(), Vector2.ONE * 0.001)


func test_spawn_multiple():
	# given
	var root = mock_game_root()
	var input_synchronizer = mock_input_synchronizer()
	input_synchronizer.relative_aim_position = -Vector2.ONE
	var chain_element_1 = load(CHAIN_ELEMENT).instantiate()
	var chain_element_2 = load(CHAIN_ELEMENT).instantiate()
	chain_element_1.spawn(Vector2.ONE, Vector2.ZERO, 0)
	chain_element_2.spawn(Vector2.LEFT, Vector2.ONE, 1)
	# when
	chain_manager.global_position = Vector2(1, 2)
	chain_manager.use()
	# then
	assert_eq(root.get_child_count(), 3)
	assert_eq(root.get_child(-1).idx, 2)
	var last_chain_element = root.get_child(-1)
	assert_eq(last_chain_element.global_rotation, Vector2.ZERO.angle_to_point(-Vector2.ONE))
	assert_almost_eq(last_chain_element._direction, -Vector2.ONE.normalized(), Vector2.ONE * 0.001)
	assert_eq(chain_element_2.global_rotation, Vector2.ONE.angle_to_point(Vector2(1, 2)))
	assert_eq(chain_element_2._direction, Vector2(1, 2) - Vector2.ONE)


func test_spawn_max_elements_reached():
	# given
	var root = mock_game_root()
	var input_synchronizer = mock_input_synchronizer()
	input_synchronizer.relative_aim_position = Vector2.ONE
	var chain_element_1 = load(CHAIN_ELEMENT).instantiate()
	chain_element_1.spawn(Vector2.RIGHT, Vector2.ZERO, 0)
	for chain_idx in range(1, chain_manager.MAX_ELEMENTS):
		var chain_element = load(CHAIN_ELEMENT).instantiate()
		chain_element.spawn(Vector2.RIGHT, Vector2.ZERO, chain_idx)
	# when
	chain_manager.use()
	# then
	assert_eq(root.get_child_count(), chain_manager.MAX_ELEMENTS)
	var last_chain_element = root.get_child(-1)
	assert_eq(last_chain_element.idx, chain_manager.MAX_ELEMENTS - 1)
	await wait_process_frames(1)
	assert_false(is_instance_valid(chain_element_1))


func test_destroy():
	# given
	var root = mock_game_root()
	var chain_element_1 = load(CHAIN_ELEMENT).instantiate()
	var chain_element_2 = load(CHAIN_ELEMENT).instantiate()
	var chain_element_3 = load(CHAIN_ELEMENT).instantiate()
	var chain_element_4 = load(CHAIN_ELEMENT).instantiate()
	chain_element_1.spawn(-Vector2.ONE, Vector2.ONE, 0)
	chain_element_2.spawn(Vector2(-2, 3), Vector2.ZERO, 1)
	chain_element_3.spawn(Vector2(-2, 3) - Vector2(4, 3), Vector2(-2, 3), 2)
	chain_element_3.destroyed.connect(chain_manager._on_chain_element_destroyed)
	chain_element_4.spawn(Vector2.UP, Vector2(4, 3), 3)
	# when
	chain_element_3._on_element_counter_empty()
	await wait_process_frames(2)
	# then
	assert_eq(root.get_child_count(), 3)
	assert_eq(chain_element_1.idx, 0)
	assert_eq(chain_element_2.idx, 1)
	assert_eq(chain_element_4.idx, 2)
	assert_eq(chain_element_1.global_rotation, Vector2.ONE.angle_to_point(Vector2.ZERO))
	assert_eq(chain_element_1._direction, -Vector2.ONE.normalized())
	assert_eq(chain_element_2.global_rotation, Vector2.ZERO.angle_to_point(Vector2(4, 3)))
	assert_eq(chain_element_2._direction, Vector2(4, 3).normalized())
	assert_almost_eq(chain_element_4.global_rotation, -PI / 2.0, 0.001)
	assert_almost_eq(chain_element_4._direction, Vector2.UP, Vector2.ONE * 0.001)


##### UTILS #####
func mock_game_root():
	var root = add_child_autofree(
		load("res://test/unit/Weapons/Powerups/Chain/mock_game_root.tscn").instantiate()
	)
	return root


func mock_input_synchronizer():
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var input_synchronizer = autofree(load("res://Scenes/Player/input_synchronizer.gd").new())
	paths.input_synchronizer = input_synchronizer
	chain_manager.player_paths = paths
	return input_synchronizer
