extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var handler
var blackboard: CommonBlackboard


##### SETUP #####
func before_each():
	handler = load("res://test/unit/AI/ai_action_handler_test_instance.tscn").instantiate()
	blackboard = CommonBlackboard.new()
	handler.BLACKBOARD = blackboard
	add_child_autofree(handler)


##### TEARDOWN #####
func after_each():
	blackboard.free()


##### TESTS #####
func test_set_player():
	# given
	var player = Node2D.new()
	# when
	handler.set_player(player)
	# then
	assert_eq(blackboard.get_value(CommonBlackboard.PLAYER_KEY), player)
	# cleanup
	player.free()


func test_state_modification():
	# given
	var action = handler.actions.JUMP
	handler._action_states[action] = handler.states.INACTIVE
	# when
	handler._set_next_state(action, true)
	# then
	assert_eq(handler._action_states[action], handler.states.JUST_ACTIVE)
	# when
	handler._set_next_state(action, true)
	# then
	assert_eq(handler._action_states[action], handler.states.ACTIVE)
	# when
	handler._set_next_state(action, true)
	# then
	assert_eq(handler._action_states[action], handler.states.ACTIVE)
	# when
	handler._set_next_state(action, false)
	# then
	assert_eq(handler._action_states[action], handler.states.JUST_INACTIVE)
	# when
	handler._set_next_state(action, true)
	# then
	assert_eq(handler._action_states[action], handler.states.JUST_ACTIVE)
	# when
	handler._set_next_state(action, true)
	# then
	assert_eq(handler._action_states[action], handler.states.ACTIVE)
	# when
	handler._set_next_state(action, false)
	# then
	assert_eq(handler._action_states[action], handler.states.JUST_INACTIVE)
	# when
	handler._set_next_state(action, false)
	# then
	assert_eq(handler._action_states[action], handler.states.INACTIVE)
	# when
	handler._set_next_state(action, false)
	# then
	assert_eq(handler._action_states[action], handler.states.INACTIVE)
	# when
	handler._set_next_state(action, true)
	# then
	assert_eq(handler._action_states[action], handler.states.JUST_ACTIVE)
	# when
	handler._set_next_state(action, false)
	# then
	assert_eq(handler._action_states[action], handler.states.JUST_INACTIVE)


func test_update():
	# given
	for action in handler.actions:
		handler._action_states[action] = handler.states.INACTIVE
	handler.relative_aim_position = Vector2.ZERO
	blackboard.set_value(CommonBlackboard.JUMP_KEY, true)
	blackboard.set_value(CommonBlackboard.MOVEMENT_DIRECTION_KEY, CommonBlackboard.DIRECTION.LEFT)
	blackboard.set_value(CommonBlackboard.FIRE_TRIGGERED_KEY, true)
	blackboard.set_value(CommonBlackboard.MOVEMENT_BONUS_TRIGGERED_KEY, true)
	blackboard.set_value(CommonBlackboard.SHIELD_KEY, true)
	blackboard.set_value(CommonBlackboard.POWERUP_TRIGGERED_KEY, true)
	blackboard.set_value(CommonBlackboard.RELATIVE_AIM_POSITION_KEY, Vector2.ONE)
	# when
	handler._process(1.0 / 60.0)
	# then
	assert_eq(handler._action_states[handler.actions.JUMP], handler.states.JUST_ACTIVE)
	assert_eq(handler._action_states[handler.actions.LEFT], handler.states.JUST_ACTIVE)
	assert_eq(handler._action_states[handler.actions.RIGHT], handler.states.INACTIVE)
	assert_eq(handler._action_states[handler.actions.FIRE], handler.states.JUST_ACTIVE)
	assert_eq(handler._action_states[handler.actions.MOVEMENT_BONUS], handler.states.JUST_ACTIVE)
	assert_eq(handler._action_states[handler.actions.SHIELD], handler.states.JUST_ACTIVE)
	assert_eq(handler._action_states[handler.actions.POWERUP], handler.states.JUST_ACTIVE)
	assert_eq(handler.relative_aim_position, Vector2.ONE)
