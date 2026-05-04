extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var action: ActionTriggerAction


##### SETUP #####
func before_each():
	action = ActionTriggerAction.new()
	add_child_autofree(action)


##### TESTS #####
func test_tick_not_common_blackboard():
	# given
	var blackboard = Blackboard.new()
	var actor = Node2D.new()
	# when
	var res = action.tick(actor, blackboard)
	# then
	assert_eq(res, ActionLeaf.FAILURE) # just checks the failure, it should not crash
	# cleanup
	blackboard.free()
	actor.free()


var trigger_action_params := [
	[ActionTriggerAction.TRIGGERABLE_ACTIONS.FIRE, CommonBlackboard.FIRE_TRIGGERED_KEY],
	[ActionTriggerAction.TRIGGERABLE_ACTIONS.MOVEMENT_BONUS, CommonBlackboard.MOVEMENT_BONUS_TRIGGERED_KEY],
	[ActionTriggerAction.TRIGGERABLE_ACTIONS.POWERUP, CommonBlackboard.POWERUP_TRIGGERED_KEY],
	[ActionTriggerAction.TRIGGERABLE_ACTIONS.PARRY, CommonBlackboard.SHIELD_KEY],
]


func test_trigger_action(params = use_parameters(trigger_action_params)):
	# given
	var action_to_trigger = params[0]
	var expected_blackboard_action_triggered = params[1]
	var blackboard = CommonBlackboard.new()
	action.ACTION = action_to_trigger
	blackboard.set_value(expected_blackboard_action_triggered, false)
	# when
	action.tick(null, blackboard)
	# then
	assert_true(blackboard.get_value(expected_blackboard_action_triggered))
	# cleanup
	blackboard.free()
