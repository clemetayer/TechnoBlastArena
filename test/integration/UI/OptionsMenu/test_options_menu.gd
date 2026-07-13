extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const VOLUME_COMPARISON_MARGIN := 0.0001

#---- VARIABLES -----
var options_menu
var user_configs: ConfigFile
var save_path: String
var helper


##### SETUP #####
func before_all():
	var temp = autofree(load("res://Utils/Config/runtime_config.gd").new())
	user_configs = ConfigFile.new()
	save_path = temp.CONFIG_FILE_PATH
	user_configs.load(save_path)


func before_each():
	options_menu = add_child_autofree(load("res://Scenes/UI/OptionsMenu/options_menu.tscn").instantiate())
	helper = autofree(load("res://test/integration/UI/OptionsMenu/helper_options_menu.gd").new())
	helper.set_options_menu(options_menu)


##### TEARDOWN #####
func after_all():
	if user_configs.get_sections().size() > 0:
		user_configs.save(save_path)


##### TESTS #####
func test_set_display_settings():
	# given
	var windowed = randf() <= 0.5
	var visual_intensity = RuntimeConfig.VISUAL_INTENSITY.values().pick_random()
	var camera_effects_intensity = RuntimeConfig.CAMERA_EFFECTS_INTENSITY.values().pick_random()
	# when
	helper.set_display_type_button(windowed)
	helper.set_visual_intensity_button(visual_intensity)
	helper.set_camera_effects_intensity_button(camera_effects_intensity)
	# then
	assert_eq(helper.get_display_type(), DisplayServer.WINDOW_MODE_WINDOWED if windowed else DisplayServer.WINDOW_MODE_FULLSCREEN)
	assert_eq(helper.get_visual_intensity(), visual_intensity)
	assert_eq(helper.get_camera_effects_intensity(), camera_effects_intensity)


func test_set_audio_settings():
	# given
	var main_volume := randf()
	var music_volume := randf()
	var effects_volume := randf()
	# when
	helper.set_main_volume_value_slider(main_volume * 100.0)
	helper.set_music_volume_value_slider(music_volume * 100.0)
	helper.set_effects_volume_value_slider(effects_volume * 100.0)
	# then
	assert_almost_eq(helper.get_main_volume_bus(), main_volume, VOLUME_COMPARISON_MARGIN)
	assert_almost_eq(helper.get_music_volume_bus(), music_volume, VOLUME_COMPARISON_MARGIN)
	assert_almost_eq(helper.get_effects_volume_bus(), effects_volume, VOLUME_COMPARISON_MARGIN)


func test_save_settings():
	# given
	var tree = mock_scene_tree()
	stub(tree, "change_scene_to_file").to_do_nothing()
	helper.randomize_all()
	# when
	helper.press_return_button()
	# then
	user_config_equals_values(helper.load_user_config())


##### UTILS #####
func mock_scene_tree():
	var scene_tree = double(SceneTree).new()
	options_menu.tree = scene_tree
	return scene_tree


func user_config_equals_values(config: ConfigFile) -> void:
	assert_almost_eq(config.get_value(RuntimeConfig.AUDIO_SECTION, RuntimeConfig.MAIN_VOLUME_CONFIG), helper.get_main_volume_bus(), VOLUME_COMPARISON_MARGIN)
	assert_almost_eq(config.get_value(RuntimeConfig.AUDIO_SECTION, RuntimeConfig.MUSIC_VOLUME_CONFIG), helper.get_music_volume_bus(), VOLUME_COMPARISON_MARGIN)
	assert_almost_eq(config.get_value(RuntimeConfig.AUDIO_SECTION, RuntimeConfig.EFFECTS_VOLUME_CONFIG), helper.get_effects_volume_bus(), VOLUME_COMPARISON_MARGIN)
	assert_eq(config.get_value(RuntimeConfig.DISPLAY_SECTION, RuntimeConfig.DISPLAY_TYPE_CONFIG), helper.get_display_type())
	assert_eq(config.get_value(RuntimeConfig.DISPLAY_SECTION, RuntimeConfig.VISUAL_INTENSITY_CONFIG), helper.get_visual_intensity())
	assert_eq(config.get_value(RuntimeConfig.DISPLAY_SECTION, RuntimeConfig.CAMERA_EFFECTS_INTENSITY_CONFIG), helper.get_camera_effects_intensity())
