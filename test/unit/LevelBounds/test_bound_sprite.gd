extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var sprite: Sprite2D


##### SETUP #####
func before_each():
	sprite = autofree(load("res://Scenes/LevelBounds/bound_sprite.gd").new())


##### TESTS #####
func test_ready_with_shape():
	# given
	var mock_sprite = partial_double(load("res://Scenes/LevelBounds/bound_sprite.gd")).new()
	var shape = CollisionShape2D.new()
	stub(mock_sprite, "_get_collision_shape").to_return(shape)
	stub(mock_sprite, "_set_scale_with_shape").to_do_nothing()
	# when
	mock_sprite._ready()
	# then
	assert_called(mock_sprite, "_get_collision_shape")
	assert_called(mock_sprite, "_set_scale_with_shape", [shape])
	# cleanup
	shape.free()


func test_process():
	# given
	var mock_sprite = partial_double(load("res://Scenes/LevelBounds/bound_sprite.gd")).new()
	var positions = [Vector2.ONE, Vector2.RIGHT]
	stub(mock_sprite, "_get_players_positions").to_return(positions)
	stub(mock_sprite, "_set_shader_players_positions").to_do_nothing()
	# when
	mock_sprite._process(1.0 / 60.0)
	# then
	assert_called(mock_sprite, "_get_players_positions")
	assert_called(mock_sprite, "_set_shader_players_positions", [positions])


func test_get_collision_shape_ok():
	# given
	var parent = autofree(load("res://test/unit/LevelBounds/level_bounds_stub.tscn").instantiate())
	var shape = autofree(CollisionShape2D.new())
	parent.add_child(shape)
	parent.add_child(sprite)
	# when
	var res = sprite._get_collision_shape()
	# then
	assert_eq(res, shape)


func test_get_collision_shape_ko():
	# given
	var parent = autofree(load("res://test/unit/LevelBounds/level_bounds_stub.tscn").instantiate())
	parent.add_child(sprite)
	# when
	var res = sprite._get_collision_shape()
	# then
	assert_null(res)


func test_get_players_positions():
	# given
	var mock_sprite = partial_double(load("res://Scenes/LevelBounds/bound_sprite.gd")).new()
	var player_1 = Node2D.new()
	var player_2 = Node2D.new()
	add_child_autofree(player_1)
	add_child_autofree(player_2)
	player_1.global_position = Vector2.RIGHT
	player_2.global_position = Vector2.LEFT
	var players = [player_1, player_2]
	stub(mock_sprite, "_get_players").to_return(players)
	# when
	var res = mock_sprite._get_players_positions()
	# then
	assert_eq(res, [Vector2.RIGHT, Vector2.LEFT])


func test_get_players_positions_no_players():
	# given
	var mock_sprite = partial_double(load("res://Scenes/LevelBounds/bound_sprite.gd")).new()
	stub(mock_sprite, "_get_players").to_return([])
	# when
	var res = mock_sprite._get_players_positions()
	# then
	assert_eq(res, [])


var set_scale_with_shape_params := [
	[Vector2.ONE],
	[4.0 * Vector2.ONE],
]


func test_set_scale_with_shape(params = use_parameters(set_scale_with_shape_params)):
	# given
	var shape_size = params[0]
	var expected_scale = shape_size * 2.0 / sprite.BASE_TEXTURE_SIZE
	sprite.free()
	sprite = autofree(load("res://Scenes/LevelBounds/bound_sprite.tscn").instantiate())
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = shape_size
	collision_shape.shape = shape
	# when
	sprite._set_scale_with_shape(collision_shape)
	# then
	assert_eq(sprite.scale, expected_scale)
	assert_eq(sprite.material.get_shader_parameter(sprite.SHADER_PARAM_SPRITE_SCALE_NAME), expected_scale)


func test_set_shader_players_positions():
	# given
	var positions = [
		5.0 * Vector2.ONE,
	]
	var expected_uv_positions = []
	expected_uv_positions.resize(8)
	expected_uv_positions.fill(sprite.DEFAULT_PLAYER_UV_POSITION)
	expected_uv_positions[0] = (5.0 * Vector2.ONE - (-5120.0 * Vector2.ONE)) / 10240.0
	sprite.free()
	sprite = autofree(load("res://Scenes/LevelBounds/bound_sprite.tscn").instantiate())
	sprite.scale = Vector2.ONE * 10.0
	# when
	sprite._set_shader_players_positions(positions)
	# then
	var shader_uv_positions = sprite.material.get_shader_parameter(sprite.SHADER_PARAM_PLAYERS_POSITIONS_NAME)
	assert_eq(shader_uv_positions.size(), expected_uv_positions.size())
	for position_idx in range(0, shader_uv_positions.size()):
		assert_almost_eq(shader_uv_positions[position_idx].x, expected_uv_positions[position_idx].x, 0.01)
		assert_almost_eq(shader_uv_positions[position_idx].y, expected_uv_positions[position_idx].y, 0.01)


var convert_to_shader_uv_position_params := [
	[Vector2.ZERO, Vector2.ONE, 2.0 * Vector2.RIGHT],
	[Vector2.ZERO, Vector2(2.0, 1.5), 3.0 * Vector2.ONE],
	[-5.0 * Vector2.ONE, Vector2.ONE, 2.0 * Vector2.ONE],
	[Vector2.ZERO, Vector2.ONE, 2048.0 * Vector2.RIGHT],
	[Vector2.ZERO, Vector2.ONE, 2048.0 * Vector2.UP],
]


func test_convert_to_shader_uv_position(params = use_parameters(convert_to_shader_uv_position_params)):
	# given
	var origin = params[0]
	var scale = params[1]
	var position = params[2]
	sprite.free()
	sprite = autofree(load("res://Scenes/LevelBounds/bound_sprite.tscn").instantiate())
	sprite.global_position = origin
	sprite.scale = scale
	# when
	var res = sprite._convert_to_shader_uv_position(position)
	# then
	var global_origin = origin - sprite.BASE_TEXTURE_SIZE * scale / sprite.BORDER_SCALE_MULTIPLIER
	var expected_uv_pos = (position - global_origin) / (sprite.BASE_TEXTURE_SIZE * scale)
	assert_almost_eq(res.x, expected_uv_pos.x, 0.01)
	assert_almost_eq(res.y, expected_uv_pos.y, 0.01)
