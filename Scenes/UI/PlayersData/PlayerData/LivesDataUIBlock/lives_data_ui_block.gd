@tool
extends HBoxContainer

# Counter player data ui type 

##### VARIABLES #####
#---- EXPORTS -----
@export var LIVES: int:
	set = set_lives

#---- STANDARD -----
#==== ONREADY ====
@onready var overflow := $"Overflow"
@onready var tokens := $"AmountLeft"


##### PUBLIC METHODS #####
func set_value(value) -> void:
	set_lives(int(value))


func set_lives(lives: int) -> void:
	for child in tokens.get_children():
		child.hide()
	for child_idx in range(min(3, lives)):
		tokens.get_child(child_idx).show()
	if (lives > 3):
		overflow.text = "+%d" % [lives - 3]
	else:
		overflow.text = ""
	LIVES = lives
