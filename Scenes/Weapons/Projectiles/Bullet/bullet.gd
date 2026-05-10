extends ProjectileBase

# A default bullet

##### VARIABLES #####
#---- CONSTANTS -----
const SPEED := 3200.0 # px/s
const DAMAGE := 15.0
const KNOCKBACK := 20.0

#---- EXPORTS -----
@export var speed := SPEED
@export var damage := DAMAGE
@export var knockback := KNOCKBACK
@export var freeze := false

#---- STANDARD -----
#==== PRIVATE ====
var _direction := Vector2.ZERO

#==== ONREADY ====
@onready var onready_paths := {
	"sprite": $"Sprite/Body",
	"trail": $"Trail",
}


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	global_position = init_position
	rotation = init_rotation
	onready_paths.trail.modulate = color
	onready_paths.sprite.modulate = color
	_direction = Vector2.RIGHT.rotated(rotation).normalized()


# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(delta):
	if not freeze:
		position += _direction * speed * delta


##### PUBLIC METHODS #####
func parried(p_owner: Node2D, relative_aim_position: Vector2) -> void:
	current_owner = p_owner
	rotation = Vector2.ZERO.angle_to_point(relative_aim_position)
	_direction = relative_aim_position.normalized()
	speed *= 2
	damage *= 2
	knockback *= 2
	onready_paths.trail.reset()


##### SIGNAL MANAGEMENT #####
func _on_body_entered(body):
	if GroupUtils.is_player(body) and current_owner != body and body.has_method("hit"):
		body.hit(PlayerHitData.new(knockback * _direction, damage, current_owner, damage, parried, shielded, solid_collision))
		queue_free()
	elif GroupUtils.is_static_obstacle(body):
		queue_free()


func _on_SceneUtils_toggle_scene_freeze(value: bool) -> void:
	freeze = value
