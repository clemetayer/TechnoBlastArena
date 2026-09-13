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
func test_chain_element():
	# given
	var direction = Vector2.ONE.normalized()
	var bullet_load = load("res://Scenes/Weapons/Projectiles/Bullet/bullet.tscn")
	var chain_element = load("res://Scenes/Weapons/Powerups/Chain/chain_element.tscn").instantiate()
	chain_element.spawn(direction, scene.get_powerup_position(), 0)
	await wait_process_frames(1)
	# when
	var bullet = bullet_load.instantiate()
	bullet.init_position = scene.get_fire_position_node().global_position
	bullet.init_rotation = 0.0
	scene.fire_projectile(bullet)
	await wait_seconds(1.0)
	# then
	assert_almost_eq(bullet._direction, direction, Vector2.ONE * 0.001)
	# cleanup
	scene.clean_projectiles()
	await wait_seconds(0.5)
