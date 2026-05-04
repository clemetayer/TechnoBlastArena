extends ActionHandlerBase

##### VARIABLES #####
#---- EXPORTS -----
@export var BLACKBOARD: CommonBlackboard


##### PROCESSING #####
# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(_delta):
	_set_next_state(actions.JUMP, BLACKBOARD.get_value(BLACKBOARD.JUMP_KEY))
	_set_next_state(actions.LEFT, BLACKBOARD.get_value(BLACKBOARD.MOVEMENT_DIRECTION_KEY) == BLACKBOARD.DIRECTION.LEFT)
	_set_next_state(actions.RIGHT, BLACKBOARD.get_value(BLACKBOARD.MOVEMENT_DIRECTION_KEY) == BLACKBOARD.DIRECTION.RIGHT)
	_set_next_state(actions.FIRE, BLACKBOARD.get_value(BLACKBOARD.FIRE_TRIGGERED_KEY))
	_set_next_state(actions.MOVEMENT_BONUS, BLACKBOARD.get_value(BLACKBOARD.MOVEMENT_BONUS_TRIGGERED_KEY))
	_set_next_state(actions.SHIELD, BLACKBOARD.get_value(BLACKBOARD.SHIELD_KEY))
	_set_next_state(actions.POWERUP, BLACKBOARD.get_value(BLACKBOARD.POWERUP_TRIGGERED_KEY))
	relative_aim_position = BLACKBOARD.get_value(BLACKBOARD.RELATIVE_AIM_POSITION_KEY)


##### PUBLIC METHODS #####
func set_player(player: Node2D) -> void:
	BLACKBOARD.set_value(BLACKBOARD.PLAYER_KEY, player)


##### PROTECTED METHODS #####
func _set_next_state(action: actions, active: bool) -> void:
	_action_states[action] = _next_button_state(_action_states[action], active)


func _next_button_state(current_state: states, active: bool) -> states:
	var next_state = current_state
	match current_state:
		states.INACTIVE:
			if active:
				next_state = states.JUST_ACTIVE
		states.JUST_ACTIVE:
			next_state = states.JUST_INACTIVE
			if active:
				next_state = states.ACTIVE
		states.ACTIVE:
			if not active:
				next_state = states.JUST_INACTIVE
		states.JUST_INACTIVE:
			next_state = states.INACTIVE
			if active:
				next_state = states.JUST_ACTIVE
	return next_state
