extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var scene
var _sender = InputSender.new(Input)


##### SETUP #####
func before_each():
	scene = load("res://test/integration/Projectile/scene_projectile.tscn").instantiate()
	add_child_autofree(scene)
	await wait_process_frames(1)
	await wait_seconds(1.0) # waits 1s to make sure the player is initialized and on the floor


##### TEARDOWN #####
func after_each():
	_sender.release_all()
	_sender.clear()


##### TESTS #####
func test_bullet():
	# given
	var player_init_pos = scene.get_player().global_position
	var bullet = load("res://Scenes/Weapons/Projectiles/Bullet/bullet.tscn").instantiate()
	var bullet_params := BulletParametersResource.new()
	bullet.PARAMETERS = bullet_params
	bullet.init_position = scene.get_fire_position()
	bullet.init_rotation = 0.0
	# when / then
	scene.fire_projectile(bullet)
	await wait_seconds(1.0)
	assert_gt(scene.get_player().DAMAGE, 0.0)
	assert_gt(scene.get_player().global_position.x, player_init_pos.x)
	assert_false(is_instance_valid(bullet))
