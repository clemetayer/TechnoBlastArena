# AI action leaf to move towards the target
@tool
class_name ActionSetDesiredPositionAsTarget
extends ActionLeaf

##### PROCESSING #####
func tick(_actor: Node, blackboard: Blackboard) -> int:
	if not blackboard is CommonBlackboard:
		return FAILURE
	var target = blackboard.get_value(CommonBlackboard.TARGET_KEY)
	if is_instance_valid(target):
		blackboard.set_value(CommonBlackboard.DESIRED_POSITION_KEY, target.get_global_position())
	return SUCCESS
