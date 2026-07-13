extends MarginContainer

# ai preset selection menu

##### SIGNALS #####
signal preset_selected(preset: PlayerConfig)

##### VARIABLES #####
#---- CONSTANTS -----
const AI_PRESETS_RESOURCE := preload("res://Resources/AIPresets/ai_profiles.tres")
const PRESET_BUTTON_LOAD = preload("res://Scenes/UI/PlayerCustomizationMenu/PresetsMenu/preset.tscn")

#---- STANDARD -----
#==== ONREADY ====
@onready var presets_root := $"VBoxContainer/ScrollContainer/PresetsRoot"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	_init_presets()


##### PROTECTED METHODS #####
func _init_presets() -> void:
	_reset()
	for preset in AI_PRESETS_RESOURCE.RESOURCES:
		_add_preset_button(preset)


func _reset() -> void:
	for preset in presets_root.get_children():
		preset.queue_free()


func _add_preset_button(preset: PlayerConfig) -> void:
	var button = PRESET_BUTTON_LOAD.instantiate()
	presets_root.add_child(button)
	button.set_preset("unused", preset)
	button.connect("preset_selected", func(): _on_preset_selected(preset))


##### SIGNAL MANAGEMENT #####
func _on_preset_selected(preset: PlayerConfig) -> void:
	preset_selected.emit(preset)
