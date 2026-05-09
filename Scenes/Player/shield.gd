extends Node2D

class_name Shield

# script for the process_hit system

##### ENUMS #####
enum HitResult { IGNORED, SHIELDED, PARRIED }

##### VARIABLES #####
#---- CONSTANTS -----
const PARRY_FREEZE_TIME := 0.25
const BASE_SHIELD_HEALTH := 1500

#---- STANDARD -----
#==== PRIVATE ====
var _shielding := false
var _parrying := false
var _firing := false
var _health := BASE_SHIELD_HEALTH

#==== ONREADY ====
@onready var paths := $"../Paths"
@onready var onready_paths := {
	"animation_player": $"ParryAnimations",
	"parry_sound": $"ParrySound",
	"parry_disabled_sound": $"ParryDisabled",
	"parry_active_sound": $"ParryActive",
}


##### PUBLIC METHODS #####
func toggle_shielding(active: bool) -> void:
	_shielding = active


func process_hit(hit_data: PlayerHitData) -> HitResult:
	if _firing or _is_broken():
		return _hit(hit_data)
	if _parrying:
		return _parry(hit_data)
	if _shielding:
		return _shield(hit_data)
	return _hit(hit_data)


func toggle_firing_disable(firing: bool) -> void:
	_firing = firing


##### PROTECTED METHODS #####
func _hit(hit_data: PlayerHitData) -> HitResult:
	hit_data.hit_process.call()
	return HitResult.IGNORED


func _parry(hit_data: PlayerHitData) -> HitResult:
	hit_data.parry_process.call(paths.player_root, paths.input_synchronizer.relative_aim_position)
	return HitResult.PARRIED


func _shield(hit_data: PlayerHitData) -> HitResult:
	_health = clamp(_health - hit_data.shield_damage, 0, BASE_SHIELD_HEALTH)
	hit_data.shield_process.call()
	return HitResult.SHIELDED


func _is_broken() -> bool:
	return _health <= 0

##### SIGNAL MANAGEMENT #####
