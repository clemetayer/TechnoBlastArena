extends Object

class_name PlayerHitData
# utility class to convey player hit information

##### VARIABLES #####
#---- CONSTANTS -----
const DAMAGE_TRESHOLDS := [14., 44.]
const KNOCKBACK_TRESHOLDS := [19., 39.]
const HITSTOP_DURATIONS := [0.05, 0.1, 0.33]

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
		p_parry_process: Callable = func(_p_owner: Node2D, _relative_aim_position: Vector2): pass,
		p_shield_process: Callable = func(): pass,
		p_hit_process: Callable = func(_with: CollisionObject2D): pass,
):
	knockback = p_knockback
	damage = p_damage
	shield_damage = p_shield_damage
	owner = p_owner
	parry_process = p_parry_process
	shield_process = p_shield_process
	hit_process = p_hit_process


# knockback
#     ^
#     | +----+----+----+
#     | |  M |  H |  H |
#     | +----+----+----+
#     | |  L |  M |  H |
#     | +----+----+----+
#     | |  L |  L |  M |
#     | +----+----+----+
#       ----------------> damage
#       L = low
#       M = medium
#       H = high
func get_hitstop_duration() -> float:
	if _is_low_hitstop():
		return HITSTOP_DURATIONS[0]
	if _is_high_hitstop():
		return HITSTOP_DURATIONS[2]
	return HITSTOP_DURATIONS[1]


func _is_low_hitstop() -> bool:
	return (damage <= DAMAGE_TRESHOLDS[0] and knockback.length() <= KNOCKBACK_TRESHOLDS[0]) \
	or (damage <= DAMAGE_TRESHOLDS[1] and knockback.length() <= KNOCKBACK_TRESHOLDS[0]) \
	or (damage <= DAMAGE_TRESHOLDS[0] and knockback.length() <= KNOCKBACK_TRESHOLDS[1])


func _is_high_hitstop() -> bool:
	return (damage > DAMAGE_TRESHOLDS[1] and knockback.length() > KNOCKBACK_TRESHOLDS[1]) \
	or (damage > DAMAGE_TRESHOLDS[0] and knockback.length() > KNOCKBACK_TRESHOLDS[1]) \
	or (damage > DAMAGE_TRESHOLDS[1] and knockback.length() > KNOCKBACK_TRESHOLDS[0])
