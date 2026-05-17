extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var scene
var _sender = InputSender.new(Input)
var bullet_scene = preload("res://Scenes/Weapons/Projectiles/Bullet/bullet.tscn")


##### SETUP #####
func before_each():
	scene = load("res://test/integration/Parry/scene_shield.tscn").instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(1)
	await wait_seconds(1.0) # waits 1s to make sure the player is initialized and on the floor


##### TEARDOWN #####
func after_each():
	_sender.release_all()
	_sender.clear()


##### TESTS #####
func test_shield_bullet():
	# given
	var bullet = autofree(bullet_scene.instantiate())
	bullet.init_position = scene.get_fire_position()
	bullet.init_rotation = 0.0
	# when
	_sender.action_down("shield").hold_for(2.0)
	await wait_seconds(0.5)
	scene.fire_projectile(bullet)
	await (_sender.idle)
	await wait_seconds(0.25)
	# then
	assert_false(is_instance_valid(bullet))
	assert_lt(scene.get_shield()._health, Shield.BASE_SHIELD_HEALTH)


func test_shield_passive_regen():
	# given
	scene.get_shield()._health = Shield.BASE_SHIELD_HEALTH / 2.0
	# when
	await wait_seconds(2.0)
	# then
	assert_gt(scene.get_shield()._health, Shield.BASE_SHIELD_HEALTH / 2.0)


func test_break_shield():
	# given
	scene.get_shield()._health = 1
	var bullet = autofree(bullet_scene.instantiate())
	bullet.init_position = scene.get_fire_position()
	bullet.init_rotation = 0.0
	# when
	_sender.action_down("shield").hold_for(2.0)
	await wait_seconds(0.5)
	scene.fire_projectile(bullet)
	await (_sender.idle)
	await wait_seconds(0.25)
	# then
	assert_false(is_instance_valid(bullet))
	assert_eq(scene.get_shield()._health, 0)
	# when
	await wait_seconds(Shield.SHIELD_BROKEN_REGEN_TIME)
	# then
	assert_eq(scene.get_shield()._health, Shield.BASE_SHIELD_HEALTH)


func test_shield_broken_hit():
	# given
	scene.get_player().DAMAGE = 0.0
	scene.get_shield()._health = 0
	var bullet = autofree(bullet_scene.instantiate())
	bullet.init_position = scene.get_fire_position()
	bullet.init_rotation = 0.0
	# when
	_sender.action_down("shield").hold_for(2.0)
	await wait_seconds(0.5)
	scene.fire_projectile(bullet)
	await (_sender.idle)
	await wait_seconds(0.25)
	# then
	assert_false(is_instance_valid(bullet))
	assert_gt(scene.get_player().DAMAGE, 0.0)


func test_parry_bullet():
	# given
	var bullet = autofree(bullet_scene.instantiate())
	bullet.init_position = scene.get_fire_position()
	bullet.init_rotation = 0.0
	var previous_owner = autofree(Node2D.new())
	bullet.current_owner = previous_owner
	scene.fire_projectile(bullet)
	# when
	await wait_seconds(0.08)
	_sender.action_down("shield").hold_for(.1)
	await (_sender.idle)
	await wait_seconds(0.25)
	# then
	assert_true(is_instance_valid(bullet))
	if is_instance_valid(bullet):
		assert_ne(bullet.rotation, 0.0)
		assert_eq(bullet.speed, bullet.SPEED_PARRY_MULTIPLIER * bullet.BASE_SPEED)
		assert_eq(bullet.damage, bullet.DAMAGE_PARRY_MULTIPLIER * bullet.BASE_DAMAGE)
		assert_eq(bullet.knockback, bullet.KNOCKBACK_PARRY_MULTIPLIER * bullet.BASE_KNOCKBACK)
		assert_eq(bullet.current_owner, scene.get_player())
