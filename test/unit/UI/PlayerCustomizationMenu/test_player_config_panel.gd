extends "res://addons/gut/test.gd"
##### VARIABLES #####

#---- VARIABLES -----
var panel


##### SETUP #####
func before_each():
	panel = add_child_autofree(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerSpriteConfig/player_config_panel.tscn").instantiate())


##### TESTS #####
func test_set_player_config():
	# given
	var sprite_config = SpriteCustomizationResource.new()
	sprite_config.BODY_COLOR = Color.AQUAMARINE
	sprite_config.OUTLINE_COLOR = Color.BEIGE
	sprite_config.EYES_COLOR = Color.AQUA
	sprite_config.MOUTH_COLOR = Color.RED
	# when
	panel.set_player_config(sprite_config)
	# then
	assert_eq(panel.main_color.color, Color.AQUAMARINE)
	assert_eq(panel.secondary_color.color, Color.BEIGE)
	assert_eq(panel.eyes_color.color, Color.AQUA)
	assert_eq(panel.mouth_color.color, Color.RED)


var set_size_params := [
	[true],
	[false],
]


func test_set_size(params = use_parameters(set_size_params)):
	# given
	var small: bool = params[0]
	# when
	panel.toggle_is_small(small)
	# then
	for element in panel.font_sizes_to_change:
		assert_eq(element.get_theme_font_size("font_size"), panel.FONT_SIZE_SMALL if small else panel.FONT_SIZE_BIG)
	assert_eq(panel.get_theme_constant("separation"), panel.H_SEPARATION_SMALL if small else panel.H_SEPARATION_BIG)


func test_send_signal_on_main_color_changed():
	# given
	watch_signals(panel)
	# when
	panel.main_color.color_changed.emit(Color.BLUE)
	# then
	assert_signal_emitted_with_parameters(panel.main_color_changed, [Color.BLUE])


func test_send_signal_on_secondary_color_changed():
	# given
	watch_signals(panel)
	# when
	panel.secondary_color.color_changed.emit(Color.BLUE)
	# then
	assert_signal_emitted_with_parameters(panel.secondary_color_changed, [Color.BLUE])


func test_send_signal_on_eyes_change_triggered():
	# given
	watch_signals(panel)
	# when
	panel.eyes_edit.pressed.emit()
	# then
	assert_signal_emitted(panel.eyes_change_triggered)


func test_send_signal_on_eyes_color_changed():
	# given
	watch_signals(panel)
	# when
	panel.eyes_color.color_changed.emit(Color.BLUE)
	# then
	assert_signal_emitted_with_parameters(panel.eyes_color_changed, [Color.BLUE])


func test_send_signal_on_mouth_change_triggered():
	# given
	watch_signals(panel)
	# when
	panel.mouth_edit.pressed.emit()
	# then
	assert_signal_emitted(panel.mouth_change_triggered)


func test_send_signal_on_mouth_color_changed():
	# given
	watch_signals(panel)
	# when
	panel.mouth_color.color_changed.emit(Color.BLUE)
	# then
	assert_signal_emitted_with_parameters(panel.mouth_color_changed, [Color.BLUE])


func test_send_signal_on_elimination_text_change_triggered():
	# given
	watch_signals(panel)
	# when
	panel.elimination_text_edit.pressed.emit()
	# then
	assert_signal_emitted(panel.elimination_text_change_triggered)


func test_send_signal_on_randomize():
	# given
	watch_signals(panel)
	# when
	panel.randomize_button.pressed.emit()
	# then
	assert_signal_emitted(panel.randomize)
