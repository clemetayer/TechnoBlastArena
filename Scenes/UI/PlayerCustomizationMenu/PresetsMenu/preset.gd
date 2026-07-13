extends HBoxContainer

# Handles a preset

##### SIGNALS #####
signal preset_deleted
signal preset_selected

##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====
var _preset_path: String

#==== ONREADY ====
@onready var name_label := $"Button/VBoxContainer/Elements/Name"
@onready var primary_weapon := $"Button/VBoxContainer/Elements/PrimaryWeapon"
@onready var movement_bonus := $"Button/VBoxContainer/Elements/MovementBonus"
@onready var powerup := $"Button/VBoxContainer/Elements/Powerup"
@onready var level := $"Button/VBoxContainer/Elements/AILevel"
@onready var sprite := $"Button/VBoxContainer/Elements/Sprite"
@onready var delete_button := $"RemoveButton"
@onready var button := $"Button"


##### PUBLIC METHODS #####
func set_preset(preset_name: String, preset: PlayerConfig) -> void:
	name_label.text = preset.PLAYER_NAME
	primary_weapon.texture = load(StaticPrimaryWeaponHandler.get_icon_path(preset.PRIMARY_WEAPON))
	movement_bonus.texture = load(StaticMovementBonusHandler.get_icon_path(preset.MOVEMENT_BONUS_HANDLER))
	powerup.texture = load(StaticPowerupHandler.get_icon_path(preset.POWERUP_HANDLER))
	sprite.update_sprite(preset.SPRITE_CUSTOMIZATION)
	tooltip_text = preset.DESCRIPTION
	_preset_path = StaticUtils.get_preset_save_path(preset_name)
	if preset is AIPlayerConfig:
		level.visible = true
		level.set_level(preset.LEVEL)
		delete_button.hide()


##### SIGNAL MANAGEMENT #####
func _on_remove_button_pressed() -> void:
	var dir_access = DirAccess.open(StaticUtils.USER_CHARACTER_PRESETS_PATH)
	dir_access.remove(_preset_path)
	preset_deleted.emit()


func _on_button_pressed() -> void:
	preset_selected.emit()
