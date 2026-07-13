extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const ICON_PATH := "res://test/unit/UI/test_icon.svg"

#---- VARIABLES -----
var progress_block


##### SETUP #####
func before_each():
	progress_block = load("res://Scenes/UI/PlayersData/PlayerData/Templates/progress_block.gd").new()


##### TEARDOWN #####
func after_each():
	progress_block.free()


##### TESTS #####
func test_set_value():
	# given
	var mock_progress_block = partial_double(load("res://Scenes/UI/PlayersData/PlayerData/Templates/progress_block.gd")).new()
	stub(mock_progress_block, "set_progress").to_do_nothing()
	# when
	mock_progress_block.set_value(1.4)
	# then
	assert_called(mock_progress_block, "set_progress", [1.4])


func test_set_icon():
	# given
	var icon = Sprite2D.new()
	progress_block.icon = icon
	# when
	progress_block.set_icon(ICON_PATH)
	# then
	assert_not_null(icon.texture)
	assert_eq(progress_block.DATA_ICON, ICON_PATH)
	# cleanup
	icon.free()


var set_progress_params := [
	[0.5],
	[2.75],
]


func test_set_progress(params = use_parameters(set_progress_params)):
	# given
	var progress = params[0]
	var progress_bar = ProgressBar.new()
	var overflow = Label.new()
	progress_block.progress = progress_bar
	progress_block.overflow = overflow
	# when
	progress_block.set_progress(progress)
	# then
	assert_eq(progress_bar.value, fmod(progress, 1.0))
	assert_eq(progress_block.PROGRESS, progress)
	if progress < 1:
		assert_eq(overflow.text, "")
	else:
		assert_eq(overflow.text, "+2")
	# cleanup
	progress_bar.free()
	overflow.free()
