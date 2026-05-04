extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var action_handler: ActionHandlerInput


##### SETUP #####
func before_each():
	action_handler = ActionHandlerInput.new()
	add_child_autofree(action_handler)


##### TEARDOWN #####
func after_each():
	action_handler.free()


##### TESTS #####
func test_process_updates_action_states():
	# given
	var input = double(load("res://test/unit/ActionHandler/test_action_handler_input_mocks/input.gd")).new()
	stub(input, "is_action_just_pressed").to_return(false)
	stub(input, "is_action_pressed").to_return(false)
	stub(input, "is_action_just_released").to_return(false)
	stub(input, "is_action_just_pressed").when_passed("jump").to_return(true)
	stub(input, "is_action_just_pressed").when_passed("left").to_return(true)
	action_handler._input = input
	# when
	action_handler._process(0.16)
	# then
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.JUMP], ActionHandlerBase.states.JUST_ACTIVE)
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.LEFT], ActionHandlerBase.states.JUST_ACTIVE)
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.RIGHT], ActionHandlerBase.states.INACTIVE)
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.UP], ActionHandlerBase.states.INACTIVE)
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.DOWN], ActionHandlerBase.states.INACTIVE)


func test_process_updates_action_states_when_held():
	# given
	var input = double(load("res://test/unit/ActionHandler/test_action_handler_input_mocks/input.gd")).new()
	stub(input, "is_action_just_pressed").to_return(false)
	stub(input, "is_action_pressed").to_return(false)
	stub(input, "is_action_just_released").to_return(false)
	stub(input, "is_action_pressed").when_passed("jump").to_return(true)
	stub(input, "is_action_pressed").when_passed("left").to_return(true)
	action_handler._input = input
	# when
	action_handler._process(0.16)
	# then
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.JUMP], ActionHandlerBase.states.ACTIVE)
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.LEFT], ActionHandlerBase.states.ACTIVE)


func test_process_updates_action_states_when_released():
	# given
	var input = double(load("res://test/unit/ActionHandler/test_action_handler_input_mocks/input.gd")).new()
	stub(input, "is_action_just_pressed").to_return(false)
	stub(input, "is_action_pressed").to_return(false)
	stub(input, "is_action_just_released").to_return(false)
	stub(input, "is_action_just_released").when_passed("jump").to_return(true)
	stub(input, "is_action_just_released").when_passed("left").to_return(true)
	action_handler._input = input
	# when
	action_handler._process(0.16)
	# then
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.JUMP], ActionHandlerBase.states.JUST_INACTIVE)
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.LEFT], ActionHandlerBase.states.JUST_INACTIVE)


func test_process_updates_all_input_actions():
	# given
	var input = double(load("res://test/unit/ActionHandler/test_action_handler_input_mocks/input.gd")).new()
	stub(input, "is_action_just_pressed").to_return(true)
	stub(input, "is_action_pressed").to_return(false)
	stub(input, "is_action_just_released").to_return(false)
	action_handler._input = input
	# when
	action_handler._process(0.16)
	# then
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.JUMP], ActionHandlerBase.states.JUST_ACTIVE)
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.LEFT], ActionHandlerBase.states.JUST_ACTIVE)
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.RIGHT], ActionHandlerBase.states.JUST_ACTIVE)
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.UP], ActionHandlerBase.states.JUST_ACTIVE)
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.DOWN], ActionHandlerBase.states.JUST_ACTIVE)
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.FIRE], ActionHandlerBase.states.JUST_ACTIVE)
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.MOVEMENT_BONUS], ActionHandlerBase.states.JUST_ACTIVE)
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.SHIELD], ActionHandlerBase.states.JUST_ACTIVE)
	assert_eq(action_handler._action_states[ActionHandlerBase.actions.POWERUP], ActionHandlerBase.states.JUST_ACTIVE)


func test_process_sets_relative_aim_position():
	# given
	# when
	action_handler._process(0.16)
	# then
	assert_eq(action_handler.relative_aim_position, action_handler.get_global_mouse_position() - action_handler.global_position)
