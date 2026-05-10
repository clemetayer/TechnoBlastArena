extends Node2D

class_name Shield

# script for the process_hit system

##### ENUMS #####
enum HitResult { IGNORED, SHIELDED, PARRIED }

##### VARIABLES #####
#---- CONSTANTS -----
const PARRY_FREEZE_TIME := 0.25
const BASE_SHIELD_HEALTH := 150
const SHIELD_REGEN_TIME := 10 #s
const DAMAGE_GRADIENT = preload("res://Scenes/Player/damage_text_gradient.tres")

#---- STANDARD -----
#==== PRIVATE ====
var _shielding := false
var _parrying := false
var _firing := false
var _health := BASE_SHIELD_HEALTH
var _regen_tween: Tween

#==== ONREADY ====
@onready var paths := $"../Paths"
@onready var onready_paths := {
	"animation_player": $"ParryAnimations",
	"shield_particles": $"ShieldParticles",
	"parry_time_window": $"ParryTimeWindow",
	"broken_shield_particles": $"BrokenShieldParticles",
	"broken_shield_anim_particles": $"BrokenShieldAnimParticles",
	"broken_shield_regen_bar": $"BrokenShieldRegenBar",
	"parry_sound": $"ParrySound",
	"parry_disabled_sound": $"ParryDisabled",
	"parry_active_sound": $"ParryActive",
}


##### PUBLIC METHODS #####
func toggle_shielding(active: bool) -> void:
	onready_paths.shield_particles.emitting = active and not _is_broken()
	onready_paths.broken_shield_particles.emitting = active and _is_broken()
	onready_paths.shield_particles.modulate = DAMAGE_GRADIENT.sample(float(BASE_SHIELD_HEALTH - _health) / BASE_SHIELD_HEALTH)
	_shielding = active


func activate_parry() -> void:
	_parrying = not _is_broken()
	onready_paths.parry_time_window.start()


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
	hit_data.hit_process.call(paths.player_root)
	return HitResult.IGNORED


func _parry(hit_data: PlayerHitData) -> HitResult:
	hit_data.parry_process.call(paths.player_root, paths.input_synchronizer.relative_aim_position)
	return HitResult.PARRIED


func _shield(hit_data: PlayerHitData) -> HitResult:
	_health = clamp(_health - hit_data.shield_damage, 0, BASE_SHIELD_HEALTH)
	hit_data.shield_process.call()
	if _health <= 0:
		_shield_broken()
	return HitResult.SHIELDED


func _is_broken() -> bool:
	return _health <= 0


func _shield_broken() -> void:
	_health = 0
	onready_paths.broken_shield_regen_bar.value = 0
	onready_paths.broken_shield_regen_bar.visible = true
	onready_paths.broken_shield_anim_particles.emitting = true
	if _regen_tween:
		_regen_tween.kill()
	_regen_tween = create_tween()
	_regen_tween.tween_property(onready_paths.broken_shield_regen_bar, "value", 100, SHIELD_REGEN_TIME)
	_regen_tween.finished.connect(_on_shield_regenerated)
	_regen_tween.play()


##### SIGNAL MANAGEMENT #####
func _on_shield_regenerated() -> void:
	onready_paths.broken_shield_regen_bar.visible = false
	_health = BASE_SHIELD_HEALTH


func _on_parry_time_window_timeout() -> void:
	_parrying = false
