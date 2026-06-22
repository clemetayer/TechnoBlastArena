extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var particles


##### SETUP #####
func before_each():
	particles = load("res://Scenes/DestructibleWalls/particles.gd").new()


##### TEARDOWN #####
func after_each():
	particles.free()


##### TESTS #####
func test_update_size():
	# given
	var mock_tilemap = double(TileMap).new()
	var tilemap_rect = Rect2i(Vector2(10, 20), Vector2(30, 40))
	stub(mock_tilemap, "get_used_rect").to_return(tilemap_rect)
	particles.tilemap = mock_tilemap
	var particle1 = double(GPUParticles2D).new()
	var particle2 = double(GPUParticles2D).new()
	var mock_material1 = double(ParticleProcessMaterial).new()
	var mock_material2 = double(ParticleProcessMaterial).new()
	stub(particle1, "get_process_material").to_return(mock_material1)
	stub(particle2, "get_process_material").to_return(mock_material2)
	stub(mock_material1, "set_emission_box_extents").to_do_nothing()
	stub(mock_material2, "set_emission_box_extents").to_do_nothing()
	particles.onready_paths.sparks = [particle1, particle2]
	# when
	particles._update_size()
	# then
	var expected_position = tilemap_rect.position * 64 + tilemap_rect.size * 64 / 2
	var expected_extents = Vector3(tilemap_rect.size.x * 64 / 2.0, tilemap_rect.size.y * 64 / 2.0, 0)
	assert_eq(particles.position, Vector2(expected_position))
	assert_called(mock_material1, "set_emission_box_extents", [expected_extents])
	assert_called(mock_material2, "set_emission_box_extents", [expected_extents])


func test_set_color():
	# given
	var test_color = Color(0.5, 0.6, 0.7)
	# when
	particles.set_color(test_color)
	# then
	assert_eq(particles.modulate, test_color)


var test_toggle_emit_params := [
	[true],
	[false],
]


func test_toggle_emit_particles(params = use_parameters(test_toggle_emit_params)):
	# given
	var particle1 = GPUParticles2D.new()
	var particle2 = GPUParticles2D.new()
	particles.onready_paths.sparks = [particle1, particle2]
	# when
	particles.toggle_emit(params[0])
	# then
	assert_eq(particle1.emitting, params[0])
	assert_eq(particle2.emitting, params[0])
	# cleanup
	particle1.free()
	particle2.free()


func test_process_in_editor_calls_update_size():
	# given
	var mock_engine = double(load("res://test/unit/DestructibleWall/test_particles_mocks/engine_mock.gd")).new()
	stub(mock_engine, "is_editor_hint").to_return(true)
	particles._engine = mock_engine
	var mock_tilemap = double(TileMap).new()
	var tilemap_rect = Rect2i(Vector2(10, 20), Vector2(30, 40))
	stub(mock_tilemap, "get_used_rect").to_return(tilemap_rect)
	particles.tilemap = mock_tilemap
	var particle1 = double(GPUParticles2D).new()
	var particle2 = double(GPUParticles2D).new()
	var mock_material1 = double(ParticleProcessMaterial).new()
	var mock_material2 = double(ParticleProcessMaterial).new()
	stub(particle1, "get_process_material").to_return(mock_material1)
	stub(particle2, "get_process_material").to_return(mock_material2)
	stub(mock_material1, "set_emission_box_extents").to_do_nothing()
	stub(mock_material2, "set_emission_box_extents").to_do_nothing()
	particles.onready_paths.sparks = [particle1, particle2]
	# when
	particles._process(0.1)
	# then
	var expected_position = tilemap_rect.position * 64 + tilemap_rect.size * 64 / 2
	var expected_extents = Vector3(tilemap_rect.size.x * 64 / 2.0, tilemap_rect.size.y * 64 / 2.0, 0)
	assert_eq(particles.position, Vector2(expected_position))
	assert_called(mock_material1, "set_emission_box_extents", [expected_extents])
	assert_called(mock_material2, "set_emission_box_extents", [expected_extents])


func test_process_not_in_editor_does_not_calls_update_size():
	# given
	var mock_engine = double(load("res://test/unit/DestructibleWall/test_particles_mocks/engine_mock.gd")).new()
	stub(mock_engine, "is_editor_hint").to_return(false)
	particles._engine = mock_engine
	var mock_tilemap = double(TileMap).new()
	stub(mock_tilemap, "get_used_rect").to_do_nothing()
	particles.tilemap = mock_tilemap
	# when
	particles._process(0.1)
	# then
	assert_not_called(mock_tilemap, "get_used_rect")
