@abstract
class_name ProjectileBase
extends Area2D

# base template for projectiles

##### VARIABLES #####
#---- EXPORTS -----
@export var init_position: Vector2
@export var init_rotation: float
@export var color := Color.WHITE

#---- STANDARD -----
#==== PUBLIC ====
var current_owner # the current "owner" of the bullet (i.e, the last thing that either spawned it, reflected it, etc.)


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", _on_body_entered)
	SceneUtils.connect("toggle_scene_freeze", _on_SceneUtils_toggle_scene_freeze)


##### PUBLIC METHODS #####
@abstract func parried(p_owner: Node2D, relative_aim_position: Vector2) -> void


func shielded() -> void:
	queue_free()


func solid_collision(_with: CollisionObject2D) -> void:
	queue_free()


##### SIGNAL MANAGEMENT #####
@abstract func _on_body_entered(body)


@abstract func _on_SceneUtils_toggle_scene_freeze(value: bool)
