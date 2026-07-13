extends Control

# Manages the player data ui

##### VARIABLES #####
#---- CONSTANTS -----
const MOVEMENT_UI_COLOR := Color.YELLOW
const POWERUP_UI_COLOR := Color.CYAN
const LIVES_UI_COLOR := Color.RED

#---- EXPORTS -----
@export var player_sprites: SpriteCustomizationResource

#---- STANDARD -----
#==== PRIVATE ====
var _lives_ui_load = preload("res://Scenes/UI/PlayersData/PlayerData/LivesDataUIBlock/lives_data_ui_block.tscn")
var _separator = preload("res://Scenes/UI/PlayersData/PlayerData/Templates/player_data_ui_separator.tscn")
var _movement_ui
var _powerup_ui
var _lives_ui

#==== ONREADY ====
@onready var sprite_root := $"VBoxContainer/Data/CenterContainer/Sprite"
@onready var sprite_body := $"VBoxContainer/Data/CenterContainer/Sprite/Body"
@onready var sprite_outline := $"VBoxContainer/Data/CenterContainer/Sprite/Outline"
@onready var sprite_mouth := $"VBoxContainer/Data/CenterContainer/Sprite/Mouth"
@onready var sprite_eyes := $"VBoxContainer/Data/CenterContainer/Sprite/Eyes"
@onready var player_indicator := $"VBoxContainer/Data/CenterContainer/PlayerIndicatorOutline"
@onready var important_data := $"VBoxContainer/Data/ImportantData"
@onready var player_name := $"VBoxContainer/Name"


##### PUBLIC METHODS #####
func init(sprites: SpriteCustomizationResource, movement: int, powerup: int, p_player_name: String, player_idx: int, lives: int) -> void:
	_clean()
	_init_sprites(sprites)
	_init_player_outline(player_idx)
	_init_movement(movement)
	_add_h_separator()
	_init_powerup(powerup)
	_add_h_separator()
	_init_lives(lives)
	_init_name(p_player_name)


func update_movement(value) -> void:
	if is_instance_valid(_movement_ui):
		_movement_ui.set_value(value)


func update_powerup(value) -> void:
	if is_instance_valid(_powerup_ui):
		_powerup_ui.set_value(value)


func update_lives(value: int) -> void:
	if is_instance_valid(_lives_ui):
		_lives_ui.set_value(value)


##### PROTECTED METHODS #####
func _clean() -> void:
	for child in important_data.get_children():
		child.queue_free()


func _add_h_separator() -> void:
	var separator = _separator.instantiate()
	important_data.add_child(separator, true)


func _init_sprites(sprite: SpriteCustomizationResource) -> void:
	sprite_body.modulate = sprite.BODY_COLOR
	sprite_outline.modulate = sprite.OUTLINE_COLOR
	sprite_mouth.texture = load(sprite.MOUTH_TEXTURE_PATH)
	sprite_mouth.modulate = sprite.MOUTH_COLOR
	sprite_eyes.texture = load(sprite.EYES_TEXTURE_PATH)
	sprite_eyes.modulate = sprite.EYES_COLOR


func _init_player_outline(player_idx: int) -> void:
	player_indicator.set_player_color(player_idx)


func _init_movement(handler: int) -> void:
	var ui = StaticMovementBonusHandler.get_ui_scene(handler)
	_movement_ui = ui
	important_data.add_child(ui, true)
	ui.set_icon(StaticMovementBonusHandler.get_icon_path(handler))
	ui.modulate = MOVEMENT_UI_COLOR


func _init_powerup(powerup: int) -> void:
	var ui = StaticPowerupHandler.get_ui_scene(powerup)
	_powerup_ui = ui
	important_data.add_child(ui, true)
	ui.set_icon(StaticPowerupHandler.get_icon_path(powerup))
	ui.modulate = POWERUP_UI_COLOR


func _init_lives(lives: int) -> void:
	var ui = _lives_ui_load.instantiate()
	_lives_ui = ui
	important_data.add_child(ui, true)
	ui.set_value(lives)
	ui.modulate = LIVES_UI_COLOR


func _init_name(p_name: String) -> void:
	player_name.text = p_name


##### SIGNAL MANAGEMENT #####
func _on_movement_update_ui(value) -> void:
	if is_instance_valid(_movement_ui):
		_movement_ui.set_value(value)
