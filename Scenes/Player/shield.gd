extends Node2D

class_name Shield

# script for the process_hit system

##### ENUMS #####
enum HitResult { IGNORED, SHIELDED, PARRIED }

##### SIGNALS #####

##### VARIABLES #####
#---- CONSTANTS -----
const PARRY_FREEZE_TIME := 0.25

#---- STANDARD -----
#==== PRIVATE ====
var _shielding := false
var _parrying := false
var _firing := false

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
	if _firing:
		hit_data.hit_process.call()
		return HitResult.IGNORED
	if _parrying:
		hit_data.parry_process.call(paths.player_root, paths.input_synchronizer.relative_aim_position)
		return HitResult.PARRIED
	if _shielding:
		hit_data.shield_process.call()
		return HitResult.SHIELDED
	hit_data.hit_process.call()
	return HitResult.IGNORED


func toggle_firing_disable(firing: bool) -> void:
	_firing = firing

##### PROTECTED METHODS #####

##### SIGNAL MANAGEMENT #####
