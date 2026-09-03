extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var scene
var _sender = InputSender.new(Input)


##### SETUP #####
func before_each():
	scene = load(
		"res://test/integration/MovementBonus/MovementBonusDash/scene_movement_bonus_dash.tscn"
	).instantiate()
	add_child_autofree(scene)
	await wait_process_frames(1)


##### TEARDOWN #####
func after_each():
	_sender.release_all()
	_sender.clear()


##### TESTS #####
func test_dash():
	# given
	scene.set_player_config(
		_create_player_config_with_movement(StaticMovementBonusHandler.handlers.DASH)
	)
	var player = load("res://Scenes/Player/player.tscn").instantiate()
	scene.add_player(player)
	await wait_seconds(1.0)
	scene.disable_truce()
	# when / then
	_sender.action_down("jump").hold_for("3f").wait("10f")
	await _sender.idle
	_sender \
			.action_down("right") \
			.action_down("up") \
			.action_down("movement_bonus") \
			.hold_for("3f") \
			.wait("10f")
	await _sender.idle
	assert_gt(player.velocity.x, 0)
	assert_lt(player.velocity.y, 0)
	_sender.release_all()
	await wait_seconds(0.25)
	_sender.action_down("left").action_down("up").action_down("movement_bonus").hold_for("3f").wait(
		"10f"
	)
	await _sender.idle
	assert_lt(player.velocity.x, 0)
	assert_lt(player.velocity.y, 0)
	_sender.release_all()
	await wait_seconds(0.25)
	_sender \
			.action_down("right") \
			.action_down("down") \
			.action_down("movement_bonus") \
			.hold_for("3f") \
			.wait("10f")
	await _sender.idle
	assert_gt(player.velocity.x, 0)
	assert_gt(player.velocity.y, 0)
	_sender.release_all()
	# this one should not trigger ( waiting for the cooldown)
	await wait_seconds(0.1)
	_sender.action_down("movement_bonus").action_down("up").hold_for("3f").wait("10f")
	await _sender.idle
	assert_gte(player.velocity.y, 0)
	_sender.release_all()
	# after the cooldown, should activate again
	await wait_seconds(2.0)
	_sender.action_down("movement_bonus").action_down("up").hold_for("3f").wait("10f")
	await _sender.idle
	assert_lt(player.velocity.y, 0)
	# cleanup
	player.free()


##### UTILS #####
func _create_player_config_with_movement(
	movement_bonus: StaticMovementBonusHandler.handlers
) -> PlayerConfig:
	var player_config = load("res://test/integration/Common/default_player_config.tres")
	player_config.MOVEMENT_BONUS_HANDLER = movement_bonus
	return player_config
