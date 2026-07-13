extends Control

# Main script for the player selection menu

##### SIGNALS #####
signal game_ready(player_configs: Array, lives: int, time: int)

##### VARIABLES #####
#---- CONSTANTS -----
const MAIN_MENU_PATH := "res://Scenes/UI/MainMenu/main_menu.tscn"

#---- STANDARD -----
#==== ONREADY ====
@onready var player_selection_items := $"MarginContainer/VBoxContainer/PlayerGrid"
@onready var start_button := $"MarginContainer/VBoxContainer/GameConfig/StartButton"
@onready var lives := $"MarginContainer/VBoxContainer/GameConfig/MarginContainer/HBoxContainer/LivesConfig"
@onready var time := $"MarginContainer/VBoxContainer/GameConfig/MarginContainer/HBoxContainer/TimeConfig"


##### PROTECTED METHODS #####
func _get_players_config() -> Array:
	var configs := []
	for player_selection_item in player_selection_items.get_children():
		var config = player_selection_item.get_config()
		if config != null:
			configs.append(config)
	return configs


##### SIGNAL MANAGEMENT #####
func _on_start_button_pressed() -> void:
	game_ready.emit(_get_players_config(), lives.get_lives(), time.get_time())


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
