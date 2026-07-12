extends VBoxContainer

# Handles the audio settings in the options menu

##### VARIABLES #####
#---- STANDARD -----
#==== ONREADY ====
@onready var main_volume := $"Main/MainVolumeSlider"
@onready var music_volume := $"Music/MusicVolumeSlider"
@onready var effects_volume := $"Effects/EffectsVolumeSlider"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	main_volume.value = AudioServer.get_bus_volume_linear(RuntimeConfig.MAIN_BUS_IDX) * 100.0
	music_volume.value = AudioServer.get_bus_volume_linear(RuntimeConfig.MUSIC_BUS_IDX) * 100.0
	effects_volume.value = AudioServer.get_bus_volume_linear(RuntimeConfig.EFFECTS_BUS_IDX) * 100.0


##### SIGNAL MANAGEMENT #####
func _on_main_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(RuntimeConfig.MAIN_BUS_IDX, value / 100.0)


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(RuntimeConfig.MUSIC_BUS_IDX, value / 100.0)


func _on_effects_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(RuntimeConfig.EFFECTS_BUS_IDX, value / 100.0)
