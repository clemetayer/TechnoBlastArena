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

#---- STANDARD ----- #==== PRIVATE ====
var _connected_players := { }

#==== ONREADY ====
@onready var game_config_menu := $"GameConfigMenu"
@onready var player_selection_menu := $"PlayerSelectionMenu"
@onready var game := $"Game"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	FullScreenEffects.toggle_active(false)
	game_config_menu.show()
	level_data = _create_level_data()


##### PUBLIC METHODS #####
func get_game_root() -> Node:
	return game


##### PROTECTED METHODS #####
func _create_player_data(config_path: String) -> PlayerConfig:
	var sprite_presets: SpriteCustomizationPresetsResource = load(SPRITE_PRESETS_PATH)
	sprite_presets.presets.shuffle() # to avoid picking the same element every time
	var player_config: PlayerConfig = load(config_path).duplicate()
	player_config.SPRITE_CUSTOMIZATION = sprite_presets.presets.pick_random()
	return player_config


func _create_level_data() -> LevelConfig:
	level_data = LevelConfig.new()
	level_data.level_path = DEFAULT_LEVEL_PATH
	level_data.background_and_music = DEFAULT_BACKGROUND_PATH
	return level_data


func _add_player(id: int) -> void:
	GSLogger.info("client %d connected" % id)
	player_selection_menu.add_player_connected()


func _delete_player(id: int) -> void:
	GSLogger.info("client %d disconnected" % id)
	player_selection_menu.remove_connected_player(id)


func _enrich_player_configs(player_configs: Array, lives: int) -> Dictionary:
	var formatted_players := { }
	for player_id in range(player_configs.size()):
		formatted_players[player_id] = {
			"config": player_configs[player_id],
			"lives": lives,
		}
	return formatted_players


func _show_player_selection_menu() -> void:
	player_selection_menu.visible = true


func _hide_and_reset_player_selection_menus() -> void:
	player_selection_menu.hide()


func _init_connected_players(players: Dictionary) -> void:
	_connected_players = { }
	for player_idx in range(0, players.size()):
		_connected_players[player_idx] = {
			"config": players[player_idx],
		}


##### SIGNAL MANAGEMENT #####
func _on_game_config_menu_init() -> void:
	GSLogger.debug("going to the player selection menu")
	game_config_menu.visible = false
	player_selection_menu.visible = true


func _on_game_game_over() -> void:
	GSLogger.debug("game over")
	game.reset()
	game_config_menu.visible = true
	FullScreenEffects.toggle_active(false)


func _on_player_selection_menu_game_ready(player_configs: Array, lives: int, time: int) -> void:
	GSLogger.debug("starting game")
	_connected_players = _enrich_player_configs(player_configs, lives)
	_hide_and_reset_player_selection_menus()
	game.init_level_data(level_data)
	game.init_players_data(_connected_players)
	game.add_game_elements()
	game.init_game_elements(time)
