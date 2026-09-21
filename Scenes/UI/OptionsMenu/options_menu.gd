extends Control

# Handles the options menu

##### SIGNALS #####
signal return_triggered

##### VARIABLES #####
#---- CONSTANTS -----
const MAIN_MENU_PATH := "res://Scenes/UI/MainMenu/main_menu.tscn"

#---- EXPORTS -----
@export var IS_FROM_PAUSE_MENU := false

#---- STANDARD -----
#==== PUBLIC ====
var runtime_config := RuntimeConfig

#==== ONREADY ====
@onready var back_button := $"MarginContainer/MarginContainer/BackButton"
@onready var audio_settings := $"MarginContainer/MarginContainer/VBoxContainer/MarginContainer/ScrollContainer/VBoxContainer/AudioSettings"
@onready var display_settings := $"MarginContainer/MarginContainer/VBoxContainer/MarginContainer/ScrollContainer/VBoxContainer/DisplaySettings"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	display_settings.IS_FROM_PAUSE_MENU = IS_FROM_PAUSE_MENU


##### SIGNAL MANAGEMENT #####
func _on_back_button_pressed() -> void:
	runtime_config.save_config()
	return_triggered.emit()
