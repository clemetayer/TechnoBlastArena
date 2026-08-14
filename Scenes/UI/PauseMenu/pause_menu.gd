extends Control

# handles the pause menu

##### SIGNALS #####
signal options_triggered

##### VARIABLES #####
#---- CONSTANTS -----
const MULTIPLAYER_MENU_PATH := "res://Scenes/GameManagers/game_manager.tscn"

#---- STANDARD -----
#==== PUBLIC ====
var tree # mostly for test purposes, to easily stub the scene tree
var music_manager # same

#==== ONREADY ====
@onready var resume_button := $"CenterContainer/Panel/MarginContainer/VBoxContainer/ResumeButton"
@onready var options_button := $"CenterContainer/Panel/MarginContainer/VBoxContainer/OptionsButton"
@onready var quit_button := $"CenterContainer/Panel/MarginContainer/VBoxContainer/QuitButton"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	if tree == null: # check to avoid erasing the test stub
		tree = get_tree()
	if music_manager == null:
		music_manager = MusicManager


##### PUBLIC METHODS #####
func pause() -> void:
	show()
	music_manager.filter_in()
	tree.set_pause(true)


##### SIGNAL MANAGEMENT #####
func _on_resume_button_pressed() -> void:
	hide()
	music_manager.filter_out()
	tree.set_pause(false)


func _on_options_button_pressed() -> void:
	options_triggered.emit()


func _on_quit_button_pressed() -> void:
	tree.set_pause(false)
	music_manager.filter_out()
	tree.change_scene_to_file(MULTIPLAYER_MENU_PATH)
