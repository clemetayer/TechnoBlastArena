extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var menu


##### SETUP #####
func before_each():
	menu = add_child_autofree(load("res://Scenes/UI/PlayerCustomizationMenu/AISelectionMenu/ai_selection_menu.tscn").instantiate())


##### TESTS #####
func test_open():
	# given
	menu.presets.hide()
	menu.visualisation.hide()
	# when
	menu.open()
	# then
	assert_true(menu.presets.visible)
	assert_false(menu.visualisation.visible)


func test_preset_selected():
	# given
	watch_signals(menu)
	var config = PlayerConfig.new()
	var visualisation = double(load("res://Scenes/UI/PlayerCustomizationMenu/AISelectionMenu/ai_visualisation.tscn")).instantiate()
	stub(visualisation, "update_ai").to_do_nothing()
	menu.visualisation = visualisation
	# when
	menu.presets.preset_selected.emit(config)
	# then
	assert_false(menu.presets.visible)
	assert_true(menu.visualisation.visible)
	assert_called(visualisation, "update_ai", [config])
	assert_signal_emitted_with_parameters(menu.preset_selected, [config])


func test_close_triggered():
	# given
	watch_signals(menu)
	# when
	menu.visualisation.close_triggered.emit()
	# then
	assert_signal_emitted(menu.close_triggered)


func test_show_presets_triggered():
	# given
	# when
	menu.visualisation.show_ai_presets_triggered.emit()
	# then
	assert_true(menu.presets.visible)
	assert_false(menu.visualisation.visible)
