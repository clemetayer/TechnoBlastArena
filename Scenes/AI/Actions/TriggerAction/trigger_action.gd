class_name ActionTriggerAction
extends ActionLeaf

##### ENUMS #####
enum TRIGGERABLE_ACTIONS { FIRE, MOVEMENT_BONUS, POWERUP, PARRY }

##### VARIABLES #####
#---- CONSTANTS -----
const HOLD_FIRE_KEY_TIME := 0.1 # seconds
const ACTION_TO_BLACKBOARD_MAP := {
	TRIGGERABLE_ACTIONS.FIRE: CommonBlackboard.FIRE_TRIGGERED_KEY,
	TRIGGERABLE_ACTIONS.MOVEMENT_BONUS: CommonBlackboard.MOVEMENT_BONUS_TRIGGERED_KEY,
	TRIGGERABLE_ACTIONS.POWERUP: CommonBlackboard.POWERUP_TRIGGERED_KEY,
	TRIGGERABLE_ACTIONS.PARRY: CommonBlackboard.SHIELD_KEY,
}

#---- EXPORTS -----
@export var ACTION: TRIGGERABLE_ACTIONS = TRIGGERABLE_ACTIONS.FIRE

#---- STANDARD -----
#==== PRIVATE ====
var _hold_trigger_timer: Timer


##### PUBLIC METHODS #####
func tick(_actor: Node, blackboard: Blackboard) -> int:
	if not blackboard is CommonBlackboard:
		return FAILURE
	blackboard.set_value(ACTION_TO_BLACKBOARD_MAP[ACTION], true)
	_create_hold_trigger_timer(blackboard)
	return SUCCESS


##### PROTECTED METHODS #####
func _create_hold_trigger_timer(blackboard: CommonBlackboard) -> void:
	if is_instance_valid(_hold_trigger_timer):
		_hold_trigger_timer.stop()
		_hold_trigger_timer.start()
		return
	_hold_trigger_timer = Timer.new()
	_hold_trigger_timer.wait_time = HOLD_FIRE_KEY_TIME
	_hold_trigger_timer.timeout.connect(func(): blackboard.set_value(ACTION_TO_BLACKBOARD_MAP[ACTION], false))
	add_child(_hold_trigger_timer)
