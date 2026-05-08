extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const PLAYER_1_DEFAULT_CONFIG_PATH := "res://test/system/Game/player_1.tres"
const PLAYER_2_DEFAULT_CONFIG_PATH := "res://test/system/Game/player_2.tres"
const DEFAULT_LEVEL_CONFIG_PATH := "res://test/system/Game/level_default.tres"

#---- VARIABLES -----
var scene
var _sender = InputSender.new(Input)
var default_level
var player_1_config
var player_2_config
var game_over_times_called := 0

##### SETUP #####
func before_each():
	scene = load("res://test/system/Game/scene_game.tscn").instantiate()
	add_child_autofree(scene)
	await wait_process_frames(5)
	game_over_times_called = 0

##### TEARDOWN #####
func after_each():
	_sender.release_all()
	_sender.clear()

##### TESTS #####
# Note : can't split this up into separate functions, otherwise, the await messes up with GUT
func test_game():
	# ---- given ----
	scene.get_game().connect("game_over", _on_game_over)
	# ==== init scene ====
	default_level = load(DEFAULT_LEVEL_CONFIG_PATH)
	player_1_config = load(PLAYER_1_DEFAULT_CONFIG_PATH)
	player_2_config = load(PLAYER_2_DEFAULT_CONFIG_PATH)
	scene.set_level_data(default_level)
	scene.set_player_data(1, player_1_config)
	scene.set_player_data(2, player_2_config)
	scene.init_players_data()
	scene.init_level_data()
	# ---- when ----
	# ==== start game ====
	scene.add_game_elements()
	scene.init_game_elements()
	scene.disable_player_mouse_input(1)
	await wait_process_frames(10)
	# ---- then ----
	# ==== check intro ====
	# checks ready text
	assert_eq(scene.get_game_message(), "Ready ?")
	# checks if can move but not use abilities
	assert_true(scene.get_player(1)._truce_active)
	assert_true(scene.get_player(2)._truce_active)
	_sender.action_down("fire").hold_for(.05)
	await _sender.idle
	_sender.release_all()
	assert_eq(scene.get_projectiles_count(), 0)
	_sender.action_down("powerup").hold_for(.05)
	await _sender.idle
	_sender.release_all()
	assert_eq(scene.get_powerups_count(), 0)
	await wait_seconds(0.1)
	var p1_ori_pos = scene.get_player(1).global_position
	# checks the countdown
	await wait_seconds(1)
	_sender.action_down("jump").action_down("right").hold_for(.25)
	await _sender.idle
	_sender.release_all()
	# assert_lt(scene.get_player(1).global_position.y, p1_ori_pos.y) # FIXME : for some reason this test is fairly unstable. However, this is already tested in integration tests so i'll comment it for the moment
	assert_gt(scene.get_player(1).global_position.x, p1_ori_pos.x)
	assert_eq(scene.get_game_message(), "3")
	await wait_seconds(1)
	assert_eq(scene.get_game_message(), "2")
	await wait_seconds(1)
	assert_eq(scene.get_game_message(), "1")
	# checks shoot and can use abilities
	await wait_seconds(1)
	assert_eq(scene.get_game_message(), "Shoot !")
	await wait_seconds(1)
	# ==== check movement and abilities ====
	_sender.action_down("fire").hold_for(.05)
	await _sender.idle
	_sender.release_all()
	await wait_process_frames(2)
	assert_eq(scene.get_projectiles_count(), 1)
	_sender.action_down("powerup").hold_for(.05)
	await _sender.idle
	_sender.release_all()
	await wait_process_frames(2)
	assert_eq(scene.get_powerups_count(), 1)
	p1_ori_pos = scene.get_player(1).global_position
	_sender.action_down("left").action_down("movement_bonus").hold_for(.05)
	await _sender.idle
	_sender.release_all()
	await wait_seconds(0.25)
	assert_lt(scene.get_player(1).global_position.x, p1_ori_pos.x)
	# ==== check kill other player ====
	for i in range(0, 3):
		_sender.action_down("fire").hold_for(.05)
		await _sender.idle
		_sender.release_all()
		await wait_seconds(1.5)
	assert_eq(scene.get_game_message(), "test_player_1")
	var wall = scene.get_right_wall()
	assert_false(wall.get_collision_enabled())
	assert_false(wall.visible)
	await wait_seconds(1.5)
	assert_eq(scene.count_players(), 1)
	await wait_seconds(2)
	assert_eq(scene.count_players(), 2)
	var ui = scene.get_ui()
	assert_eq(ui._players[2]._lives_ui.LIVES, 2)
	# ==== check end game ====
	scene.get_player(2).kill()
	await wait_seconds(4)
	scene.get_player(2).kill()
	await wait_seconds(2.5)
	assert_true(scene.get_game_message().contains("Game !"))
	await wait_seconds(5)
	assert_eq(game_over_times_called, 1)


##### UTILS #####
func _check_player_data(player_idx: int, config: PlayerConfig):
	var player = scene.get_player(player_idx)
	assert_not_null(player)
	assert_eq(player.paths.sprites.onready_paths.body.modulate, config.SPRITE_CUSTOMIZATION.BODY_COLOR)
	assert_eq(player.paths.sprites.onready_paths.outline.modulate, config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR)
	var ui = scene.get_ui()
	assert_eq(ui._players[player_idx].onready_paths.sprites.body.modulate, config.SPRITE_CUSTOMIZATION.BODY_COLOR)
	assert_eq(ui._players[player_idx].onready_paths.sprites.outline.modulate, config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR)
	assert_eq(ui._players[player_idx].onready_paths.name.text, "temporary_man")
	var p_movement = ui._players[player_idx]._movement_ui
	var p_powerup = ui._players[player_idx]._powerup_ui
	var p_lives = ui._players[player_idx]._lives_ui
	assert_not_null(p_movement)
	assert_not_null(p_powerup)
	assert_not_null(p_lives)
	assert_eq(p_lives.LIVES, 3)

func _on_game_over() -> void:
	game_over_times_called += 1
