extends Button
# Common button class to choose a weapon / movement bonus / powerup

##### SIGNALS #####
signal element_selected(element: ItemGridMenuElement)

##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====
var _data: ItemGridMenuElement

#==== ONREADY ====
@onready var weapon_icon := $"HBoxContainer/WeaponIcon"
@onready var weapon_name := $"HBoxContainer/WeaponName"
@onready var weapon_description := $"ToolTip/MarginContainer/ToolTipText"
@onready var custom_tooltip := $"ToolTip"


##### PUBLIC METHODS #####
func set_data(data: ItemGridMenuElement) -> void:
	_data = data
	weapon_icon.texture = load(data.ICON_PATH)
	weapon_name.text = data.NAME
	weapon_description.text = data.DESCRIPTION


##### SIGNAL MANAGEMENT #####
func _on_mouse_entered() -> void:
	custom_tooltip.show()


func _on_mouse_exited() -> void:
	custom_tooltip.hide()


func _on_pressed() -> void:
	element_selected.emit(_data)
