extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const VOLUME_COMPARISON_MARGIN := 0.0001

#---- VARIABLES -----
var runtime_config
var user_configs: ConfigFile
var save_path: String


##### SETUP #####
func before_all():
	var temp = autofree(load("res://Utils/Config/runtime_config.gd").new())
	user_configs = ConfigFile.new()
	save_path = temp.CONFIG_FILE_PATH
	user_configs.load(save_path)


func before_each():
	runtime_config = autofree(load("res://Utils/Config/runtime_config.gd").new())


##### TEARDOWN #####
func after_all():
	if user_configs.get_sections().size() > 0:
		user_configs.save(save_path)


##### TESTS #####
func test_load_config_on_ready():
	# given
	# when
	runtime_config._ready()
	# then
	var config = ConfigFile.new()
	var err = config.load(runtime_config.CONFIG_FILE_PATH)
	assert_eq(err, OK)
	assert_almost_eq(AudioServer.get_bus_volume_linear(runtime_config.MAIN_BUS_IDX), config.get_value(runtime_config.AUDIO_SECTION, runtime_config.MAIN_VOLUME_CONFIG), VOLUME_COMPARISON_MARGIN)
	assert_almost_eq(AudioServer.get_bus_volume_linear(runtime_config.MUSIC_BUS_IDX), config.get_value(runtime_config.AUDIO_SECTION, runtime_config.MUSIC_VOLUME_CONFIG), VOLUME_COMPARISON_MARGIN)
	assert_almost_eq(AudioServer.get_bus_volume_linear(runtime_config.EFFECTS_BUS_IDX), config.get_value(runtime_config.AUDIO_SECTION, runtime_config.EFFECTS_VOLUME_CONFIG), VOLUME_COMPARISON_MARGIN)
	assert_eq(DisplayServer.window_get_mode(), config.get_value(runtime_config.DISPLAY_SECTION, runtime_config.DISPLAY_TYPE_CONFIG))
	assert_eq(runtime_config.visual_intensity, config.get_value(runtime_config.DISPLAY_SECTION, runtime_config.VISUAL_INTENSITY_CONFIG))
	assert_eq(runtime_config.camera_effects_intensity, config.get_value(runtime_config.DISPLAY_SECTION, runtime_config.CAMERA_EFFECTS_INTENSITY_CONFIG))


func test_create_default_config_if_not_existing():
	# given
	var config = ConfigFile.new()
	var dir := DirAccess.open(runtime_config.CONFIG_FOLDER)
	if dir.file_exists(runtime_config.CONFIG_FILE_PATH):
		config.load(runtime_config.CONFIG_FILE_PATH)
		dir.remove(runtime_config.CONFIG_FILE_PATH)
	# when
	runtime_config._ready()
	# then
	assert_true(dir.file_exists(runtime_config.CONFIG_FILE_PATH))
	# cleanup
	if config.get_sections().size() > 0:
		config.save(runtime_config.CONFIG_FILE_PATH)


func test_save_config():
	# given
	var original_config = ConfigFile.new()
	var dir := DirAccess.open(runtime_config.CONFIG_FOLDER)
	if dir.file_exists(runtime_config.CONFIG_FILE_PATH):
		original_config.load(runtime_config.CONFIG_FILE_PATH)
	_randomize_values()
	# when
	runtime_config.save_config()
	# then
	var new_config = ConfigFile.new()
	new_config.load(runtime_config.CONFIG_FILE_PATH)
	assert_eq(new_config.get_value(runtime_config.DISPLAY_SECTION, runtime_config.VISUAL_INTENSITY_CONFIG), runtime_config.visual_intensity)
	assert_eq(new_config.get_value(runtime_config.DISPLAY_SECTION, runtime_config.CAMERA_EFFECTS_INTENSITY_CONFIG), runtime_config.camera_effects_intensity)
	assert_eq(new_config.get_value(runtime_config.DISPLAY_SECTION, runtime_config.DISPLAY_TYPE_CONFIG), DisplayServer.window_get_mode())
	assert_almost_eq(new_config.get_value(runtime_config.AUDIO_SECTION, runtime_config.MAIN_VOLUME_CONFIG), AudioServer.get_bus_volume_linear(0), VOLUME_COMPARISON_MARGIN)
	assert_almost_eq(new_config.get_value(runtime_config.AUDIO_SECTION, runtime_config.MUSIC_VOLUME_CONFIG), AudioServer.get_bus_volume_linear(1), VOLUME_COMPARISON_MARGIN)
	assert_almost_eq(new_config.get_value(runtime_config.AUDIO_SECTION, runtime_config.EFFECTS_VOLUME_CONFIG), AudioServer.get_bus_volume_linear(2), VOLUME_COMPARISON_MARGIN)
	# cleanup
	if original_config.get_sections().size() > 0:
		original_config.save(runtime_config.CONFIG_FILE_PATH)


func test_get_current_camera_effects_intensity_preset():
	for intensity in runtime_config.CAMERA_EFFECTS_INTENSITY.values():
		# given
		runtime_config.camera_effects_intensity = intensity
		# when
		var res = runtime_config.get_current_camera_effects_intensity_preset()
		# then
		assert_eq(res.resource_path, runtime_config.CAMERA_EFFECTS_INTENSITY_PRESETS_PATH[intensity])


##### UTILS #####
func _randomize_values() -> void:
	runtime_config.visual_intensity = randi() % runtime_config.VISUAL_INTENSITY.values().size()
	runtime_config.camera_effects_intensity = randi() % runtime_config.CAMERA_EFFECTS_INTENSITY.values().size()
	AudioServer.set_bus_volume_linear(RuntimeConfig.MAIN_BUS_IDX, randf())
	AudioServer.set_bus_volume_linear(RuntimeConfig.MUSIC_BUS_IDX, randf())
	AudioServer.set_bus_volume_linear(RuntimeConfig.EFFECTS_BUS_IDX, randf())
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if randf() <= 0.5 else DisplayServer.WINDOW_MODE_FULLSCREEN)
