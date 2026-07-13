extends VBoxContainer

# handles the sprite section in the player selection menu

##### SIGNALS #####
signal primary_weapon_change_requested
signal powerup_change_requested
signal movement_bonus_change_requested
signal name_changed(new_name: String)
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
const NAME_FONT_SIZE_SMALL := 10
const NAME_FONT_SIZE_BIG := 32

#---- STANDARD -----
#==== ONREADY ====
@onready var name_edit := $"Name"
@onready var player_sprite_config := $"Player"
@onready var primary_weapon := $"Weapons/Primary"
@onready var powerup := $"Weapons/Powerup"
@onready var movement_bonus := $"Weapons/MovementBonus"


##### PUBLIC METHODS #####
func update_player(player_config: PlayerConfig) -> void:
	name_edit.text = player_config.PLAYER_NAME
	player_sprite_config.update_config(player_config.SPRITE_CUSTOMIZATION)
	primary_weapon.icon = load(StaticPrimaryWeaponHandler.get_icon_path(player_config.PRIMARY_WEAPON))
	powerup.icon = load(StaticPowerupHandler.get_icon_path(player_config.POWERUP_HANDLER))
	movement_bonus.icon = load(StaticMovementBonusHandler.get_icon_path(player_config.MOVEMENT_BONUS_HANDLER))


func toggle_is_small(is_small: bool) -> void:
	player_sprite_config.toggle_is_small(is_small)
	name_edit.add_theme_font_size_override("font_size", NAME_FONT_SIZE_SMALL if is_small else NAME_FONT_SIZE_BIG)


##### SIGNAL MANAGEMENT #####
func _on_primary_pressed() -> void:
	primary_weapon_change_requested.emit()


func _on_powerup_pressed() -> void:
	powerup_change_requested.emit()


func _on_movement_bonus_pressed() -> void:
	movement_bonus_change_requested.emit()


func _on_player_elimination_text_change_triggered() -> void:
	elimination_text_change_triggered.emit()


func _on_player_eyes_change_triggered() -> void:
	eyes_change_triggered.emit()


func _on_player_eyes_color_changed(color: Color) -> void:
	eyes_color_changed.emit(color)


func _on_player_main_color_changed(color: Color) -> void:
	main_color_changed.emit(color)


func _on_player_mouth_change_triggered() -> void:
	mouth_change_triggered.emit()


func _on_player_mouth_color_changed(color: Color) -> void:
	mouth_color_changed.emit(color)


func _on_player_randomize() -> void:
	randomize.emit()


func _on_player_secondary_color_changed(color: Color) -> void:
	secondary_color_changed.emit(color)


func _on_name_focus_exited() -> void:
	name_changed.emit(name_edit.text)
