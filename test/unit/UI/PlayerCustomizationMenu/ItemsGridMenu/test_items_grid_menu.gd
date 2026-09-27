extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var menu


##### SETUP #####
func before_each():
	menu = add_child_autofree(
		load("res://Scenes/UI/PlayerCustomizationMenu/ItemsGridMenu/items_grid_menu.tscn").instantiate()
	)


##### TESTS #####
func test_ready():
	# given
	menu.TITLE = "TITLE"
	# when
	menu._ready()
	# then
	assert_eq(menu.title.text, "TITLE")


func test_set_items():
	# given
	var items = [
		ItemGridMenuElement.new(1, "res://icon.svg", "name 1", "description 1"),
		ItemGridMenuElement.new(2, "res://icon.svg", "name 2", "description 2"),
	]
	# when
	menu.set_items(items)
	await wait_process_frames(1)
	# then
	assert_eq(menu.items.get_child_count(), 2)


func test_on_item_list_item_selected():
	# given
	var item = ItemGridMenuElement.new(1, "res://icon.svg", "name 1", "description 1")
	menu.set_items([item])
	watch_signals(menu)
	await wait_process_frames(1)
	# when
	menu.items.get_child(0).element_selected.emit(item)
	# then
	assert_signal_emitted_with_parameters(menu.item_selected, [item])
