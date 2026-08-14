extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const DEFAULT_FILTER_IN_OUT_TIME := 1.0

#---- VARIABLES -----
var manager


##### SETUP #####
func before_each():
	manager = add_child_autofree(load("res://Utils/Audio/music_manager.tscn").instantiate())

##### TESTS #####
var filter_out_params := [
	[0.5],
	[],
]


func test_filter_out(params = use_parameters(filter_out_params)):
	# given
	var duration = params[0] if params.size() > 0 else manager.DEFAULT_FILTER_IN_OUT_TIME
	AudioServer.get_bus_effect(manager.BUS_IDX, manager.LOWPASS_FILTER_IDX).cutoff_hz = manager.FILTER_IN_CUTOFF
	# when
	if params.size() > 0:
		manager.filter_out(duration)
	else:
		manager.filter_out()
	await wait_seconds(duration)
	await wait_process_frames(2)
	# then
	assert_eq(AudioServer.get_bus_effect(manager.BUS_IDX, manager.LOWPASS_FILTER_IDX).cutoff_hz, manager.FILTER_OUT_CUTOFF)


var filter_in_params := [
	[0.5],
	[],
]


func test_filter_in(params = use_parameters(filter_in_params)):
	# given
	var duration = params[0] if params.size() > 0 else manager.DEFAULT_FILTER_IN_OUT_TIME
	AudioServer.get_bus_effect(manager.BUS_IDX, manager.LOWPASS_FILTER_IDX).cutoff_hz = manager.FILTER_OUT_CUTOFF
	# when
	if params.size() > 0:
		manager.filter_in(duration)
	else:
		manager.filter_in()
	await wait_seconds(duration)
	await wait_process_frames(2)
	# then
	assert_eq(AudioServer.get_bus_effect(manager.BUS_IDX, manager.LOWPASS_FILTER_IDX).cutoff_hz, manager.FILTER_IN_CUTOFF)
