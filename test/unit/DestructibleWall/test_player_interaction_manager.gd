extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var player_interaction_manager


##### SETUP #####
func before_each():
	player_interaction_manager = load("res://Scenes/DestructibleWalls/player_interactions_manager.gd").new()
	var audio_manager = double(load("res://Scenes/DestructibleWalls/audio_manager.gd")).new()
	player_interaction_manager.onready_paths.audio_manager = audio_manager
	var health_manager = double(load("res://Scenes/DestructibleWalls/health_manager.gd")).new()
	player_interaction_manager.onready_paths.health_manager = health_manager


##### TEARDOWN #####
func after_each():
	player_interaction_manager.free()


##### TESTS #####
func test_player_hit():
	# given
	var player = double(load("res://Scenes/Player/player.gd")).new()
	# when
	player_interaction_manager.handle_player_hit(player, Vector2.RIGHT, 2.0)
	# then


func test_kill_player():
	# given
	var player = double(load("res://Scenes/Player/player.gd")).new()
	stub(player, "kill").to_do_nothing()
	player_interaction_manager.kill_player(player)
	# when
	# then
	assert_called(player, "kill")
