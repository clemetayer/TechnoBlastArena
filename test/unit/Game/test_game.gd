extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var game


##### SETUP #####
func before_each():
	game = add_child_autofree((load("res://Scenes/Game/game.tscn").instantiate()))


##### TESTS #####
func test_init_level_data():
	# given
	var level_data = LevelConfig.new()
	var mock_level = double(load("res://Scenes/Game/level.gd")).new()
	stub(mock_level, "init_level_data").to_do_nothing()
	game.level = mock_level
	# when
	game.init_level_data(level_data)
	# then
	assert_called(mock_level, "init_level_data", [level_data])


func test_init_players_data():
	# given
	var players_data = {
		"test": 0,
	}
	var mock_players = double(load("res://Scenes/Game/players.gd")).new()
	stub(mock_players, "init_players_data").to_do_nothing()
	game.players = mock_players
	# when
	game.init_players_data(players_data)
	# then
	assert_called(mock_players, "init_players_data", [players_data])


func test_add_game_elements():
	# given
	var mock_level = double(load("res://Scenes/Game/level.gd")).new()
	var mock_players = double(load("res://Scenes/Game/players.gd")).new()
	var mock_camera = autofree(load("res://Scenes/Camera/camera.tscn").instantiate())
	var mock_background = double(load("res://Scenes/Game/background.gd")).new()
	stub(mock_level, "add_level").to_do_nothing()
	stub(mock_level, "get_spawn_positions").to_return([Vector2.RIGHT])
	stub(mock_level, "get_background_path").to_return("res://test")
	stub(mock_players, "init_spawn_positions").to_do_nothing()
	stub(mock_players, "add_players").to_do_nothing()
	stub(mock_background, "add_background").to_do_nothing()
	add_child_autofree(mock_level)
	add_child_autofree(mock_players)
	add_child_autofree(mock_camera)
	game.level = mock_level
	game.players = mock_players
	game.camera = mock_camera
	game.background = mock_background
	# when
	game.add_game_elements()
	# then
	assert_called(mock_level, "add_level")
	assert_called(mock_players, "init_spawn_positions", [[Vector2.RIGHT]])
	assert_called(mock_players, "add_players")
	assert_eq(mock_camera.PLAYERS_ROOT_PATH, mock_camera.get_path_to(mock_players))
	assert_called(mock_background, "add_background", ["res://test"])


func test_init_game_elements():
	# given
	var players_data = {
		"test": 0,
	}
	var mock_fse = double(load("res://Scenes/Camera/FullScreenEffects/full_screen_effects.gd")).new()
	var mock_ui = double(load("res://Scenes/Game/ui.gd")).new()
	var mock_camera = autofree(load("res://Scenes/Camera/camera.gd").new())
	var mock_players = double(load("res://Scenes/Game/players.gd")).new()
	var mock_ap = double(AnimationPlayer).new()
	stub(mock_fse, "toggle_active").to_do_nothing()
	stub(mock_players, "get_players_data").to_return(players_data)
	stub(mock_ui, "init_game_ui").to_do_nothing()
	stub(mock_ui, "init_chronometer").to_do_nothing()
	stub(mock_ui, "init_screen_game_message").to_do_nothing()
	stub(mock_ap, "play").to_do_nothing()
	game._full_screen_effects = mock_fse
	game.ui = mock_ui
	game.players = mock_players
	game.camera = mock_camera
	game.animation_player = mock_ap
	# when
	game.init_game_elements(321)
	# then
	assert_called(mock_fse, "toggle_active", [true])
	assert_called(mock_ui, "init_game_ui", [players_data])
	assert_called(mock_ui, "init_chronometer", [321])
	assert_called(mock_ui, "init_screen_game_message")
	assert_true(mock_camera.enabled)
	assert_called(mock_ap, "play", ["start_game", null, null, null])


func test_spawn_powerup():
	# given
	var powerup = autofree(Node.new())
	# when
	game.spawn_powerup(powerup)
	# then
	assert_eq(powerup.name, "powerup_0")


func test_spawn_projectile():
	# given
	var projectile = autofree(Node.new())
	# when
	game.spawn_projectile(projectile)
	# then
	assert_eq(game.projectiles.get_child_count(), 1)


var toggle_players_truce_params := [
	[true],
	[false],
]


func test_toggle_players_truce(params = use_parameters(toggle_players_truce_params)):
	# given
	var players_mock = double(load("res://Scenes/Game/players.gd")).new()
	stub(players_mock, "toggle_players_truce").to_do_nothing()
	game.players = players_mock
	# when
	game.toggle_players_truce(params[0])
	# then
	assert_called(players_mock, "toggle_players_truce", [params[0]])


func test_reset():
	# given
	var mock_players = double(load("res://Scenes/Game/players.gd")).new()
	var mock_ui = double(load("res://Scenes/Game/ui.gd")).new()
	var mock_level = double(load("res://Scenes/Game/level.gd")).new()
	var mock_background = double(load("res://Scenes/Game/background.gd")).new()
	var mock_camera = autofree(load("res://Scenes/Camera/camera.gd").new())
	game.players = mock_players
	game.ui = mock_ui
	game.level = mock_level
	game.background = mock_background
	game.camera = mock_camera
	var projectiles = autofree(Node2D.new())
	var powerups = autofree(Node2D.new())
	game.projectiles = projectiles
	game.powerups = powerups
	stub(mock_players, "reset").to_do_nothing()
	stub(mock_ui, "reset").to_do_nothing()
	stub(mock_level, "reset").to_do_nothing()
	stub(mock_background, "reset").to_do_nothing()
	# when
	game.reset()
	# then
	assert_called(mock_players, "reset")
	assert_called(mock_ui, "reset")
	assert_called(mock_level, "reset")
	assert_called(mock_background, "reset")
	assert_false(mock_camera.enabled)


func test_init_start_game_animation():
	# given
	var mock_ap = double(AnimationPlayer).new()
	stub(mock_ap, "play").to_do_nothing()
	game.animation_player = mock_ap
	# when
	game._init_start_game_animation()
	# then
	assert_called(mock_ap, "play", ["start_game", null, null, null])

# cannot really test _clean_node_tree because of the queue_free


func test_end_game():
	# given
	var mock_ap = double(AnimationPlayer).new()
	stub(mock_ap, "play").to_do_nothing()
	game.animation_player = mock_ap
	# when
	game._end_game()
	# then
	assert_called(mock_ap, "play", ["end_game", null, null, null])

# on_ui_time_over and _on_players_player_won not really usefull to test since we already tested _end_game


func test_on_players_lives_updated():
	# given
	var mock_ui = double(load("res://Scenes/Game/ui.gd")).new()
	stub(mock_ui, "update_lives").to_do_nothing()
	game.ui = mock_ui
	# when
	game._on_players_lives_updated(1, 4)
	# then
	assert_called(mock_ui, "update_lives", [1, 4])


func test_on_players_movement_updated():
	# given
	var mock_ui = double(load("res://Scenes/Game/ui.gd")).new()
	stub(mock_ui, "update_movement").to_do_nothing()
	game.ui = mock_ui
	# when
	game._on_players_movement_updated(1, 4.75)
	# then
	assert_called(mock_ui, "update_movement", [1, 4.75])


func test_on_players_powerup_updated():
	# given
	var mock_ui = double(load("res://Scenes/Game/ui.gd")).new()
	stub(mock_ui, "update_powerup").to_do_nothing()
	game.ui = mock_ui
	# when
	game._on_players_powerup_updated(1, 0.75)
	# then
	assert_called(mock_ui, "update_powerup", [1, 0.75])


func test_on_players_game_message_triggered():
	# given
	var mock_ui = double(load("res://Scenes/Game/ui.gd")).new()
	stub(mock_ui, "display_message").to_do_nothing()
	game.ui = mock_ui
	# when
	game._on_players_game_message_triggered("test")
	# then
	assert_called(mock_ui, "display_message", ["test", false])


var _on_animation_player_animation_finished_params := [
	["end_game", true],
	["not_end_game", false],
]


func test_on_animation_player_animation_finished(params = use_parameters(_on_animation_player_animation_finished_params)):
	# given
	watch_signals(game)
	# when
	game._on_animation_player_animation_finished(params[0])
	# then
	if params[1]:
		assert_signal_emitted(game.game_over)
	else:
		assert_signal_not_emitted(game.game_over)
