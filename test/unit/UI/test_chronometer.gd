extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const CHRONOMETER_SCENE_PATH := "res://Scenes/UI/Chronometer/chronometer.tscn"

#---- VARIABLES -----
var chronometer


##### SETUP #####
func before_each():
	chronometer = autofree(load("res://Scenes/UI/Chronometer/chronometer.gd").new())

##### TESTS #####
var process_params := [
	[null, 100, 50],
	[10, null, 50],
	[10, 100, 50],
	[100, 10, 110],
]


func test_process(params = use_parameters(process_params)):
	# given
	var start_time = params[0]
	var end_time = params[1]
	var current_time = params[2]
	var mock_chronometer = partial_double(load("res://Scenes/UI/Chronometer/chronometer.gd")).new()
	stub(mock_chronometer, "_get_current_time").to_return(current_time)
	stub(mock_chronometer, "_time_over").to_do_nothing()
	stub(mock_chronometer, "_refresh_timer").to_do_nothing()
	mock_chronometer._start_time = start_time
	mock_chronometer._end_time = end_time
	# when
	mock_chronometer._process(1.0 / 60.0)
	# then
	if start_time == null or end_time == null:
		assert_not_called(mock_chronometer, "_time_over")
		assert_not_called(mock_chronometer, "_refresh_timer")
	elif current_time >= end_time:
		assert_called(mock_chronometer, "_time_over")
		assert_not_called(mock_chronometer, "_refresh_timer")
	else:
		assert_not_called(mock_chronometer, "_time_over")
		assert_called(mock_chronometer, "_refresh_timer", [current_time])


func test_start_timer():
	# given
	var mock_chronometer = partial_double(load("res://Scenes/UI/Chronometer/chronometer.gd")).new()
	stub(mock_chronometer, "_get_current_time").to_return(50)
	# when
	mock_chronometer.start_timer(10.0)
	# then
	assert_eq(mock_chronometer._start_time, 50.0)
	assert_eq(mock_chronometer._end_time, 10050.0)


func test_reset_timer():
	# given
	chronometer._start_time = 100
	chronometer._end_time = 200
	# when
	chronometer.reset_timer()
	# then
	assert_null(chronometer._start_time)
	assert_null(chronometer._end_time)


func test_time_over():
	# given
	watch_signals(chronometer)
	var label = Label.new()
	chronometer.label = label
	chronometer._start_time = 10.0
	chronometer._end_time = 80.0
	# when
	chronometer._time_over()
	# then
	assert_eq(chronometer.label.text, chronometer.END_TEXT)
	assert_null(chronometer._start_time)
	assert_null(chronometer._end_time)
	assert_signal_emitted(chronometer.time_over)
	# cleanup
	label.free()


func test_refresh_timer():
	# given
	var label = Label.new()
	chronometer.label = label
	chronometer._end_time = 1000000.0
	# when
	chronometer._refresh_timer(555)
	# then
	assert_eq(label.text, "%02d:%02d" % [16, 39])
	# cleanup
	label.free()


func test_scene_time_decreasing():
	# given
	var chronometer_scene = load(CHRONOMETER_SCENE_PATH).instantiate()
	add_child_autofree(chronometer_scene)
	# when
	chronometer_scene.start_timer(90)
	# then
	await wait_process_frames(2)
	assert_eq(chronometer_scene.label.text, "01:29")
	await wait_seconds(3)
	assert_eq(chronometer_scene.label.text, "01:26")
