extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var visualisation


##### SETUP #####
func before_each():
	visualisation = autofree(load("res://Scenes/UI/PlayerCustomizationMenu/AISelectionMenu/ai_visualisation.tscn").instantiate())


##### TESTS #####
func test_update_ai():
	# given
	var player_sprite = double(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerSprite/player_sprite.gd")).new()
	stub(player_sprite, "update_sprite").to_do_nothing()
	var player_config = PlayerConfig.new()
	player_config.PRIMARY_WEAPON = StaticPrimaryWeaponHandler.handlers.REVOLVER
	player_config.MOVEMENT_BONUS_HANDLER = StaticMovementBonusHandler.handlers.DASH
	player_config.POWERUP_HANDLER = StaticPowerupHandler.handlers.SPLITTER
	player_config.SPRITE_CUSTOMIZATION = SpriteCustomizationResource.new()
	player_config.PLAYER_NAME = "test"
	visualisation.player_sprite = player_sprite
	var primary_weapon = autofree(TextureRect.new())
	visualisation.primary_weapon = primary_weapon
	var movement_bonus = autofree(TextureRect.new())
	visualisation.movement_bonus = movement_bonus
	var powerup = autofree(TextureRect.new())
	visualisation.powerup = powerup
	var player_name = autofree(Label.new())
	visualisation.player_name = player_name
	# when
	visualisation.update_ai(player_config)
	# then
	assert_called(player_sprite, "update_sprite", [player_config.SPRITE_CUSTOMIZATION])
	assert_eq(primary_weapon.texture.resource_path, StaticPrimaryWeaponHandler.get_icon_path(StaticPrimaryWeaponHandler.handlers.REVOLVER))
	assert_eq(movement_bonus.texture.resource_path, StaticMovementBonusHandler.get_icon_path(StaticMovementBonusHandler.handlers.DASH))
	assert_eq(powerup.texture.resource_path, StaticPowerupHandler.get_icon_path(StaticPowerupHandler.handlers.SPLITTER))
	assert_eq(player_name.text, "test")


func test_close_menu_emits_signal():
	# given
	add_child(visualisation)
	watch_signals(visualisation)
	# when
	visualisation.close_button.pressed.emit()
	# then
	assert_signal_emitted(visualisation.close_triggered)


func test_show_presets_emit_signal():
	# given
	add_child(visualisation)
	watch_signals(visualisation)
	# when
	visualisation.ai_preset_selection_button.pressed.emit()
	# then
	assert_signal_emitted(visualisation.show_ai_presets_triggered)
