extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var item


##### SETUP #####
func before_each():
	item = add_child_autofree(
		load("res://Scenes/UI/PlayerCustomizationMenu/player_selection_item.tscn").instantiate()
	)


##### TESTS #####
var get_config_params := [[true, false], [false, true], [false, false]]


func test_get_config(params = use_parameters(get_config_params)):
	# given
	var config = PlayerConfig.new()
	var is_human_player: bool = params[0]
	var is_ai_player: bool = params[1]
	item.empty_menu.visible = (not is_human_player and not is_ai_player)
	item.user_menu.visible = is_human_player
	item.ai_menu.visible = is_ai_player
	if is_human_player:
		item.user_menu.player_config = config
	elif is_ai_player:
		item.ai_menu.player_config = config
	# when
	var res = item.get_config()
	# then
	if (is_human_player or is_ai_player):
		assert_eq(res, config)
		return
	assert_null(res)


func test_add_user_shows_player_customization_menu():
	# given
	watch_signals(item)
	# when
	item.add_user_button.pressed.emit()
	# then
	assert_true(item.user_menu.visible)
	assert_false(item.ai_menu.visible)
	assert_false(item.empty_menu.visible)
	assert_signal_emitted(item.player_toggled)


func test_add_ai_shows_ai_menu():
	# given
	watch_signals(item)
	# when
	item.add_ai_button.pressed.emit()
	# then
	assert_false(item.user_menu.visible)
	assert_true(item.ai_menu.visible)
	assert_false(item.empty_menu.visible)
	assert_signal_emitted(item.player_toggled)


func test_player_customization_menu_quit():
	# given
	watch_signals(item)
	item.user_menu.visible = true
	item.empty_menu.visible = false
	# when
	item.user_menu.quit.emit()
	# then
	assert_false(item.user_menu.visible)
	assert_false(item.ai_menu.visible)
	assert_true(item.empty_menu.visible)
	assert_signal_emitted(item.player_toggled)


func test_ai_menu_quit():
	# given
	watch_signals(item)
	item.ai_menu.visible = true
	item.empty_menu.visible = false
	# when
	item.ai_menu.quit.emit()
	# then
	assert_false(item.user_menu.visible)
	assert_false(item.ai_menu.visible)
	assert_true(item.empty_menu.visible)
	assert_signal_emitted(item.player_toggled)
