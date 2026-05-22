extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var circles

##### SETUP #####
func before_each():
	circles = load("res://Scenes/Weapons/Powerups/Common/circles.gd").new()

##### TEARDOWN #####
func after_each():
	circles.free()

##### TESTS #####
func test_init():
	# given
	# when
	circles.init(3)
	# then
	assert_eq(circles.get_child_count(), 3)

# remove_circle hard to test because of the queue_free()
