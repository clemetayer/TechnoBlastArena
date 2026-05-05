extends Node2D

# script for the shield system

##### SIGNALS #####
@warning_ignore("unused_signal")
signal parried

##### VARIABLES #####
#---- CONSTANTS -----
const PARRY_FREEZE_TIME := 0.25

#---- STANDARD -----
#==== PRIVATE ====
var _parrying := false
var _can_parry := true
var _shielding := true

#==== ONREADY ====
@onready var onready_paths_node := $"../Paths"
@onready var onready_paths := {
	"animation_player": $"ParryAnimations",
	"parry_lockout_sprite": $"ParryLockout",
	"parry_sound": $"ParrySound",
	"parry_disabled_sound": $"ParryDisabled",
	"parry_active_sound": $"ParryActive",
	"parry_timer": $"ParryTimer",
	"lockout_timer": $"LockoutTimer",
	"disable_after_fire_timer": $"DisableAfterFireTimer",
}


##### PUBLIC METHODS #####
func toggle_shielding(active: bool) -> void:
	_shielding = active


func shield() -> void:
	if _shielding:
		if _can_parry and not _parrying:
			_parrying = true
			onready_paths.parry_timer.start()
			onready_paths.animation_player.play("parrying")
			onready_paths.parry_active_sound.play()
		else:
			onready_paths.parry_disabled_sound.play()


func disable_shield_after_firing() -> void:
	if _shielding:
		onready_paths.disable_after_fire_timer.start()
		_toggle_can_parry(false)


##### PROTECTED METHODS #####
func _toggle_can_parry(enabled: bool) -> void:
	_can_parry = enabled
	onready_paths.parry_lockout_sprite.visible = not enabled


##### SIGNAL MANAGEMENT #####
func _on_lockout_timer_timeout():
	_toggle_can_parry(true)
	_parrying = false


func _on_parry_timer_timeout():
	_toggle_can_parry(false)
	_parrying = false
	onready_paths.lockout_timer.start()


func _on_disable_after_fire_timer_timeout() -> void:
	_toggle_can_parry(true)
	_parrying = false


func _on_player_abilities_toggled(active: bool) -> void:
	_toggle_can_parry(active)
