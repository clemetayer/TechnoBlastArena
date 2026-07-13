# AI Preview for the player selection menu
extends MarginContainer

##### SIGNALS #####
signal close_triggered
signal show_ai_presets_triggered

##### VARIABLES #####
#---- STANDARD -----
#==== ONREADY ====
@onready var player_sprite := $"HBoxContainer/VBoxContainer/PlayerSprite"
@onready var close_button := $"HBoxContainer/VBoxContainer/Tools/HBoxContainer/DeleteButton"
@onready var ai_preset_selection_button := $"HBoxContainer/VBoxContainer/Tools/HBoxContainer/AIPresetSelectionButton"
@onready var primary_weapon := $"HBoxContainer/Weapons/MarginContainer/HBoxContainer/PrimaryWeapon"
@onready var movement_bonus := $"HBoxContainer/Weapons/MarginContainer/HBoxContainer/MovementBonus"
@onready var powerup := $"HBoxContainer/Weapons/MarginContainer/HBoxContainer/Powerup"
@onready var player_name := $"HBoxContainer/VBoxContainer/Name"


##### PUBLIC METHODS #####
func update_ai(player_config: PlayerConfig) -> void:
	player_sprite.update_sprite(player_config.SPRITE_CUSTOMIZATION)
	primary_weapon.texture = load(StaticPrimaryWeaponHandler.get_icon_path(player_config.PRIMARY_WEAPON))
	movement_bonus.texture = load(StaticMovementBonusHandler.get_icon_path(player_config.MOVEMENT_BONUS_HANDLER))
	powerup.texture = load(StaticPowerupHandler.get_icon_path(player_config.POWERUP_HANDLER))
	player_name.text = player_config.PLAYER_NAME


##### SIGNAL MANAGEMENT #####
func _on_delete_button_pressed() -> void:
	close_triggered.emit()


func _on_ai_preset_selection_button_pressed() -> void:
	show_ai_presets_triggered.emit()
