extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
# const CONST := "value"

#---- VARIABLES -----
var victory_screen


##### SETUP #####
func before_each():
	victory_screen = add_child_autofree(
		load("res://Scenes/UI/VictoryScreen/victory_screen.tscn").instantiate()
	)


##### TESTS #####
var setup_params := [
	[
		[random_player_data(), random_player_data()],
		[random_player_data(), random_player_data(), random_player_data(), random_player_data()],
	]
]


func test_setup(params = use_parameters(setup_params)):
	# given
	var players = params[0]
	for child in victory_screen.player_grid.get_children():
		child.free()
	for player_rank_idx in range(4):
		var player_rank = partial_double(load("res://Scenes/UI/VictoryScreen/player_rank.tscn")).instantiate()
		stub(player_rank, "set_player_data").to_do_nothing()
		victory_screen.player_grid.add_child(player_rank)
	victory_screen.visible = false
	# when
	victory_screen.show_victory(players)
	# then
	assert_true(victory_screen.visible)
	for child_idx in range(victory_screen.player_grid.get_child_count()):
		var child = victory_screen.player_grid.get_child(child_idx)
		if child_idx < players.size():
			var player = players[child_idx]
			assert_called(
				child,
				"set_player_data",
				[player.SPRITE_CUSTOMIZATION, player.PLAYER_NAME],
			)
			assert_true(child.visible)
		else:
			assert_false(child.visible)


##### UTILS #####
static func random_player_data() -> PlayerConfig:
	var config = PlayerConfig.new()
	config.PLAYER_NAME = "player%d" % [randi() % 20]
	config.SPRITE_CUSTOMIZATION = random_sprite_customization()
	return config


static func random_sprite_customization() -> SpriteCustomizationResource:
	var sprite = SpriteCustomizationResource.new()
	sprite.BODY_COLOR = StaticUtils.random_color()
	sprite.OUTLINE_COLOR = StaticUtils.random_color()
	sprite.EYES_TEXTURE_PATH = "res://icon.svg"
	sprite.EYES_COLOR = StaticUtils.random_color()
	sprite.MOUTH_TEXTURE_PATH = "res://icon.svg"
	sprite.MOUTH_COLOR = StaticUtils.random_color()
	return sprite
