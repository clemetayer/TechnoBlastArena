extends Node2D

##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====
var players_data = { }
var level_data

#==== ONREADY ====
@onready var game := $"Game"


##### PUBLIC METHODS #####
func set_player_data(id: int, config: PlayerConfig) -> void:
	players_data[id] = { }
	players_data[id]["config"] = config


func init_players_data() -> void:
	var data = { }
	for player_id in players_data.keys():
		data[player_id] = { }
		data[player_id]["config"] = players_data[player_id].config
		data[player_id]["lives"] = 3
	game.init_players_data(data)


func set_level_data(data: LevelConfig) -> void:
	level_data = data


func init_level_data() -> void:
	game.init_level_data(level_data)


func add_game_elements() -> void:
	game.add_game_elements()


func init_game_elements() -> void:
	game.init_game_elements(60)


func get_pause_menu() -> Node:
	return game.ui.pause_menu


func get_pause_option_menu() -> Node:
	return game.ui.options_menu
