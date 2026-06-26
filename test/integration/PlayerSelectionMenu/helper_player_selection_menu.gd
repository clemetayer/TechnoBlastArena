extends Node

##### VARIABLES #####
#---- CONSTANTS -----
const INTEGRATION_TEST_PRESET_PATH = "res://test/integration/PlayerSelectionMenu/integration_preset.tres"
const INTEGRATION_TEST_SAVE_PATH := StaticUtils.USER_CHARACTER_PRESETS_PATH + "integration_test" + StaticUtils.GODOT_RESOURCE_FILE_EXTENSION
const INTEGRATION_TEST_PRESET_NAME := "integration_test"

#---- STANDARD -----
#==== PRIVATE ====
var _menu


##### PUBLIC METHODS #####
func set_selection_menu(menu):
	_menu = menu


func get_player_selection_items() -> Array:
	return _menu.player_selection_items.get_children()


func get_integration_test_config() -> PlayerConfig:
	return load(INTEGRATION_TEST_PRESET_PATH)


func save_std_preset() -> void:
	var preset = load(INTEGRATION_TEST_PRESET_PATH)
	ResourceSaver.save(preset, INTEGRATION_TEST_SAVE_PATH)


func remove_std_preset() -> void:
	remove_preset_with_name(INTEGRATION_TEST_PRESET_NAME)


func remove_preset_with_name(pname: String) -> void:
	var dir_access = DirAccess.open(StaticUtils.USER_CHARACTER_PRESETS_PATH)
	dir_access.remove(pname + StaticUtils.GODOT_RESOURCE_FILE_EXTENSION)


func count_saved_presets() -> int:
	var dir = DirAccess.open(StaticUtils.USER_CHARACTER_PRESETS_PATH)
	return dir.get_files().size()


func add_player_on_item(item: Node) -> void:
	item.add_user_button.pressed.emit()


func add_ai_player_on_item(item: Node) -> void:
	item.add_ai_button.pressed.emit()


func is_empty_menu_visible(item: Node) -> bool:
	return item.empty_menu.visible


func is_user_menu_visible(item: Node) -> bool:
	return item.user_menu.visible


func is_ai_preset_menu_visible(item: Node) -> bool:
	return item.ai_menu.presets.visible


func is_ai_visualisation_menu_visible(item: Node) -> bool:
	return item.ai_menu.visualisation.visible


func select_first_ai_preset(item: Node) -> void:
	item.ai_menu.presets.presets_root.get_child(0).button.pressed.emit()


func remove_ai_player_on_item(item: Node) -> void:
	item.ai_menu.quit.emit()


func remove_player_on_item(item: Node) -> void:
	item.user_menu.quit.emit()


func is_config_equals_display(config: PlayerConfig, item: Node) -> bool:
	var res = true
	res = res and _get_player_config_diplay(item).name_edit.text == config.PLAYER_NAME
	res = res and _get_sprite_preview(item).body.modulate == config.SPRITE_CUSTOMIZATION.BODY_COLOR
	res = res and _get_sprite_preview(item).outline.modulate == config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR
	res = res and _get_sprite_preview(item).eyes.texture.resource_path == config.SPRITE_CUSTOMIZATION.EYES_TEXTURE_PATH
	res = res and _get_sprite_preview(item).eyes.modulate == config.SPRITE_CUSTOMIZATION.EYES_COLOR
	res = res and _get_sprite_preview(item).mouth.texture.resource_path == config.SPRITE_CUSTOMIZATION.MOUTH_TEXTURE_PATH
	res = res and _get_sprite_preview(item).mouth.modulate == config.SPRITE_CUSTOMIZATION.MOUTH_COLOR
	res = res and _get_player_config_diplay(item).primary_weapon.icon.resource_path == StaticPrimaryWeaponHandler.get_icon_path(config.PRIMARY_WEAPON)
	res = res and _get_player_config_diplay(item).powerup.icon.resource_path == StaticPowerupHandler.get_icon_path(config.POWERUP_HANDLER)
	res = res and _get_player_config_diplay(item).movement_bonus.icon.resource_path == StaticMovementBonusHandler.get_icon_path(config.MOVEMENT_BONUS_HANDLER)
	return res


func is_presets_menu_visible(item: Node) -> bool:
	return _get_menus(item).full_menus.preset_selection.visible


func select_presets_menu(item: Node) -> void:
	_get_user_menu(item).preset_selection_button.pressed.emit()


func get_presets(item: Node) -> Array:
	return _get_menus(item).full_menus.preset_selection.presets_root.get_children()


func get_presets_configs(item: Node) -> Dictionary:
	return _get_menus(item).full_menus.preset_selection._presets


func is_preset_menu_visible(item: Node) -> bool:
	return _get_menus(item).full_menus.preset_selection.visible


func is_preset_equal(preset: Control, config: PlayerConfig) -> bool:
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


func preset_buttons_contains_preset(preset_buttons: Array, preset: PlayerConfig) -> bool:
	for preset_button in preset_buttons:
		if is_preset_equal(preset_button, preset):
			return true
	return false


func select_preset(preset: Control) -> void:
	preset.button.pressed.emit()


func select_primary_weapon_menu(item: Node) -> void:
	_get_player_config_diplay(item).primary_weapon.pressed.emit()


func select_primary_weapon(idx: int, item: Node) -> void:
	_get_menus(item).full_menus.primary_weapon.items.select(idx)
	_get_menus(item).full_menus.primary_weapon.items.item_selected.emit(idx)


func is_primary_weapon_menu_visible(item: Node) -> bool:
	return _get_menus(item).full_menus.primary_weapon.visible


func is_primary_weapon_selected(weapon: StaticPrimaryWeaponHandler.handlers, item: Node) -> bool:
	return item.get_config().PRIMARY_WEAPON == weapon


func select_movement_bonus_menu(item: Node) -> void:
	_get_player_config_diplay(item).movement_bonus.pressed.emit()


func select_movement_bonus(idx: int, item: Node) -> void:
	_get_menus(item).full_menus.movement_bonus.items.select(idx)
	_get_menus(item).full_menus.movement_bonus.items.item_selected.emit(idx)


func is_movement_bonus_menu_visible(item: Node) -> bool:
	return _get_menus(item).full_menus.movement_bonus.visible


func is_movement_bonus_selected(movement_bonus: StaticMovementBonusHandler.handlers, item: Node) -> bool:
	return item.get_config().MOVEMENT_BONUS_HANDLER == movement_bonus


func select_powerup_menu(item: Node) -> void:
	_get_player_config_diplay(item).powerup.pressed.emit()


func select_powerup(idx: int, item: Node) -> void:
	_get_menus(item).full_menus.powerup.items.select(idx)
	_get_menus(item).full_menus.powerup.items.item_selected.emit(idx)


func is_powerup_menu_visible(item: Node) -> bool:
	return _get_menus(item).full_menus.powerup.visible


func is_powerup_selected(powerup: StaticPowerupHandler.handlers, item: Node) -> bool:
	return item.get_config().POWERUP_HANDLER == powerup


func _get_user_menu(item: Node) -> Node:
	return item.user_menu


func _get_player_config_diplay(item: Node) -> Node:
	return _get_user_menu(item).player_config_display


func _get_menus(item: Node) -> Node:
	return _get_user_menu(item).menus


func _get_player_config_panel(item: Node) -> Node:
	return _get_player_config_diplay(item).player_sprite_config.panel


func _get_sprite_preview(item: Node) -> Node:
	return _get_player_config_diplay(item).player_sprite_config.sprites
