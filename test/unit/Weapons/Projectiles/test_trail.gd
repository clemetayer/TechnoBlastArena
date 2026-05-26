extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var trail


##### SETUP #####
func before_each():
	trail = load("res://Scenes/Weapons/Projectiles/trail.gd").new()


##### TEARDOWN #####
func after_each():
	if is_instance_valid(trail):
		trail.free()


##### TESTS #####
func test_process():
	# given
	var parent = autofree(Node2D.new())
	parent.add_child(trail)
	mock_timer()
	add_child(parent)
	trail.global_position = Vector2.RIGHT
	trail.global_rotation = PI / 4.0
	# when
	trail._process(1.0 / 60.0)
	# then
	assert_eq(trail.global_position, Vector2.ZERO)
	assert_eq(trail.global_rotation, 0)
	# cleanup
	trail.free()


func test_reset():
	# given
	trail.points = []
	trail.add_point(Vector2.ONE)
	# when
	trail.reset()
	# then
	assert_eq(trail.points.size(), 0)


var add_point_timer_timeout_params := [
	[0],
	[15],
]


func test_add_point_timer_timeout(params = use_parameters(add_point_timer_timeout_params)):
	# given
	var init_size = params[0]
	var parent = autofree(Node2D.new())
	parent.add_child(trail)
	mock_timer()
	add_child(parent)
	for i in range(init_size):
		trail.add_point(Vector2.ZERO)
	parent.global_position = Vector2.LEFT
	# when
	trail._on_add_point_timer_timeout()
	# then
	assert_eq(trail.get_point_count(), init_size + 1 if init_size < trail.SIZE else init_size)
	assert_eq(trail.get_point_position(trail.get_point_count() - 1), Vector2.LEFT)


##### UTILS #####
func mock_timer() -> Timer:
	var timer = autofree(Timer.new())
	timer.name = "AddPointTimer"
	trail.add_child(timer)
	return timer
