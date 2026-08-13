extends Control

# Handles the options menu

##### SIGNALS #####
signal return_triggered

##### VARIABLES #####
#---- CONSTANTS -----
const MAIN_MENU_PATH := "res://Scenes/UI/MainMenu/main_menu.tscn"

#---- STANDARD -----
#==== PUBLIC ====
var runtime_config := RuntimeConfig

#==== ONREADY ====
@onready var back_button := $"MarginContainer/MarginContainer/BackButton"
@onready var audio_settings := $"MarginContainer/MarginContainer/VBoxContainer/MarginContainer/ScrollContainer/VBoxContainer/AudioSettings"
@onready var display_settings := $"MarginContainer/MarginContainer/VBoxContainer/MarginContainer/ScrollContainer/VBoxContainer/DisplaySettings"


##### SIGNAL MANAGEMENT #####
func _on_back_button_pressed() -> void:
	runtime_config.save_config()
	return_triggered.emit()
