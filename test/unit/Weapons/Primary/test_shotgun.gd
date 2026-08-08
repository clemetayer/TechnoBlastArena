extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var shotgun


##### SETUP #####
func before_each():
	shotgun = add_child_autofree(load("res://Scenes/Weapons/Primary/Shotgun/shotgun.tscn").instantiate())

##### TESTS #####
var fire_params := [
	[true, true],
	[false, true],
	[true, false],
	[true, true],
]


func test_fire(params = use_parameters(fire_params)):
	# given
	var root = _mock_runtime_utils_and_game_root()
	var on_cooldown = params[0]
	var active = params[1]
	shotgun._on_cooldown = on_cooldown
	shotgun.active = active
	# when
	shotgun.fire()
	# then
	assert_eq(shotgun._fire_anim_tween != null, not on_cooldown and active)
	assert_eq(shotgun.gunshot.playing, not on_cooldown and active)
	assert_eq(shotgun.shoot_cooldown_timer.is_stopped(), on_cooldown or not active)
	if not on_cooldown and active:
		assert_called_count(root.spawn_projectile, shotgun.PROJECTILE_AMOUNT)
	else:
		assert_not_called(root.spawn_projectile)


func test_create_projectiles():
	# given
	var projectile_owner = Node2D.new()
	shotgun.projectile_owner = projectile_owner
	shotgun.global_position = Vector2.RIGHT
	shotgun.rotation = PI / 4.0
	shotgun.owner_color = Color.ANTIQUE_WHITE
	# when
	var res = shotgun._create_projectiles()
	# then
	assert_false(res.is_empty())
	assert_eq(res.size(), shotgun.PROJECTILE_AMOUNT)
	var bullet_angle = PI / 4.0 - (shotgun.SPREAD / 2.0)
	for projectile in res:
		assert_eq(projectile.current_owner, projectile_owner)
		assert_eq(projectile.init_position, Vector2.RIGHT)
		assert_almost_eq(projectile.init_rotation, bullet_angle, 0.01)
		assert_eq(projectile.color, Color.ANTIQUE_WHITE)
		bullet_angle += shotgun.SPREAD / shotgun.PROJECTILE_AMOUNT
		# cleanup
		projectile.free()
	projectile_owner.free()


var aim_params := [
	[Vector2.RIGHT],
	[Vector2.LEFT],
]


func test_aim(params = use_parameters(aim_params)):
	# given
	var original_size = shotgun.sprite.scale.y
	var aim_pos = params[0]
	var analog_angle = Vector2.ZERO.angle_to_point(aim_pos)
	# when
	shotgun.aim(aim_pos)
	# then
	assert_eq(shotgun.sprite.scale.y, -original_size if abs(analog_angle) >= PI / 2.0 else original_size)
	assert_eq(shotgun.rotation, analog_angle)


func test_set_los_init_modulate():
	# given
	shotgun.owner_color = Color.ALICE_BLUE
	# when
	shotgun._set_los_init_modulate()
	# then
	assert_eq(shotgun.line_of_sight.modulate, Color.ALICE_BLUE)


func test_on_shoot_cooldown_timeout():
	# given
	shotgun._on_cooldown = true
	# when
	shotgun._on_shoot_cooldown_timeout()
	# then
	assert_false(shotgun._on_cooldown)


##### UTILS #####
func _mock_runtime_utils_and_game_root():
	var root = double(load("res://Scenes/Game/game.gd")).new()
	stub(root, "spawn_projectile").to_do_nothing()
	var runtime_utils = double(load("res://Utils/runtime_utils.gd")).new()
	stub(runtime_utils, "get_game_root").to_return(root)
	shotgun._runtime_utils = runtime_utils
	return root
