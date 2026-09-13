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


##### UTILS #####
func _has_projectile_with_angle(projectiles, angle) -> bool:
	for projectile in projectiles:
		if is_equal_approx(projectile.rotation, angle):
			return true
	return false
