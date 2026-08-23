extends Node

class_name GameManager
# Manages the game

##### VARIABLES #####
#---- CONSTANTS -----
const SPRITE_PRESETS_PATH := "res://Scenes/Player/SpriteCustomizationPresets/presets.tres"
const INPUT_PLAYER_CONFIG_PATH := "res://Scenes/Player/PlayerConfigs/input_player_config.tres"
const RECORD_PLAYER_CONFIG_PATH := "res://Scenes/Player/PlayerConfigs/record_player_config.tres"
const DEFAULT_LEVEL_PATH := "res://Scenes/Levels/Level1/level_1_map.tscn"
const DEFAULT_BACKGROUND_PATH := "res://Scenes/Levels/Backgrounds/TriangleCity/triangle_city.tscn"

#---- EXPORTS -----
@export var level_data: LevelConfig

#---- STANDARD -----
#==== PUBLIC ====
var full_screen_effects := FullScreenEffects

#==== PRIVATE ====
var _players := { }

#==== ONREADY ====
@onready var player_selection_menu := $"PlayerSelectionMenu"
@onready var victory_screen := $"VictoryScreen"
@onready var game := $"Game"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	full_screen_effects.toggle_active(false)
	player_selection_menu.show()
	level_data = _create_level_data()


##### PUBLIC METHODS #####
func get_game_root() -> Node:
	return game


##### PROTECTED METHODS #####
func _create_level_data() -> LevelConfig:
	level_data = LevelConfig.new()
	level_data.level_path = DEFAULT_LEVEL_PATH
	level_data.background_and_music = DEFAULT_BACKGROUND_PATH
	return level_data


func _enrich_player_configs(player_configs: Array, lives: int) -> Dictionary:
	var formatted_players := { }
	for player_id in range(player_configs.size()):
		formatted_players[player_id] = { "config": player_configs[player_id], "lives": lives }
	return formatted_players


##### SIGNAL MANAGEMENT #####
func _on_game_game_over(players_rank: Array) -> void:
	GSLogger.debug("game over")
	game.reset()
	victory_screen.show_victory(players_rank)
	full_screen_effects.toggle_active(false)


func _on_player_selection_menu_game_ready(player_configs: Array, lives: int, time: int) -> void:
	GSLogger.debug("starting game")
	_players = _enrich_player_configs(player_configs, lives)
	player_selection_menu.hide()
	game.init_level_data(level_data)
	game.init_players_data(_players)
	game.add_game_elements()
	game.init_game_elements(time)


func _on_victory_screen_next() -> void:
	victory_screen.hide()
	player_selection_menu.show()
