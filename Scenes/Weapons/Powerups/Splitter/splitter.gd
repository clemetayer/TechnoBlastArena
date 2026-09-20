extends Node2D

# Powerups that duplicates a projectile in multiple projectiles

##### SIGNALS #####
signal destroyed

##### VARIABLES #####
#---- CONSTANTS -----
const PROJECTILE_DUPLICATES := 5 # note : most likely should be an uneven number (to let the original projectile keep its trajectory)
const PROJECTILE_DUP_DAMAGE_BONUS_MULTIPLIER := 1.2
const PROJECTILE_DUP_KNOCKBACK_BONUS_MULTIPLIER := 1.2
const MAX_BULLETS_DUPLICATED := 32 # To prevent silly players to try to put 5 splitters next to each other to spawn about 759375 projectiles and crash the game

#---- STANDARD -----
#==== PRIVATE ====
var _whitelist := [] # to avoid duplicating too much (with the fresh new projectiles for instance)
var _runtime_utils := RuntimeUtils
var _bullet_dup_cnt := 0

#==== ONREADY ====
@onready var hitbox := $"Hitbox"
@onready var audio := $"AudioStreamPlayer2D"
@onready var collision := $"Hitbox/CollisionShape2D"
@onready var sprite := $"Sprite2D"
@onready var hit_effect := $"HitEffect"
@onready var counter := $"ElementCounter"
@onready var bullet_count_reset_timer := $"BulletCountReset"


##### PROTECTED METHODS #####
func _spawn_projectile(projectile) -> void:
	var game_root = _runtime_utils.get_game_root()
	if game_root != null and game_root.has_method("spawn_projectile"):
		game_root.spawn_projectile(projectile)
	else:
		GSLogger.error(
			"Game root does not exist or does not have the method '%s'" % "spawn_projectile"
		)


func _duplicate_projectile_with_angle(
	projectile: Node,
	angle: float,
	new_damage: float,
	new_knockback: float,
) -> void:
	if _bullet_dup_cnt < MAX_BULLETS_DUPLICATED:
		var duplicated_projectile = projectile.duplicate()
		duplicated_projectile.PARAMETERS = duplicated_projectile.PARAMETERS.duplicate()
		duplicated_projectile.damage = new_damage
		duplicated_projectile.PARAMETERS.DAMAGE = new_damage
		duplicated_projectile.knockback = new_knockback
		duplicated_projectile.PARAMETERS.KNOCKBACK = new_knockback
		duplicated_projectile.current_owner = projectile.current_owner
		duplicated_projectile.init_rotation = duplicated_projectile.rotation + angle
		duplicated_projectile.init_position = duplicated_projectile.global_position
		_spawn_projectile(duplicated_projectile)
		_whitelist.append(duplicated_projectile)
		_bullet_dup_cnt += 1


func _handle_feedback() -> void:
	hit_effect.emitting = true
	audio.play()


func _prepare_for_deletion() -> void:
	collision.set_deferred("disabled", true)
	sprite.hide()
	if audio.playing:
		await audio.finished
	emit_signal("destroyed", self)
	queue_free()


##### SIGNAL MANAGEMENT #####
# Note : the PROJECTILE_DUPLICATES + 1 thing seems weird, but it's actually needed to spawn an even amount of bullets
func _on_hitbox_area_entered(area):
	if GroupUtils.is_projectile(area) and not _whitelist.has(area):
		_handle_feedback()
		var projectile_damage = (area.damage / PROJECTILE_DUPLICATES) * PROJECTILE_DUP_DAMAGE_BONUS_MULTIPLIER
		var projectile_knockback = (area.knockback / PROJECTILE_DUPLICATES) * PROJECTILE_DUP_KNOCKBACK_BONUS_MULTIPLIER
		area.damage = projectile_damage
		area.knockback = projectile_knockback
		counter.decrease()
		for duplicate_idx in range(1, PROJECTILE_DUPLICATES + 1):
			var dup_angle = (duplicate_idx * ((PI / 2) / (PROJECTILE_DUPLICATES + 1))) - PI / 4
			if dup_angle != 0: # PI/2 angle (forward) is reserved for the original projectile
				_duplicate_projectile_with_angle(
					area,
					dup_angle,
					projectile_damage,
					projectile_knockback,
				)
		if PROJECTILE_DUPLICATES % 2 == 0:
			area.queue_free()
		else:
			_whitelist.append(area)


func _on_hitbox_area_exited(area):
	if _whitelist.has(area):
		_whitelist.erase(area)


func _on_element_counter_empty() -> void:
	_prepare_for_deletion()


func _on_bullet_count_reset_timeout() -> void:
	_bullet_dup_cnt = 0
