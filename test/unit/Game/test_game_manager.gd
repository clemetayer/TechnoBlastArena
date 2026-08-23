extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var game_manager


##### SETUP #####
func before_each():
	game_manager = add_child_autofree(
		load("res://Scenes/GameManagers/game_manager.tscn").instantiate()
	)


##### TESTS #####
func test_init():
	# given
	var full_screen_effects = mock_full_screen_effects()
	# when
	game_manager._ready()
	# then
	assert_true(game_manager.player_selection_menu.visible)
	assert_not_null(game_manager.level_data)
	assert_called(full_screen_effects, "toggle_active", [false])


func test_start_game():
	# given
	var player_configs := [PlayerConfig.new(), PlayerConfig.new(), PlayerConfig.new()]
	var lives := 4
	var time := 120
	var level_data := LevelConfig.new()
	var expected_players_data := {
		0: { "config": player_configs[0], "lives": lives },
		1: { "config": player_configs[1], "lives": lives },
		2: { "config": player_configs[2], "lives": lives },
	}
	game_manager.level_data = level_data
	var game = mock_game()
	stub(game, "init_level_data").to_do_nothing()
	stub(game, "init_players_data").to_do_nothing()
	stub(game, "add_game_elements").to_do_nothing()
	stub(game, "init_game_elements").to_do_nothing()
	# when
	game_manager.player_selection_menu.game_ready.emit(player_configs, lives, time)
	# then
	assert_false(game_manager.player_selection_menu.visible)
	assert_called(game, "init_level_data", [level_data])
	assert_called(game, "init_players_data", [expected_players_data])
	assert_called(game, "add_game_elements")
	assert_called(game, "init_game_elements", [time])


func test_game_over():
	# given
	assert_connected(game_manager.game.game_over, game_manager._on_game_game_over)
	var game = mock_game()
	stub(game, "reset").to_do_nothing()
	var victory_screen = mock_victory_screen()
	stub(victory_screen, "show_victory").to_do_nothing()
	var full_screen_effects = mock_full_screen_effects()
	stub(full_screen_effects, "toggle_active").to_do_nothing()
	var players_rank := [PlayerConfig.new(), PlayerConfig.new()]
	# when
	game_manager._on_game_game_over(players_rank)
	# then
	assert_called(game, "reset")
	assert_called(victory_screen, "show_victory", [players_rank])
	assert_called(full_screen_effects, "toggle_active", [false])


func test_victory_screen_next_loops_to_player_selection():
	# given
	game_manager.victory_screen.show()
	game_manager.player_selection_menu.hide()
	# when
	game_manager.victory_screen.next.emit()
	# then
	assert_false(game_manager.victory_screen.visible)
	assert_true(game_manager.player_selection_menu.visible)


##### UTILS #####
func mock_full_screen_effects():
	var full_screen_effects = double(
		load("res://Scenes/Camera/FullScreenEffects/full_screen_effects.gd")
	).new()
	stub(full_screen_effects, "toggle_active").to_do_nothing()
	game_manager.full_screen_effects = full_screen_effects
	return full_screen_effects


func mock_game():
	var game = double(load("res://Scenes/Game/game.gd")).new()
	game_manager.game = game
	return game


func mock_victory_screen():
	var victory_screen = double(load("res://Scenes/UI/VictoryScreen/victory_screen.gd")).new()
	game_manager.victory_screen = victory_screen
	return victory_screen
