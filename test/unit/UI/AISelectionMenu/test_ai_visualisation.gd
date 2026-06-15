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
	var sprite_config = SpriteCustomizationResource.new()
	visualisation.player_sprite = player_sprite
	# when
	visualisation.update_ai(sprite_config)
	# then
	assert_called(player_sprite, "update_sprite", [sprite_config])


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
