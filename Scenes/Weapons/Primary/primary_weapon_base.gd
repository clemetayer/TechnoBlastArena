@abstract
class_name PrimaryWeaponBase
extends Node2D

# Base class for the primary weapon

##### VARIABLES #####
#---- EXPORTS -----
@export var owner_color := Color.WHITE

#---- STANDARD -----
#==== PRIVATE ====
var _runtime_utils := RuntimeUtils # for test purposes

#==== PUBLIC ====
var active := false
var projectile_owner = null # the owner of the projectile that will spawn, i.e : the player with the weapon


##### PUBLIC METHODS #####
@abstract func fire() -> void


@warning_ignore("UNUSED_PARAMETER")
@abstract func aim(relative_aim_position: Vector2) -> void


##### PROTECTED METHODS #####
func _spawn_projectile(projectile: Node) -> void:
	var game_root = _runtime_utils.get_game_root()
	if game_root != null and game_root.has_method("spawn_projectile"):
		game_root.spawn_projectile(projectile)
	else:
		GSLogger.error("Game root does not exist or does not have the method '%s'" % "spawn_projectile")


##### SIGNAL MANAGEMENT #####
func _on_player_abilities_toggled(p_active: bool) -> void:
	active = p_active
