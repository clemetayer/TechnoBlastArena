@abstract
class_name ProjectileBase
extends Area2D

# base template for projectiles

##### VARIABLES #####
#---- EXPORTS -----
@export var PARAMETERS: ProjectileParametersResource
@export var init_position: Vector2
@export var init_rotation: float
@export var color := Color.WHITE

#---- STANDARD -----
#==== PUBLIC ====
var speed := 3200.0
var damage := 15.0
var knockback := 1.0
var current_owner # the current "owner" of the bullet (i.e, the last thing that either spawned it, reflected it, etc.)


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", _on_body_entered)
	_set_params()
	global_position = init_position
	rotation = init_rotation


##### PUBLIC METHODS #####
@abstract func parried(p_owner: Node2D, relative_aim_position: Vector2) -> void


@abstract func change_direction(new_direction: Vector2) -> void


func shielded() -> void:
	queue_free()


func solid_collision(_with: Node2D) -> void:
	queue_free()


##### PROTECTED METHODS #####
func _set_params() -> void:
	if PARAMETERS == null:
		GSLogger.error("Error when trying to set the bullet parameters. Exported variable is null")
		return
	speed = PARAMETERS.SPEED
	damage = PARAMETERS.DAMAGE
	knockback = PARAMETERS.KNOCKBACK
	scale = Vector2.ONE * PARAMETERS.SIZE


##### SIGNAL MANAGEMENT #####
@abstract func _on_body_entered(body)
