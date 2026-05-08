extends Node

# Tool to initalize the player's config

##### VARIABLES #####
#---- STANDARD -----
#==== ONREADY ====
@onready var paths := $"../Paths"
@export var ACTION_HANDLER: StaticActionHandler.handlers
@export var PRIMARY_WEAPON: StaticPrimaryWeaponHandler.handlers
@export var MOVEMENT_BONUS_HANDLER: StaticMovementBonusHandler.handlers
@export var POWERUP_HANDLER: StaticPowerupHandler.handlers


##### PUBLIC METHODS #####
func initialize(config: PlayerConfig) -> void:
	paths.sprites.load_sprite_preset(config.SPRITE_CUSTOMIZATION)
	paths.sprites.set_player_indicator(paths.player_root.PLAYER_ID)
	ACTION_HANDLER = config.ACTION_HANDLER
	PRIMARY_WEAPON = config.PRIMARY_WEAPON
	MOVEMENT_BONUS_HANDLER = config.MOVEMENT_BONUS_HANDLER
	POWERUP_HANDLER = config.POWERUP_HANDLER
	paths.crosshair.set_color(RuntimeUtils.PLAYER_INDICATOR_COLORS[paths.player_root.PLAYER_ID])
	paths.primary_weapon = StaticPrimaryWeaponHandler.get_weapon(PRIMARY_WEAPON)
	paths.player_root.abilities_toggled.connect(paths.primary_weapon._on_player_abilities_toggled)
	paths.movement_bonus = StaticMovementBonusHandler.get_handler(MOVEMENT_BONUS_HANDLER)
	paths.player_root.abilities_toggled.connect(paths.movement_bonus._on_player_abilities_toggled)
	paths.powerup_manager = StaticPowerupHandler.get_powerup_manager(POWERUP_HANDLER)
	paths.player_root.abilities_toggled.connect(paths.powerup_manager._on_player_abilities_toggled)
	paths.input_synchronizer.set_action_handler(ACTION_HANDLER)
	paths.movement_bonus.player = paths.player_root
	paths.primary_weapon.projectile_owner = paths.player_root
	paths.damage_label.init_damage()
	paths.primary_weapon.owner_color = RuntimeUtils.PLAYER_INDICATOR_COLORS[paths.player_root.PLAYER_ID]
	paths.death_manager.set_particles_color(config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR)
	paths.appear_elements.init(config.SPRITE_CUSTOMIZATION.BODY_COLOR, config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR)
	paths.hit_particles.init(config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR)
	paths.player_root.add_child(paths.primary_weapon)
	paths.player_root.add_child(paths.movement_bonus)
	paths.player_root.add_child(paths.powerup_manager)
	paths.movement_bonus.connect("value_updated", func(value): paths.player_root.emit_signal("movement_updated", paths.player_root.PLAYER_ID, value))
	paths.powerup_manager.connect("value_updated", func(value): paths.player_root.emit_signal("powerup_updated", paths.player_root.PLAYER_ID, value))
