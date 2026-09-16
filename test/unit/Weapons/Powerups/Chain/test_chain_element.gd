extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var chain_element


##### SETUP #####
func before_each():
	chain_element = load("res://Scenes/Weapons/Powerups/Chain/chain_element.tscn").instantiate()

# TODO : mettre un délai où c'est actif et où ça
# peut rediriger tous les projectiles sans cramer d'utilisations


##### TESTS #####
func test_spawn():
	# given
	var root = mock_game_root()
	var direction = Vector2.ONE
	var spawn_position = Vector2(randf_range(-10, 10), randf_range(-10, 10))
	var idx = 0
	# when
	chain_element.spawn(direction, spawn_position, idx)
	await wait_process_frames(1)
	# then
	assert_eq(root.get_child_count(), 1)
	assert_almost_eq(chain_element.global_rotation, Vector2.ZERO.angle_to_point(direction), 0.001)
	assert_eq(chain_element.global_position, spawn_position)
	assert_eq(chain_element.idx, idx)


func test_change_direction():
	# given
	mock_game_root()
	var direction = Vector2.ONE
	var spawn_position = Vector2(randf_range(-10, 10), randf_range(-10, 10))
	var idx = 0
	var new_dir = Vector2(2, 3)
	# when
	chain_element.spawn(direction, spawn_position, idx)
	await wait_process_frames(1)
	chain_element.change_direction(new_dir)
	# then
	assert_eq(chain_element._direction, new_dir.normalized())
	assert_eq(chain_element.global_rotation, Vector2.ZERO.angle_to_point(new_dir))


func test_projectile_entered_not_destroyed():
	# given
	watch_signals(chain_element)
	mock_game_root()
	var projectile = mock_projectile()
	chain_element.spawn(Vector2.ONE, Vector2.ZERO, 0)
	await wait_process_frames(1)
	var counter = mock_counter()
	# when
	chain_element.area_entered.emit(projectile)
	# then
	assert_eq(projectile._direction, Vector2.ONE.normalized())
	assert_called(counter, "decrease")
	assert_signal_not_emitted(chain_element.destroyed)
	assert_true(chain_element.hitsound.playing)
	assert_true(chain_element.particles.emitting)


func test_projectile_entered_destroyed():
	# given
	watch_signals(chain_element)
	mock_game_root()
	var projectile = mock_projectile()
	chain_element.spawn(Vector2(2, 3), Vector2.ZERO, 0)
	await wait_process_frames(1)
	for _hit_idx in range(chain_element.counter.BASE_AMOUNT - 1):
		chain_element.counter.decrease()
		await wait_process_frames(1)
	# when
	chain_element.area_entered.emit(projectile)
	# then
	assert_eq(projectile._direction, Vector2(2, 3).normalized())
	assert_true(chain_element.hitsound.playing)
	assert_true(chain_element.particles.emitting)
	assert_signal_not_emitted(chain_element.destroyed)
	await wait_for_signal(chain_element.particles.finished, 1.0)
	assert_signal_emitted(chain_element.destroyed, [0])


##### UTILS #####
func mock_game_root():
	var root = add_child_autofree(
		load("res://test/unit/Weapons/Powerups/Chain/mock_game_root.tscn").instantiate()
	)
	return root


func mock_counter():
	var counter = double(load("res://Scenes/Weapons/Powerups/Common/element_counter.gd")).new()
	stub(counter, "decrease").to_do_nothing()
	chain_element.counter = counter
	return counter


func mock_projectile():
	var projectile = add_child_autofree(
		load("res://test/unit/Weapons/Powerups/Common/projectile_mock.tscn").instantiate()
	)
	return projectile
