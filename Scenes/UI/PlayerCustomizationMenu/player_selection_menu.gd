extends Control

# Main script for the player selection menu

##### SIGNALS #####
signal players_ready(player_configs: Array)

##### VARIABLES #####
#---- STANDARD -----
#==== ONREADY ====
@onready var player_selection_items := $"MarginContainer/VBoxContainer/PlayerGrid"
@onready var start_button := $"MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/StartButton"


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
	players_ready.emit(_get_players_config())
