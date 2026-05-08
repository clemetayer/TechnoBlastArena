extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const MOCK_GAME_ROOT_PATH := "res://test/unit/Player/test_player/mock_game_root.tscn"
var damage_received_times_called := 0
var damage_received_args := []
var last_hit_owner_changed_times_called := 0
var last_hit_owner_changed_args := []
var abilities_toggled_times_called := 0
var abilities_toggled_args := []

#---- VARIABLES -----
var player


##### SETUP #####
func before_each():
	player = load("res://Scenes/Player/player.gd").new()
	damage_received_times_called = 0
	damage_received_args = []
	last_hit_owner_changed_times_called = 0
	last_hit_owner_changed_args = []
	abilities_toggled_times_called = 0
	abilities_toggled_args = []


##### TEARDOWN #####
func after_each():
	player.free()


##### TESTS #####
func test_ready():
	# given
	var mock_player = partial_double(load("res://Scenes/Player/player.gd")).new()
	stub(mock_player, "_appear").to_do_nothing()
	var scene_utils = load("res://Utils/scene_utils.gd").new()
	mock_player._scene_utils = scene_utils
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	paths.name = "Paths"
	mock_player.add_child(paths, false, 0)
	var init = double(load("res://Scenes/Player/init.gd")).new()
	stub(init, "initialize").to_do_nothing()
	paths.init = init
	player.paths = paths
	var game_proxy = load("res://Scenes/Game/players.gd").new()
	var player_config = PlayerConfig.new()
	game_proxy._players_data = {
		1: {
			"config": player_config,
		},
	}
	game_proxy.add_child(mock_player)
	# when
	mock_player._ready()
	# then
	assert_called(init, "initialize", [player_config])
	assert_called(mock_player, "_appear")
	assert_true(scene_utils.is_connected("toggle_scene_freeze", mock_player._on_SceneUtils_toggle_scene_freeze))
	# cleanup
	scene_utils.free()
	paths.free()
	game_proxy.free()


func test_physics_process_frozen():
	# given
	var mock_player = partial_double(load("res://Scenes/Player/player.gd"), DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	mock_player._frozen = true
	stub(mock_player, "_predict_bounces").to_do_nothing()
	stub(mock_player, "move_and_slide").to_do_nothing()
	stub(mock_player, "_buffer_velocity").to_do_nothing()
	# when
	mock_player._physics_process(1.0 / 60.0)
	# then
	assert_not_called(mock_player, "_predict_bounces")
	assert_not_called(mock_player, "move_and_slide")
	assert_not_called(mock_player, "_buffer_velocity")


var physics_process_falling_params := [
	[Vector2.ZERO, false],
	[Vector2.RIGHT, false],
	[Vector2.ZERO, true],
]


func test_physics_process_falling(params = use_parameters(physics_process_falling_params)):
	# given
	var game_proxy = load("res://Scenes/Game/players.gd").new()
	var player_config = load("res://test/unit/Player/default_player_config.tres")
	game_proxy._players_data = {
		1: {
			"config": player_config,
		},
	}
	var mock_player = partial_double(load("res://Scenes/Player/player.gd"), DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	var paths_node = Node2D.new()
	paths_node.name = "Paths"
	mock_player.add_child(paths_node, false, 0)
	game_proxy.add_child(mock_player)
	stub(mock_player, "_ready").to_do_nothing()
	add_child_autofree(game_proxy)
	mock_player.velocity = Vector2.ZERO
	mock_player._frozen = false
	mock_player.direction = params[0]
	mock_player.jump_triggered = params[1]
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var hitstun_manager = load("res://Scenes/Player/hitstun_manager.gd").new()
	hitstun_manager.hitstunned = false
	paths.hitstun_manager = hitstun_manager
	mock_player.paths = paths
	stub(mock_player, "_is_on_floor").to_return(false)
	stub(mock_player, "_predict_bounces").to_do_nothing()
	stub(mock_player, "_buffer_velocity").to_do_nothing()
	var expected_velocity = Vector2.ZERO + Vector2.DOWN * ProjectSettings.get_setting("physics/2d/default_gravity") * mock_player.WEIGHT * 1.0 / 60.0 # falling velocity
	if params[0] != Vector2.ZERO:
		expected_velocity.x = move_toward(expected_velocity.x, params[0].x * mock_player.TARGET_SPEED, mock_player.AIR_ACCELERATION * 1.0 / 60.0)
	# when
	mock_player._physics_process(1.0 / 60.0)
	# then
	assert_eq(mock_player.velocity, expected_velocity)
	assert_not_called(mock_player, "_predict_bounces")
	assert_called(mock_player, "_buffer_velocity", [expected_velocity])
	# cleanup
	hitstun_manager.free()
	paths_node.free()


var physics_process_on_floor_params := [
	[Vector2.ZERO, Vector2.ZERO],
	[Vector2.LEFT, Vector2.ZERO],
	[Vector2.ZERO, Vector2.DOWN * 100],
]


func test_physics_process_on_floor(params = use_parameters(physics_process_on_floor_params)):
	# given
	var game_proxy = load("res://Scenes/Game/players.gd").new()
	var player_config = load("res://test/unit/Player/default_player_config.tres")
	game_proxy._players_data = {
		1: {
			"config": player_config,
		},
	}
	var mock_player = partial_double(load("res://Scenes/Player/player.gd"), DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	var paths_node = Node2D.new()
	paths_node.name = "Paths"
	mock_player.add_child(paths_node, false, 0)
	game_proxy.add_child(mock_player)
	stub(mock_player, "_ready").to_do_nothing()
	add_child_autofree(game_proxy)
	mock_player._frozen = false
	mock_player.direction = params[0]
	mock_player.velocity = params[1]
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var hitstun_manager = load("res://Scenes/Player/hitstun_manager.gd").new()
	hitstun_manager.hitstunned = false
	paths.hitstun_manager = hitstun_manager
	mock_player.paths = paths
	stub(mock_player, "_is_on_floor").to_return(true)
	stub(mock_player, "_predict_bounces").to_do_nothing()
	stub(mock_player, "_buffer_velocity").to_do_nothing()
	var expected_velocity = Vector2.ZERO
	expected_velocity.x = move_toward(params[1].x, params[0].x * mock_player.TARGET_SPEED, mock_player.FLOOR_ACCELERATION * 1.0 / 60.0)
	# when
	mock_player._physics_process(1.0 / 60.0)
	# then
	assert_eq(mock_player.velocity, expected_velocity)
	assert_not_called(mock_player, "_predict_bounces")
	assert_called(mock_player, "_buffer_velocity", [expected_velocity])
	# cleanup
	hitstun_manager.free()
	paths_node.free()


func test_physics_process_jumping():
	# given
	var game_proxy = load("res://Scenes/Game/players.gd").new()
	var player_config = load("res://test/unit/Player/default_player_config.tres")
	game_proxy._players_data = {
		1: {
			"config": player_config,
		},
	}
	var mock_player = partial_double(load("res://Scenes/Player/player.gd"), DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	var paths_node = Node2D.new()
	paths_node.name = "Paths"
	mock_player.add_child(paths_node, false, 0)
	game_proxy.add_child(mock_player)
	stub(mock_player, "_ready").to_do_nothing()
	add_child_autofree(game_proxy)
	mock_player.velocity = Vector2.ZERO
	mock_player._frozen = false
	mock_player.direction = Vector2.ZERO
	mock_player.jump_triggered = true
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var hitstun_manager = load("res://Scenes/Player/hitstun_manager.gd").new()
	hitstun_manager.hitstunned = false
	paths.hitstun_manager = hitstun_manager
	mock_player.paths = paths
	stub(mock_player, "_is_on_floor").to_return(true)
	stub(mock_player, "_predict_bounces").to_do_nothing()
	stub(mock_player, "_buffer_velocity").to_do_nothing()
	var expected_velocity = Vector2.ZERO
	expected_velocity.y = mock_player.JUMP_VELOCITY
	# when
	mock_player._physics_process(1.0 / 60.0)
	# then
	assert_eq(mock_player.velocity, expected_velocity)
	assert_not_called(mock_player, "_predict_bounces")
	assert_called(mock_player, "_buffer_velocity", [expected_velocity])
	# cleanup
	hitstun_manager.free()
	paths_node.free()


func test_physics_process_hitstunned():
	# given
	var game_proxy = load("res://Scenes/Game/players.gd").new()
	var player_config = load("res://test/unit/Player/default_player_config.tres")
	game_proxy._players_data = {
		1: {
			"config": player_config,
		},
	}
	var mock_player = partial_double(load("res://Scenes/Player/player.gd"), DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	var paths_node = Node2D.new()
	paths_node.name = "Paths"
	mock_player.add_child(paths_node, false, 0)
	game_proxy.add_child(mock_player)
	stub(mock_player, "_ready").to_do_nothing()
	add_child_autofree(game_proxy)
	mock_player.velocity = Vector2.RIGHT
	mock_player._frozen = false
	mock_player.direction = Vector2.ZERO
	mock_player.jump_triggered = false
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var hitstun_manager = load("res://Scenes/Player/hitstun_manager.gd").new()
	hitstun_manager.hitstunned = true
	paths.hitstun_manager = hitstun_manager
	mock_player.paths = paths
	stub(mock_player, "_is_on_floor").to_return(true)
	stub(mock_player, "_get_collisions_normal").to_return(Vector2.LEFT)
	stub(mock_player, "_predict_bounces").to_do_nothing()
	stub(mock_player, "_buffer_velocity").to_do_nothing()
	var expected_velocity = Vector2.ZERO
	expected_velocity.x = move_toward(Vector2.RIGHT.x, 0.0, mock_player.FLOOR_ACCELERATION * 1.0 / 60.0) # when
	expected_velocity.bounce(Vector2.LEFT)
	mock_player._physics_process(1.0 / 60.0)
	# then
	assert_eq(mock_player.velocity, expected_velocity)
	assert_called(mock_player, "_predict_bounces")
	assert_called(mock_player, "_buffer_velocity", [expected_velocity])
	# cleanup
	hitstun_manager.free()
	paths_node.free()


func test_physics_process_freeze_buffer_velocity():
	# given
	var game_proxy = load("res://Scenes/Game/players.gd").new()
	var player_config = load("res://test/unit/Player/default_player_config.tres")
	game_proxy._players_data = {
		1: {
			"config": player_config,
		},
	}
	var mock_player = partial_double(load("res://Scenes/Player/player.gd"), DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	var paths_node = Node2D.new()
	paths_node.name = "Paths"
	mock_player.add_child(paths_node, false, 0)
	game_proxy.add_child(mock_player)
	stub(mock_player, "_ready").to_do_nothing()
	add_child_autofree(game_proxy)
	mock_player.velocity = Vector2.RIGHT
	mock_player._frozen = false
	mock_player.direction = Vector2.ZERO
	mock_player.jump_triggered = false
	mock_player._freeze_buffer_velocity = Vector2.LEFT
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var hitstun_manager = load("res://Scenes/Player/hitstun_manager.gd").new()
	hitstun_manager.hitstunned = false
	paths.hitstun_manager = hitstun_manager
	mock_player.paths = paths
	stub(mock_player, "_is_on_floor").to_return(true)
	stub(mock_player, "_get_collisions_normal").to_return(Vector2.LEFT)
	stub(mock_player, "_predict_bounces").to_do_nothing()
	stub(mock_player, "_buffer_velocity").to_do_nothing()
	var expected_velocity = Vector2.ZERO
	expected_velocity.x = move_toward(Vector2.LEFT.x, 0.0, mock_player.FLOOR_ACCELERATION * 1.0 / 60.0) # when
	mock_player._physics_process(1.0 / 60.0)
	# then
	assert_eq(mock_player.velocity, expected_velocity)
	assert_not_called(mock_player, "_predict_bounces")
	assert_called(mock_player, "_buffer_velocity", [expected_velocity])
	assert_eq(mock_player._freeze_buffer_velocity, Vector2.ZERO)
	# cleanup
	hitstun_manager.free()
	paths_node.free()


func test_physics_process_override_velocity():
	# given
	var game_proxy = load("res://Scenes/Game/players.gd").new()
	var player_config = load("res://test/unit/Player/default_player_config.tres")
	game_proxy._players_data = {
		1: {
			"config": player_config,
		},
	}
	var mock_player = partial_double(load("res://Scenes/Player/player.gd"), DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	var paths_node = Node2D.new()
	paths_node.name = "Paths"
	mock_player.add_child(paths_node, false, 0)
	game_proxy.add_child(mock_player)
	stub(mock_player, "_ready").to_do_nothing()
	add_child_autofree(game_proxy)
	mock_player.velocity = Vector2.RIGHT
	mock_player._frozen = false
	mock_player.direction = Vector2.ZERO
	mock_player.jump_triggered = false
	mock_player._velocity_override = Vector2.LEFT
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var hitstun_manager = load("res://Scenes/Player/hitstun_manager.gd").new()
	hitstun_manager.hitstunned = false
	paths.hitstun_manager = hitstun_manager
	mock_player.paths = paths
	stub(mock_player, "_is_on_floor").to_return(true)
	stub(mock_player, "_get_collisions_normal").to_return(Vector2.LEFT)
	stub(mock_player, "_predict_bounces").to_do_nothing()
	stub(mock_player, "_buffer_velocity").to_do_nothing()
	var expected_velocity = Vector2.ZERO
	expected_velocity.x = move_toward(Vector2.LEFT.x, 0.0, mock_player.FLOOR_ACCELERATION * 1.0 / 60.0) # when
	mock_player._physics_process(1.0 / 60.0)
	# then
	assert_eq(mock_player.velocity, expected_velocity)
	assert_not_called(mock_player, "_predict_bounces")
	assert_called(mock_player, "_buffer_velocity", [expected_velocity])
	assert_eq(mock_player._velocity_override, Vector2.ZERO)
	# cleanup
	hitstun_manager.free()
	paths_node.free()


func test_add_velocity():
	# given
	var game_proxy = load("res://Scenes/Game/players.gd").new()
	var player_config = load("res://test/unit/Player/default_player_config.tres")
	game_proxy._players_data = {
		1: {
			"config": player_config,
		},
	}
	var mock_player = partial_double(load("res://Scenes/Player/player.gd"), DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	var paths_node = Node2D.new()
	paths_node.name = "Paths"
	mock_player.add_child(paths_node, false, 0)
	game_proxy.add_child(mock_player)
	stub(mock_player, "_ready").to_do_nothing()
	add_child_autofree(game_proxy)
	mock_player.velocity = Vector2.LEFT
	mock_player._frozen = false
	mock_player.direction = Vector2.ZERO
	mock_player.jump_triggered = false
	mock_player._additional_vector = Vector2.LEFT
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var hitstun_manager = load("res://Scenes/Player/hitstun_manager.gd").new()
	hitstun_manager.hitstunned = false
	paths.hitstun_manager = hitstun_manager
	mock_player.paths = paths
	stub(mock_player, "_is_on_floor").to_return(true)
	stub(mock_player, "_get_collisions_normal").to_return(Vector2.LEFT)
	stub(mock_player, "_predict_bounces").to_do_nothing()
	stub(mock_player, "_buffer_velocity").to_do_nothing()
	var expected_velocity = Vector2.ZERO
	expected_velocity.x = move_toward(Vector2.LEFT.x * 2.0, 0.0, mock_player.FLOOR_ACCELERATION * 1.0 / 60.0) # when
	mock_player._physics_process(1.0 / 60.0)
	# then
	assert_eq(mock_player.velocity, expected_velocity)
	assert_not_called(mock_player, "_predict_bounces")
	assert_called(mock_player, "_buffer_velocity", [expected_velocity])
	assert_eq(mock_player._additional_vector, Vector2.ZERO)
	# cleanup
	hitstun_manager.free()
	paths_node.free()


var hit_params := [
	[false, 400, 400],
	[true, 400, 900.0],
	[true, 600, 999.0],
]


func test_hit_no_shield(params = use_parameters(hit_params)):
	# given
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var shield = double(load("res://Scenes/Player/shield.gd")).new()
	stub(shield, "process_hit").to_return(Shield.HitResult.IGNORED)
	paths.shield = shield
	player.paths = paths
	player._damage_enabled = params[0]
	player.damage_received.connect(_on_damage_received)
	player.last_hit_owner_changed.connect(_on_last_hit_owner_changed)
	player.DAMAGE = params[1]
	var p_owner = Node2D.new()
	# when
	player.hit(PlayerHitData.new(Vector2.RIGHT, 500, p_owner))
	# then
	if params[0]:
		assert_eq(player._additional_vector, Vector2.RIGHT * params[2])
		assert_eq(player.DAMAGE, params[2])
		assert_eq(damage_received_times_called, 1)
		assert_eq(
			damage_received_args,
			[[params[1] * 1.0, params[2] * 1.0, Vector2.RIGHT * params[2]]],
		)
		assert_eq(last_hit_owner_changed_times_called, 1)
		assert_eq(last_hit_owner_changed_args, [[p_owner]])
	else:
		assert_eq(player._additional_vector, Vector2.ZERO)
		assert_eq(player.DAMAGE, params[2])
		assert_eq(damage_received_times_called, 0)
		assert_eq(last_hit_owner_changed_times_called, 0)
	# cleanup
	p_owner.free()


func test_hit_shielded():
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var shield = double(load("res://Scenes/Player/shield.gd")).new()
	stub(shield, "process_hit").to_return(Shield.HitResult.SHIELDED)
	paths.shield = shield
	player.paths = paths
	player._damage_enabled = true
	player.damage_received.connect(_on_damage_received)
	player.last_hit_owner_changed.connect(_on_last_hit_owner_changed)
	player.DAMAGE = 0
	var p_owner = Node2D.new()
	# when
	player.hit(PlayerHitData.new(Vector2.RIGHT, 500, p_owner))
	# then
	assert_eq(player._additional_vector, Vector2.ZERO)
	assert_eq(player.DAMAGE, 0)
	assert_eq(damage_received_times_called, 0)
	assert_eq(last_hit_owner_changed_times_called, 0)
	# cleanup
	p_owner.free()


func test_hit_parried():
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var shield = double(load("res://Scenes/Player/shield.gd")).new()
	stub(shield, "process_hit").to_return(Shield.HitResult.PARRIED)
	paths.shield = shield
	player.paths = paths
	player._damage_enabled = true
	player.damage_received.connect(_on_damage_received)
	player.last_hit_owner_changed.connect(_on_last_hit_owner_changed)
	player.DAMAGE = 0
	var p_owner = Node2D.new()
	# when
	player.hit(PlayerHitData.new(Vector2.RIGHT, 500, p_owner))
	# then
	assert_eq(player._additional_vector, Vector2.ZERO)
	assert_eq(player.DAMAGE, 0)
	assert_eq(damage_received_times_called, 0)
	assert_eq(last_hit_owner_changed_times_called, 0)
	# cleanup
	p_owner.free()


func test_hit_update_damage():
	# given
	var game_root = load(
		MOCK_GAME_ROOT_PATH,
	).instantiate()

	var player_scene = load("res://Scenes/Player/player.tscn").instantiate()
	game_root.add_child(player_scene)
	add_child_autofree(game_root)
	player_scene._damage_enabled = true
	await wait_process_frames(2)
	# when / then
	assert_eq(player_scene.paths.damage_label.text, "0")
	player_scene.hit(PlayerHitData.new(Vector2.ZERO, 100, null))
	await wait_process_frames(2)
	assert_true(player_scene.paths.damage_label.text.contains("[color=ffff33ff]100[/color]"))


func test_kill():
	# given
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var death_manager = double(load("res://Scenes/Player/death_manager.gd")).new()
	stub(death_manager, "kill")
	paths.death_manager = death_manager
	player.paths = paths
	# when
	player.kill()
	# then
	assert_called(death_manager, "kill")
	# cleanup
	paths.free()


func test_override_velocity():
	# given
	player._velocity_override = Vector2.RIGHT
	# when
	player.override_velocity(Vector2.RIGHT)
	# then
	assert_eq(player._velocity_override, 2 * Vector2.RIGHT)


var toggle_freeze_params := [
	[true],
	[false],
]


func test_toggle_freeze(params = use_parameters(toggle_freeze_params)): # note : set deferred not tested here
	# given
	player._truce_active = false
	player.velocity = Vector2.LEFT
	player.abilities_toggled.connect(_on_abilities_toggled)
	# when
	player.toggle_freeze(params[0])
	# then
	assert_eq(player._freeze_buffer_velocity, Vector2.LEFT)
	assert_eq(player._frozen, params[0])
	assert_eq(player._damage_enabled, not params[0])
	assert_eq(abilities_toggled_times_called, 1)
	assert_eq(abilities_toggled_args, [[not params[0]]])


var toggle_abilities_params := [
	[false, false],
	[true, false],
	[true, true],
]


func test_toggle_abilities(params = use_parameters(toggle_abilities_params)):
	# given
	player._truce_active = params[0]
	player.abilities_toggled.connect(_on_abilities_toggled)
	# when
	player.toggle_abilities(params[1])
	# then
	if params[0]:
		assert_eq(abilities_toggled_times_called, 0)
	else:
		assert_eq(abilities_toggled_times_called, 1)
		assert_eq(abilities_toggled_args, [[params[1]]])


var toggle_damage_params := [
	[true],
	[false],
]


func test_toggle_damage(params = use_parameters(toggle_damage_params)):
	# given
	# when
	player.toggle_damage(params[0])
	# then
	assert_eq(player._damage_enabled, params[0])


var toggle_truce_params := [
	[true],
	[false],
]


func test_toggle_truce(params = use_parameters(toggle_truce_params)):
	# given
	var mock_player = partial_double(load("res://Scenes/Player/player.gd")).new()
	stub(mock_player, "toggle_abilities").to_do_nothing()
	# when
	mock_player.toggle_truce(params[0])
	# then
	assert_called(mock_player, "toggle_abilities", [not params[0]])
	assert_eq(mock_player._truce_active, params[0])


func test_get_config():
	# given
	var proxy = double(load("res://Scenes/Game/players.gd")).new()
	proxy.add_child(player, false, 0)
	var player_config = PlayerConfig.new()
	stub(proxy, "get_player_config").to_return(player_config)
	# when
	var res = player.get_config()
	# then
	assert_eq(res, player_config)


func test_get_velocity_buffer():
	# given
	player._velocity_buffer = [Vector2.RIGHT]
	# when
	var res = player.get_velocity_buffer()
	# then
	assert_eq(res, [Vector2.RIGHT])


func test_get_direction():
	# given
	player.direction = Vector2.LEFT
	# when
	var res = player.get_direction()
	# then
	assert_eq(res, Vector2.LEFT)


func test_appear():
	# given
	var mock_player = partial_double(load("res://Scenes/Player/player.gd")).new()
	stub(mock_player, "toggle_freeze").to_do_nothing()
	stub(mock_player, "toggle_abilities").to_do_nothing()
	stub(mock_player, "toggle_damage").to_do_nothing()
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var appear_elements = double(load("res://Scenes/Player/appear_elements.gd")).new()
	stub(appear_elements, "play_spawn_animation").to_do_nothing()
	paths.appear_elements = appear_elements
	mock_player.paths = paths
	# when
	mock_player._appear()
	# then
	assert_called(mock_player, "toggle_freeze", [true])
	assert_called(mock_player, "toggle_abilities", [false])
	assert_called(mock_player, "toggle_damage", [false])
	assert_called(appear_elements, "play_spawn_animation")
	# cleanup
	paths.free()


func test_buffer_velocity():
	# given
	player._velocity_buffer = [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	# when
	player._buffer_velocity(Vector2.UP)
	# then
	assert_eq(player._velocity_buffer, [Vector2.UP, Vector2.DOWN, Vector2.LEFT])

# weirdly, _get_collisions_normal can't really be tested, even with a partial double including native methods, get_slide_count still returns 0.

var on_SceneUtils_toggle_scene_freeze_params := [
	[true],
	[false],
]


func test_on_SceneUtils_toggle_scene_freeze(params = use_parameters(on_SceneUtils_toggle_scene_freeze_params)):
	# given
	var mock_player = partial_double(load("res://Scenes/Player/player.gd")).new()
	stub(mock_player, "toggle_freeze").to_do_nothing()
	# when
	mock_player._on_SceneUtils_toggle_scene_freeze(params[0])
	# then
	assert_called(mock_player, "toggle_freeze", [params[0]])


func test_on_appear_elements_appear_animation_finished():
	# given
	var mock_player = partial_double(load("res://Scenes/Player/player.gd")).new()
	stub(mock_player, "toggle_freeze").to_do_nothing()
	stub(mock_player, "toggle_abilities").to_do_nothing()
	stub(mock_player, "toggle_damage").to_do_nothing()
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	var appear_elements = load("res://Scenes/Player/appear_elements.gd").new()
	paths.appear_elements = appear_elements
	mock_player.paths = paths
	# when
	mock_player._on_appear_elements_appear_animation_finished()
	# then
	assert_called(mock_player, "toggle_freeze", [false])
	assert_called(mock_player, "toggle_abilities", [true])
	assert_called(mock_player, "toggle_damage", [true])
	# cleanup
	appear_elements.free()
	paths.free()


##### UTILS #####
func _on_damage_received(old_damage: float, new_damage: float, knockback: Vector2) -> void:
	damage_received_times_called += 1
	damage_received_args.append([old_damage, new_damage, knockback])


func _on_last_hit_owner_changed(new_owner: Node2D) -> void:
	last_hit_owner_changed_times_called += 1
	last_hit_owner_changed_args.append([new_owner])


func _on_abilities_toggled(active: bool) -> void:
	abilities_toggled_times_called += 1
	abilities_toggled_args.append([active])
