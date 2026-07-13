extends Node

##### ENUMS #####
enum VISUAL_INTENSITY { NONE, LOW, MID, HIGH }
enum CAMERA_EFFECTS_INTENSITY { NONE, LOW, MID, HIGH }

##### VARIABLES #####
#---- CONSTANTS -----
#++++ CONFIG VARIABLES ++++
const AUDIO_SECTION = "Audio"
const DISPLAY_SECTION = "Display"
const VISUAL_INTENSITY_CONFIG = "visual_intensity"
const CAMERA_EFFECTS_INTENSITY_CONFIG = "camera_effects_intensity"
const DISPLAY_TYPE_CONFIG = "display_type"
const MAIN_VOLUME_CONFIG = "main_volume"
const MUSIC_VOLUME_CONFIG = "music_volume"
const EFFECTS_VOLUME_CONFIG = "effects_volume"

#++++ OTHER VARIABLES ++++
const MAIN_BUS_IDX := 0
const MUSIC_BUS_IDX := 1
const EFFECTS_BUS_IDX := 2

#++++ FILE PATHS ++++
const CONFIG_FOLDER := "user://"
const CONFIG_FILE_PATH := CONFIG_FOLDER + "user_configs.conf"
const CAMERA_EFFECTS_INTENSITY_PRESETS_PATH := {
	CAMERA_EFFECTS_INTENSITY.NONE: "res://Scenes/Camera/CameraEffectsIntensityPresets/none.tres",
	CAMERA_EFFECTS_INTENSITY.LOW: "res://Scenes/Camera/CameraEffectsIntensityPresets/low.tres",
	CAMERA_EFFECTS_INTENSITY.MID: "res://Scenes/Camera/CameraEffectsIntensityPresets/mid.tres",
	CAMERA_EFFECTS_INTENSITY.HIGH: "res://Scenes/Camera/CameraEffectsIntensityPresets/high.tres",
}

#---- STANDARD -----
#==== PUBLIC ====
var visual_intensity: VISUAL_INTENSITY = VISUAL_INTENSITY.LOW
var camera_effects_intensity: CAMERA_EFFECTS_INTENSITY = CAMERA_EFFECTS_INTENSITY.LOW:
	set = _set_camera_effects_intensity

#==== PRIVATE ====
var _camera_effects_intensity_preset_cache: Resource = preload(CAMERA_EFFECTS_INTENSITY_PRESETS_PATH[CAMERA_EFFECTS_INTENSITY.LOW])


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	_create_default_config_if_needed()
	_set_user_config()
	GSLogger.set_logger_level(GSLogger.LOG_LEVEL_ALL)


##### PUBLIC METHODS #####
func save_config() -> void:
	_get_current_config().save(CONFIG_FILE_PATH)
	GSLogger.info("Config saved !")


func get_current_camera_effects_intensity_preset() -> Resource:
	return _camera_effects_intensity_preset_cache


##### PROTECTED METHODS #####
func _set_camera_effects_intensity(new_intensity: CAMERA_EFFECTS_INTENSITY) -> void:
	camera_effects_intensity = new_intensity
	_camera_effects_intensity_preset_cache = load(CAMERA_EFFECTS_INTENSITY_PRESETS_PATH[new_intensity])


func _create_default_config_if_needed() -> void:
	var dir := DirAccess.open(CONFIG_FOLDER)
	if not dir.file_exists(CONFIG_FILE_PATH):
		GSLogger.info("No config file detected : creating default config")
		_get_default_config().save(CONFIG_FILE_PATH)


func _get_default_config() -> ConfigFile:
	var config = ConfigFile.new()
	config.set_value(DISPLAY_SECTION, VISUAL_INTENSITY_CONFIG, VISUAL_INTENSITY.MID)
	config.set_value(DISPLAY_SECTION, CAMERA_EFFECTS_INTENSITY_CONFIG, CAMERA_EFFECTS_INTENSITY.MID)
	config.set_value(DISPLAY_SECTION, DISPLAY_TYPE_CONFIG, DisplayServer.WINDOW_MODE_WINDOWED)
	config.set_value(AUDIO_SECTION, MAIN_VOLUME_CONFIG, 1.0)
	config.set_value(AUDIO_SECTION, MUSIC_VOLUME_CONFIG, 1.0)
	config.set_value(AUDIO_SECTION, EFFECTS_VOLUME_CONFIG, 1.0)
	return config


func _get_current_config() -> ConfigFile:
	var config = ConfigFile.new()
	config.set_value(DISPLAY_SECTION, VISUAL_INTENSITY_CONFIG, visual_intensity)
	config.set_value(DISPLAY_SECTION, CAMERA_EFFECTS_INTENSITY_CONFIG, camera_effects_intensity)
	config.set_value(DISPLAY_SECTION, DISPLAY_TYPE_CONFIG, DisplayServer.window_get_mode())
	config.set_value(AUDIO_SECTION, MAIN_VOLUME_CONFIG, AudioServer.get_bus_volume_linear(MAIN_BUS_IDX))
	config.set_value(AUDIO_SECTION, MUSIC_VOLUME_CONFIG, AudioServer.get_bus_volume_linear(MUSIC_BUS_IDX))
	config.set_value(AUDIO_SECTION, EFFECTS_VOLUME_CONFIG, AudioServer.get_bus_volume_linear(EFFECTS_BUS_IDX))
	return config


func _set_user_config() -> void:
	var config = ConfigFile.new()
	config.load(CONFIG_FILE_PATH)
	visual_intensity = config.get_value(DISPLAY_SECTION, VISUAL_INTENSITY_CONFIG)
	camera_effects_intensity = config.get_value(DISPLAY_SECTION, CAMERA_EFFECTS_INTENSITY_CONFIG)
	DisplayServer.window_set_mode(config.get_value(DISPLAY_SECTION, DISPLAY_TYPE_CONFIG))
	AudioServer.set_bus_volume_linear(MAIN_BUS_IDX, config.get_value(AUDIO_SECTION, MAIN_VOLUME_CONFIG))
	AudioServer.set_bus_volume_linear(MUSIC_BUS_IDX, config.get_value(AUDIO_SECTION, MUSIC_VOLUME_CONFIG))
	AudioServer.set_bus_volume_linear(EFFECTS_BUS_IDX, config.get_value(AUDIO_SECTION, EFFECTS_VOLUME_CONFIG))
