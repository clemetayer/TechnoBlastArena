extends Node2D
##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====
var _fired_projectile

#==== ONREADY ====
@onready var onready_paths := {
	"player": $"Player",
	"fire_position_node": $"FirePosition"
}

##### PUBLIC METHODS #####
func get_fire_position() -> Vector2:
	return onready_paths.fire_position_node.global_position

func get_player_config(_id: int) -> PlayerConfig:
	return load("res://test/integration/Common/default_player_config.tres")

func get_player() -> Node2D:
	return onready_paths.player

func get_fired_projectile():
	return _fired_projectile

func is_parrying() -> bool:
	return onready_paths.player.paths.parry_area._parrying

func is_parry_lockout() -> bool:
	return not onready_paths.player.paths.parry_area._can_parry

func toggle_shield_enabled(active: bool) -> void:
	onready_paths.player.paths.parry_area.toggle_shield_enabled(active)

func fire_projectile(projectile_scene) -> void:
	_fired_projectile = projectile_scene
	add_child(_fired_projectile)
