@tool
extends ActionLeaf

class_name ActionMoveTowardsDesiredPosition
# makes the player move towards a specific position

##### PROCESSING #####
func tick(_actor: Node, blackboard: Blackboard) -> int:
	if not blackboard is CommonBlackboard:
		return FAILURE
	blackboard.set_value(CommonBlackboard.MOVEMENT_DIRECTION_KEY, CommonBlackboard.DIRECTION.NONE)
	blackboard.set_value(CommonBlackboard.JUMP_KEY, false)
	var player = blackboard.get_value(CommonBlackboard.PLAYER_KEY)
	var desired_position = blackboard.get_value(CommonBlackboard.DESIRED_POSITION_KEY)
	if is_instance_valid(player):
		blackboard.set_value(CommonBlackboard.MOVEMENT_DIRECTION_KEY, _get_movement_direction(player, desired_position))
		blackboard.set_value(CommonBlackboard.JUMP_KEY, player.get_global_position().y > desired_position.y)
	return SUCCESS


##### PROTECTED METHODS #####
func _get_movement_direction(player: Node2D, desired_position: Vector2) -> CommonBlackboard.DIRECTION:
	if player.get_global_position().x == desired_position.x:
		return CommonBlackboard.DIRECTION.NONE
	elif player.get_global_position().x > desired_position.x:
		return CommonBlackboard.DIRECTION.LEFT
	else:
		return CommonBlackboard.DIRECTION.RIGHT
