extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
# const CONST := "value"

#---- VARIABLES -----
var sprite_config


##### SETUP #####
func before_each():
	sprite_config = add_child_autofree(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerSpriteConfig/player_sprite_config.tscn").instantiate())


##### TESTS #####
func test_update_config():
	# given
	var config = SpriteCustomizationResource.new()
	var panel = mock_panel()
	stub(panel, "set_player_config").to_do_nothing()
	var sprites = mock_sprites()
	stub(sprites, "update_sprite").to_do_nothing()
	# when
	sprite_config.update_config(config)
	# then
	assert_called(panel, "set_player_config", [config])
	assert_called(sprites, "update_sprite", [config])


var set_size_params := [
	[true],
	[false],
]


func test_set_size(params = use_parameters(set_size_params)):
	# given
	var is_small: bool = params[0]
	var panel = mock_panel()
	stub(panel, "toggle_is_small").to_do_nothing()
	# when
	sprite_config.toggle_is_small(is_small)
	# then
	assert_called(panel, "toggle_is_small", [is_small])
	assert_eq(sprite_config.get_theme_constant("margin_left"), sprite_config.MARGIN_SMALL.x if is_small else sprite_config.MARGIN_BIG.x)
	assert_eq(sprite_config.get_theme_constant("margin_right"), sprite_config.MARGIN_SMALL.x if is_small else sprite_config.MARGIN_BIG.x)
	assert_eq(sprite_config.get_theme_constant("margin_bottom"), sprite_config.MARGIN_SMALL.y if is_small else sprite_config.MARGIN_BIG.y)
	assert_eq(sprite_config.get_theme_constant("margin_top"), sprite_config.MARGIN_SMALL.y if is_small else sprite_config.MARGIN_BIG.y)


func test_transfer_main_color_changed():
	# given
	watch_signals(sprite_config)
	# when
	sprite_config.panel.main_color_changed.emit(Color.BLUE)
	# then
	assert_signal_emitted_with_parameters(sprite_config.main_color_changed, [Color.BLUE])


func test_transfer_secondary_color_changed():
	# given
	watch_signals(sprite_config)
	# when
	sprite_config.panel.secondary_color_changed.emit(Color.BLUE)
	# then
	assert_signal_emitted_with_parameters(sprite_config.secondary_color_changed, [Color.BLUE])


func test_transfer_eyes_change_triggered():
	# given
	watch_signals(sprite_config)
	# when
	sprite_config.panel.eyes_change_triggered.emit()
	# then
	assert_signal_emitted(sprite_config.eyes_change_triggered)


func test_transfer_eyes_color_changed():
	# given
	watch_signals(sprite_config)
	# when
	sprite_config.panel.eyes_color_changed.emit(Color.BLUE)
	# then
	assert_signal_emitted_with_parameters(sprite_config.eyes_color_changed, [Color.BLUE])


func test_transfer_mouth_change_triggered():
	# given
	watch_signals(sprite_config)
	# when
	sprite_config.panel.mouth_change_triggered.emit()
	# then
	assert_signal_emitted(sprite_config.mouth_change_triggered)


func test_transfer_mouth_color_changed():
	# given
	watch_signals(sprite_config)
	# when
	sprite_config.panel.mouth_color_changed.emit(Color.BLUE)
	# then
	assert_signal_emitted_with_parameters(sprite_config.mouth_color_changed, [Color.BLUE])


func test_transfer_elimination_text_change_requested():
	# given
	watch_signals(sprite_config)
	# when
	sprite_config.panel.elimination_text_change_triggered.emit()
	# then
	assert_signal_emitted(sprite_config.elimination_text_change_triggered)


func test_transfer_randomize():
	# given
	watch_signals(sprite_config)
	# when
	sprite_config.panel.randomize.emit()
	# then
	assert_signal_emitted(sprite_config.randomize)


##### UTILS #####
func mock_panel():
	var panel = double(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerSpriteConfig/player_config_panel.gd")).new()
	sprite_config.panel = panel
	return panel


func mock_sprites():
	var sprites = double(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerSprite/player_sprite.gd")).new()
	sprite_config.sprites = sprites
	return sprites
