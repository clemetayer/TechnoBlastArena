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

#==== ONREADY ====
@onready var counter := $"ElementCounter"


##### PUBLIC METHODS #####
func spawn(direction: Vector2, spawn_position: Vector2, p_idx: int) -> void:
	RuntimeUtils.get_game_root().spawn_powerup(self)
	global_rotation = Vector2.ZERO.angle_to_point(direction)
	_direction = direction.normalized()
	global_position = spawn_position
	idx = p_idx


func change_direction(new_direction: Vector2) -> void:
	_direction = new_direction.normalized()
	global_rotation = Vector2.ZERO.angle_to_point(new_direction)


##### SIGNAL MANAGEMENT #####
func _on_element_counter_empty() -> void:
	destroyed.emit(idx)


func _on_area_entered(area: Area2D) -> void:
	if GroupUtils.is_projectile(area):
		area.change_direction(_direction)
		counter.decrease()
