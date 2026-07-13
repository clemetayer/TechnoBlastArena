extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var sprite_items


##### SETUP #####
func before_each():
	sprite_items = add_child_autofree(load("res://Scenes/UI/PlayerCustomizationMenu/SpriteItems/sprite_items.tscn").instantiate())


##### TESTS #####
func test_init():
	# given
	sprite_items.TITLE = "test title"
	sprite_items.RESOURCE_LIST_PATH = "res://Scenes/Player/Eyes/eyes.tres"
	var resource_load = load(sprite_items.RESOURCE_LIST_PATH)
	# when
	sprite_items._ready()
	# then
	assert_eq(sprite_items.title.text, "test title")
	assert_eq(resource_load.RESOURCES.size(), sprite_items.items.item_count)
	for element_idx in sprite_items.items.item_count:
		assert_true(resource_load.RESOURCES.has(sprite_items.items.get_item_icon(element_idx)))


func test_item_activated():
	# given
	watch_signals(sprite_items)
	sprite_items.items.clear()
	sprite_items.items.add_icon_item(load("res://icon.svg"))
	# when
	sprite_items.items.item_activated.emit(0)
	# then
	assert_signal_emitted_with_parameters(sprite_items.sprite_selected, ["res://icon.svg"])
