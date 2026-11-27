extends Control

# Handles one item for the player selection menu

##### SIGNALS #####
signal player_toggled

##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====
var _current_device_id: int = -1

#==== ONREADY ====
@onready var empty_menu := $"Panel/EmptyMenu"
@onready var user_menu := $"Panel/PlayerCustomizationMenu"
@onready var ai_menu := $"Panel/AiSelectionMenu"
@onready var add_ai_button := $"Panel/EmptyMenu/AddAI"


##### PUBLIC METHODS #####
# returns the current player config or null if there is no player in the item
func get_config():
	if user_menu.visible:
		return user_menu.player_config
	if ai_menu.visible:
		return ai_menu.player_config
	return null


func get_device_id() -> int:
	return _current_device_id


func add_user(device_id: int) -> void:
	empty_menu.hide()
	user_menu.show()
	player_toggled.emit()
	_current_device_id = device_id


##### SIGNAL MANAGEMENT #####
func _on_add_ai_pressed() -> void:
	empty_menu.hide()
	ai_menu.show()


func _on_player_customization_menu_quit() -> void:
	user_menu.hide()
	empty_menu.show()
	player_toggled.emit()
	_current_device_id = -1


func _on_ai_selection_menu_quit() -> void:
	ai_menu.hide()
	empty_menu.show()
	player_toggled.emit()


func _on_ai_selection_menu_config_changed() -> void:
	player_toggled.emit()
