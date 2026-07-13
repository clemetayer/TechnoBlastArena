extends MarginContainer

# handles the preset selection menu

##### SIGNALS #####
signal preset_selected(preset: PlayerConfig)

##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====
var _presets = { }
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
	for preset_name in _presets.keys():
		_add_preset_button(preset_name)


##### PROTECTED METHODS #####
func _get_presets() -> Dictionary:
	StaticUtils.create_folder_if_not_exists(StaticUtils.USER_CHARACTER_PRESETS_PATH)
	var presets = { }
	for resource in ResourceLoader.list_directory(StaticUtils.USER_CHARACTER_PRESETS_PATH):
		var res_load = load(StaticUtils.USER_CHARACTER_PRESETS_PATH + resource).duplicate(true)
		if res_load is PlayerConfig:
			presets[resource.replace(".tres", "")] = res_load
	return presets


func _reset_preset_root() -> void:
	for element in presets_root.get_children():
		element.queue_free()


func _add_preset_button(preset_name: String) -> void:
	var preset = _preset_button_load.instantiate()
	presets_root.add_child(preset)
	preset.set_preset(preset_name, _presets[preset_name])
	preset.preset_selected.connect(func(): _on_preset_selected(_presets[preset_name]))
	preset.preset_deleted.connect(_on_preset_preset_deleted)


##### SIGNAL MANAGEMENT #####
func _on_preset_selected(player_config: PlayerConfig) -> void:
	preset_selected.emit(player_config)


func _on_preset_preset_deleted() -> void:
	refresh()
