extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var player_rank


##### SETUP #####
func before_each():
	player_rank = add_child_autofree(
		load("res://Scenes/UI/VictoryScreen/player_rank.tscn").instantiate()
	)


##### TESTS #####
var load_rank_params := [
	[1, "res://Scenes/UI/VictoryScreen/RankParameters/rank_1.tres"],
	[2, "res://Scenes/UI/VictoryScreen/RankParameters/rank_2.tres"],
	[3, "res://Scenes/UI/VictoryScreen/RankParameters/rank_3.tres"],
	[4, "res://Scenes/UI/VictoryScreen/RankParameters/rank_4.tres"],
]


func test_load_rank_on_ready(params = use_parameters(load_rank_params)):
	# given
	var rank = params[0]
	var rank_parameters: PlayerRankParameters = load(params[1])
	player_rank.RANK = rank
	player_rank.PARAMETERS = rank_parameters
	# when
	player_rank._ready()
	# then
	assert_eq(player_rank.custom_minimum_size, rank_parameters.SIZE)
	assert_eq(player_rank.theme_type_variation, player_rank.THEME_VARIATION_NAME % ["Panel", rank])
	assert_eq(
		player_rank.rank_rtl.theme_type_variation,
		player_rank.THEME_VARIATION_NAME % ["RTL", rank],
	)
	assert_eq(
		player_rank.rank_label.theme_type_variation,
		player_rank.THEME_VARIATION_NAME % ["Label", rank],
	)
	assert_eq(player_rank.rank_rtl.text, player_rank.RTL_TEXT % rank)
	assert_eq(player_rank.rank_label.text, player_rank.LABEL_TEXT % rank)
	assert_eq(player_rank.rank_rtl.visible, rank_parameters.WAVY_RANK_DISPLAY)
	assert_eq(player_rank.rank_label.visible, not rank_parameters.WAVY_RANK_DISPLAY)
