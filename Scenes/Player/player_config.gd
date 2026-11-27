extends Resource

class_name PlayerConfig
# Parameters to give to the player to fine tune it easily

##### VARIABLES #####
#---- EXPORTS -----
@export var PLAYER_NAME: String
@export var DESCRIPTION: String
@export var ACTION_HANDLER: StaticActionHandler.handlers
@export var DEVICE_ID: int = -1
@export var PRIMARY_WEAPON: StaticPrimaryWeaponHandler.handlers
@export var MOVEMENT_BONUS_HANDLER: StaticMovementBonusHandler.handlers
@export var POWERUP_HANDLER: StaticPowerupHandler.handlers
@export var SPRITE_CUSTOMIZATION: SpriteCustomizationResource
@export var ELIMINATION_TEXT: String
