extends Control

# handles the player customization menu

##### SIGNALS #####
signal quit

##### VARIABLES #####
#---- CONSTANTS -----
const DEFAULT_CONFIG_PATH := "res://Scenes/Player/PlayerConfigs/default_player_config.tres"
const EYES_LIST_RESOURCE := preload("res://Scenes/Player/Eyes/eyes.tres")
const MOUTH_LIST_RESOURCE := preload("res://Scenes/Player/Mouths/mouths.tres")

#---- EXPORTS -----
@export var IS_SMALL := true
@export var ALLOW_SAVE := true

#---- STANDARD -----
#==== PUBLIC ====
var player_config: PlayerConfig

#==== ONREADY ====
@onready var main_window := $"MainWindow"
@onready var preset_selection_button := $"MainWindow/VBoxContainer/PresetSelectionButton"
@onready var save_preset_button := $"MainWindow/VBoxContainer/SavePresetButton"
@onready var quit_button := $"MainWindow/VBoxContainer/QuitButton"
@onready var player_config_display := $"MainWindow/MarginContainer/PlayerConfigDisplay"
@onready var menus := $"Menus"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	_init_small()
	_init_allow_save()
	_init_player_config()


##### PROTECTED METHODS #####
func _init_small() -> void:
	player_config_display.toggle_is_small(IS_SMALL)
	menus.toggle_is_small(IS_SMALL)


func _init_allow_save() -> void:
	save_preset_button.visible = ALLOW_SAVE


func _init_player_config() -> void:
	player_config = load(DEFAULT_CONFIG_PATH)
	player_config_display.update_player(player_config)


func _randomize_preset() -> void:
	player_config.SPRITE_CUSTOMIZATION.BODY_COLOR = StaticUtils.random_color()
	player_config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR = StaticUtils.random_color()
	player_config.SPRITE_CUSTOMIZATION.EYES_COLOR = StaticUtils.random_color()
	player_config.SPRITE_CUSTOMIZATION.MOUTH_COLOR = StaticUtils.random_color()
	player_config.SPRITE_CUSTOMIZATION.EYES_TEXTURE_PATH = _random_eye_texture().resource_path
	player_config.SPRITE_CUSTOMIZATION.MOUTH_TEXTURE_PATH = _random_mouth_texture().resource_path
	player_config.ACTION_HANDLER = StaticPrimaryWeaponHandler.handlers.values().pick_random()
	player_config.POWERUP_HANDLER = StaticPowerupHandler.handlers.values().pick_random()
	player_config.MOVEMENT_BONUS_HANDLER = StaticMovementBonusHandler.handlers.values().pick_random()


func _random_eye_texture() -> Texture:
	return EYES_LIST_RESOURCE.RESOURCES.pick_random()


func _random_mouth_texture() -> Texture:
	return MOUTH_LIST_RESOURCE.RESOURCES.pick_random()


##### SIGNAL MANAGEMENT #####
func _on_preset_selection_button_pressed() -> void:
	menus.open_preset_selection()
	main_window.visible = not IS_SMALL


func _on_save_preset_button_pressed() -> void:
	menus.open_save_preset_popup()


func _on_quit_button_pressed() -> void:
	quit.emit()


func _on_player_config_display_elimination_text_change_triggered() -> void:
	menus.open_elimination_text()
	main_window.visible = not IS_SMALL


func _on_player_config_display_eyes_change_triggered() -> void:
	menus.open_eyes_selection()
	main_window.visible = not IS_SMALL


func _on_player_config_display_eyes_color_changed(color: Color) -> void:
	player_config.SPRITE_CUSTOMIZATION.EYES_COLOR = color
	player_config_display.update_player(player_config)


func _on_player_config_display_main_color_changed(color: Color) -> void:
	player_config.SPRITE_CUSTOMIZATION.BODY_COLOR = color
	player_config_display.update_player(player_config)


func _on_player_config_display_mouth_change_triggered() -> void:
	menus.open_mouth_selection()
	main_window.visible = not IS_SMALL


func _on_player_config_display_mouth_color_changed(color: Color) -> void:
	player_config.SPRITE_CUSTOMIZATION.MOUTH_COLOR = color
	player_config_display.update_player(player_config)


func _on_player_config_display_movement_bonus_change_requested() -> void:
	menus.open_movement_bonus()
	main_window.visible = not IS_SMALL


func _on_player_config_display_name_changed(new_name: String) -> void:
	player_config.PLAYER_NAME = new_name
	player_config_display.update_player(player_config)
	main_window.show()


func _on_player_config_display_powerup_change_requested() -> void:
	menus.open_powerup()
	main_window.visible = not IS_SMALL


func _on_player_config_display_primary_weapon_change_requested() -> void:
	menus.open_primary_weapon()
	main_window.visible = not IS_SMALL


func _on_player_config_display_randomize() -> void:
	_randomize_preset()
	player_config_display.update_player(player_config)


func _on_player_config_display_secondary_color_changed(color: Color) -> void:
	player_config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR = color
	player_config_display.update_player(player_config)


func _on_menus_elimination_text_updated(elimination_text: String) -> void:
	player_config.ELIMINATION_TEXT = elimination_text
	main_window.show()


func _on_menus_eyes_selected(sprite_path: String) -> void:
	player_config.SPRITE_CUSTOMIZATION.EYES_TEXTURE_PATH = sprite_path
	player_config_display.update_player(player_config)
	main_window.show()


func _on_menus_mouth_selected(sprite_path: String) -> void:
	player_config.SPRITE_CUSTOMIZATION.MOUTH_TEXTURE_PATH = sprite_path
	player_config_display.update_player(player_config)
	main_window.show()


func _on_menus_movement_bonus_selected(handler: StaticMovementBonusHandler.handlers) -> void:
	player_config.MOVEMENT_BONUS_HANDLER = handler
	player_config_display.update_player(player_config)
	main_window.show()


func _on_menus_powerup_selected(handler: StaticPowerupHandler.handlers) -> void:
	player_config.POWERUP_HANDLER = handler
	player_config_display.update_player(player_config)
	main_window.show()


func _on_menus_preset_selected(preset: PlayerConfig) -> void:
	player_config = preset
	player_config_display.update_player(player_config)
	main_window.show()


func _on_menus_primary_weapon_selected(handler: StaticPrimaryWeaponHandler.handlers) -> void:
	player_config.PRIMARY_WEAPON = handler
	player_config_display.update_player(player_config)
	main_window.show()


func _on_menus_save_preset(preset_name: String, preset_description: String) -> void:
	player_config.DESCRIPTION = preset_description
	var save_path = StaticUtils.get_preset_save_path(preset_name)
	GSLogger.info("saving preset to %s" % save_path)
	ResourceSaver.save(player_config, save_path)
	menus.refresh_presets()


func _on_menus_menu_closed() -> void:
	main_window.show()
