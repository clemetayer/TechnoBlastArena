extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var collision_manager
var player_hit_triggered := false
var player_hit_args := []


##### SETUP #####
func before_each():
	player_hit_triggered = false
	player_hit_args = []
	collision_manager = load("res://Scenes/DestructibleWalls/collision_manager.gd").new()


##### TEARDOWN #####
func after_each():
	collision_manager.free()


##### TESTS #####
func test_init():
	# given
	var bounce_direction = Vector2.LEFT
	# when
	collision_manager.init(bounce_direction)
	# then
	assert_eq(collision_manager._bounce_back_direction, bounce_direction)


var active_tests_params := [
	[true],
	[false],
]


func test_set_active(params = use_parameters(active_tests_params)):
	# given
	var mock_damage_area = double(Area2D).new()
	collision_manager.onready_paths.damage_wall_area = mock_damage_area
	stub(mock_damage_area, "set_deferred").to_do_nothing()
	# when
	collision_manager.set_active(params[0])
	# then
	assert_called(mock_damage_area, "set_deferred", ["monitoring", params[0]])
	assert_called(mock_damage_area, "set_deferred", ["monitorable", params[0]])


func test_get_latest_hit_velocity():
	# given
	var expected_velocity = Vector2(100, 200)
	collision_manager._latest_hit_velocity = expected_velocity
	# when
	var result = collision_manager.get_latest_hit_velocity()
	# then
	assert_eq(result, expected_velocity)


func test_get_max_velocity_in_buffer_x_direction():
	# given
	collision_manager._bounce_back_direction = Vector2.RIGHT
	var velocity_buffer = [
		Vector2(10, 50),
		Vector2(30, 20),
		Vector2(20, 100),
	]
	# when
	var result = collision_manager._get_max_velocity_in_buffer(velocity_buffer)
	# then
	assert_eq(result, Vector2(30, 20))


func test_get_max_velocity_in_buffer_y_direction():
	# given
	collision_manager._bounce_back_direction = Vector2.UP
	var velocity_buffer = [
		Vector2(10, 50),
		Vector2(30, 20),
		Vector2(20, 100),
	]
	# when
	var result = collision_manager._get_max_velocity_in_buffer(velocity_buffer)
	# then
	assert_eq(result, Vector2(20, 100))


# Note : due to limitations on the GUT framework, can't test the global position
func test_on_damage_wall_area_body_entered():
	# given
	collision_manager.onready_paths.destructible_wall = double(load("res://Scenes/DestructibleWalls/destructible_wall.gd")).new()
	stub(collision_manager.onready_paths.destructible_wall, "get_collision_enabled").to_return(true)
	var group_utils = double(load("res://test/unit/DestructibleWall/test_collision_manager/mock_group_utils.gd")).new()
	stub(group_utils, "is_player").to_return(true)
	collision_manager._group_utils = group_utils
	var mock_player = double(load("res://Scenes/Player/player.gd")).new()
	stub(mock_player, "get_velocity_buffer").to_return([Vector2(10, 20), Vector2(30, 40)])
	collision_manager.connect("player_hit", _on_collision_manager_player_hit)
	# when
	collision_manager._on_damage_wall_area_body_entered(mock_player)
	# then
	assert_eq(collision_manager._latest_hit_velocity, Vector2(30, 40))
	await wait_frames(1)
	assert_true(player_hit_triggered)
	assert_eq(player_hit_args, [mock_player, Vector2(30, 40)])


func test_on_damage_wall_area_body_entered_not_player():
	# given
	var mock_body = partial_double(load("res://Scenes/Player/player.gd"), DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	collision_manager.connect("player_hit", _on_collision_manager_player_hit)
	var group_utils = double(load("res://test/unit/DestructibleWall/test_collision_manager/mock_group_utils.gd")).new()
	stub(group_utils, "is_player").to_return(false)
	collision_manager._group_utils = group_utils
	# when
	collision_manager._on_damage_wall_area_body_entered(mock_body)
	# then
	await wait_frames(1)
	assert_false(player_hit_triggered)


func test_on_damage_wall_area_body_entered_collision_disabled():
	# given
	collision_manager.onready_paths.destructible_wall = double(load("res://Scenes/DestructibleWalls/destructible_wall.gd")).new()
	stub(collision_manager.onready_paths.destructible_wall, "get_collision_enabled").to_return(false)
	var mock_player = partial_double(load("res://Scenes/Player/player.gd"), DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	collision_manager.connect("player_hit", _on_collision_manager_player_hit)
	var group_utils = double(load("res://test/unit/DestructibleWall/test_collision_manager/mock_group_utils.gd")).new()
	stub(group_utils, "is_player").to_return(true)
	collision_manager._group_utils = group_utils
	# when
	collision_manager._on_damage_wall_area_body_entered(mock_player)
	# then
	await wait_frames(1)
	assert_false(player_hit_triggered)


func _on_collision_manager_player_hit(player: Node2D, velocity: Vector2):
	player_hit_triggered = true
	player_hit_args = [player, velocity]
