@tool
extends HBoxContainer

# Counter player data ui type 

##### VARIABLES #####
#---- EXPORTS -----
@export var DATA_ICON: String:
	set = set_icon
@export var QUANTITY: int:
	set = set_quantity

#---- STANDARD -----
#==== ONREADY ====
@onready var icon := $"Icon"
@onready var overflow := $"Overflow"
@onready var tokens := $"AmountLeft"


##### PUBLIC METHODS #####
func set_value(value) -> void:
	set_quantity(int(value))


func set_icon(icon_path: String) -> void:
	icon.texture = load(icon_path)
	DATA_ICON = icon_path


func set_quantity(quantity: int) -> void:
	for child in tokens.get_children():
		child.hide()
	for child_idx in range(min(3, quantity)):
		tokens.get_child(child_idx).show()
	if (quantity > 3):
		overflow.text = "+%d" % [quantity - 3]
	else:
		overflow.text = ""
	QUANTITY = quantity
