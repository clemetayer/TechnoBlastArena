extends ProjectileBase
# to unit test the chain powerup

##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====
var _direction


##### PUBLIC METHODS #####
func parried(_owner: Node2D, _relative_aim_position: Vector2) -> void:
	pass


func change_direction(new_direction: Vector2) -> void:
	_direction = new_direction


##### SIGNAL MANAGEMENT #####
func _on_body_entered(_body):
	pass
