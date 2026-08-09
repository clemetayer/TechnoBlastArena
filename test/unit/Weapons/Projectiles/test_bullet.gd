extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var bullet


##### SETUP #####
func before_each():
	bullet = autofree(load("res://Scenes/Weapons/Projectiles/Bullet/bullet.gd").new())


##### TESTS #####
func test_ready():
	# given
	bullet.free()
	bullet = load("res://Scenes/Weapons/Projectiles/Bullet/bullet.tscn").instantiate() # Actually loads the bullet scene to test _ready
	var parameters = BulletParametersResource.new()
	parameters.SPEED = 1
	parameters.DAMAGE = 2
	parameters.KNOCKBACK = 3
	parameters.SIZE = 4
	bullet.PARAMETERS = parameters
	bullet.init_position = Vector2.RIGHT
	bullet.init_rotation = PI / 4.0
	bullet.color = Color.AQUA
	# when
	add_child(bullet)
	# then
	assert_eq(bullet._speed, 1)
	assert_eq(bullet._damage, 2)
	assert_eq(bullet._knockback, 3)
	assert_eq(bullet.scale, Vector2.ONE * 4)
	assert_eq(bullet.global_position, Vector2.RIGHT)
	assert_almost_eq(bullet.rotation, PI / 4.0, 0.001)
	assert_eq(bullet.onready_paths.trail.modulate, Color.AQUA)
	assert_eq(bullet.onready_paths.sprite.modulate, Color.AQUA)
	assert_eq(bullet._direction, Vector2.RIGHT.rotated(PI / 4.0).normalized())


func test_process():
	# given
	bullet.position = Vector2.ZERO
	bullet._direction = Vector2.RIGHT
	bullet._speed = 2.0
	# when
	bullet._process(0.5)
	# then
	assert_eq(bullet.position, Vector2.RIGHT)


func test_parried():
	# given
	bullet.free()
	bullet = load("res://Scenes/Weapons/Projectiles/Bullet/bullet.tscn").instantiate() # Actually loads the bullet scene to test _ready
	bullet.color = Color.WHITE
	var p_owner = autofree(load("res://Scenes/Player/player.gd").new())
	p_owner.PLAYER_ID = 1
	bullet._speed = 1.0
	bullet._damage = 2.0
	bullet._knockback = 3.0
	# when
	add_child_autofree(bullet)
	bullet.parried(p_owner, Vector2.UP)
	# then
	await wait_seconds(Shield.PARRY_STOP_TIME)
	await wait_physics_frames(1)
	assert_eq(bullet.current_owner, p_owner)
	assert_almost_eq(bullet.rotation, -PI / 2.0, 0.01)
	assert_eq(bullet._direction, Vector2.UP)
	assert_eq(bullet._speed, 1.0 * bullet.SPEED_PARRY_MULTIPLIER)
	assert_eq(bullet._damage, 2.0 * bullet.DAMAGE_PARRY_MULTIPLIER)
	assert_eq(bullet._knockback, 3.0 * bullet.KNOCKBACK_PARRY_MULTIPLIER)
	assert_eq(bullet.onready_paths.trail.modulate, RuntimeUtils.PLAYER_INDICATOR_COLORS[1])
	assert_eq(bullet.onready_paths.sprite.modulate, RuntimeUtils.PLAYER_INDICATOR_COLORS[1])


var on_body_entered_params := [
	[true, true, false],
	[true, false, true],
	[true, false, false],
	[false, true, true],
]


func test_on_body_entered(params = use_parameters(on_body_entered_params)):
	# given
	var is_authority = params[0]
	var is_player = params[1]
	var is_static_obstacle = params[2]
	var body
	if is_player:
		body = double(load("res://Scenes/Player/player.gd")).new()
		stub(body, "hit").to_do_nothing()
		body.add_to_group("player", false)
	elif is_static_obstacle:
		body = StaticBody2D.new()
		body.add_to_group("static_obstacle")
	else:
		body = StaticBody2D.new()
	# when
	bullet._on_body_entered(body)
	# then
	if is_authority and is_player:
		assert_called(body, "hit")
	else:
		assert_not_null(body) # kind of useless. Just to check if the code runs well everywhere, especially around the queue free
	# cleanup
	body.free()


func test_stop_for_duration():
	# given
	bullet = add_child_autofree(load("res://Scenes/Weapons/Projectiles/Bullet/bullet.tscn").instantiate())
	bullet.position = Vector2.ZERO
	bullet._direction = Vector2.RIGHT
	bullet._speed = 2.0
	# when
	bullet._stop_for_duration(0.15)
	bullet._process(0.5)
	# then
	assert_eq(bullet.position, Vector2.ZERO)
	await wait_seconds(0.15)
	await wait_physics_frames(2)
	# when
	bullet._process(0.5)
	assert_ne(bullet.position, Vector2.ZERO)
