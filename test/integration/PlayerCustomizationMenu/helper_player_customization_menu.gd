extends Node

# helper for the player customization menu

##### VARIABLES #####
#---- CONSTANTS -----
const INTEGRATION_TEST_PRESET_PATH := "res://test/integration/PlayerCustomizationMenu/integration_preset.tres"
const INTEGRATION_TEST_SAVE_PATH := StaticUtils.USER_CHARACTER_PRESETS_PATH + "integration_test" + StaticUtils.GODOT_RESOURCE_FILE_EXTENSION
const INTEGRATION_TEST_PRESET_NAME := "integration_test"
const INTEGRATION_TEST_2_PRESET_NAME := "integration_test_2"
const INTEGRATION_TEST_2_PRESET_DESCRIPTION := "description_test_2"

#---- STANDARD -----
#==== PRIVATE ====
var _menu


##### PUBLIC METHODS #####
func count_saved_presets() -> int:
	var dir = DirAccess.open(StaticUtils.USER_CHARACTER_PRESETS_PATH)
	return dir.get_files().size()


func set_customization_menu(menu):
	_menu = menu


func get_current_menu_config() -> PlayerConfig:
	return _get_player_customization_ui().player_config


func get_integration_test_config() -> PlayerConfig:
	return load(INTEGRATION_TEST_PRESET_PATH)


func save_std_preset() -> void:
	var preset = load(INTEGRATION_TEST_PRESET_PATH)
	ResourceSaver.save(preset, INTEGRATION_TEST_SAVE_PATH)


func is_config_equals_display(config: PlayerConfig) -> bool:
	var res = true
	res = res and _get_player_config_diplay().name_edit.text == config.PLAYER_NAME
	res = res and _get_player_config_diplay().player_sprite_config.sprites.body.modulate == config.SPRITE_CUSTOMIZATION.BODY_COLOR
	res = res and _get_player_config_diplay().player_sprite_config.sprites.outline.modulate == config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR
	res = res and _get_player_config_diplay().player_sprite_config.sprites.eyes.texture.resource_path == config.SPRITE_CUSTOMIZATION.EYES_TEXTURE_PATH
	res = res and _get_player_config_diplay().player_sprite_config.sprites.eyes.modulate == config.SPRITE_CUSTOMIZATION.EYES_COLOR
	res = res and _get_player_config_diplay().player_sprite_config.sprites.mouth.texture.resource_path == config.SPRITE_CUSTOMIZATION.MOUTH_TEXTURE_PATH
	res = res and _get_player_config_diplay().player_sprite_config.sprites.mouth.modulate == config.SPRITE_CUSTOMIZATION.MOUTH_COLOR
	res = res and _get_player_config_diplay().primary_weapon.icon.resource_path == StaticPrimaryWeaponHandler.get_icon_path(config.PRIMARY_WEAPON)
	res = res and _get_player_config_diplay().powerup.icon.resource_path == StaticPowerupHandler.get_icon_path(config.POWERUP_HANDLER)
	res = res and _get_player_config_diplay().movement_bonus.icon.resource_path == StaticMovementBonusHandler.get_icon_path(config.MOVEMENT_BONUS_HANDLER)
	return res


func update_config(config: PlayerConfig) -> void:
	_get_player_customization_ui()._on_menus_preset_selected(config)


func remove_std_preset() -> void:
	remove_preset_with_name(INTEGRATION_TEST_PRESET_NAME)


func remove_preset_with_name(pname: String) -> void:
	var dir_access = DirAccess.open(StaticUtils.USER_CHARACTER_PRESETS_PATH)
	dir_access.remove(pname + StaticUtils.GODOT_RESOURCE_FILE_EXTENSION)


func open_presets_menu() -> void:
	_get_player_customization_ui().preset_selection_button.pressed.emit()


func is_preset_menu_visible() -> bool:
	return _get_menus().popup_menus_root.preset_selection.visible


func get_presets() -> Array:
	return _get_menus().menus_in_popups.preset_selection.presets_root.get_children()


func is_preset_equal(preset: Button, config: PlayerConfig) -> bool:
	var res = true
	res = res and preset.name_label.text == config.PLAYER_NAME
	res = res and preset.primary_weapon.texture.resource_path == StaticPrimaryWeaponHandler.get_icon_path(config.PRIMARY_WEAPON)
	res = res and preset.movement_bonus.texture.resource_path == StaticMovementBonusHandler.get_icon_path(config.MOVEMENT_BONUS_HANDLER)
	res = res and preset.powerup.texture.resource_path == StaticPowerupHandler.get_icon_path(config.POWERUP_HANDLER)
	res = res and preset.primary_weapon.texture.resource_path == StaticPrimaryWeaponHandler.get_icon_path(config.PRIMARY_WEAPON)
	res = res and preset.sprite.body.modulate == config.SPRITE_CUSTOMIZATION.BODY_COLOR
	res = res and preset.sprite.outline.modulate == config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR
	res = res and preset.sprite.eyes.texture.resource_path == config.SPRITE_CUSTOMIZATION.EYES_TEXTURE_PATH
	res = res and preset.sprite.eyes.modulate == config.SPRITE_CUSTOMIZATION.EYES_COLOR
	res = res and preset.sprite.mouth.texture.resource_path == config.SPRITE_CUSTOMIZATION.MOUTH_TEXTURE_PATH
	res = res and preset.sprite.mouth.modulate == config.SPRITE_CUSTOMIZATION.MOUTH_COLOR
	return res


func open_save_preset_menu() -> void:
	_get_player_customization_ui().save_preset_button.pressed.emit()


func is_save_preset_popup_visible() -> bool:
	return _get_menus().save_preset_popup.visible


func save_preset_with_name_and_description(pname: String, pdescription: String) -> void:
	_get_menus().save_preset_popup.preset_name.text = pname
	_get_menus().save_preset_popup.preset_description.text = pdescription
	_get_menus().save_preset_popup.get_ok_button().pressed.emit()


func preset_buttons_contains_preset(preset_buttons: Array, preset: PlayerConfig) -> bool:
	for preset_button in preset_buttons:
		if is_preset_equal(preset_button, preset):
			return true
	return false


func is_override_preset_popup_visible() -> bool:
	return _get_menus().get_node("OverridePresetPopup").visible


func override_preset() -> void:
	_get_menus().get_node("OverridePresetPopup").get_ok_button().pressed.emit()


func get_player_name() -> String:
	return _get_player_config_diplay().name_edit.text


func set_player_name(pname: String) -> void:
	_get_player_config_diplay().name_edit.text = pname
	_get_player_config_diplay().name_edit.focus_exited.emit()


func open_elimination_text_menu() -> void:
	_get_player_config_panel().elimination_text_edit.pressed.emit()


func is_elimination_text_menu_visible() -> bool:
	return _get_menus().popup_menus_root.elimination_text.visible


func set_elimination_text(text: String) -> void:
	_get_menus().menus_in_popups.elimination_text.set_elimination_text(text)
	_get_menus().menus_in_popups.elimination_text.ok_button.pressed.emit()


func get_elimination_text() -> String:
	return _get_menus().menus_in_popups.elimination_text.get_elimination_text()


func change_main_color(color: Color) -> void:
	_get_player_config_panel().main_color.color = color
	_get_player_config_panel().main_color.color_changed.emit(color)


func is_customization_preview_main_color(color: Color) -> bool:
	var res = true
	res = res and _get_player_config_panel().main_color.color == color
	res = res and _get_sprite_preview().body.modulate == color
	return res


func change_secondary_color(color: Color) -> void:
	_get_player_config_panel().secondary_color.color = color
	_get_player_config_panel().secondary_color.color_changed.emit(color)


func is_customization_preview_secondary_color(color: Color) -> bool:
	var res = true
	res = res and _get_player_config_panel().secondary_color.color == color
	res = res and _get_sprite_preview().outline.modulate == color
	return res


func change_eyes_color(color: Color) -> void:
	_get_player_config_panel().eyes_color.color = color
	_get_player_config_panel().eyes_color.color_changed.emit(color)


func is_customization_preview_eyes_color(color: Color) -> bool:
	var res = true
	res = res and _get_player_config_panel().eyes_color.color == color
	res = res and _get_sprite_preview().eyes.modulate == color
	return res


func change_mouth_color(color: Color) -> void:
	_get_player_config_panel().mouth_color.color = color
	_get_player_config_panel().mouth_color.color_changed.emit(color)


func is_customization_preview_mouth_color(color: Color) -> bool:
	var res = true
	res = res and _get_player_config_panel().mouth_color.color == color
	res = res and _get_sprite_preview().mouth.modulate == color
	return res


func change_eyes() -> void:
	_get_player_config_panel().eyes_edit.pressed.emit()


func is_eyes_selection_menu_visible() -> bool:
	return _get_menus().popup_menus_root.eyes_selection.visible


func get_eyes_items() -> Array:
	var ret = []
	for item_idx in range(0, _get_menus().menus_in_popups.eyes_selection.items.item_count):
		ret.append(_get_menus().menus_in_popups.eyes_selection.items.get_item_icon(item_idx))
	return ret


func select_eyes_item(item_idx: int) -> void:
	_get_menus().menus_in_popups.eyes_selection.items.select(item_idx)
	_get_menus().menus_in_popups.eyes_selection.items.item_activated.emit(item_idx)


func is_eyes_texture_path_equal(path: String) -> bool:
	return path == _get_sprite_preview().eyes.texture.resource_path


func change_mouth() -> void:
	_get_player_config_panel().mouth_edit.pressed.emit()


func is_mouth_selection_menu_visible() -> bool:
	return _get_menus().popup_menus_root.mouth_selection.visible


func get_mouth_items() -> Array:
	var ret = []
	for item_idx in range(0, _get_menus().menus_in_popups.mouth_selection.items.item_count):
		ret.append(_get_menus().menus_in_popups.mouth_selection.items.get_item_icon(item_idx))
	return ret


func select_mouth_item(item_idx: int) -> void:
	_get_menus().menus_in_popups.mouth_selection.items.select(item_idx)
	_get_menus().menus_in_popups.mouth_selection.items.item_activated.emit(item_idx)


func is_mouth_texture_path_equal(path: String) -> bool:
	return path == _get_sprite_preview().mouth.texture.resource_path


func open_primary_weapon_menu() -> void:
	_get_player_config_diplay().primary_weapon.pressed.emit()


func is_primary_weapon_menu_visible() -> bool:
	return _get_menus().popup_menus_root.primary_weapon.visible


func get_primary_weapon_item_grid_element(idx: int) -> ItemGridMenuElement:
	return _get_menus().menus_in_popups.primary_weapon._items[idx]


func select_primary_weapon(idx: int) -> void:
	_get_menus().menus_in_popups.primary_weapon.items.select(idx)
	_get_menus().menus_in_popups.primary_weapon.items.item_selected.emit(idx)


func open_movement_bonus_menu() -> void:
	_get_player_config_diplay().movement_bonus.pressed.emit()


func is_movement_bonus_menu_visible() -> bool:
	return _get_menus().popup_menus_root.movement_bonus.visible


func get_movement_bonus_item_grid_element(idx: int) -> ItemGridMenuElement:
	return _get_menus().menus_in_popups.movement_bonus._items[idx]


func select_movement_bonus(idx: int) -> void:
	_get_menus().menus_in_popups.movement_bonus.items.select(idx)
	_get_menus().menus_in_popups.movement_bonus.items.item_selected.emit(idx)


func open_powerup_menu() -> void:
	_get_player_config_diplay().powerup.pressed.emit()


func is_powerup_menu_visible() -> bool:
	return _get_menus().popup_menus_root.powerup.visible


func get_powerup_item_grid_element(idx: int) -> ItemGridMenuElement:
	return _get_menus().menus_in_popups.powerup._items[idx]


func select_powerup(idx: int) -> void:
	_get_menus().menus_in_popups.powerup.items.select(idx)
	_get_menus().menus_in_popups.powerup.items.item_selected.emit(idx)


func _get_player_customization_ui() -> Node:
	return _menu.player_customization_ui


func _get_player_config_diplay() -> Node:
	return _get_player_customization_ui().player_config_display


func _get_menus() -> Node:
	return _get_player_customization_ui().menus


func _get_player_config_panel() -> Node:
	return _get_player_config_diplay().player_sprite_config.panel


func _get_sprite_preview() -> Node:
	return _get_player_config_diplay().player_sprite_config.sprites
