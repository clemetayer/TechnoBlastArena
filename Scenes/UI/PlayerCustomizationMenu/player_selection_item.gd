extends Control

# Handles one item for the player selection menu

##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====

#==== ONREADY ====
@onready var empty_menu := $"Panel/EmptyMenu"
@onready var user_menu := $"Panel/PlayerCustomizationMenu"
@onready var ai_menu := $"Panel/AiSelectionMenu"
@onready var add_user_button := $"Panel/EmptyMenu/AddUser"
@onready var add_ai_button := $"Panel/EmptyMenu/AddAI"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


##### PUBLIC METHODS #####
# returns the current player config or null if there is no player in the item
func get_config() -> PlayerConfig:
	if user_menu.visible:
		return user_menu.player_config
	if ai_menu.visible:
		return ai_menu.player_config
	return null


##### PROTECTED METHODS #####
func _on_add_ai_pressed() -> void:
	empty_menu.hide()
	ai_menu.show()


func _on_add_user_pressed() -> void:
	empty_menu.hide()
	user_menu.show()


func _on_player_customization_menu_quit() -> void:
	user_menu.hide()
	empty_menu.show()


func _on_ai_selection_menu_quit() -> void:
	ai_menu.hide()
	empty_menu.show()
