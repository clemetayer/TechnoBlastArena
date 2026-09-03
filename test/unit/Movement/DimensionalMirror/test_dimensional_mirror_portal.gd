extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var portal


##### SETUP #####
func before_each():
	portal = add_child_autofree(
		load("res://Scenes/Movement/MovementBonusDimensionalMirror/dimensional_mirror_portal.tscn").instantiate()
	)


##### TESTS #####
func test_rotate_on_process():
	# given
	portal.rotation = 0.0
	# when
	simulate(portal, 10, 1.0 / 60.0)
	# then
	assert_gt(portal.rotation, 0.0)


var appear_params := [[true], [false]]


func test_appear(params = use_parameters(appear_params)):
	# given
	var is_in = params[0]
	var expected_position = Vector2(randf() * 10.0, randf() * 10.0)
	# when
	portal.appear(is_in, expected_position)
	# then
	assert_eq(portal.global_position, expected_position)
	assert_true(portal.animation_player.is_playing())
	assert_eq(
		portal.animation_player.current_animation,
		portal.APPEAR_IN_ANIMATION if is_in else portal.APPEAR_OUT_ANIMATION,
	)
	await wait_for_signal(portal.animation_player.animation_finished, 1.0)
	await wait_process_frames(2)
	assert_false(is_instance_valid(portal))
