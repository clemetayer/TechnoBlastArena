extends ProjectileBase

# A default bullet

##### VARIABLES #####
#---- CONSTANTS -----
const BASE_SPEED := 3200.0 # px/s
const BASE_DAMAGE := 15.0
const BASE_KNOCKBACK := 20.0
const SPEED_PARRY_MULTIPLIER := 1.125
const DAMAGE_PARRY_MULTIPLIER := 2
const KNOCKBACK_PARRY_MULTIPLIER := 2

#---- EXPORTS -----
@export var speed := BASE_SPEED
@export var damage := BASE_DAMAGE
@export var knockback := BASE_KNOCKBACK

#---- STANDARD -----
#==== PRIVATE ====
var _direction := Vector2.ZERO

#==== ONREADY ====
@onready var onready_paths := {
	"sprite": $"Sprite",
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
	position += _direction * speed * delta


##### PUBLIC METHODS #####
func parried(p_owner: Node2D, relative_aim_position: Vector2) -> void:
	current_owner = p_owner
	color = RuntimeUtils.PLAYER_INDICATOR_COLORS[p_owner.PLAYER_ID]
	onready_paths.trail.modulate = color
	onready_paths.sprite.modulate = color
	rotation = Vector2.ZERO.angle_to_point(relative_aim_position)
	_direction = relative_aim_position.normalized()
	speed *= SPEED_PARRY_MULTIPLIER
	damage *= DAMAGE_PARRY_MULTIPLIER
	knockback *= KNOCKBACK_PARRY_MULTIPLIER
	onready_paths.trail.reset()


##### SIGNAL MANAGEMENT #####
func _on_body_entered(body):
	if GroupUtils.is_player(body) and current_owner != body and body.has_method("hit"):
		body.hit(PlayerHitData.new(knockback * _direction, damage, current_owner, damage, parried, shielded, solid_collision))
	elif GroupUtils.is_static_obstacle(body) or GroupUtils.is_destructible_wall(body):
		solid_collision(body)
