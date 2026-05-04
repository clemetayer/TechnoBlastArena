@abstract
class_name ActionHandlerBase
extends Node2D

# Base class to handle actions

##### ENUMS #####
enum states { INACTIVE, JUST_ACTIVE, ACTIVE, JUST_INACTIVE }
enum actions { JUMP, UP, DOWN, LEFT, RIGHT, FIRE, MOVEMENT_BONUS, SHIELD, POWERUP }

##### VARIABLES #####
#---- STANDARD -----
#==== PUBLIC ====
var relative_aim_position := Vector2.ZERO # aim position relative to the current node position

#==== PRIVATE ====
var _action_states := {
	actions.JUMP: states.INACTIVE,
	actions.UP: states.INACTIVE,
	actions.DOWN: states.INACTIVE,
	actions.LEFT: states.INACTIVE,
	actions.RIGHT: states.INACTIVE,
	actions.FIRE: states.INACTIVE,
	actions.MOVEMENT_BONUS: states.INACTIVE,
	actions.SHIELD: states.INACTIVE,
	actions.POWERUP: states.INACTIVE,
}


##### PUBLIC METHODS #####
# Mostly used by AI action handlers
# does nothing by default
func set_player(_player: Node2D) -> void:
	pass


func get_action_state(action: actions) -> states:
	return _action_states[action]


# convenient method to quickly check if an action is active or not since JUST_ACTIVE has priority over ACTIVE
static func is_active(action: states) -> bool:
	return action == states.ACTIVE or action == states.JUST_ACTIVE


static func is_just_active(action: states) -> bool:
	return action == states.JUST_ACTIVE


static func is_just_inactive(action: states) -> bool:
	return action == states.JUST_INACTIVE
