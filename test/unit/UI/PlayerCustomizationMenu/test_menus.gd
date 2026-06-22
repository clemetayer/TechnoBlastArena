extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var menus


##### SETUP #####
func before_each():
	menus = add_child_autofree(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerCustomizationMenus/menus.tscn").instantiate())


##### TESTS #####
func test_refresh_presets():
	# given
	var presets = double(load("res://Scenes/UI/PlayerCustomizationMenu/PresetsMenu/presets.gd")).new()
	stub(presets, "refresh").to_do_nothing()
	menus.full_menus["preset_selection"] = presets
	menus.menus_in_popups["preset_selection"] = presets
	# when
	menus.refresh_presets()
	# then
	assert_called(presets, "refresh")


func test_set_primary_weapon_data():
	# given
	var item_grid = double(load("res://Scenes/UI/PlayerCustomizationMenu/ItemsGridMenu/items_grid_menu.gd")).new()
	stub(item_grid, "set_items").to_do_nothing()
	menus.full_menus["primary_weapon"] = item_grid
	menus.menus_in_popups["primary_weapon"] = item_grid
	# when
	menus._set_primary_weapon_data()
	# then
	assert_called(item_grid, "set_items")


func test_set_movement_bonus_data():
	# given
	var item_grid = double(load("res://Scenes/UI/PlayerCustomizationMenu/ItemsGridMenu/items_grid_menu.gd")).new()
	stub(item_grid, "set_items").to_do_nothing()
	menus.full_menus["movement_bonus"] = item_grid
	menus.menus_in_popups["movement_bonus"] = item_grid
	# when
	menus._set_movement_bonus_data()
	# then
	assert_called(item_grid, "set_items")


func test_set_powerup_data():
	# given
	var item_grid = double(load("res://Scenes/UI/PlayerCustomizationMenu/ItemsGridMenu/items_grid_menu.gd")).new()
	stub(item_grid, "set_items").to_do_nothing()
	menus.full_menus["powerup"] = item_grid
	menus.menus_in_popups["powerup"] = item_grid
	# when
	menus._set_powerup_data()
	# then
	assert_called(item_grid, "set_items")


var open_preset_selection_params := [
	[true],
	[false],
]


func test_open_preset_selection(params = use_parameters(open_preset_selection_params)):
	# given
	var is_small: bool = params[0]
	# when
	menus.toggle_is_small(is_small)
	menus.open_preset_selection()
	# then
	common_open_menu_test(is_small)
	assert_eq(menus.popup_menus_root.preset_selection.visible, not is_small)
	assert_eq(menus.full_menus.preset_selection.visible, is_small)


var open_primary_weapon_grid_params := [
	[true],
	[false],
]


func test_open_primary_weapon_grid(params = use_parameters(open_primary_weapon_grid_params)):
	# given
	var is_small: bool = params[0]
	# when
	menus.toggle_is_small(is_small)
	menus.open_primary_weapon()
	# then
	common_open_menu_test(is_small)
	assert_eq(menus.popup_menus_root.primary_weapon.visible, not is_small)
	assert_eq(menus.full_menus.primary_weapon.visible, is_small)


var open_powerup_grid_params := [
	[true],
	[false],
]


func test_open_powerup_grid(params = use_parameters(open_powerup_grid_params)):
	# given
	var is_small: bool = params[0]
	# when
	menus.toggle_is_small(is_small)
	menus.open_powerup()
	# then
	common_open_menu_test(is_small)
	assert_eq(menus.popup_menus_root.powerup.visible, not is_small)
	assert_eq(menus.full_menus.powerup.visible, is_small)


var open_movement_bonus_grid_params := [
	[true],
	[false],
]


func test_open_movement_bonus_grid(params = use_parameters(open_movement_bonus_grid_params)):
	# given
	var is_small: bool = params[0]
	# when
	menus.toggle_is_small(is_small)
	menus.open_movement_bonus()
	# then
	common_open_menu_test(is_small)
	assert_eq(menus.popup_menus_root.movement_bonus.visible, not is_small)
	assert_eq(menus.full_menus.movement_bonus.visible, is_small)


var open_elimination_text_menu_params := [
	[true],
	[false],
]


func test_open_elimination_text_menu(params = use_parameters(open_elimination_text_menu_params)):
	# given
	var is_small: bool = params[0]
	# when
	menus.toggle_is_small(is_small)
	menus.open_elimination_text()
	# then
	common_open_menu_test(is_small)
	assert_eq(menus.popup_menus_root.elimination_text.visible, not is_small)
	assert_eq(menus.full_menus.elimination_text.visible, is_small)


var open_eyes_selection_menu_params := [
	[true],
	[false],
]


func test_open_eyes_selection_menu(params = use_parameters(open_eyes_selection_menu_params)):
	# given
	var is_small: bool = params[0]
	# when
	menus.toggle_is_small(is_small)
	menus.open_eyes_selection()
	# then
	common_open_menu_test(is_small)
	assert_eq(menus.popup_menus_root.eyes_selection.visible, not is_small)
	assert_eq(menus.full_menus.eyes_selection.visible, is_small)


var open_mouth_selection_menu_params := [
	[true],
	[false],
]


func test_open_mouth_selection_menu(params = use_parameters(open_mouth_selection_menu_params)):
	# given
	var is_small: bool = params[0]
	# when
	menus.toggle_is_small(is_small)
	menus.open_mouth_selection()
	# then
	common_open_menu_test(is_small)
	assert_eq(menus.popup_menus_root.mouth_selection.visible, not is_small)
	assert_eq(menus.full_menus.mouth_selection.visible, is_small)


var open_save_preset_popup_params := [
	[true],
	[false],
]


func test_open_save_preset_popup(params = use_parameters(open_save_preset_popup_params)):
	# given
	var is_small: bool = params[0]
	# when
	menus.toggle_is_small(is_small)
	menus.open_save_preset_popup()
	# then
	assert_true(menus.visible)
	assert_eq(menus.save_preset_popup.visible, true)
	assert_eq(menus.popup_background.visible, not is_small)


var select_preset_params := [
	[true],
	[false],
]


func test_select_preset(params = use_parameters(select_preset_params)):
	# given
	var is_small: bool = params[0]
	var selected_preset := PlayerConfig.new()
	watch_signals(menus)
	# when
	menus.toggle_is_small(is_small)
	menus.open_preset_selection()
	var path_dict = menus.full_menus if is_small else menus.menus_in_popups
	path_dict.preset_selection.preset_selected.emit(selected_preset)
	# then
	assert_signal_emitted_with_parameters(menus.preset_selected, [selected_preset])
	assert_false(menus.visible)
	assert_false(menus.full_menus.preset_selection.visible)
	assert_false(menus.popup_menus_root.preset_selection.visible)
	assert_false(menus.popup_background.visible)


var primary_weapon_selected_params := [
	[true],
	[false],
]


func test_primary_weapon_selected(params = use_parameters(primary_weapon_selected_params)):
	# given
	var is_small: bool = params[0]
	var item = ItemGridMenuElement.new(StaticPrimaryWeaponHandler.handlers.REVOLVER, "res://icon.svg", "", "")
	watch_signals(menus)
	# when
	menus.toggle_is_small(is_small)
	menus.open_primary_weapon()
	var path_dict = menus.full_menus if is_small else menus.menus_in_popups
	path_dict.primary_weapon.item_selected.emit(item)
	# then
	assert_signal_emitted_with_parameters(menus.primary_weapon_selected, [StaticPrimaryWeaponHandler.handlers.REVOLVER])
	assert_false(menus.visible)
	assert_false(menus.full_menus.primary_weapon.visible)
	assert_false(menus.popup_menus_root.primary_weapon.visible)
	assert_false(menus.popup_background.visible)


var movement_bonus_selected_params := [
	[true],
	[false],
]


func test_movement_bonus_selected(params = use_parameters(movement_bonus_selected_params)):
	# given
	var is_small: bool = params[0]
	var item = ItemGridMenuElement.new(StaticMovementBonusHandler.handlers.DASH, "res://icon.svg", "", "")
	watch_signals(menus)
	# when
	menus.toggle_is_small(is_small)
	menus.open_movement_bonus()
	var path_dict = menus.full_menus if is_small else menus.menus_in_popups
	path_dict.movement_bonus.item_selected.emit(item)
	# then
	assert_signal_emitted_with_parameters(menus.movement_bonus_selected, [StaticMovementBonusHandler.handlers.DASH])
	assert_false(menus.visible)
	assert_false(menus.full_menus.movement_bonus.visible)
	assert_false(menus.popup_menus_root.movement_bonus.visible)
	assert_false(menus.popup_background.visible)


var powerup_selected_params := [
	[true],
	[false],
]


func test_powerup_selected(params = use_parameters(powerup_selected_params)):
	# given
	var is_small: bool = params[0]
	var item = ItemGridMenuElement.new(StaticPowerupHandler.handlers.SPLITTER, "res://icon.svg", "", "")
	watch_signals(menus)
	# when
	menus.toggle_is_small(is_small)
	menus.open_powerup()
	var path_dict = menus.full_menus if is_small else menus.menus_in_popups
	path_dict.powerup.item_selected.emit(item)
	# then
	assert_signal_emitted_with_parameters(menus.powerup_selected, [StaticPowerupHandler.handlers.SPLITTER])
	assert_false(menus.visible)
	assert_false(menus.full_menus.powerup.visible)
	assert_false(menus.popup_menus_root.powerup.visible)
	assert_false(menus.popup_background.visible)


var elimination_text_updated_params := [
	[true],
	[false],
]


func test_elimination_text_updated(params = use_parameters(elimination_text_updated_params)):
	# given
	var is_small: bool = params[0]
	watch_signals(menus)
	# when
	menus.toggle_is_small(is_small)
	menus.open_elimination_text()
	var path_dict = menus.full_menus if is_small else menus.menus_in_popups
	path_dict.elimination_text.elimination_text_updated.emit("elimination_text")
	# then
	assert_signal_emitted_with_parameters(menus.elimination_text_updated, ["elimination_text"])
	assert_false(menus.visible)
	assert_false(menus.full_menus.elimination_text.visible)
	assert_false(menus.popup_menus_root.elimination_text.visible)
	assert_false(menus.popup_background.visible)


var eyes_selection_updated_params := [
	[true],
	[false],
]


func test_eyes_selection_updated(params = use_parameters(eyes_selection_updated_params)):
	# given
	var is_small: bool = params[0]
	watch_signals(menus)
	# when
	menus.toggle_is_small(is_small)
	menus.open_eyes_selection()
	var path_dict = menus.full_menus if is_small else menus.menus_in_popups
	path_dict.eyes_selection.sprite_selected.emit("sprite_path")
	# then
	assert_signal_emitted_with_parameters(menus.eyes_selected, ["sprite_path"])
	assert_false(menus.visible)
	assert_false(menus.full_menus.eyes_selection.visible)
	assert_false(menus.popup_menus_root.eyes_selection.visible)
	assert_false(menus.popup_background.visible)


var mouth_selection_updated_params := [
	[true],
	[false],
]


func test_mouth_selection_updated(params = use_parameters(mouth_selection_updated_params)):
	# given
	var is_small: bool = params[0]
	watch_signals(menus)
	# when
	menus.toggle_is_small(is_small)
	menus.open_mouth_selection()
	var path_dict = menus.full_menus if is_small else menus.menus_in_popups
	path_dict.mouth_selection.sprite_selected.emit("mouth_selection")
	# then
	assert_signal_emitted_with_parameters(menus.mouth_selected, ["mouth_selection"])
	assert_false(menus.visible)
	assert_false(menus.full_menus.mouth_selection.visible)
	assert_false(menus.popup_menus_root.mouth_selection.visible)
	assert_false(menus.popup_background.visible)


var close_menu_params := [
	[true, "preset_selection"],
	[false, "preset_selection"],
	[true, "primary_weapon"],
	[false, "primary_weapon"],
	[true, "movement_bonus"],
	[false, "movement_bonus"],
	[true, "powerup"],
	[false, "powerup"],
	[true, "elimination_text"],
	[false, "elimination_text"],
	[true, "eyes_selection"],
	[false, "eyes_selection"],
	[true, "mouth_selection"],
	[false, "mouth_selection"],
]


func test_close_menu(params = use_parameters(close_menu_params)):
	# given
	watch_signals(menus)
	var is_small: bool = params[0]
	var menu: String = params[1]
	# when
	menus.toggle_is_small(is_small)
	if is_small:
		menus.popup_menus_root[menu].show()
		menus.popup_menus_root[menu].close_requested.emit()
	else:
		menus.full_menus[menu].show()
		menus.full_menus_close_buttons[menu].pressed.emit()
	# then
	assert_false(menus.visible)
	assert_false(menus.full_menus[menu].visible)
	assert_false(menus.popup_menus_root[menu].visible)
	assert_false(menus.popup_background.visible)
	assert_signal_emitted(menus.menu_closed)


func test_save_preset_canceled():
	# given
	# when
	menus.save_preset_popup.canceled.emit()
	# then
	assert_false(menus.save_preset_popup.visible)
	assert_false(menus.visible)
	assert_false(menus.popup_background.visible)


func test_save_preset_ok():
	# given
	watch_signals(menus)
	# when
	menus.save_preset_popup.save_preset.emit("preset_name", "preset_description")
	# then
	assert_signal_emitted_with_parameters(menus.save_preset, ["preset_name", "preset_description"])
	assert_false(menus.visible)
	assert_false(menus.save_preset_popup.visible)
	assert_false(menus.popup_background.visible)


##### UTILS #####
func common_open_menu_test(is_small: bool) -> void:
	assert_true(menus.visible)
	assert_eq(menus.popup_background.visible, not is_small)
