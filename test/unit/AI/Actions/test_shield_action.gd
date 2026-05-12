extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var action: ActionShield


##### SETUP #####
func before_each():
	action = ActionShield.new()
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


var set_shielding_params := [
	[true],
	[false],
]


func test_set_shielding(params = use_parameters(set_shielding_params)):
	# given
	var activate_shield = params[0]
	action.SHIELDING = activate_shield
	var blackboard = autofree(CommonBlackboard.new())
	# when
	action.tick(null, blackboard)
	# then
	assert_eq(blackboard.get_value(CommonBlackboard.SHIELD_KEY), activate_shield)
