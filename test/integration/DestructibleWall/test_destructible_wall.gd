extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var scene
var _sender = InputSender.new(Input)


##### SETUP #####
func before_each():
	scene = load("res://test/integration/DestructibleWall/scene_destructible_wall.tscn").instantiate()
	add_child_autofree(scene)
	await wait_frames(1)
	await wait_seconds(0.25)


##### TEARDOWN #####
func after_each():
	_sender.release_all()
	_sender.clear()

##### TESTS #####
var hit_wall_not_destroyed_params := [
	["left", true],
	["left", false],
	["right", true],
]


func test_hit_wall_not_destroyed(params = use_parameters(hit_wall_not_destroyed_params)):
	# given
	var action = params[0]
	var jump = params[1]
	var wall_direction = scene.DIRECTION.RIGHT
	if action == "left":
		if jump:
			wall_direction = scene.DIRECTION.LEFT
		else:
			wall_direction = scene.DIRECTION.DOWN
	# when / then
	assert_true(scene.is_spawn_animation_playing(scene.DIRECTION.LEFT))
	assert_true(scene.is_spawn_animation_playing(scene.DIRECTION.DOWN))
	assert_true(scene.is_spawn_animation_playing(scene.DIRECTION.RIGHT))
	await wait_seconds(2)
	assert_false(scene.is_spawn_animation_playing(scene.DIRECTION.LEFT))
	assert_false(scene.is_spawn_animation_playing(scene.DIRECTION.DOWN))
	assert_false(scene.is_spawn_animation_playing(scene.DIRECTION.RIGHT))
	if jump:
		_sender.action_down(action).action_down("jump").hold_for(1.5)
		await (_sender.idle)
	else:
		_sender.action_down(action).hold_for(1.5)
		await (_sender.idle)
	var wall = scene.get_wall(wall_direction)
	assert_lt(wall.onready_paths.health_manager.HEALTH, wall.BASE_HEALTH)
	assert_true(scene.get_player()._movement_stopped)
	await wait_seconds(0.5)
	match wall_direction:
		scene.DIRECTION.LEFT:
			assert_gt(scene.get_player().velocity.x, 0.0)
		scene.DIRECTION.RIGHT:
			assert_lt(scene.get_player().velocity.x, 0.0)
		scene.DIRECTION.DOWN:
			assert_lt(scene.get_player().velocity.y, 0.0)


func test_hit_wall_destroyed(): # with wall respawn
	# given
	var wall_direction = scene.DIRECTION.LEFT
	await wait_seconds(2)
	scene.set_wall_life(wall_direction, 1)
	# when / then
	_sender.action_down("left").action_down("jump").hold_for(1.5)
	await (_sender.idle)
	var wall = scene.get_wall(wall_direction)
	await wait_seconds(1.0)
	assert_lte(wall.onready_paths.health_manager.HEALTH, 0.0)
	assert_false(scene.get_player().paths.sprites.visible) # queue_free does not work well with GUT, so we check other things.
	assert_eq(scene.get_player().collision_layer, 0)
	assert_eq(scene.get_player().collision_mask, 0)
	assert_false(wall.visible)
	assert_false(wall.collision_enabled)
	assert_false(wall.onready_paths.collision_manager.onready_paths.damage_wall_area.monitoring)
	assert_false(wall.onready_paths.collision_manager.onready_paths.damage_wall_area.monitorable)
	await wait_seconds(19.0)
	assert_true(scene.is_spawn_animation_playing(scene.DIRECTION.LEFT))
	await wait_seconds(2.0)
	assert_gte(wall.onready_paths.health_manager.HEALTH, 0.0)
	assert_true(wall.visible)
	assert_true(wall.collision_enabled)
	assert_true(wall.onready_paths.collision_manager.onready_paths.damage_wall_area.monitoring)
	assert_true(wall.onready_paths.collision_manager.onready_paths.damage_wall_area.monitorable)
