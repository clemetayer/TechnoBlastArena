extends MarginContainer

# handles the player sprite

##### SIGNALS #####
signal main_color_changed(color: Color)
signal secondary_color_changed(color: Color)
signal eyes_change_triggered
signal eyes_color_changed(color: Color)
signal mouth_change_triggered
signal mouth_color_changed(color: Color)
signal elimination_text_change_triggered
signal randomize

##### VARIABLES #####
#---- CONSTANTS -----
const MARGIN_SMALL := Vector2i.ONE * 4
const MARGIN_BIG := Vector2i.ONE * 64

#---- STANDARD -----
#==== ONREADY ====
@onready var panel := $"HBoxContainer/PlayerConfigPanel"
@onready var sprites := $"HBoxContainer/PlayerSprite"


##### PUBLIC METHODS #####
func update_config(config: SpriteCustomizationResource) -> void:
	panel.set_player_config(config)
	sprites.update_sprite(config)


func toggle_is_small(is_small: bool) -> void:
	panel.toggle_is_small(is_small)
	add_theme_constant_override("margin_left", MARGIN_SMALL.x if is_small else MARGIN_BIG.x)
	add_theme_constant_override("margin_right", MARGIN_SMALL.x if is_small else MARGIN_BIG.x)
	add_theme_constant_override("margin_top", MARGIN_SMALL.y if is_small else MARGIN_BIG.y)
	add_theme_constant_override("margin_bottom", MARGIN_SMALL.y if is_small else MARGIN_BIG.y)


##### SIGNAL MANAGEMENT #####
func _on_player_config_panel_elimination_text_change_triggered() -> void:
	elimination_text_change_triggered.emit()


func _on_player_config_panel_eyes_change_triggered() -> void:
	eyes_change_triggered.emit()


func _on_player_config_panel_eyes_color_changed(color: Color) -> void:
	eyes_color_changed.emit(color)


func _on_player_config_panel_main_color_changed(color: Color) -> void:
	main_color_changed.emit(color)


func _on_player_config_panel_mouth_change_triggered() -> void:
	mouth_change_triggered.emit()


func _on_player_config_panel_mouth_color_changed(color: Color) -> void:
	mouth_color_changed.emit(color)


func _on_player_config_panel_randomize() -> void:
	randomize.emit()


func _on_player_config_panel_secondary_color_changed(color: Color) -> void:
	secondary_color_changed.emit(color)
