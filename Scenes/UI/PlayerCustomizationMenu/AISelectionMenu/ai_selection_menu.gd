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
@onready var visualisation := $"AIVisualisation"


##### PUBLIC METHODS #####
func open() -> void:
	presets.show()
	visualisation.hide()


##### SIGNAL MANAGEMENT #####
func _on_ai_preset_selection_menu_preset_selected(preset: PlayerConfig) -> void:
	visualisation.update_ai(preset.SPRITE_CUSTOMIZATION)
	presets.hide()
	visualisation.show()
	player_config = preset


func _on_ai_visualisation_close_triggered() -> void:
	quit.emit()


func _on_ai_visualisation_show_ai_presets_triggered() -> void:
	presets.show()
	visualisation.hide()
