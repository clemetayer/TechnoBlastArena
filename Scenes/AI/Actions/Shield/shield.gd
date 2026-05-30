@tool
extends ActionLeaf

class_name ActionShield
# AI Action to activate/deactivate the shield

##### VARIABLES #####
#---- EXPORTS -----
@export var SHIELDING := true


##### PROCESSING #####
func tick(_actor: Node, blackboard: Blackboard) -> int:
	if not blackboard is CommonBlackboard:
		return FAILURE
	blackboard.set_value(CommonBlackboard.SHIELD_KEY, SHIELDING)
	return SUCCESS
