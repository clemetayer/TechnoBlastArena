extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var options_menu


##### SETUP #####
func before_each():
	options_menu = add_child_autofree(
		load("res://Scenes/UI/OptionsMenu/options_menu.tscn").instantiate()
	)


##### TESTS #####
func test_save_options():
	# given
	watch_signals(options_menu)
	var runtime_config = mock_runtime_configs()
	stub(runtime_config, "save_config").to_do_nothing()
	# when
	options_menu.back_button.pressed.emit()
	# then
	assert_called(runtime_config, "save_config")
	assert_signal_emitted(options_menu.return_triggered)


##### UTILS #####
func mock_runtime_configs():
	var runtime_config = double(load("res://Utils/Config/runtime_config.gd")).new()
	options_menu.runtime_config = runtime_config
	return runtime_config
