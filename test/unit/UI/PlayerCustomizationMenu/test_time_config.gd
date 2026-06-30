extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var config


##### SETUP #####
func before_each():
	config = add_child_autofree(load("res://Scenes/UI/PlayerCustomizationMenu/TimeConfig/time_config.tscn").instantiate())

##### TESTS #####
var get_time_params := [
	[0, 30],
	[30, 0],
	[10, 15],
]


func test_get_time(params = use_parameters(get_time_params)):
	# given
	var minutes = params[0]
	var seconds = params[1]
	config.minutes.value = minutes
	config.seconds.value = seconds
	# when
	var res = config.get_time()
	# then
	assert_eq(res, minutes * 60 + seconds)
