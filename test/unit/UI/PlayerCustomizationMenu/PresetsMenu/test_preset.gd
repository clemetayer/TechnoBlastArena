extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var preset


##### SETUP #####
func before_each():
	preset = add_child_autofree(load("res://Scenes/UI/PlayerCustomizationMenu/PresetsMenu/preset.tscn").instantiate())


func test_set_preset():
	# given
	var sprite = double(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerSprite/player_sprite.gd")).new()
	stub(sprite, "update_sprite").to_do_nothing()
	preset.sprite = sprite
	var config = PlayerConfig.new()
	config.PLAYER_NAME = "name"
	config.PRIMARY_WEAPON = StaticPrimaryWeaponHandler.handlers.REVOLVER
	config.MOVEMENT_BONUS_HANDLER = StaticMovementBonusHandler.handlers.DASH
	config.POWERUP_HANDLER = StaticPowerupHandler.handlers.SPLITTER
	config.SPRITE_CUSTOMIZATION = SpriteCustomizationResource.new() # when
	config.DESCRIPTION = "description of the preset"
	preset.set_preset("test", config)
	# then
	assert_eq(preset.name_label.text, "name")
	assert_not_null(preset.primary_weapon.texture)
	assert_not_null(preset.movement_bonus.texture)
	assert_not_null(preset.powerup.texture)
	assert_called(sprite, "update_sprite", [config.SPRITE_CUSTOMIZATION])
	assert_false(preset.level.visible)
	assert_eq(preset.tooltip_text, config.DESCRIPTION)
	assert_eq(preset._preset_path, StaticUtils.get_preset_save_path("test"))


func test_preset_selected():
	# given
	watch_signals(preset)
	# when
	preset.button.pressed.emit()
	# then
	assert_signal_emitted(preset.preset_selected)


func test_remove_preset():
	# given
	var sprite_config = SpriteCustomizationResource.new()
	sprite_config.EYES_TEXTURE_PATH = "res://icon.svg"
	sprite_config.MOUTH_TEXTURE_PATH = "res://icon.svg"
	var preset_to_save = PlayerConfig.new()
	preset_to_save.SPRITE_CUSTOMIZATION = sprite_config
	ResourceSaver.save(preset_to_save, StaticUtils.get_preset_save_path("gdunittest"))
	watch_signals(preset)
	# when
	var saved_preset = load(StaticUtils.get_preset_save_path("gdunittest"))
	preset.set_preset("gdunittest", saved_preset)
	preset.delete_button.pressed.emit()
	await wait_process_frames(2)
	# then
	var dir_access = DirAccess.open(StaticUtils.USER_CHARACTER_PRESETS_PATH)
	assert_signal_emitted(preset.preset_deleted)
	var resource_exists = dir_access.file_exists(StaticUtils.get_preset_save_path("gdunittest"))
	assert_false(resource_exists)
	# cleanup
	if resource_exists:
		dir_access.remove(StaticUtils.get_preset_save_path("gdunittest"))


func test_set_ai_preset():
	# given
	var config = load("res://Resources/AIPresets/groggy_gary.tres")
	var level = double(load("res://Scenes/UI/PlayerCustomizationMenu/PresetsMenu/ai_level.tscn")).instantiate()
	stub(level, "set_level").to_do_nothing()
	preset.level = level
	# when
	preset.set_preset("test", config)
	# then
	assert_eq(preset.name_label.text, config.PLAYER_NAME)
	assert_true(preset.level.visible)
	assert_called(level, "set_level")
	assert_false(preset.delete_button.visible)
