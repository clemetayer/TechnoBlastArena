extends MarginContainer

# Generic menu to display a grid of elements to select (with helpers)

##### SIGNALS #####
signal item_selected(item: ItemGridMenuElement)

##### VARIABLES #####
#---- EXPORTS -----
@export var TITLE := ""

#---- STANDARD -----
#==== PRIVATE ====
var _items: Array = []

#==== ONREADY ====
@onready var items := $"VBoxContainer/ScrollContainer/ItemList"
@onready var title := $"VBoxContainer/Title"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	title.text = TITLE


##### PUBLIC METHODS #####
# Parameters are an array of ItemGridMenuElement
func set_items(p_items: Array) -> void:
	_reset_items()
	for item in p_items:
		if item is ItemGridMenuElement:
			_set_item(item)
		else:
			GSLogger.error("item %s not an ItemGridMenuRessource, not adding" % item)


##### PROTECTED METHODS #####
func _set_item(item: ItemGridMenuElement) -> void:
	_items.append(item)
	items.add_icon_item(load(item.ICON_PATH))
	var last_item_idx: int = items.item_count - 1
	items.set_item_tooltip_enabled(last_item_idx, true)
	items.set_item_tooltip(last_item_idx, "%s : %s" % [item.NAME, item.DESCRIPTION])


func _reset_items() -> void:
	_items = []
	items.clear()


##### SIGNAL MANAGEMENT #####
func _on_item_list_item_selected(index: int) -> void:
	item_selected.emit(_items[index])
