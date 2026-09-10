extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var counter


##### SETUP #####
func before_each():
	counter = add_child_autofree(
		load("res://Scenes/Weapons/Powerups/Common/element_counter.tscn").instantiate()
	)


##### TESTS #####
func test_init():
	# given
	var base_amount = randi_range(1, 10)
	counter.BASE_AMOUNT = base_amount
	# when
	counter._ready()
	await wait_process_frames(1)
	# then
	assert_eq(counter.get_child_count(), base_amount)


func test_decrease_counter_not_zero():
	# given
	watch_signals(counter)
	var base_amount = randi_range(2, 10)
	counter.BASE_AMOUNT = base_amount
	counter._ready()
	await wait_process_frames(1)
	# when
	counter.decrease()
	await wait_process_frames(1)
	# then
	assert_eq(counter.get_child_count(), base_amount - 1)
	assert_signal_not_emitted(counter.empty)


func test_decrease_counter_zero():
	# given
	watch_signals(counter)
	counter.BASE_AMOUNT = 1
	counter._ready()
	await wait_process_frames(1)
	# when
	counter.decrease()
	# then
	assert_signal_emitted(counter.empty)
	await wait_process_frames(1)
	assert_false(is_instance_valid(counter))
