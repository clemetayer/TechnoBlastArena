extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var config


##### SETUP #####
func before_each():
	config = add_child_autofree(load("res://Scenes/UI/PlayerCustomizationMenu/LivesConfig/lives_config.tscn").instantiate())


##### TESTS #####
func test_get_lives():
	# given
	config.lives.value = 5
	# when
	var res = config.get_lives()
	# then
	assert_eq(res, 5)
