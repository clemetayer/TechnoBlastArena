extends MarginContainer

# list of sprites to select for the player customization

##### SIGNALS #####
signal sprite_selected(sprite_path: String)

##### VARIABLES #####
#---- EXPORTS -----
@export var TITLE := "Sprite items"
@export_file("*.tres") var RESOURCE_LIST_PATH

#---- STANDARD -----
#==== ONREADY ====
@onready var title := $"VBoxContainer/Title"
@onready var items := $"VBoxContainer/ItemList"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	_init_title()
	_init_items()


##### PROTECTED METHODS #####
func _init_title() -> void:
	title.text = TITLE


func _init_items() -> void:
	items.clear()
	if RESOURCE_LIST_PATH == null:
		GSLogger.error("RESOURCE_LIST_PATH not set for %s" % [name])
		return
	var items_res = load(RESOURCE_LIST_PATH)
	if not items_res is ResourceList:
		GSLogger.error("%s is not a valid ResourceList" % [RESOURCE_LIST_PATH])
		return
	for sprite in items_res.RESOURCES:
		items.add_icon_item(sprite)


##### SIGNAL MANAGEMENT #####
func _on_item_list_item_activated(index: int) -> void:
	sprite_selected.emit(items.get_item_icon(index).resource_path)
