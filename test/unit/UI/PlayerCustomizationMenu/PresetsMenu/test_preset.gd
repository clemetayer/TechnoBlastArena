extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var preset


##### SETUP #####
func before_each():
	preset = load("res://Scenes/UI/PlayerCustomizationMenu/PresetsMenu/preset.tscn").instantiate()
	add_child_autofree(preset)
	wait_for_signal(preset.tree_entered, 0.1)


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
	preset.set_preset(config)
	# then
	assert_eq(preset.name_label.text, "name")
	assert_not_null(preset.primary_weapon.texture)
	assert_not_null(preset.movement_bonus.texture)
	assert_not_null(preset.powerup.texture)
	assert_called(sprite, "update_sprite", [config.SPRITE_CUSTOMIZATION])
	assert_false(preset.level.visible)
	assert_eq(preset.tooltip_text, config.DESCRIPTION)


func test_set_ai_preset():
	# given
	var config = load("res://Resources/AIPresets/groggy_gary.tres")
	var level = double(load("res://Scenes/UI/PlayerCustomizationMenu/PresetsMenu/ai_level.tscn")).instantiate()
	stub(level, "set_level").to_do_nothing()
	preset.level = level
	# when
	preset.set_preset(config)
	# then
	assert_eq(preset.name_label.text, config.PLAYER_NAME)
	assert_true(preset.level.visible)
	assert_called(level, "set_level")
