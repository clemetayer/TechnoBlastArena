@tool
extends HBoxContainer

# Counter player data ui type 

##### VARIABLES #####
#---- EXPORTS -----
@export var DATA_ICON: String:
	set = set_icon
@export var PROGRESS: float:
	set = set_progress

#---- STANDARD -----
#==== ONREADY ====
@onready var icon := $"Icon"
@onready var overflow := $"Overflow"
@onready var progress := $"ProgressBar"


##### PUBLIC METHODS #####
func set_value(value) -> void:
	set_progress(float(value))


func set_icon(icon_path: String) -> void:
	icon.texture = load(icon_path)
	DATA_ICON = icon_path


func set_progress(value: float) -> void:
	progress.value = fmod(value, 1.0)
	if (value >= 1):
		overflow.text = "+%d" % [value]
	else:
		overflow.text = ""
	PROGRESS = value
