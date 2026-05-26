extends Node

# Script to manage the death animation of the player

##### VARIABLES #####
#---- CONSTANTS -----
const CAMERA_DEATH_IMPACT_TIME := 1 #s

#---- STANDARD -----
#==== PRIVATE ====
var _last_hit_owner: Node2D = null
var _camera_effects := CameraEffects

#==== ONREADY ====
@onready var paths := $"../Paths"
@onready var onready_paths := {
	"particles": $"DeathParticles",
	"sound": $"DeathSound",
	"death_anim_time": $"DeathAnimTime",
}


##### PUBLIC METHODS #####
func set_particles_color(color: Color) -> void:
	onready_paths.particles.modulate = color


# Triggers the death animation
func kill() -> void:
	_camera_effects.emit_signal_start_camera_impact(CAMERA_DEATH_IMPACT_TIME, CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH, CameraEffects.CAMERA_IMPACT_PRIORITY.HIGH)
	if is_instance_valid(_last_hit_owner):
		paths.player_root.emit_signal("game_message_triggered", _get_last_hit_owner_id(_last_hit_owner))
	onready_paths.particles.emitting = true
	paths.stop_manager.toggle_stop(true)
	# disables the collisions, just in case
	paths.player_root.set_collision_layer(0)
	paths.player_root.set_collision_mask(0)
	paths.damage_label.hide()
	paths.sprites.hide()
	paths.shield.hide()
	paths.hitstun_manager.hide()
	paths.primary_weapon.hide()
	if onready_paths.sound.is_inside_tree():
		onready_paths.sound.play()
	if onready_paths.death_anim_time.is_inside_tree():
		onready_paths.death_anim_time.start()
	paths.player_root.toggle_truce(true)


##### PROTECTED METHODS #####
func _get_last_hit_owner_id(last_hit_owner: Node2D) -> int:
	return last_hit_owner.PLAYER_ID


func _on_death_anim_time_timeout() -> void:
	paths.player_root.emit_signal("killed", paths.player_root.PLAYER_ID)
	paths.player_root.queue_free()


func _on_player_last_hit_owner_changed(hit_owner: Node2D) -> void:
	_last_hit_owner = hit_owner
