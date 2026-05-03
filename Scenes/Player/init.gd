extends Node

# Tool to initalize the player's config

##### VARIABLES #####
#---- STANDARD -----
#==== ONREADY ====
@onready var onready_paths_node := $"../Paths"
@export var ACTION_HANDLER: StaticActionHandler.handlers
@export var PRIMARY_WEAPON: StaticPrimaryWeaponHandler.handlers
@export var MOVEMENT_BONUS_HANDLER: StaticMovementBonusHandler.handlers
@export var POWERUP_HANDLER: StaticPowerupHandler.handlers


##### PUBLIC METHODS #####
func initialize(config: PlayerConfig) -> void:
	onready_paths_node.sprites.load_sprite_preset(config.SPRITE_CUSTOMIZATION)
	onready_paths_node.sprites.set_player_indicator(onready_paths_node.player_root.PLAYER_ID)
	ACTION_HANDLER = config.ACTION_HANDLER
	PRIMARY_WEAPON = config.PRIMARY_WEAPON
	MOVEMENT_BONUS_HANDLER = config.MOVEMENT_BONUS_HANDLER
	POWERUP_HANDLER = config.POWERUP_HANDLER
	onready_paths_node.crosshair.set_color(RuntimeUtils.PLAYER_INDICATOR_COLORS[onready_paths_node.player_root.PLAYER_ID])
	onready_paths_node.primary_weapon = StaticPrimaryWeaponHandler.get_weapon(PRIMARY_WEAPON)
	onready_paths_node.player_root.abilities_toggled.connect(onready_paths_node.primary_weapon._on_player_abilities_toggled)
	onready_paths_node.movement_bonus = StaticMovementBonusHandler.get_handler(MOVEMENT_BONUS_HANDLER)
	onready_paths_node.player_root.abilities_toggled.connect(onready_paths_node.movement_bonus._on_player_abilities_toggled)
	onready_paths_node.powerup_manager = StaticPowerupHandler.get_powerup_manager(POWERUP_HANDLER)
	onready_paths_node.player_root.abilities_toggled.connect(onready_paths_node.powerup_manager._on_player_abilities_toggled)
	onready_paths_node.input_synchronizer.set_action_handler(ACTION_HANDLER)
	onready_paths_node.movement_bonus.player = onready_paths_node.player_root
	onready_paths_node.primary_weapon.projectile_owner = onready_paths_node.player_root
	onready_paths_node.damage_label.init_damage()
	onready_paths_node.primary_weapon.owner_color = RuntimeUtils.PLAYER_INDICATOR_COLORS[onready_paths_node.player_root.PLAYER_ID]
	onready_paths_node.death_manager.set_particles_color(config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR)
	onready_paths_node.appear_elements.init(config.SPRITE_CUSTOMIZATION.BODY_COLOR, config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR)
	onready_paths_node.hit_particles.init(config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR)
	onready_paths_node.player_root.add_child(onready_paths_node.primary_weapon)
	onready_paths_node.player_root.add_child(onready_paths_node.movement_bonus)
	onready_paths_node.player_root.add_child(onready_paths_node.powerup_manager)
	onready_paths_node.movement_bonus.connect("value_updated", func(value): onready_paths_node.player_root.emit_signal("movement_updated", onready_paths_node.player_root.PLAYER_ID, value))
	onready_paths_node.powerup_manager.connect("value_updated", func(value): onready_paths_node.player_root.emit_signal("powerup_updated", onready_paths_node.player_root.PLAYER_ID, value))
