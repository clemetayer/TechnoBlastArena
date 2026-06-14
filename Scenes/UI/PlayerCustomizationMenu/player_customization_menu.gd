extends Control

# handles the player customization menu

##### VARIABLES #####
#---- CONSTANTS -----
const GAME_ROOT := "res://Scenes/GameManagers/game_manager.tscn"

#---- STANDARD -----
#==== ONREADY ====
@onready var player_customization_ui := $"MarginContainer/MarginContainer/PlayerCustomizationUI"


##### PROTECTED METHODS #####
func _return_to_previous_menu() -> void:
	get_tree().change_scene_to_file(GAME_ROOT)


##### SIGNAL MANAGEMENT #####
func _on_player_customization_ui_quit() -> void:
	_return_to_previous_menu()
