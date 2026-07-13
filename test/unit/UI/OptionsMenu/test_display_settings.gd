extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var display_settings
var runtime_config

var original_window_mode
var original_visual_intensity
var original_camera_effects_intensity


##### SETUP #####
func before_all():
	original_window_mode = DisplayServer.window_get_mode()
	original_visual_intensity = RuntimeConfig.visual_intensity
	original_camera_effects_intensity = RuntimeConfig.camera_effects_intensity


func before_each():
	display_settings = add_child_autofree(load("res://Scenes/UI/OptionsMenu/display_settings.tscn").instantiate())


##### TEARDOWN #####
func after_all():
	DisplayServer.window_set_mode(original_window_mode)
	RuntimeConfig.visual_intensity = original_visual_intensity
	RuntimeConfig.camera_effects_intensity = original_camera_effects_intensity


##### TESTS #####
func test_init():
	# given
	_randomize_settings()
	# when
	display_settings._ready()
	# then
	assert_eq(display_settings.display_type_button.selected, 0 if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED else 1)
	assert_eq(display_settings.visual_intensity_button.selected, RuntimeConfig.visual_intensity as int)
	assert_eq(display_settings.camera_effects_intensity_button.selected, RuntimeConfig.camera_effects_intensity as int)


func test_set_display_type():
	# when
	display_settings.display_type_button.item_selected.emit(0)
	# then
	assert_eq(DisplayServer.window_get_mode(), DisplayServer.WINDOW_MODE_WINDOWED)
	# when
	display_settings.display_type_button.item_selected.emit(1)
	# then
	assert_eq(DisplayServer.window_get_mode(), DisplayServer.WINDOW_MODE_FULLSCREEN)


func test_set_visual_intensity():
	for intensity_idx in range(display_settings.visual_intensity_button.item_count):
		# given
		var intensity := intensity_idx as RuntimeConfig.VISUAL_INTENSITY
		# when
		display_settings.visual_intensity_button.item_selected.emit(intensity_idx)
		# then
		assert_eq(RuntimeConfig.visual_intensity, intensity)


func test_set_camera_effects_intensity():
	for intensity_idx in range(display_settings.camera_effects_intensity_button.item_count):
		# given
		var intensity := intensity_idx as RuntimeConfig.CAMERA_EFFECTS_INTENSITY
		# when
		display_settings.camera_effects_intensity_button.item_selected.emit(intensity_idx)
		# then
		assert_eq(RuntimeConfig.camera_effects_intensity, intensity)


##### UTILS #####
func _randomize_settings() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if randf() <= 0.5 else DisplayServer.WINDOW_MODE_FULLSCREEN)
	RuntimeConfig.visual_intensity = RuntimeConfig.VISUAL_INTENSITY.values().pick_random()
	RuntimeConfig.camera_effects_intensity = RuntimeConfig.CAMERA_EFFECTS_INTENSITY.values().pick_random()
