extends Control

# ai selection menu

##### SIGNALS #####
signal quit
signal config_changed

##### VARIABLES #####
#---- STANDARD -----
#==== PUBLIC ====
var player_config: PlayerConfig = null

#==== ONREADY ====
@onready var presets := $"AIPresetSelectionMenu"
@onready var presets_close_button := $"AIPresetSelectionMenu/AIPresetCloseButton"
@onready var visualisation := $"AIVisualisation"


##### PUBLIC METHODS #####
func open() -> void:
	presets.show()
	visualisation.hide()


##### SIGNAL MANAGEMENT #####
func _on_ai_preset_selection_menu_preset_selected(preset: PlayerConfig) -> void:
	visualisation.update_ai(preset)
	presets.hide()
	visualisation.show()
	player_config = preset
	config_changed.emit()


func _on_ai_visualisation_close_triggered() -> void:
	player_config = null
	quit.emit()
	config_changed.emit()


func _on_ai_visualisation_show_ai_presets_triggered() -> void:
	player_config = null
	presets.show()
	visualisation.hide()
	config_changed.emit()


func _on_ai_preset_close_button_pressed() -> void:
	player_config = null
	quit.emit()
	config_changed.emit()
