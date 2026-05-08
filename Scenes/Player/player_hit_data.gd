extends Object

class_name PlayerHitData
# utility class to convey player hit information

##### VARIABLES #####
#---- STANDARD -----
#==== PUBLIC ====
var knockback: Vector2
var damage: float
var owner: Node2D
var shield_damage: float
var parry_process: Callable
var shield_process: Callable
var hit_process: Callable


##### PROCESSING #####
func _init(
		p_knockback: Vector2,
		p_damage: float,
		p_owner: Node2D,
		p_shield_damage: float = p_damage,
		p_parry_process: Callable = func(): pass,
		p_shield_process: Callable = func(): pass,
		p_hit_process: Callable = func(): pass,
):
	knockback = p_knockback
	damage = p_damage
	shield_damage = p_shield_damage
	owner = p_owner
	parry_process = p_parry_process
	shield_process = p_shield_process
	hit_process = p_hit_process
