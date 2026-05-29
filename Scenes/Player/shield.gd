extends Node2D

class_name Shield

# script for the process_hit system

##### ENUMS #####
enum HitResult { IGNORED, SHIELDED, PARRIED }

#---- CONSTANTS -----
const BASE_SHIELD_HEALTH := 150

##### VARIABLES #####
const SHIELD_BROKEN_REGEN_TIME := 10 #s
const SHIELD_PASSIVE_HEALTH_REGEN_PER_TICK := 3
const DAMAGE_GRADIENT = preload("res://Scenes/Player/damage_text_gradient.tres")
const PARRY_STOP_TIME := 0.33 #s

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
	"shield_sound": $"ShieldLoop",
	"shield_absorbed_sound": $"ShieldHit",
	"shield_break_sound": $"ShieldBreak",
	"shield_broken_sound": $"ShieldBroken",
	"shield_init_sound": $"ShieldInit",
	"shield_regenerated_sound": $"ShieldRegenerated",
	"parry_sound": $"ParrySound",
}


##### PUBLIC METHODS #####
func toggle_shielding(active: bool) -> void:
	_handle_normal_shield(active)
	_handle_broken_shield(active)
	onready_paths.shield_particles.modulate = DAMAGE_GRADIENT.sample(float(BASE_SHIELD_HEALTH - _health) / BASE_SHIELD_HEALTH)
	_shielding = active


func activate_parry() -> void:
	if not _is_broken():
		_parrying = true
		onready_paths.shield_init_sound.play()
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
func _handle_normal_shield(active: bool) -> void:
	if not onready_paths.shield_sound.playing and _should_show_shield(active):
		onready_paths.shield_sound.play()
	elif not _should_show_shield(active):
		onready_paths.shield_sound.stop()
	onready_paths.shield_particles.emitting = _should_show_shield(active)


func _handle_broken_shield(active: bool) -> void:
	if not onready_paths.shield_broken_sound.playing and _should_show_broken_shield(active):
		onready_paths.shield_broken_sound.play()
	elif not _should_show_broken_shield(active):
		onready_paths.shield_broken_sound.stop()
	onready_paths.broken_shield_particles.emitting = _should_show_broken_shield(active)


func _should_show_shield(shield_active: bool) -> bool:
	return shield_active and not _is_broken() and not _firing


func _should_show_broken_shield(shield_active: bool) -> bool:
	return shield_active and _is_broken() and not _firing


func _hit(hit_data: PlayerHitData) -> HitResult:
	hit_data.hit_process.call(paths.player_root)
	return HitResult.IGNORED


func _parry(hit_data: PlayerHitData) -> HitResult:
	paths.stop_manager.stop_for_duration(PARRY_STOP_TIME)
	hit_data.parry_process.call(paths.player_root, paths.input_synchronizer.relative_aim_position)
	onready_paths.parry_sound.play()
	return HitResult.PARRIED


func _shield(hit_data: PlayerHitData) -> HitResult:
	_health = clamp(_health - hit_data.shield_damage, 0, BASE_SHIELD_HEALTH)
	onready_paths.shield_absorbed_sound.play()
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
	onready_paths.shield_break_sound.play()
	if _regen_tween:
		_regen_tween.kill()
	_regen_tween = create_tween()
	_regen_tween.tween_property(onready_paths.broken_shield_regen_bar, "value", 100, SHIELD_BROKEN_REGEN_TIME)
	_regen_tween.finished.connect(_on_shield_regenerated)
	_regen_tween.play()


##### SIGNAL MANAGEMENT #####
func _on_shield_regenerated() -> void:
	onready_paths.broken_shield_regen_bar.visible = false
	onready_paths.shield_regenerated_sound.play()
	_health = BASE_SHIELD_HEALTH


func _on_parry_time_window_timeout() -> void:
	_parrying = false


func _on_shield_passive_regen_timeout() -> void:
	if not _is_broken():
		_health = clamp(BASE_SHIELD_HEALTH, 0, _health + SHIELD_PASSIVE_HEALTH_REGEN_PER_TICK)
