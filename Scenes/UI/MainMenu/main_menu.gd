extends Control

# handles the main menu

##### VARIABLES #####
#---- CONSTANTS -----
const MULTIPLAYER_MENU_PATH := "res://Scenes/GameManagers/game_manager.tscn"
const OPTIONS_MENU_PATH := "res://Scenes/UI/OptionsMenu/options_menu.tscn"
const CUSTOMIZATION_MENU_PATH := "res://Scenes/UI/PlayerCustomizationMenu/player_customization_menu.tscn"

#---- STANDARD -----
#==== PUBLIC ====
var tree # mostly for test purposes, to easily stub the scene tree

#==== ONREADY ====
@onready var multiplayer_button := $"MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/Multiplayer"
@onready var options_button := $"MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/Options"
@onready var customization_button := $"MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/Customization"
@onready var quit_button := $"MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/Quit"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	if tree == null: # check to avoid erasing the test stub
		tree = get_tree()


##### SIGNAL MANAGEMENT #####
func _on_multiplayer_pressed() -> void:
	tree.change_scene_to_file(MULTIPLAYER_MENU_PATH)


func _on_options_pressed() -> void:
	tree.change_scene_to_file(OPTIONS_MENU_PATH)


func _on_customization_pressed() -> void:
	tree.change_scene_to_file(CUSTOMIZATION_MENU_PATH)


func _on_quit_pressed() -> void:
	tree.quit()
