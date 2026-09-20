extends Node

# Runtime utilitary functions that are usefull when the game is launched

##### SIGNALS #####
signal pause_toggled(enabled: bool)

##### VARIABLES #####
#---- CONSTANTS -----
const GAME_ROOT_GROUP_NAME := "game_root"
const PLAYER_INDICATOR_COLORS := [
	Color("ff0000"), # red
	Color("0000ff"), # blue
	Color("00ff00"), # green
	Color("ffff00"), # yellow
]


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS


##### PUBLIC METHODS #####
# Returns the game root or null if it does not exists
func get_game_root() -> Node:
	return get_tree().get_first_node_in_group(GAME_ROOT_GROUP_NAME)
