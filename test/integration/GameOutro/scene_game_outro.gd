extends Node2D

##### SIGNALS #####
# Node signals

##### ENUMS #####
# enumerations

##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====
var players_data = { }
var level_data

#==== ONREADY ====
@onready var onready_paths := {
	"game": $"Game",
}


##### PUBLIC METHODS #####
func get_game() -> Node:
	return onready_paths.game


func set_player_data(id: int, config: PlayerConfig) -> void:
	players_data[id] = { }
	players_data[id]["config"] = config


func init_players_data() -> void:
	var data = { }
	for player_id in players_data.keys():
		data[player_id] = { }
		data[player_id]["config"] = players_data[player_id].config
	onready_paths.game.init_players_data(data)


func set_level_data(data: LevelConfig) -> void:
	level_data = data


func init_level_data() -> void:
	onready_paths.game.init_level_data(level_data)


func add_game_elements() -> void:
	onready_paths.game.add_game_elements()


func init_game_elements() -> void:
	onready_paths.game.init_game_elements(600)


func get_game_message() -> String:
	return onready_paths.game \
	.onready_paths.ui \
	.onready_paths.screen_message \
	.onready_paths.label.text

##### PROTECTED METHODS #####
# Methods that are intended to be used exclusively by this scripts
# func _private_method(arg):
#     pass

##### SIGNAL MANAGEMENT #####
# Functions that should be triggered when a specific signal is received
