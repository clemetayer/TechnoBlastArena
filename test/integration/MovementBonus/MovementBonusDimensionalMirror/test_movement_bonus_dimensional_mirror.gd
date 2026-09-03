extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const SCENE_TEST_FLOORS := "res://test/integration/MovementBonus/MovementBonusDimensionalMirror/scene_movement_bonus_dimensional_mirror_floors.tscn"
const SCENE_TEST_WALLS := "res://test/integration/MovementBonus/MovementBonusDimensionalMirror/scene_movement_bonus_dimensional_mirror_walls.tscn"
const SCENE_TEST_DESTRUCTIBLE_WALLS := "res://test/integration/MovementBonus/MovementBonusDimensionalMirror/scene_movement_bonus_dimensional_mirror_destructible_walls.tscn"
const SCENE_TEST_NO_CEILING := "res://test/integration/MovementBonus/MovementBonusDimensionalMirror/scene_movement_bonus_dimensional_mirror_floor_only.tscn"

#---- VARIABLES -----
var _sender = InputSender.new(Input)


##### TEARDOWN #####
func after_each():
	_sender.release_all()
	_sender.clear()


##### TESTS #####
func test_activate_on_floor():
	# given
	var scene = add_child_autofree(load(SCENE_TEST_FLOORS).instantiate())
	scene.add_to_group(RuntimeUtils.GAME_ROOT_GROUP_NAME)
	scene.set_player_config(
		_create_player_config_with_movement(StaticMovementBonusHandler.handlers.DIMENSIONAL_MIRROR)
	)
	var player = load("res://Scenes/Player/player.tscn").instantiate()
	scene.add_player(player)
	await wait_seconds(0.5)
	scene.disable_truce()
	var base_position = player.global_position
	# when
	_sender.action_down("movement_bonus").hold_for("10f")
	await wait_seconds(0.25)
	# then
	assert_lt(player.global_position.y, base_position.y)


func test_activate_on_wall():
	# given
	var scene = add_child_autofree(load(SCENE_TEST_WALLS).instantiate())
	scene.add_to_group(RuntimeUtils.GAME_ROOT_GROUP_NAME)
	scene.set_player_config(
		_create_player_config_with_movement(StaticMovementBonusHandler.handlers.DIMENSIONAL_MIRROR)
	)
	var player = load("res://Scenes/Player/player.tscn").instantiate()
	scene.add_player(player)
	await wait_seconds(0.5)
	scene.disable_truce()
	var base_position = player.global_position
	# when
	_sender.action_down("jump").action_down("left").hold_for("10f")
	await _sender.idle
	_sender.action_down("left").action_down("movement_bonus").hold_for("10f")
	await wait_seconds(0.25)
	# then
	assert_gt(player.global_position.x, base_position.x)


func test_activate_on_destructible_wall():
	# given
	var scene = add_child_autofree(load(SCENE_TEST_DESTRUCTIBLE_WALLS).instantiate())
	scene.add_to_group(RuntimeUtils.GAME_ROOT_GROUP_NAME)
	scene.set_player_config(
		_create_player_config_with_movement(StaticMovementBonusHandler.handlers.DIMENSIONAL_MIRROR)
	)
	var player = load("res://Scenes/Player/player.tscn").instantiate()
	scene.add_player(player)
	await wait_seconds(2.0)
	scene.disable_truce()
	var base_position = player.global_position
	# when
	_sender.action_down("jump").action_down("left").hold_for("10f")
	await _sender.idle
	_sender.action_down("left").action_down("movement_bonus").hold_for("10f")
	await wait_seconds(0.25)
	# then
	assert_gt(player.global_position.x, base_position.x)


func test_activate_floor_no_ceiling():
	# given
	var scene = add_child_autofree(load(SCENE_TEST_NO_CEILING).instantiate())
	scene.add_to_group(RuntimeUtils.GAME_ROOT_GROUP_NAME)
	scene.set_player_config(
		_create_player_config_with_movement(StaticMovementBonusHandler.handlers.DIMENSIONAL_MIRROR)
	)
	var player = load("res://Scenes/Player/player.tscn").instantiate()
	scene.add_player(player)
	await wait_seconds(1.0)
	scene.disable_truce()
	var base_position = player.global_position
	# when
	_sender.action_down("movement_bonus").hold_for("10f")
	await wait_seconds(0.25)
	# then
	assert_eq(player.global_position, base_position)


func test_activate_no_collision():
	# given
	var scene = add_child_autofree(load(SCENE_TEST_FLOORS).instantiate())
	scene.add_to_group(RuntimeUtils.GAME_ROOT_GROUP_NAME)
	scene.set_player_config(
		_create_player_config_with_movement(StaticMovementBonusHandler.handlers.DIMENSIONAL_MIRROR)
	)
	var player = load("res://Scenes/Player/player.tscn").instantiate()
	scene.add_player(player)
	await wait_seconds(1.0)
	scene.disable_truce()
	var base_position = player.global_position
	# when
	_sender.action_down("jump").hold_for("3f")
	await _sender.idle
	_sender.action_down("movement_bonus").hold_for("10f")
	await wait_seconds(2.0)
	# then
	assert_almost_eq(player.global_position.y, base_position.y, 0.1)


##### UTILS #####
func _create_player_config_with_movement(
	movement_bonus: StaticMovementBonusHandler.handlers
) -> PlayerConfig:
	var player_config = load("res://test/integration/Common/default_player_config.tres")
	player_config.MOVEMENT_BONUS_HANDLER = movement_bonus
	return player_config
