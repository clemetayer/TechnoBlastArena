extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const ICON_PATH := "res://test/unit/UI/test_icon.svg"

#---- VARIABLES -----
var counter_block


##### SETUP #####
func before_each():
	counter_block = load("res://Scenes/UI/PlayersData/PlayerData/Templates/counter_block.gd").new()


##### TEARDOWN #####
func after_each():
	counter_block.free()


##### TESTS #####
func test_set_value():
	# given
	var mock_counter_block = partial_double(load("res://Scenes/UI/PlayersData/PlayerData/Templates/counter_block.gd")).new()
	stub(mock_counter_block, "set_quantity").to_do_nothing()
	# when
	mock_counter_block.set_value(1.4)
	# then
	assert_called(mock_counter_block, "set_quantity", [1])


func test_set_icon():
	# given
	var icon = Sprite2D.new()
	counter_block.icon = icon
	# when
	counter_block.set_icon(ICON_PATH)
	# then
	assert_not_null(icon.texture)
	assert_eq(counter_block.DATA_ICON, ICON_PATH)
	# cleanup
	icon.free()


var set_quantity_params := [
	[2],
	[5],
]


func test_set_quantity(params = use_parameters(set_quantity_params)):
	# given
	var quantity = params[0]
	var tokens = Node2D.new()
	var token1 = Sprite2D.new()
	tokens.add_child(token1)
	var token2 = Sprite2D.new()
	tokens.add_child(token2)
	var token3 = Sprite2D.new()
	tokens.add_child(token3)
	add_child(tokens)
	wait_for_signal(tokens.tree_entered, 0.25)
	var overflow = Label.new()
	counter_block.tokens = tokens
	counter_block.overflow = overflow
	# when
	counter_block.set_quantity(quantity)
	# then
	if quantity <= 3:
		assert_eq(count_visible_tokens(tokens), quantity)
		assert_eq(overflow.text, "")
	else:
		assert_eq(count_visible_tokens(tokens), 3)
		assert_eq(overflow.text, "+%d" % [quantity - 3])
	# cleanup
	token1.free()
	token2.free()
	token3.free()
	tokens.free()
	overflow.free()


##### UTILS #####
func count_visible_tokens(tokens: Node2D) -> int:
	var visible_cnt = 0
	for token in tokens.get_children():
		if token.visible:
			visible_cnt += 1
	return visible_cnt
