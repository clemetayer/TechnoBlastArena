extends Node

# Input synchronizer

##### VARIABLES #####
#---- STANDARD -----
#==== PUBLIC ====
@export var action_states: Dictionary
@export var relative_aim_position := Vector2.ZERO

#==== ONREADY ====
@onready var paths := $"../Paths"


##### PROCESSING #####
# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(_delta):
	if is_instance_valid(paths.action_handler):
		action_states = paths.action_handler._action_states
		relative_aim_position = paths.action_handler.relative_aim_position


##### PUBLIC METHODS #####
func set_action_handler(handler: StaticActionHandler.handlers) -> void:
	paths.action_handler = StaticActionHandler.get_handler(handler)
	paths.action_handler.name = "ActionHandler"
	paths.action_handler.set_player(paths.player_root)
	paths.player_root.add_child(paths.action_handler)
