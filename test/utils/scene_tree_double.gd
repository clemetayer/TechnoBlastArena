extends Node

# utilitary class to mock the scene tree for the tests

##### SIGNALS #####
# Node signals

##### ENUMS #####
# enumerations

##### VARIABLES #####
#---- CONSTANTS -----
const GAME_ROOT_PATH := "res://Scenes/GameManagers/game_manager.tscn"

#---- EXPORTS -----
# @export var EXPORT_NAME := 10.0 # Optionnal comment

#---- STANDARD -----
#==== PUBLIC ====
# var public_var # Optionnal comment

#==== PRIVATE ====
# var _private_var # Optionnal comment

#==== ONREADY ====
@onready var player_customization_ui := $"Margin"


##### PROTECTED METHODS #####
func _return_to_previous_menu() -> void:
	get_tree().change_scene_to_file(GAME_ROOT_PATH)

##### SIGNAL MANAGEMENT #####
# Functions that should be triggered when a specific signal is received
