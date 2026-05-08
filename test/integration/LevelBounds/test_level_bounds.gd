extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var scene
var _sender = InputSender.new(Input)

##### SETUP #####
func before_each():
	scene = load("res://test/integration/LevelBounds/scene_level_bounds.tscn").instantiate()
	add_child_autofree(scene)
	await wait_frames(1)
	await wait_seconds(1.0) # waits 1s to make sure the player is initialized and on the floor

##### TEARDOWN #####
func after_each():
	_sender.release_all()
	_sender.clear()

##### TESTS #####
func test_out_of_bounds():
	# given
	# when/then
	_sender.action_down("left").action_down("jump").hold_for(1.5)
	await _sender.idle
	assert_false(scene.get_player().paths.sprites.visible) # queue_free does not work well with GUT, so we check other things.
	assert_eq(scene.get_player().collision_layer,0)
	assert_eq(scene.get_player().collision_mask,0)
