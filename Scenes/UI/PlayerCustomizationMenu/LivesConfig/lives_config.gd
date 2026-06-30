extends HBoxContainer

##### VARIABLES #####
#---- STANDARD -----
#==== ONREADY ====
@onready var lives := $"Lives"


##### PUBLIC METHODS #####
func get_lives() -> int:
	return lives.value
