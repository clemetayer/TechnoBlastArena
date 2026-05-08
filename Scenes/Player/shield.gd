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
var _shielding := true

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
	pass


func process_hit(hit_data: PlayerHitData) -> HitResult:
	return HitResult.IGNORED


func disable_after_firing() -> void:
	pass

##### PROTECTED METHODS #####

##### SIGNAL MANAGEMENT #####
