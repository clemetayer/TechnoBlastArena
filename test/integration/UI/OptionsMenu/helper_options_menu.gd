extends Node

# helper for the options menu

##### VARIABLES #####
#---- CONSTANTS -----
# const constant := 10 # Optionnal comment

#---- EXPORTS -----
# @export var EXPORT_NAME := 10.0 # Optionnal comment

#---- STANDARD -----
#==== PUBLIC ====
# var public_var # Optionnal comment

#==== PRIVATE ====
var _menu


##### PUBLIC METHODS #####
func set_options_menu(menu):
	_menu = menu


func set_main_volume_value_slider(value: float) -> void:
	_menu.audio_settings.main_volume.value = value
	_menu.audio_settings.main_volume.value_changed.emit(value)


func get_main_volume_bus() -> float:
	return AudioServer.get_bus_volume_linear(RuntimeConfig.MAIN_BUS_IDX)


func set_music_volume_value_slider(value: float) -> void:
	_menu.audio_settings.music_volume.value = value
	_menu.audio_settings.music_volume.value_changed.emit(value)


func get_music_volume_bus() -> float:
	return AudioServer.get_bus_volume_linear(RuntimeConfig.MUSIC_BUS_IDX)


func set_effects_volume_value_slider(value: float) -> void:
	_menu.audio_settings.effects_volume.value = value
	_menu.audio_settings.effects_volume.value_changed.emit(value)


func get_effects_volume_bus() -> float:
	return AudioServer.get_bus_volume_linear(RuntimeConfig.EFFECTS_BUS_IDX)


func set_display_type_button(windowed: bool) -> void:
	_menu.display_settings.display_type_button.select(0 if windowed else 1)
	_menu.display_settings.display_type_button.item_selected.emit(0 if windowed else 1)


func get_display_type() -> DisplayServer.WindowMode:
	return DisplayServer.window_get_mode()


func set_visual_intensity_button(value: RuntimeConfig.VISUAL_INTENSITY) -> void:
	_menu.display_settings.visual_intensity_button.select(value as int)
	_menu.display_settings.visual_intensity_button.item_selected.emit(value as int)


func get_visual_intensity() -> RuntimeConfig.VISUAL_INTENSITY:
	return RuntimeConfig.visual_intensity


func set_camera_effects_intensity_button(value: RuntimeConfig.CAMERA_EFFECTS_INTENSITY) -> void:
	_menu.display_settings.camera_effects_intensity_button.select(value as int)
	_menu.display_settings.camera_effects_intensity_button.item_selected.emit(value as int)


func get_camera_effects_intensity() -> RuntimeConfig.CAMERA_EFFECTS_INTENSITY:
	return RuntimeConfig.camera_effects_intensity


func randomize_all():
	randomize_audio_values()
	randomize_display_values()


func randomize_audio_values():
	set_main_volume_value_slider(randf() * 100.0)
	set_music_volume_value_slider(randf() * 100.0)
	set_effects_volume_value_slider(randf() * 100.0)


func randomize_display_values():
	set_display_type_button(randf() <= 0.5)
	set_visual_intensity_button(RuntimeConfig.VISUAL_INTENSITY.values().pick_random())
	set_camera_effects_intensity_button(RuntimeConfig.CAMERA_EFFECTS_INTENSITY.values().pick_random())


func press_return_button():
	_menu.back_button.pressed.emit()


func load_user_config() -> ConfigFile:
	var config = ConfigFile.new()
	config.load(RuntimeConfig.CONFIG_FILE_PATH)
	return config
