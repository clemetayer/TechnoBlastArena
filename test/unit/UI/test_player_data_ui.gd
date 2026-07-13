extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var player_data


##### SETUP #####
func before_each():
	player_data = load("res://Scenes/UI/PlayersData/PlayerData/player_data_ui.gd").new()


##### TEARDOWN #####
func after_each():
	player_data.free()


##### TESTS #####
func test_init():
	# given
	var mock_player_data = partial_double(load("res://Scenes/UI/PlayersData/PlayerData/player_data_ui.gd")).new()
	stub(mock_player_data, "_clean").to_do_nothing()
	stub(mock_player_data, "_init_sprites").to_do_nothing()
	stub(mock_player_data, "_init_player_outline").to_do_nothing()
	stub(mock_player_data, "_init_movement").to_do_nothing()
	stub(mock_player_data, "_add_h_separator").to_do_nothing()
	stub(mock_player_data, "_init_powerup").to_do_nothing()
	stub(mock_player_data, "_init_lives").to_do_nothing()
	stub(mock_player_data, "_init_name").to_do_nothing()
	var sprites = SpriteCustomizationResource.new()
	sprites.BODY_COLOR = Color.AZURE
	sprites.OUTLINE_COLOR = Color.AQUAMARINE
	sprites.EYES_TEXTURE_PATH = "res://Scenes/Player/Eyes/eyes_1.PNG"
	sprites.MOUTH_TEXTURE_PATH = "res://Scenes/Player/Mouth/mouth_1.PNG"
	# when
	mock_player_data.init(sprites, 1, 2, "Funky Franklin", 1, 3)
	# then
	assert_called(mock_player_data, "_clean")
	assert_called(mock_player_data, "_init_sprites", [sprites])
	assert_called(mock_player_data, "_init_player_outline", [1])
	assert_called(mock_player_data, "_init_movement", [1])
	assert_called(mock_player_data, "_add_h_separator")
	assert_called(mock_player_data, "_init_powerup", [2])
	assert_called(mock_player_data, "_init_lives", [3])
	assert_called(mock_player_data, "_init_name", ["Funky Franklin"])


func test_update_movement():
	# given
	var movement_ui = double(load("res://Scenes/UI/PlayersData/PlayerData/Templates/counter_block.gd")).new()
	stub(movement_ui, "set_value")
	player_data._movement_ui = movement_ui
	# when
	player_data.update_movement(2)
	# then
	assert_called(movement_ui, "set_value", [2])


func test_update_powerup():
	# given
	var powerup_ui = double(load("res://Scenes/UI/PlayersData/PlayerData/Templates/counter_block.gd")).new()
	stub(powerup_ui, "set_value")
	player_data._powerup_ui = powerup_ui
	# when
	player_data.update_powerup(2)
	# then
	assert_called(powerup_ui, "set_value", [2])


func test_update_lives():
	# given
	var lives_ui = double(load("res://Scenes/UI/PlayersData/PlayerData/Templates/counter_block.gd")).new()
	stub(lives_ui, "set_value")
	player_data._lives_ui = lives_ui
	# when
	player_data.update_lives(2)
	# then
	assert_called(lives_ui, "set_value", [2])

# _clean hard to test because it's mostly a queue_free thing


func test_add_h_separator():
	# given
	var important_data = Node2D.new()
	player_data.important_data = important_data
	add_child(important_data)
	wait_for_signal(important_data.tree_entered, 0.25)
	# when
	player_data._add_h_separator()
	# then
	assert_eq(important_data.get_child_count(), 1)
	# cleanup
	important_data.free()


func test_init_sprites():
	# given
	var body = Sprite2D.new()
	var outline = Sprite2D.new()
	var eyes = Sprite2D.new()
	var mouth = Sprite2D.new()
	player_data.sprite_body = body
	player_data.sprite_outline = outline
	player_data.sprite_eyes = eyes
	player_data.sprite_mouth = mouth
	var sprite_resource = SpriteCustomizationResource.new()
	sprite_resource.BODY_COLOR = Color.ALICE_BLUE
	sprite_resource.OUTLINE_COLOR = Color.AZURE
	sprite_resource.EYES_TEXTURE_PATH = "res://Scenes/Player/Eyes/eyes_1.PNG"
	sprite_resource.MOUTH_TEXTURE_PATH = "res://Scenes/Player/Mouths/mouth_1.PNG"
	# when
	player_data._init_sprites(sprite_resource)
	# then
	assert_eq(body.modulate, Color.ALICE_BLUE)
	assert_eq(outline.modulate, Color.AZURE)
	assert_not_null(eyes.texture)
	assert_not_null(mouth.texture)
	# cleanup
	body.free()
	outline.free()
	eyes.free()
	mouth.free()


func test_init_movement():
	# given
	var important_data = Node2D.new()
	add_child(important_data)
	wait_for_signal(important_data.tree_entered, 0.25)
	player_data.important_data = important_data
	# when
	player_data._init_movement(StaticMovementBonusHandler.handlers.DASH)
	# then
	assert_eq(important_data.get_child_count(), 1)
	assert_not_null(player_data._movement_ui)
	# cleanup
	important_data.free()


func test_init_powerup():
	# given
	var important_data = Node2D.new()
	add_child(important_data)
	wait_for_signal(important_data.tree_entered, 0.25)
	player_data.important_data = important_data
	# when
	player_data._init_powerup(StaticPowerupHandler.handlers.SPLITTER)
	# then
	assert_eq(important_data.get_child_count(), 1)
	assert_not_null(player_data._powerup_ui)
	# cleanup
	important_data.free()


func test_init_lives():
	# given
	var important_data = Node2D.new()
	add_child(important_data)
	wait_for_signal(important_data.tree_entered, 0.25)
	player_data.important_data = important_data
	# when
	player_data._init_lives(2)
	# then
	assert_eq(important_data.get_child_count(), 1)
	assert_not_null(player_data._lives_ui)
	# cleanup
	important_data.free()


func test_init_name():
	# given
	var l_name = Label.new()
	player_data.player_name = l_name
	# when
	player_data._init_name("test")
	# then
	assert_eq(l_name.text, "test")
	# cleanup
	l_name.free()


func test_on_movement_update_ui():
	# given
	var movement_ui = double(load("res://Scenes/UI/PlayersData/PlayerData/Templates/counter_block.gd")).new()
	stub(movement_ui, "set_value").to_do_nothing()
	player_data._movement_ui = movement_ui
	# when
	player_data._on_movement_update_ui(123)
	# then
	assert_called(movement_ui, "set_value", [123])


func test_init_player_outline():
	# given
	var player_indicator = double(load("res://Scenes/UI/PlayersData/PlayerData/player_indicator_outline.gd")).new()
	stub(player_indicator, "set_player_color").to_do_nothing()
	player_data.player_indicator = player_indicator
	# when
	player_data._init_player_outline(1)
	# then
	assert_called(player_indicator, "set_player_color", [1])
