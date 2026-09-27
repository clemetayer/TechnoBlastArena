extends MarginContainer

# Generic menu to display a grid of elements to select (with helpers)

##### SIGNALS #####
signal item_selected(item: ItemGridMenuElement)

##### VARIABLES #####
#---- CONSTANTS -----
const ITEM_BUTTON_ELEMENT := preload(
	"res://Scenes/UI/PlayerCustomizationMenu/ItemsGridMenu/item_button.tscn"
)

#---- EXPORTS -----
@export var TITLE := ""

#---- STANDARD -----
#==== ONREADY ====
@onready var items := $"VBoxContainer/ScrollContainer/Items"
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
	var element = ITEM_BUTTON_ELEMENT.instantiate()
	items.add_child(element)
	element.set_data(item)
	element.element_selected.connect(_on_item_list_item_selected)


func _reset_items() -> void:
	for element in items.get_children():
		element.queue_free()


##### SIGNAL MANAGEMENT #####
func _on_item_list_item_selected(data: ItemGridMenuElement) -> void:
	item_selected.emit(data)
