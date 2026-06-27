extends Control

# ai selection menu

##### SIGNALS #####
signal quit

##### VARIABLES #####
#---- STANDARD -----
#==== PUBLIC ====
var player_config := PlayerConfig.new()

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


func _on_ai_visualisation_close_triggered() -> void:
	quit.emit()


func _on_ai_visualisation_show_ai_presets_triggered() -> void:
	presets.show()
	visualisation.hide()


func _on_ai_preset_close_button_pressed() -> void:
	quit.emit()
