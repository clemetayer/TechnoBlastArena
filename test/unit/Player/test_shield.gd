extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var shield
var parried_times_called := 0


##### SETUP #####
func before_each():
	parried_times_called = 0
	shield = load("res://Scenes/Player/shield.gd").new()


##### TEARDOWN #####
func after_each():
	shield.free()

##### TESTS #####
