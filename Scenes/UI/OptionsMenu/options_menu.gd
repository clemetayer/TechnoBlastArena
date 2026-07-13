extends Control

# Handles the options menu

##### VARIABLES #####
#---- CONSTANTS -----
const MAIN_MENU_PATH := "res://Scenes/UI/MainMenu/main_menu.tscn"

#---- STANDARD -----
#==== PUBLIC ====
var runtime_config := RuntimeConfig
var tree

#==== ONREADY ====
@onready var back_button := $"MarginContainer/MarginContainer/BackButton"
@onready var audio_settings := $"MarginContainer/MarginContainer/VBoxContainer/MarginContainer/ScrollContainer/VBoxContainer/AudioSettings"
@onready var display_settings := $"MarginContainer/MarginContainer/VBoxContainer/MarginContainer/ScrollContainer/VBoxContainer/DisplaySettings"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	if tree == null: # check to avoid erasing the test stub
		tree = get_tree()


##### SIGNAL MANAGEMENT #####
func _on_back_button_pressed() -> void:
	runtime_config.save_config()
	tree.change_scene_to_file(MAIN_MENU_PATH)
