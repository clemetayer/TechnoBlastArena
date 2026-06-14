extends Button

# Handles a preset

##### VARIABLES #####
#---- STANDARD -----
#==== ONREADY ====
@onready var name_label := $"VBoxContainer/Elements/Name"
@onready var primary_weapon := $"VBoxContainer/Elements/PrimaryWeapon"
@onready var movement_bonus := $"VBoxContainer/Elements/MovementBonus"
@onready var powerup := $"VBoxContainer/Elements/Powerup"
@onready var level := $"VBoxContainer/Elements/AILevel"
@onready var sprite := $"VBoxContainer/Elements/Sprite"


##### PUBLIC METHODS #####
func set_preset(preset: PlayerConfig) -> void:
	name_label.text = preset.PLAYER_NAME
	primary_weapon.texture = load(StaticPrimaryWeaponHandler.get_icon_path(preset.PRIMARY_WEAPON))
	movement_bonus.texture = load(StaticMovementBonusHandler.get_icon_path(preset.MOVEMENT_BONUS_HANDLER))
	powerup.texture = load(StaticPowerupHandler.get_icon_path(preset.POWERUP_HANDLER))
	sprite.update_sprite(preset.SPRITE_CUSTOMIZATION)
	tooltip_text = preset.DESCRIPTION
	if preset is AIPlayerConfig:
		level.visible = true
		level.set_level(preset.LEVEL)
