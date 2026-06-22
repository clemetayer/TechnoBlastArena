extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var menu


##### SETUP #####
func before_each():
	menu = add_child_autofree(load("res://Scenes/UI/PlayerCustomizationMenu/EliminationTextEditMenu/elimination_text_edit_menu.tscn").instantiate())


##### TEARDOWN #####
func after_each():
	menu.free()


##### TESTS #####
func test_get_elimination_text():
	# given
	menu.text_edit.text = "test"
	# when
	var res = menu.get_elimination_text()
	# then
	assert_eq(res, "test")


func test_set_elimination_text():
	# given
	# when
	menu.set_elimination_text("test")
	# then
	assert_eq(menu.text_edit.text, "test")


func test_on_ok_button_pressed():
	# given
	watch_signals(menu)
	menu.text_edit.text = "test"
	# when
	menu.ok_button.pressed.emit()
	# then
	assert_signal_emitted_with_parameters(menu.elimination_text_updated, ["test"])
