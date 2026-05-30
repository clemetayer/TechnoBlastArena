@tool
class_name ActionAimAtTarget
extends ActionLeaf

##### VARIABLES #####
#---- EXPORTS -----
@export var ACQUIRE_TARGET_SPEED := 500.0 # move towards speed per delta time

#---- STANDARD -----
#==== PRIVATE ====
var _delta: float


##### PROCESSING #####
# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(delta):
	_delta = delta


##### PUBLIC METHODS #####
func tick(_actor: Node, blackboard: Blackboard) -> int:
	if not blackboard is CommonBlackboard:
		return FAILURE
	var player = blackboard.get_value(CommonBlackboard.PLAYER_KEY)
	var target = blackboard.get_value(CommonBlackboard.TARGET_KEY)
	if is_instance_valid(player) and is_instance_valid(target):
		var aim_position = blackboard.get_value(CommonBlackboard.RELATIVE_AIM_POSITION_KEY)
		var global_aim_position: Vector2 = player.get_global_position() + aim_position
		global_aim_position = global_aim_position.move_toward(target.get_global_position(), _delta * ACQUIRE_TARGET_SPEED)
		aim_position = global_aim_position - player.get_global_position()
		blackboard.set_value(CommonBlackboard.RELATIVE_AIM_POSITION_KEY, aim_position)
	return SUCCESS
