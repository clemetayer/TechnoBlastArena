extends HBoxContainer

##### VARIABLES #####
#---- STANDARD -----
#==== ONREADY ====
@onready var minutes := $"Minutes"
@onready var seconds := $"Seconds"


##### PUBLIC METHODS #####
func get_time() -> int:
	return minutes.value * 60 + seconds.value
