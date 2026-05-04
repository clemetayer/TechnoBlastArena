extends Area2D

# script for the parry system

##### SIGNALS #####
signal parried

##### VARIABLES #####
#---- CONSTANTS -----
const PARRY_FREEZE_TIME := 0.25

#---- STANDARD -----
#==== PRIVATE ====
var _parrying := false
var _can_parry := true
var _enabled := true
var _camera_effects := CameraEffects
var _scene_utils := SceneUtils

#==== ONREADY ====
@onready var _owner := get_parent()
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
func toggle_parry_enabled(active: bool) -> void:
	_enabled = active


func parry() -> void:
	if _enabled:
		if _can_parry and not _parrying:
			_parrying = true
			onready_paths.parry_timer.start()
			onready_paths.animation_player.play("parrying")
			onready_paths.parry_active_sound.play()
		else:
			onready_paths.parry_disabled_sound.play()


func disable_parry_after_firing() -> void:
	if _enabled:
		onready_paths.disable_after_fire_timer.start()
		_toggle_can_parry(false)


##### PROTECTED METHODS #####
func _toggle_can_parry(enabled: bool) -> void:
	_can_parry = enabled
	onready_paths.parry_lockout_sprite.visible = not enabled


##### SIGNAL MANAGEMENT #####
func _on_area_entered(area):
	if GroupUtils.is_projectile(area) and _parrying and _can_parry:
		onready_paths.animation_player.play("parried")
		onready_paths.parry_sound.play()
		onready_paths.parry_timer.stop()
		_toggle_can_parry(true)
		_parrying = false
		area.parried(_owner, onready_paths_node.input_synchronizer.relative_aim_position)
		_camera_effects.emit_signal_start_camera_impact(PARRY_FREEZE_TIME, CameraEffects.CAMERA_IMPACT_INTENSITY.LIGHT, CameraEffects.CAMERA_IMPACT_PRIORITY.MEDIUM)
		_scene_utils.freeze_scene_parry(PARRY_FREEZE_TIME)
		emit_signal("parried")


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
