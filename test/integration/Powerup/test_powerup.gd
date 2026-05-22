extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var scene


##### SETUP #####
func before_each():
	scene = load("res://test/integration/Powerup/scene_powerup.tscn").instantiate()
	add_child_autofree(scene)
	await wait_process_frames(1)


##### TESTS #####
func test_splitter():
	# given
	var bullet_load = load("res://Scenes/Weapons/Projectiles/Bullet/bullet.tscn")
	var splitter = load("res://Scenes/Weapons/Powerups/Splitter/splitter.tscn").instantiate()
	var runtime_utils = double(load("res://Utils/runtime_utils.gd")).new()
	stub(runtime_utils, "get_game_root").to_return(scene)
	scene.spawn_powerup(splitter)
	await wait_seconds(0.1)
	splitter._runtime_utils = runtime_utils
	var projectiles_duplicates = splitter.PROJECTILE_DUPLICATES
	# when/then
	var bullet = bullet_load.instantiate()
	bullet.init_position = scene.get_fire_position_node().global_position
	bullet.init_rotation = 0.0
	scene.fire_projectile(bullet)
	await wait_seconds(1.0)
	var projectiles_cnt = scene.get_projectiles().size()
	assert_eq(projectiles_cnt, projectiles_duplicates + 1)
	for projectile_idx in range(1, projectiles_cnt):
		var angle = (projectile_idx * ((PI / 2) / (projectiles_cnt))) - PI / 4
		assert_true(_has_projectile_with_angle(scene.get_projectiles(), angle))
	scene.clean_projectiles()
	await wait_seconds(0.5)
	assert_false(is_instance_valid(splitter))


func test_splitter_manager():
	# given
	var splitter_manager = load("res://Scenes/Weapons/Powerups/Splitter/splitter_manager.tscn").instantiate()
	splitter_manager._init_ui_done = true
	splitter_manager.active = true
	splitter_manager.global_position = scene.get_powerup_position_node().global_position
	var runtime_utils = double(load("res://Utils/runtime_utils.gd")).new()
	stub(runtime_utils, "get_game_root").to_return(scene)
	scene.add_child(splitter_manager)
	await wait_seconds(0.1)
	splitter_manager._runtime_utils = runtime_utils
	# when / then
	## test simple spawn
	splitter_manager.use()
	await wait_seconds(0.1)
	assert_eq(scene.get_powerups().size(), 1)
	## test can shoot at it
	var bullet = load("res://Scenes/Weapons/Projectiles/Bullet/bullet.tscn").instantiate()
	bullet.init_position = scene.get_fire_position_node().global_position
	bullet.init_rotation = 0.0
	scene.fire_projectile(bullet)
	await wait_seconds(1.0)
	var projectiles_cnt = scene.get_projectiles().size()
	for projectile_idx in range(1, projectiles_cnt):
		var angle = (projectile_idx * ((PI / 2) / (projectiles_cnt))) - PI / 4
		assert_true(_has_projectile_with_angle(scene.get_projectiles(), angle))
	scene.clean_projectiles()
	bullet.free()
	await wait_seconds(splitter_manager.COOLDOWN_TIMER)
	splitter_manager.use()
	await wait_seconds(0.5)
	## trying to spawn one while the cooldown is not over
	splitter_manager.use()
	await wait_seconds(0.1)
	assert_eq(scene.get_powerups().size(), 1)
	## spawning x more just to see if we stay at the max possible active splitters
	await wait_seconds(splitter_manager.COOLDOWN_TIMER)
	for splitter_idx in range(0, splitter_manager.MAX_SPLITTERS_ACTIVE):
		splitter_manager.use()
		await wait_seconds(splitter_manager.COOLDOWN_TIMER)
	assert_eq(scene.get_powerups().size(), splitter_manager.MAX_SPLITTERS_ACTIVE)
	# cleanup
	scene.clean_powerups()
	scene.clean_projectiles()
	await wait_seconds(0.5)


##### UTILS #####
func _has_projectile_with_angle(projectiles, angle) -> bool:
	for projectile in projectiles:
		if is_equal_approx(projectile.rotation, angle):
			return true
	return false
