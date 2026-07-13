extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var moving_pattern


##### SETUP #####
func before_each():
	moving_pattern = load("res://Scenes/DestructibleWalls/moving_pattern.gd").new()


##### TEARDOWN #####
func after_each():
	moving_pattern.free()


##### TESTS #####
func test_update_size():
	# given
	var mock_tilemap = double(TileMap).new()
	var mock_material = ShaderMaterial.new()
	moving_pattern.material = mock_material
	var tilemap_rect = Rect2i(Vector2(10, 20), Vector2(30, 40))
	stub(mock_tilemap, "get_used_rect").to_return(tilemap_rect)
	moving_pattern.tilemap = mock_tilemap
	# when
	moving_pattern._update_size()
	# then
	assert_eq(moving_pattern.size, Vector2(tilemap_rect.size * 64))
	assert_eq(moving_pattern.position, Vector2(tilemap_rect.position * 64))
	assert_eq(moving_pattern.material.get_shader_parameter("fract_size"), tilemap_rect.size)


func test_process_in_editor_calls_update_size():
	# given
	var mock_engine = double(load("res://test/unit/DestructibleWall/test_moving_patterns_mocks/engine_mock.gd")).new()
	stub(mock_engine, "is_editor_hint").to_return(true)
	moving_pattern._engine = mock_engine
	var mock_tilemap = double(TileMap).new()
	var mock_material = ShaderMaterial.new()
	moving_pattern.material = mock_material
	var tilemap_rect = Rect2i(Vector2(10, 20), Vector2(30, 40))
	stub(mock_tilemap, "get_used_rect").to_return(tilemap_rect)
	moving_pattern.tilemap = mock_tilemap
	# when
	moving_pattern._process(0.1)
	# then
	assert_eq(moving_pattern.size, Vector2(tilemap_rect.size * 64))
	assert_eq(moving_pattern.position, Vector2(tilemap_rect.position * 64))


func test_process_not_in_editor_skips_update():
	# given
	var mock_engine = double(load("res://test/unit/DestructibleWall/test_moving_patterns_mocks/engine_mock.gd")).new()
	stub(mock_engine, "is_editor_hint").to_return(false)
	moving_pattern._engine = mock_engine
	var mock_tilemap = double(TileMap).new()
	stub(mock_tilemap, "get_used_rect").to_do_nothing()
	# when
	moving_pattern._process(0.1)
	# then
	assert_not_called(mock_tilemap, "get_used_rect")
