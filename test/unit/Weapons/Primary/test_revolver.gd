extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var revolver


##### SETUP #####
func before_each():
	revolver = add_child_autofree(load("res://Scenes/Weapons/Primary/Revolver/revolver.tscn").instantiate())

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
	revolver._on_cooldown = on_cooldown
	revolver.active = active
	# when
	revolver.fire()
	# then
	assert_eq(revolver._fire_anim_tween != null, not on_cooldown and active)
	assert_eq(revolver.gunshot.playing, not on_cooldown and active)
	assert_eq(revolver.shoot_cooldown_timer.is_stopped(), on_cooldown or not active)
	if not on_cooldown and active:
		assert_called(root, "spawn_projectile")
	else:
		assert_not_called(root, "spawn_projectile")


var aim_params := [
	[Vector2.RIGHT],
	[Vector2.LEFT],
]


func test_aim(params = use_parameters(aim_params)):
	# given
	var aim_pos = params[0]
	var analog_angle = Vector2.ZERO.angle_to_point(aim_pos)
	var sprite = Sprite2D.new()
	revolver.sprite = sprite
	# when
	revolver.aim(aim_pos)
	# then
	assert_eq(sprite.scale.y, -1 if abs(analog_angle) >= PI / 2.0 else 1)
	assert_eq(revolver.rotation, analog_angle)
	# cleanup
	sprite.free()


func test_create_projectile():
	# given
	var projectile_owner = Node2D.new()
	revolver.projectile_owner = projectile_owner
	revolver.global_position = Vector2.RIGHT
	revolver.rotation = PI / 4.0
	revolver.owner_color = Color.ANTIQUE_WHITE
	# when
	var res = revolver._create_projectile()
	# then
	assert_not_null(res)
	assert_eq(res.current_owner, projectile_owner)
	assert_eq(res.init_position, Vector2.RIGHT)
	assert_almost_eq(res.init_rotation, PI / 4.0, 0.01)
	assert_eq(res.color, Color.ANTIQUE_WHITE)
	# cleanup
	projectile_owner.free()
	res.free()


func test_set_los_init_modulate():
	# given
	revolver.owner_color = Color.ALICE_BLUE
	# when
	revolver._set_los_init_modulate()
	# then
	assert_eq(revolver.line_of_sight.modulate, Color.ALICE_BLUE)


func test_on_shoot_cooldown_timeout():
	# given
	revolver._on_cooldown = true
	# when
	revolver._on_shoot_cooldown_timeout()
	# then
	assert_false(revolver._on_cooldown)


func _mock_runtime_utils_and_game_root():
	var root = double(load("res://Scenes/Game/game.gd")).new()
	stub(root, "spawn_projectile").to_do_nothing()
	var runtime_utils = double(load("res://Utils/runtime_utils.gd")).new()
	stub(runtime_utils, "get_game_root").to_return(root)
	revolver._runtime_utils = runtime_utils
	return root
