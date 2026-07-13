extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const PLAYER_1_DEFAULT_CONFIG_PATH := "res://test/integration/UI/player_1.tres"
const PLAYER_2_DEFAULT_CONFIG_PATH := "res://test/integration/UI/player_2.tres"
const DEFAULT_LEVEL_CONFIG_PATH := "res://test/integration/UI/level_default.tres"

#---- VARIABLES -----
var scene
var _sender = InputSender.new(Input)


##### SETUP #####
func before_each():
	scene = load("res://test/integration/UI/scene_ui.tscn").instantiate()
	add_child_autofree(scene)
	await wait_process_frames(5)


##### TEARDOWN #####
func after_each():
	_sender.release_all()
	_sender.clear()


##### TESTS #####
func test_init_two_players():
	# given
	var default_level = load(DEFAULT_LEVEL_CONFIG_PATH)
	var player_1_config = load(PLAYER_1_DEFAULT_CONFIG_PATH)
	var player_2_config = load(PLAYER_2_DEFAULT_CONFIG_PATH)
	scene.set_level_data(default_level)
	scene.set_player_data(1, player_1_config)
	scene.set_player_data(2, player_2_config)
	scene.init_players_data()
	scene.init_level_data()
	scene.add_game_elements()
	scene.init_game_elements()
	await wait_seconds(3)
	# when / then
	var ui = scene.get_ui()
	assert_eq(ui.get_child_count(), 2)
	assert_eq(ui._players.size(), 2)
	assert_eq(ui._players[1].sprite_body.modulate, player_1_config.SPRITE_CUSTOMIZATION.BODY_COLOR)
	assert_eq(ui._players[1].sprite_outline.modulate, player_1_config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR)
	assert_eq(ui._players[2].sprite_body.modulate, player_2_config.SPRITE_CUSTOMIZATION.BODY_COLOR)
	assert_eq(ui._players[2].sprite_outline.modulate, player_2_config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR)
	assert_eq(ui._players[1].player_name.text, "")
	assert_eq(ui._players[2].player_name.text, "")
	var p1_movement_icon_path = StaticMovementBonusHandler.get_icon_path(player_1_config.MOVEMENT_BONUS_HANDLER)
	var p2_movement_icon_path = StaticMovementBonusHandler.get_icon_path(player_2_config.MOVEMENT_BONUS_HANDLER)
	var p1_powerup_icon_path = StaticPowerupHandler.get_icon_path(player_1_config.POWERUP_HANDLER)
	var p2_powerup_icon_path = StaticPowerupHandler.get_icon_path(player_2_config.POWERUP_HANDLER)
	var p1_movement = ui._players[1]._movement_ui
	var p1_powerup = ui._players[1]._powerup_ui
	var p1_lives = ui._players[1]._lives_ui
	var p2_movement = ui._players[2]._movement_ui
	var p2_powerup = ui._players[2]._powerup_ui
	var p2_lives = ui._players[2]._lives_ui
	assert_not_null(p1_movement)
	assert_eq(p1_movement.DATA_ICON, p1_movement_icon_path)
	assert_not_null(p1_powerup)
	assert_eq(p1_powerup.DATA_ICON, p1_powerup_icon_path)
	assert_not_null(p1_lives)
	assert_eq(p1_lives.LIVES, 3)
	assert_not_null(p2_movement)
	assert_eq(p2_movement.DATA_ICON, p2_movement_icon_path)
	assert_not_null(p2_powerup)
	assert_eq(p2_powerup.DATA_ICON, p2_powerup_icon_path)
	assert_not_null(p2_lives)
	assert_eq(p2_lives.LIVES, 3)


func test_lives():
	# given
	var default_level = load(DEFAULT_LEVEL_CONFIG_PATH)
	var player_1_config = load(PLAYER_1_DEFAULT_CONFIG_PATH)
	var player_2_config = load(PLAYER_2_DEFAULT_CONFIG_PATH)
	scene.set_level_data(default_level)
	scene.set_player_data(1, player_1_config)
	scene.set_player_data(2, player_2_config)
	scene.init_players_data()
	scene.init_level_data()
	scene.add_game_elements()
	scene.init_game_elements()
	await wait_seconds(3)
	# when / then
	var ui = scene.get_ui()
	var p1_lives = ui._players[1]._lives_ui
	var p2_lives = ui._players[2]._lives_ui
	assert_eq(p1_lives.LIVES, 3)
	assert_eq(p1_lives.tokens.get_child_count(), 3)
	assert_eq(_count_visible_tokens(p1_lives.tokens), 3)
	assert_eq(p1_lives.overflow.text, "")
	assert_eq(p2_lives.LIVES, 3)
	assert_eq(p2_lives.tokens.get_child_count(), 3)
	assert_eq(_count_visible_tokens(p2_lives.tokens), 3)
	assert_eq(p2_lives.overflow.text, "")
	scene.get_player(1).kill()
	await wait_seconds(3.0)
	assert_eq(p1_lives.LIVES, 2)
	assert_eq(p1_lives.tokens.get_child_count(), 3)
	assert_eq(_count_visible_tokens(p1_lives.tokens), 2)
	assert_eq(p1_lives.overflow.text, "")
	assert_eq(p2_lives.LIVES, 3)
	assert_eq(p2_lives.tokens.get_child_count(), 3)
	assert_eq(_count_visible_tokens(p2_lives.tokens), 3)
	assert_eq(p2_lives.overflow.text, "")


func test_dash():
	# given
	var default_level = load(DEFAULT_LEVEL_CONFIG_PATH)
	var player_1_config = load(PLAYER_1_DEFAULT_CONFIG_PATH)
	var player_2_config = load(PLAYER_2_DEFAULT_CONFIG_PATH)
	player_1_config.MOVEMENT_BONUS_HANDLER = StaticMovementBonusHandler.handlers.DASH
	player_2_config.MOVEMENT_BONUS_HANDLER = StaticMovementBonusHandler.handlers.DASH
	scene.set_level_data(default_level)
	scene.set_player_data(1, player_1_config)
	scene.set_player_data(2, player_2_config)
	scene.init_players_data()
	scene.init_level_data()
	scene.add_game_elements()
	scene.init_game_elements()
	await wait_seconds(3)
	scene.toggle_truce(false)
	# when / then
	var ui = scene.get_ui()
	await wait_process_frames(1)
	var p1_movement_icon_path = StaticMovementBonusHandler.get_icon_path(player_1_config.MOVEMENT_BONUS_HANDLER)
	var p2_movement_icon_path = StaticMovementBonusHandler.get_icon_path(player_2_config.MOVEMENT_BONUS_HANDLER)
	var p1_movement = ui._players[1]._movement_ui
	var p2_movement = ui._players[2]._movement_ui
	assert_eq(p1_movement.DATA_ICON, p1_movement_icon_path)
	assert_eq(p2_movement.DATA_ICON, p2_movement_icon_path)
	assert_eq(p1_movement.QUANTITY, 3)
	assert_eq(p1_movement.tokens.get_child_count(), 3)
	assert_eq(_count_visible_tokens(p1_movement.tokens), 3)
	assert_eq(p1_movement.overflow.text, "")
	assert_eq(p2_movement.QUANTITY, 3)
	assert_eq(p2_movement.tokens.get_child_count(), 3)
	assert_eq(_count_visible_tokens(p2_movement.tokens), 3)
	assert_eq(p2_movement.overflow.text, "")
	_sender.action_down("movement_bonus").hold_for(.1)
	await _sender.idle
	await wait_seconds(0.5)
	assert_eq(p1_movement.QUANTITY, 2)
	assert_eq(p1_movement.tokens.get_child_count(), 3)
	assert_eq(_count_visible_tokens(p1_movement.tokens), 2)
	assert_eq(p1_movement.overflow.text, "")
	assert_eq(p2_movement.QUANTITY, 3)
	assert_eq(p2_movement.tokens.get_child_count(), 3)
	assert_eq(_count_visible_tokens(p2_movement.tokens), 3)
	assert_eq(p2_movement.overflow.text, "")


func test_splitter():
	# given
	var default_level = load(DEFAULT_LEVEL_CONFIG_PATH)
	var player_1_config = load(PLAYER_1_DEFAULT_CONFIG_PATH)
	var player_2_config = load(PLAYER_2_DEFAULT_CONFIG_PATH)
	player_1_config.POWERUP_HANDLER = StaticPowerupHandler.handlers.SPLITTER
	player_2_config.POWERUP_HANDLER = StaticPowerupHandler.handlers.SPLITTER
	scene.set_level_data(default_level)
	scene.set_player_data(1, player_1_config)
	scene.set_player_data(2, player_2_config)
	scene.init_players_data()
	scene.init_level_data()
	scene.add_game_elements()
	scene.init_game_elements()
	await wait_seconds(3)
	scene.toggle_truce(false)
	# when / then
	var ui = scene.get_ui()
	await wait_process_frames(1)
	var p1_powerup_icon_path = StaticPowerupHandler.get_icon_path(player_1_config.POWERUP_HANDLER)
	var p2_powerup_icon_path = StaticPowerupHandler.get_icon_path(player_2_config.POWERUP_HANDLER)
	var p1_powerup = ui._players[1]._powerup_ui
	var p2_powerup = ui._players[2]._powerup_ui
	ui.update_powerup(1, 1)
	ui.update_powerup(2, 1)
	await wait_process_frames(1)
	assert_eq(p1_powerup.DATA_ICON, p1_powerup_icon_path)
	assert_eq(p2_powerup.DATA_ICON, p2_powerup_icon_path)
	assert_eq(p1_powerup.PROGRESS, 1)
	assert_eq(p1_powerup.overflow.text, "+1")
	assert_eq(p2_powerup.PROGRESS, 1)
	assert_eq(p2_powerup.overflow.text, "+1")
	_sender.action_down("powerup").hold_for(.1)
	await _sender.idle
	await wait_seconds(0.5)
	assert_between(p1_powerup.PROGRESS, 0.01, 0.99)
	assert_eq(p1_powerup.overflow.text, "")
	assert_eq(p2_powerup.PROGRESS, 1)
	assert_eq(p2_powerup.overflow.text, "+1")


##### UTILS #####
func _count_visible_tokens(tokens_parent) -> int:
	var count = 0
	for token in tokens_parent.get_children():
		if token.visible:
			count += 1
	return count
