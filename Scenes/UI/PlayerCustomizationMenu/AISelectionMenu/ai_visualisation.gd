# AI Preview for the player selection menu
extends MarginContainer

##### SIGNALS #####
signal close_triggered
signal show_ai_presets_triggered

##### VARIABLES #####
#---- STANDARD -----
#==== ONREADY ====
@onready var player_sprite := $"VBoxContainer/PlayerSprite"
@onready var close_button := $"VBoxContainer/MarginContainer/HBoxContainer/DeleteButton"
@onready var ai_preset_selection_button := $"VBoxContainer/MarginContainer/HBoxContainer/AIPresetSelectionButton"


##### PUBLIC METHODS #####
func update_ai(player_sprite_config: SpriteCustomizationResource) -> void:
	player_sprite.update_sprite(player_sprite_config)


##### SIGNAL MANAGEMENT #####
func _on_delete_button_pressed() -> void:
	close_triggered.emit()


func _on_ai_preset_selection_button_pressed() -> void:
	show_ai_presets_triggered.emit()
