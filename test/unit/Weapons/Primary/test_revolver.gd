extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var revolver


##### SETUP #####
func before_each():
	revolver = load("res://Scenes/Weapons/Primary/Revolver/revolver.gd").new()


##### TEARDOWN #####
func after_each():
	revolver.free()

##### TESTS #####
var fire_params := [
	[true, true, true],
	[false, true, true],
	[true, false, true],
	[true, true, false],
]


func test_fire(params = use_parameters(fire_params)):
	# given
	var on_cooldown = params[0]
	var active = params[1]
	var is_authority = params[2]
	var projectile = Node2D.new()
	var mock_revolver = partial_double(load("res://Scenes/Weapons/Primary/Revolver/revolver.gd")).new()
	stub(mock_revolver, "_fire_anim").to_do_nothing()
	stub(mock_revolver, "_play_gunshot").to_do_nothing()
	stub(mock_revolver, "_create_projectile").to_return(projectile)
	var shoot_cooldown_timer = double(Timer).new()
	stub(shoot_cooldown_timer, "start").to_do_nothing()
	mock_revolver.onready_paths.shoot_cooldown_timer = shoot_cooldown_timer
	mock_revolver._on_cooldown = on_cooldown
	mock_revolver.active = active
	# when
	mock_revolver.fire()
	# then
	if not on_cooldown and active:
		assert_called(mock_revolver, "_fire_anim")
		assert_called(mock_revolver, "_play_gunshot")
		if is_authority:
			assert_called(mock_revolver, "_spawn_projectile", [projectile])
		else:
			assert_not_called(mock_revolver, "_spawn_projectile")
		assert_true(mock_revolver._on_cooldown)
		assert_called(shoot_cooldown_timer, "start")
	else:
		assert_not_called(mock_revolver, "_fire_anim")
		assert_not_called(mock_revolver, "_play_gunshot")
		assert_not_called(mock_revolver, "_spawn_projectile", [projectile])
		assert_not_called(shoot_cooldown_timer, "start")
	# cleanup
	projectile.free()


var aim_params := [
	[Vector2.RIGHT],
	[Vector2.LEFT],
]


func test_aim(params = use_parameters(aim_params)):
	# given
	var aim_pos = params[0]
	var analog_angle = Vector2.ZERO.angle_to_point(aim_pos)
	var sprite = Sprite2D.new()
	revolver.onready_paths.sprite = sprite
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


func test_fire_anim():
	# given
	var los = Line2D.new()
	revolver.onready_paths.line_of_sight = los
	# when
	revolver._fire_anim()
	# then
	assert_not_null(revolver._fire_anim_tween)
	assert_eq(los.modulate, Color.WHITE)
	assert_eq(los.width, revolver.FIRE_ANIM_MAX_WIDTH)
	# cleanup
	los.free()


func test_play_gunshot():
	# given
	var gunshot = double(AudioStreamPlayer2D).new()
	stub(gunshot, "play").to_do_nothing()
	revolver.onready_paths.gunshot = gunshot
	# when
	revolver._play_gunshot()
	# then
	assert_called(gunshot, "play")


func test_set_los_init_modulate():
	# given
	var los = Line2D.new()
	revolver.owner_color = Color.ALICE_BLUE
	revolver.onready_paths.line_of_sight = los
	# when
	revolver._set_los_init_modulate()
	# then
	assert_eq(los.modulate, Color.ALICE_BLUE)
	# cleanup
	los.free()


func test_on_shoot_cooldown_timeout():
	# given
	revolver._on_cooldown = true
	# when
	revolver._on_shoot_cooldown_timeout()
	# then
	assert_false(revolver._on_cooldown)
