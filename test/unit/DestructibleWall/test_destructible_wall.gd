extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var destructible_wall
var explode_fragments_triggered := false
var explode_fragments_args := []


##### SETUP #####
func before_each():
	destructible_wall = load("res://Scenes/DestructibleWalls/destructible_wall.gd").new()
	explode_fragments_triggered = false
	explode_fragments_args = []


func after_each():
	destructible_wall.free()


##### TESTS #####
func test_init_node():
	# given
	var mock_destructible_wall = partial_double(load("res://Scenes/DestructibleWalls/destructible_wall.gd")).new()
	stub(mock_destructible_wall, "_add_particles").to_do_nothing()
	var mock_health_manager = _mock_health_manager()
	mock_destructible_wall.onready_paths.health_manager = mock_health_manager
	var mock_collision_manager = _mock_collision_manager()
	mock_destructible_wall.onready_paths.collision_manager = mock_collision_manager
	var mock_visual_effects_manager = _mock_visual_effects_manager()
	mock_destructible_wall.onready_paths.visual_effects_manager = mock_visual_effects_manager
	stub(mock_health_manager, "init").to_do_nothing()
	stub(mock_collision_manager, "init").to_do_nothing()
	stub(mock_visual_effects_manager, "init").to_do_nothing()
	stub(mock_visual_effects_manager, "play_spawn_animation").to_do_nothing()
	# when
	mock_destructible_wall._init_node()
	# then
	assert_called(mock_health_manager, "init", [mock_destructible_wall.BASE_HEALTH])
	assert_called(mock_collision_manager, "init", [mock_destructible_wall.BOUNCE_BACK_DIRECTION])
	assert_called(mock_visual_effects_manager, "init", [mock_destructible_wall.BOUNCE_BACK_DIRECTION])
	assert_called(mock_visual_effects_manager, "play_spawn_animation")
	assert_true(mock_destructible_wall.visible)
	assert_true(mock_destructible_wall.collision_enabled)


func test_add_particles():
	# given
	var parent = Node.new()
	var mock_destructible_wall = partial_double(load("res://Scenes/DestructibleWalls/destructible_wall.tscn")).instantiate()
	stub(mock_destructible_wall, "_init_node").to_do_nothing()
	parent.add_child(mock_destructible_wall)
	# when
	mock_destructible_wall._add_particles()
	await wait_process_frames(1)
	# then
	assert_eq(parent.get_child_count(), 2)
	# cleanup
	parent.free()


var test_get_collision_params := [
	[true],
	[false],
]


func test_get_collision_enabled(params = use_parameters(test_get_collision_params)):
	# given
	destructible_wall.collision_enabled = params[0]
	# when
	var result = destructible_wall.get_collision_enabled()
	# then
	assert_eq(result, params[0])


var test_get_damage_params := [
	[Vector2.RIGHT, Vector2(-500, 200), 500.0],
	[Vector2.UP, Vector2(100, -800), 800.0],
]


func test_get_damage(params = use_parameters(test_get_damage_params)):
	# given
	destructible_wall.BOUNCE_BACK_DIRECTION = params[0]
	var velocity = params[1]
	# when
	var damage = destructible_wall._get_damage(velocity)
	# then
	assert_eq(damage, params[2])


var test_toggle_activated_params := [
	[true],
	[false],
]


func test_toggle_activated(params = use_parameters(test_toggle_activated_params)):
	# given
	var mock_collision_manager = _mock_collision_manager()
	stub(mock_collision_manager, "set_active").to_do_nothing()
	# when
	destructible_wall._toggle_activated(params[0])
	# then
	assert_eq(destructible_wall.visible, params[0])
	assert_eq(destructible_wall.collision_enabled, params[0])
	assert_called(mock_collision_manager, "set_active", [params[0]])


func test_on_area_entered():
	# given
	var mock_projectile = Area2D.new()
	mock_projectile.add_to_group("projectile")
	add_child(mock_projectile)
	# when
	destructible_wall._on_area_entered(mock_projectile)
	# then
	await wait_frames(1)
	assert_freed(mock_projectile)


func test_on_health_manager_health_changed():
	# given
	var new_health = 3000.0
	var old_health = 4000.0
	var mock_visual_effects_manager = _mock_visual_effects_manager()
	stub(mock_visual_effects_manager, "update_visuals_tween").to_do_nothing()
	# when
	destructible_wall._on_health_manager_health_changed(new_health, old_health)
	# then
	assert_called(mock_visual_effects_manager, "update_visuals_tween", [new_health, old_health, destructible_wall.BASE_HEALTH])


func test_on_health_manager_health_empty():
	# given
	var mock_audio_manager = _mock_audio_manager()
	var mock_respawn_manager = _mock_respawn_manager()
	var mock_collision_manager = _mock_collision_manager()
	var mock_visual_effects_manager = _mock_visual_effects_manager()
	stub(mock_audio_manager, "play_break").to_do_nothing()
	stub(mock_respawn_manager, "start_respawn_timer").to_do_nothing()
	stub(mock_respawn_manager, "enable_respawn_detection").to_do_nothing()
	stub(mock_collision_manager, "get_latest_hit_velocity").to_return(Vector2(-300, 0))
	stub(mock_visual_effects_manager, "play_break_animation").to_do_nothing()
	destructible_wall.connect("explode_fragments", _on_explode_fragments)
	# when
	destructible_wall._on_health_manager_health_empty()
	# then
	assert_called(mock_audio_manager, "play_break")
	assert_called(mock_respawn_manager, "start_respawn_timer")
	assert_called(mock_visual_effects_manager, "play_break_animation")
	assert_called(mock_respawn_manager, "enable_respawn_detection", [true])
	assert_false(destructible_wall.visible)
	assert_false(destructible_wall.collision_enabled)
	assert_true(explode_fragments_triggered)
	assert_eq(explode_fragments_args, [Vector2(-300, 0)])


func test_on_collision_manager_player_hit_wall_not_destroyed():
	# given
	var mock_player = Node2D.new()
	var velocity = Vector2(-800, 0)
	var damage = 800.0
	var mock_health_manager = _mock_health_manager()
	var mock_player_interactions_manager = _mock_player_interactions_manager()
	stub(mock_health_manager, "apply_damage").to_do_nothing()
	stub(mock_health_manager, "is_destroyed").to_return(false)
	stub(mock_health_manager, "get_health_ratio").to_return(0.5)
	stub(mock_player_interactions_manager, "handle_player_hit").to_do_nothing()
	# when
	destructible_wall._on_collision_manager_player_hit(mock_player, velocity)
	# then
	assert_called(mock_health_manager, "apply_damage", [damage])
	assert_called(mock_health_manager, "is_destroyed")
	assert_called(mock_player_interactions_manager, "handle_player_hit", [mock_player, velocity, destructible_wall.BOUNCE_BACK_DIRECTION, destructible_wall.BOUNCE_BACK_FORCE])
	# cleanup
	mock_player.free()


func test_on_collision_manager_player_hit_wall_destroyed():
	# given
	var mock_player = autofree(Node2D.new())
	var velocity = Vector2(-800, 0)
	var damage = 800.0
	var mock_health_manager = _mock_health_manager()
	var mock_player_interactions_manager = _mock_player_interactions_manager()
	stub(mock_health_manager, "apply_damage").to_do_nothing()
	stub(mock_health_manager, "is_destroyed").to_return(true)
	stub(mock_player_interactions_manager, "kill_player").to_do_nothing()
	# when
	destructible_wall._on_collision_manager_player_hit(mock_player, velocity)
	# then
	assert_called(mock_health_manager, "apply_damage", [damage])
	assert_called(mock_health_manager, "is_destroyed")
	assert_called(mock_player_interactions_manager, "kill_player", [mock_player])


func test_on_respawn_manager_wall_respawned():
	# given
	var mock_health_manager = _mock_health_manager()
	var mock_visual_effects_manager = _mock_visual_effects_manager()
	var mock_respawn_manager = _mock_respawn_manager()
	var mock_collision_manager = _mock_collision_manager()
	stub(mock_health_manager, "apply_damage").to_do_nothing()
	stub(mock_visual_effects_manager, "update_visuals").to_do_nothing()
	stub(mock_visual_effects_manager, "play_spawn_animation").to_do_nothing()
	stub(mock_respawn_manager, "enable_respawn_detection").to_do_nothing()
	stub(mock_collision_manager, "set_active").to_do_nothing()
	# when
	destructible_wall._on_respawn_manager_wall_respawned()
	# then
	assert_called(mock_health_manager, "reset_health", [])
	assert_called(mock_visual_effects_manager, "update_visuals", [0.0])
	assert_called(mock_respawn_manager, "enable_respawn_detection", [false])
	assert_called(mock_visual_effects_manager, "play_spawn_animation")
	assert_true(destructible_wall.visible)
	assert_true(destructible_wall.collision_enabled)
	assert_called(mock_collision_manager, "set_active", [true])


##### UTILS #####
func _on_explode_fragments(force: Vector2) -> void:
	explode_fragments_triggered = true
	explode_fragments_args = [force]


func _mock_health_manager():
	var mock_health_manager = double(load("res://Scenes/DestructibleWalls/health_manager.gd")).new()
	destructible_wall.onready_paths["health_manager"] = mock_health_manager
	return mock_health_manager


func _mock_visual_effects_manager():
	var mock_visual_effects_manager = double(load("res://Scenes/DestructibleWalls/visual_effects_manager.gd")).new()
	destructible_wall.onready_paths["visual_effects_manager"] = mock_visual_effects_manager
	return mock_visual_effects_manager


func _mock_collision_manager():
	var mock_collision_manager = double(load("res://Scenes/DestructibleWalls/collision_manager.gd")).new()
	destructible_wall.onready_paths["collision_manager"] = mock_collision_manager
	return mock_collision_manager


func _mock_audio_manager():
	var mock_audio_manager = double(load("res://Scenes/DestructibleWalls/audio_manager.gd")).new()
	destructible_wall.onready_paths["audio_manager"] = mock_audio_manager
	return mock_audio_manager


func _mock_respawn_manager():
	var mock_respawn_manager = double(load("res://Scenes/DestructibleWalls/respawn_manager.gd")).new()
	destructible_wall.onready_paths["respawn_manager"] = mock_respawn_manager
	return mock_respawn_manager


func _mock_player_interactions_manager():
	var mock_player_interactions_manager = double(load("res://Scenes/DestructibleWalls/player_interactions_manager.gd")).new()
	destructible_wall.onready_paths["player_interactions_manager"] = mock_player_interactions_manager
	return mock_player_interactions_manager
