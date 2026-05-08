extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var projectile: ProjectileBase


##### SETUP #####
func before_each():
	projectile = add_child_autofree(load("res://test/unit/Weapons/Projectiles/projectile_base_instance.tscn").instantiate())


##### TESTS #####
func test_shield_should_free():
	# given
	# when
	projectile.shielded()
	# then
	await wait_seconds(.1)
	assert_false(is_instance_valid(projectile))


func test_solid_collision_free():
	# given
	# when
	projectile.solid_collision(autofree(StaticBody2D.new()))
	# then
	await wait_seconds(.1)
	assert_false(is_instance_valid(projectile))
