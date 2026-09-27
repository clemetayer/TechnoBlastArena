extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var item


##### SETUP #####
func before_each():
	item = add_child_autofree(
		load("res://Scenes/UI/PlayerCustomizationMenu/ItemsGridMenu/item_button.tscn").instantiate()
	)


##### TESTS #####
func test_set_data():
	# given
	var item_grid_menu_element = _create_default_item_grid_menu_element()
	# when
	item.set_data(item_grid_menu_element)
	# then
	assert_eq(item.weapon_icon.texture.resource_path, item_grid_menu_element.ICON_PATH)
	assert_eq(item.weapon_name.text, item_grid_menu_element.NAME)
	assert_eq(item.weapon_description.text, item_grid_menu_element.DESCRIPTION)


func test_custom_tooltip_visibility():
	# given
	item.custom_tooltip.hide()
	# when
	item.mouse_entered.emit()
	# then
	assert_true(item.custom_tooltip.visible)
	# when
	item.mouse_exited.emit()
	# then
	assert_false(item.custom_tooltip.visible)


func test_clicked():
	# given
	watch_signals(item)
	var item_grid_menu_element = _create_default_item_grid_menu_element()
	item.set_data(item_grid_menu_element)
	# when
	item.pressed.emit()
	# then
	assert_signal_emitted(item.element_selected, [item_grid_menu_element])


##### UTILS #####
func _create_default_item_grid_menu_element():
	return StaticItemDescriptions.get_primary_weapons_descriptions()[
		StaticPrimaryWeaponHandler.handlers.REVOLVER
	]
