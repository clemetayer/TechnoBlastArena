extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var audio_manager
var mock_hit_sound
var mock_break_sound
var mock_trebble_sound


##### SETUP #####
func before_each():
	audio_manager = autofree(load("res://Scenes/DestructibleWalls/audio_manager.gd").new())


##### TESTS #####
func test_play_hit():
	# given
	audio_manager.onready_paths.hit_sound = double(AudioStreamPlayer).new()
	stub(audio_manager.onready_paths.hit_sound, "play").to_do_nothing()
	# when
	audio_manager.play_hit()
	# then
	assert_called(audio_manager.onready_paths.hit_sound, "play")


func test_play_break_calls_play_on_break_sound():
	# given
	audio_manager.onready_paths.break_sound = double(AudioStreamPlayer).new()
	stub(audio_manager.onready_paths.break_sound, "play").to_do_nothing()
	# when
	audio_manager.play_break()
	# then
	assert_called(audio_manager.onready_paths.break_sound, "play")


var trebble_test_parameters := [
	[0.0, 4.0],
	[0.5, 1.5],
	[1.0, 0.0],
]


func test_play_trebble(params = use_parameters(trebble_test_parameters)):
	# given
	var mock_stream = double(AudioStream).new()
	audio_manager.onready_paths.trebble_sound = double(AudioStreamPlayer).new()
	stub(mock_stream, "get_length").to_return(5.0)
	stub(audio_manager.onready_paths.trebble_sound, "get_stream").to_return(mock_stream)
	stub(audio_manager.onready_paths.trebble_sound, "play").to_do_nothing()
	# when
	audio_manager.play_trebble(params[0])
	# then
	assert_called(audio_manager.onready_paths.trebble_sound, "play", [params[1]])


func test_stop_trebble_calls_stop_on_trebble_sound():
	#given
	audio_manager.onready_paths.trebble_sound = double(AudioStreamPlayer).new()
	stub(audio_manager.onready_paths.trebble_sound, "stop")
	# when
	audio_manager.stop_trebble()
	# then
	assert_called(audio_manager.onready_paths.trebble_sound, "stop")
