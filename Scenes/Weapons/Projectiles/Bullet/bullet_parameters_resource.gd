extends Resource

class_name BulletParametersResource

func _init(
		speed = 3200,
		damage = 15.0,
		knockback = 20.0,
		size = 1.0,
):
	SPEED = speed
	DAMAGE = damage
	KNOCKBACK = knockback
	SIZE = size

# parameters resource to change some bullet elements
@export var SPEED := 3200 # px/s
@export var DAMAGE := 15.0
@export var KNOCKBACK := 20.0
@export var SIZE := 1.0
