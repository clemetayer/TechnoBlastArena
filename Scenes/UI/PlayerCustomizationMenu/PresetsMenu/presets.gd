extends MarginContainer

# handles the preset selection menu

##### SIGNALS #####
signal preset_selected(preset: PlayerConfig)

##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====
var _presets = []
var _preset_button_load = preload("res://Scenes/UI/PlayerCustomizationMenu/PresetsMenu/preset.tscn")

#==== ONREADY ====
@onready var presets_root := $"VBoxContainer/ScrollContainer/ElementsList"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	refresh()


##### PUBLIC #####
func refresh() -> void:
	_reset_preset_root()
	_presets = _get_presets()
	for preset in _presets:
		_add_preset_button(preset)


##### PROTECTED METHODS #####
func _get_presets() -> Array:
	StaticUtils.create_folder_if_not_exists(StaticUtils.USER_CHARACTER_PRESETS_PATH)
	var presets = []
	for resource in ResourceLoader.list_directory(StaticUtils.USER_CHARACTER_PRESETS_PATH):
		var res_load = load(StaticUtils.USER_CHARACTER_PRESETS_PATH + resource).duplicate(true)
		if res_load is PlayerConfig:
			presets.append(res_load)
	return presets


func _reset_preset_root() -> void:
	for element in presets_root.get_children():
		element.free()


func _add_preset_button(preset: PlayerConfig) -> void:
	var button = _preset_button_load.instantiate()
	presets_root.add_child(button)
	button.set_preset(preset)
	button.connect("pressed", func(): _on_preset_selected(preset))


##### SIGNAL MANAGEMENT #####
func _on_close_button_pressed() -> void:
	emit_signal("close_triggered")


func _on_preset_selected(player_config: PlayerConfig) -> void:
	emit_signal("preset_selected", player_config)
