extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var shield


##### SETUP #####
func before_each():
	shield = load("res://Scenes/Player/shield.gd").new()


##### TEARDOWN #####
func after_each():
	shield.free()

##### TESTS #####
var toggle_shielding_params := [
	[true],
	[false],
]


func test_toggle_shielding(params = use_parameters(toggle_shielding_params)):
	# given
	var shielding = params[0]
	# when
	shield.toggle_shielding(shielding)
	# then
	assert_eq(shield._shielding, shielding)
