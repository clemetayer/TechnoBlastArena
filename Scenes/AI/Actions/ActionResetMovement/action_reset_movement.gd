@tool
extends ActionLeaf

class_name ActionResetMovement
# action that resets the desired movement for the player

##### PROCESSING #####
func tick(_actor: Node, blackboard: Blackboard) -> int:
	if not blackboard is CommonBlackboard:
		return FAILURE
	blackboard.set_value(CommonBlackboard.JUMP_KEY, false)
	blackboard.set_value(CommonBlackboard.MOVEMENT_DIRECTION_KEY, CommonBlackboard.DIRECTION.NONE)
	return SUCCESS
