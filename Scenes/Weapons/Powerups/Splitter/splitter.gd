extends Node2D

# Powerups that duplicates a projectile in multiple projectiles

##### SIGNALS #####
signal destroyed

##### VARIABLES #####
#---- CONSTANTS -----
const PROJECTILE_DUPLICATES := 3 # note : most likely should be an uneven number (to let the original projectile keep its trajectory)

#---- STANDARD -----
#==== PRIVATE ====
var _whitelist := [] # to avoid duplicating too much (with the fresh new projectiles for instance)
var _runtime_utils := RuntimeUtils

#==== ONREADY ====
@onready var onready_paths := {
	"audio": $"AudioStreamPlayer2D",
	"collision": $"Hitbox/CollisionShape2D",
	"sprite": $"Sprite2D",
	"hit_effect": $"HitEffect",
}


##### PROTECTED METHODS #####
func _spawn_projectile(projectile) -> void:
	var game_root = _runtime_utils.get_game_root()
	if game_root != null and game_root.has_method("spawn_projectile"):
		game_root.spawn_projectile(projectile)
	else:
		GSLogger.error("Game root does not exist or does not have the method '%s'" % "spawn_projectile")


func _duplicate_projectile_with_angle(projectile: Node, angle: float) -> void:
	var duplicated_projectile = projectile.duplicate()
	duplicated_projectile.current_owner = projectile.current_owner
	duplicated_projectile.init_rotation = duplicated_projectile.rotation + angle
	duplicated_projectile.init_position = duplicated_projectile.global_position
	_spawn_projectile(duplicated_projectile)
	_whitelist.append(duplicated_projectile)


func _handle_feedback() -> void:
	onready_paths.hit_effect.emitting = true
	onready_paths.audio.play()


func _prepare_for_deletion() -> void:
	onready_paths.collision.set_deferred("disabled", true)
	onready_paths.sprite.hide()
	if onready_paths.audio.playing:
		await onready_paths.audio.finished
	emit_signal("destroyed", self)
	queue_free()


##### SIGNAL MANAGEMENT #####
# Note : the PROJECTILE_DUPLICATES + 1 thing seems weird, but it's actually needed to spawn an even amount of bullets
func _on_hitbox_area_entered(area):
	if GroupUtils.is_projectile(area) and not _whitelist.has(area):
		_handle_feedback()
		for duplicate_idx in range(1, PROJECTILE_DUPLICATES + 1):
			var dup_angle = (duplicate_idx * ((PI / 2) / (PROJECTILE_DUPLICATES + 1))) - PI / 4
			if dup_angle != PI / 2: # PI/2 angle (forward) is reserved for the original projectile
				_duplicate_projectile_with_angle(area, dup_angle)
		if PROJECTILE_DUPLICATES % 2 == 0:
			area.queue_free()
		else:
			_whitelist.append(area)
		_prepare_for_deletion()


func _on_hitbox_area_exited(area):
	if _whitelist.has(area):
		_whitelist.erase(area)
