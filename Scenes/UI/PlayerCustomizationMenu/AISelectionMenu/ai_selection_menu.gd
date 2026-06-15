extends Control

# ai selection menu

##### SIGNALS #####
signal close_triggered
signal preset_selected(preset: PlayerConfig)

##### VARIABLES #####
#---- STANDARD -----
#==== ONREADY ====
@onready var presets := $"AIPresetSelectionMenu"
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
	preset_selected.emit(preset)


func _on_ai_visualisation_close_triggered() -> void:
	close_triggered.emit()


func _on_ai_visualisation_show_ai_presets_triggered() -> void:
	presets.show()
	visualisation.hide()
