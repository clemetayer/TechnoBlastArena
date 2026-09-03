extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var movement_bonus


##### SETUP #####
func before_each():
	movement_bonus = add_child_autofree(
		load(
			"res://Scenes/Movement/MovementBonusDimensionalMirror/movement_bonus_dimensional_mirror.tscn"
		).instantiate()
	)


##### TESTS #####
func test_first_init():
	# given
	watch_signals(movement_bonus)
	# when
	simulate(movement_bonus, 2, 1.0 / 60.0)
	# then
	assert_signal_emitted(movement_bonus.value_updated, [movement_bonus.MAX_ACTIONS])


func test_activate_action():
	# given
	watch_signals(movement_bonus)
	movement_bonus._ability_active = false
	movement_bonus.player = autofree(load("res://Scenes/Player/player.tscn").instantiate())
	movement_bonus.player.can_hit_destructible_wall = true
	movement_bonus.active = true
	# when
	movement_bonus.activate()
	# then
	assert_true(movement_bonus._ability_active)
	assert_eq(movement_bonus.ACTIONS_AVAILABLE, movement_bonus.MAX_ACTIONS - 1)
	assert_signal_emitted(movement_bonus.value_updated, movement_bonus.MAX_ACTIONS - 1)
	assert_false(movement_bonus.player.can_hit_destructible_wall)
	await wait_for_signal(movement_bonus.reload_timer.timeout, 10)
	await wait_process_frames(1)
	assert_false(movement_bonus._ability_active)
	assert_true(movement_bonus.player.can_hit_destructible_wall)
	assert_eq(movement_bonus.ACTIONS_AVAILABLE, movement_bonus.MAX_ACTIONS)
	assert_signal_emitted(movement_bonus.value_updated, movement_bonus.MAX_ACTIONS)


func test_cannot_activate_if_no_action_left():
	# given
	watch_signals(movement_bonus)
	movement_bonus._ability_active = false
	movement_bonus.player = autofree(load("res://Scenes/Player/player.tscn").instantiate())
	movement_bonus.player.can_hit_destructible_wall = true
	movement_bonus.active = true
	movement_bonus.ACTIONS_AVAILABLE = 0
	# when
	movement_bonus.activate()
	# then
	assert_false(movement_bonus._ability_active)
	assert_signal_not_emitted(movement_bonus.value_updated)
	assert_true(movement_bonus.player.can_hit_destructible_wall)
