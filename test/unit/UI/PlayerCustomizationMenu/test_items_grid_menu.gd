extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var menu


##### SETUP #####
func before_each():
	menu = add_child_autofree(load("res://Scenes/UI/PlayerCustomizationMenu/ItemsGridMenu/items_grid_menu.tscn").instantiate())


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
	# then
	assert_eq(menu.items.item_count, 2)
	assert_not_null(menu.items.get_item_icon(0))
	assert_not_null(menu.items.get_item_icon(1))
	assert_eq(menu._items.size(), 2)
	assert_eq(menu._items, items)
	assert_eq(menu.items.get_item_tooltip(0), "%s : %s" % ["name 1", "description 1"])
	assert_eq(menu.items.get_item_tooltip(1), "%s : %s" % ["name 2", "description 2"])


func test_on_item_list_item_selected():
	# given
	var item_1 = ItemGridMenuElement.new(1, "res://icon.svg", "name 1", "description 1")
	var items = [
		item_1,
	]
	menu.set_items(items)
	watch_signals(menu)
	# when
	menu.items.item_selected.emit(0)
	# then
	assert_signal_emitted_with_parameters(menu.item_selected, [item_1])
