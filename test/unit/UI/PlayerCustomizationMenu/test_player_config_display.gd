extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var display


##### SETUP #####
func before_each():
	display = load("res://Scenes/UI/PlayerCustomizationMenu/PlayerConfigDisplay/player_config_display.tscn").instantiate()
	add_child_autofree(display)


##### TESTS #####
func test_update_player():
	# given
	var player_sprite_config = mock_player_sprite_config()
	stub(player_sprite_config, "update_config").to_do_nothing()
	var player_config = PlayerConfig.new()
	player_config.PLAYER_NAME = "name"
	player_config.PRIMARY_WEAPON = StaticPrimaryWeaponHandler.handlers.REVOLVER
	player_config.MOVEMENT_BONUS_HANDLER = StaticMovementBonusHandler.handlers.DASH
	player_config.POWERUP_HANDLER = StaticPowerupHandler.handlers.SPLITTER
	var sprite_customization = SpriteCustomizationResource.new()
	player_config.SPRITE_CUSTOMIZATION = sprite_customization
	player_config.PRIMARY_WEAPON = StaticPrimaryWeaponHandler.handlers.REVOLVER
	player_config.POWERUP_HANDLER = StaticPowerupHandler.handlers.SPLITTER
	player_config.MOVEMENT_BONUS_HANDLER = StaticMovementBonusHandler.handlers.DASH
	# when
	display.update_player(player_config)
	# then
	assert_called(player_sprite_config, "update_config", [player_config.SPRITE_CUSTOMIZATION])
	assert_eq(display.name_edit.text, "name")
	assert_eq(display.primary_weapon.icon.resource_path, StaticPrimaryWeaponHandler.get_icon_path(StaticPrimaryWeaponHandler.handlers.REVOLVER))
	assert_eq(display.movement_bonus.icon.resource_path, StaticMovementBonusHandler.get_icon_path(StaticMovementBonusHandler.handlers.DASH))
	assert_eq(display.powerup.icon.resource_path, StaticPowerupHandler.get_icon_path(StaticPowerupHandler.handlers.SPLITTER))


var set_size_params := [
	[true],
	[false],
]


func test_set_size(params = use_parameters(set_size_params)):
	# given
	var is_small: bool = params[0]
	var player_sprite_config = mock_player_sprite_config()
	stub(player_sprite_config, "toggle_is_small").to_do_nothing()
	# when
	display.toggle_is_small(is_small)
	# then
	assert_called(player_sprite_config, "toggle_is_small", [is_small])
	assert_eq(display.name_edit.get_theme_font_size("font_size"), display.NAME_FONT_SIZE_SMALL if is_small else display.NAME_FONT_SIZE_BIG)


func test_press_primary_weapon_sends_signal():
	# given
	watch_signals(display)
	# when
	display.primary_weapon.pressed.emit()
	# then
	assert_signal_emitted(display.primary_weapon_change_requested)


func test_press_powerup_sends_signal():
	# given
	watch_signals(display)
	# when
	display.powerup.pressed.emit()
	# then
	assert_signal_emitted(display.powerup_change_requested)


func test_press_movement_bonus_sends_signal():
	# given
	watch_signals(display)
	# when
	display.movement_bonus.pressed.emit()
	# then
	assert_signal_emitted(display.movement_bonus_change_requested)


func test_change_name_sends_signal():
	# given
	watch_signals(display)
	display.name_edit.text = "test"
	# when
	display.name_edit.focus_exited.emit()
	# then
	assert_signal_emitted_with_parameters(display.name_changed, ["test"])


func test_transfer_main_color_changed():
	# given
	watch_signals(display)
	# when
	display.player_sprite_config.main_color_changed.emit(Color.BLUE)
	# then
	assert_signal_emitted_with_parameters(display.main_color_changed, [Color.BLUE])


func test_transfer_secondary_color_changed():
	# given
	watch_signals(display)
	# when
	display.player_sprite_config.secondary_color_changed.emit(Color.BLUE)
	# then
	assert_signal_emitted_with_parameters(display.secondary_color_changed, [Color.BLUE])


func test_transfer_eyes_change_triggered():
	# given
	watch_signals(display)
	# when
	display.player_sprite_config.eyes_change_triggered.emit()
	# then
	assert_signal_emitted(display.eyes_change_triggered)


func test_transfer_eyes_color_changed():
	# given
	watch_signals(display)
	# when
	display.player_sprite_config.eyes_color_changed.emit(Color.BLUE)
	# then
	assert_signal_emitted_with_parameters(display.eyes_color_changed, [Color.BLUE])


func test_transfer_mouth_change_triggered():
	# given
	watch_signals(display)
	# when
	display.player_sprite_config.mouth_change_triggered.emit()
	# then
	assert_signal_emitted(display.mouth_change_triggered)


func test_transfer_mouth_color_changed():
	# given
	watch_signals(display)
	# when
	display.player_sprite_config.mouth_color_changed.emit(Color.BLUE)
	# then
	assert_signal_emitted_with_parameters(display.mouth_color_changed, [Color.BLUE])


func test_transfer_elimination_text_change_requested():
	# given
	watch_signals(display)
	# when
	display.player_sprite_config.elimination_text_change_triggered.emit()
	# then
	assert_signal_emitted(display.elimination_text_change_triggered)


func test_transfer_randomize():
	# given
	watch_signals(display)
	# when
	display.player_sprite_config.randomize.emit()
	# then
	assert_signal_emitted(display.randomize)


##### UTILS #####
func mock_player_sprite_config():
	var player_sprite_config = double(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerSpriteConfig/player_sprite_config.gd")).new()
	display.player_sprite_config = player_sprite_config
	return player_sprite_config
