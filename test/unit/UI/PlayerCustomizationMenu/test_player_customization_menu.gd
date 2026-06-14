extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var menu


##### SETUP #####
func before_each():
	menu = add_child_autofree(load("res://Scenes/UI/PlayerCustomizationMenu/player_customization_menu.tscn").instantiate())


##### TESTS #####
func test_quit():
	# given
	menu = partial_double(load("res://Scenes/UI/PlayerCustomizationMenu/player_customization_menu.tscn")).instantiate()
	stub(menu, "_return_to_previous_menu").to_do_nothing()
	add_child_autofree(menu)
	# when
	menu.player_customization_ui.quit.emit()
	# then
	assert_called(menu, "_return_to_previous_menu")
