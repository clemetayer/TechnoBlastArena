extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const ACCEPTABLE_VOLUME_DIFFERENCE := 0.005

#---- VARIABLES -----
var audio_settings

var original_main_volume
var original_music_volume
var original_effects_volume


##### SETUP #####
func before_all():
	original_main_volume = AudioServer.get_bus_volume_linear(RuntimeConfig.MAIN_BUS_IDX)
	original_music_volume = AudioServer.get_bus_volume_linear(RuntimeConfig.MUSIC_BUS_IDX)
	original_effects_volume = AudioServer.get_bus_volume_linear(RuntimeConfig.EFFECTS_BUS_IDX)


func before_each():
	audio_settings = add_child_autofree(load("res://Scenes/UI/OptionsMenu/audio_settings.tscn").instantiate())


##### TEARDOWN #####
func after_all():
	AudioServer.set_bus_volume_linear(RuntimeConfig.MAIN_BUS_IDX, original_main_volume)
	AudioServer.set_bus_volume_linear(RuntimeConfig.MUSIC_BUS_IDX, original_music_volume)
	AudioServer.set_bus_volume_linear(RuntimeConfig.EFFECTS_BUS_IDX, original_effects_volume)


##### TESTS #####
func test_init():
	# given
	_randomize_values()
	# when
	audio_settings._ready()
	# then
	assert_almost_eq(audio_settings.main_volume.value, AudioServer.get_bus_volume_linear(RuntimeConfig.MAIN_BUS_IDX) * 100.0, ACCEPTABLE_VOLUME_DIFFERENCE)
	assert_almost_eq(audio_settings.music_volume.value, AudioServer.get_bus_volume_linear(RuntimeConfig.MUSIC_BUS_IDX) * 100.0, ACCEPTABLE_VOLUME_DIFFERENCE)
	assert_almost_eq(audio_settings.effects_volume.value, AudioServer.get_bus_volume_linear(RuntimeConfig.EFFECTS_BUS_IDX) * 100.0, ACCEPTABLE_VOLUME_DIFFERENCE)


func test_set_main_volume():
	# given
	var volume = randf()
	# when
	audio_settings.main_volume.set_value(volume * 100.0)
	# then
	assert_almost_eq(AudioServer.get_bus_volume_linear(RuntimeConfig.MAIN_BUS_IDX), volume, ACCEPTABLE_VOLUME_DIFFERENCE)


func test_set_music_volume():
	# given
	var volume = randf()
	# when
	audio_settings.music_volume.set_value(volume * 100.0)
	# then
	assert_almost_eq(AudioServer.get_bus_volume_linear(RuntimeConfig.MUSIC_BUS_IDX), volume, ACCEPTABLE_VOLUME_DIFFERENCE)


func test_set_effects_volume():
	# given
	var volume = randf()
	# when
	audio_settings.effects_volume.set_value(volume * 100.0)
	# then
	assert_almost_eq(AudioServer.get_bus_volume_linear(RuntimeConfig.EFFECTS_BUS_IDX), volume, ACCEPTABLE_VOLUME_DIFFERENCE)


##### UTILS #####
func _randomize_values() -> void:
	AudioServer.set_bus_volume_linear(RuntimeConfig.MAIN_BUS_IDX, randf())
	AudioServer.set_bus_volume_linear(RuntimeConfig.MUSIC_BUS_IDX, randf())
	AudioServer.set_bus_volume_linear(RuntimeConfig.EFFECTS_BUS_IDX, randf())
