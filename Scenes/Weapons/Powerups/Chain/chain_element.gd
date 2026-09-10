extends Node2D
# powerup that redirects a projectile when entering

##### SIGNALS #####
signal destroyed(idx: int)

##### VARIABLES #####
#---- STANDARD -----
#==== PUBLIC ====
var idx: int

#==== PRIVATE ====
var _direction: Vector2
var _active := false

#==== ONREADY ====
@onready var counter := $"ElementCounter"
@onready var particles := $"HitEffect"
@onready var hitsound := $"Hitsound"


##### PUBLIC METHODS #####
func spawn(direction: Vector2, spawn_position: Vector2, p_idx: int) -> void:
	RuntimeUtils.get_game_root().spawn_powerup(self)
	global_rotation = Vector2.ZERO.angle_to_point(direction)
	_direction = direction.normalized()
	global_position = spawn_position
	idx = p_idx
	_active = false


func change_direction(new_direction: Vector2) -> void:
	_direction = new_direction.normalized()
	global_rotation = Vector2.ZERO.angle_to_point(new_direction)


##### SIGNAL MANAGEMENT #####
func _on_element_counter_empty() -> void:
	if particles.emitting:
		await particles.finished
	destroyed.emit(idx)


func _on_area_entered(area: Area2D) -> void:
	if GroupUtils.is_projectile(area):
		area.change_direction(_direction)
		if not _active:
			hitsound.play()
			particles.emitting = true
			counter.decrease()
			_active = true


func _on_hit_effect_finished() -> void:
	_active = false
