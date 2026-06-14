extends Object

class_name ItemGridMenuElement

@export var ITEM_ID: int
@export var ICON_PATH: String
@export var NAME: String
@export var DESCRIPTION: String


func _init(item_id: int, icon_path: String, name: String, description: String):
	ITEM_ID = item_id
	ICON_PATH = icon_path
	NAME = name
	DESCRIPTION = description
