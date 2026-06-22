extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var menu


##### SETUP #####
func before_each():
	menu = add_child_autofree(load("res://Scenes/UI/PlayerCustomizationMenu/player_selection_menu.tscn").instantiate())


##### TESTS #####
func test_on_start_button_button_up():
	# given
	var config1 = PlayerConfig.new()
	var item1 = create_player_selection_item_mock()
	stub(item1, "get_config").to_return(config1)
	var config2 = PlayerConfig.new()
	var item2 = create_player_selection_item_mock()
	stub(item2, "get_config").to_return(config2)
	for item in menu.player_selection_items.get_children():
		item.free()
	menu.player_selection_items.add_child(item1)
	menu.player_selection_items.add_child(item2)
	watch_signals(menu)
	# when
	menu.start_button.pressed.emit()
	await wait_process_frames(2)
	# then
	assert_signal_emitted_with_parameters(menu.players_ready, [[config1, config2]])


##### UTILS #####
func create_player_selection_item_mock():
	return partial_double(load("res://Scenes/UI/PlayerCustomizationMenu/player_selection_item.tscn")).instantiate()
