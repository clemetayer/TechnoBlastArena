extends ProjectileBase

# A default bullet

##### VARIABLES #####
#---- CONSTANTS -----
const SPEED_PARRY_MULTIPLIER := 1.125
const DAMAGE_PARRY_MULTIPLIER := 2
const KNOCKBACK_PARRY_MULTIPLIER := 2

#---- EXPORTS -----
@export var PARAMETERS: BulletParametersResource

#---- STANDARD -----
#==== PRIVATE ====
var _speed := 3200.0
var _damage := 15.0
var _knockback := 1.0
var _direction := Vector2.ZERO
var _stopped := false

#==== ONREADY ====
@onready var onready_paths := {
	"sprite": $"Sprite",
	"trail": $"Trail",
}


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	_set_params()
	global_position = init_position
	rotation = init_rotation
	onready_paths.trail.modulate = color
	onready_paths.sprite.modulate = color
	_direction = Vector2.RIGHT.rotated(rotation).normalized()


# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(delta):
	if not _stopped:
		position += _direction * _speed * delta


##### PUBLIC METHODS #####
func parried(p_owner: Node2D, relative_aim_position: Vector2) -> void:
	await _stop_for_duration(Shield.PARRY_STOP_TIME)
	current_owner = p_owner
	color = RuntimeUtils.PLAYER_INDICATOR_COLORS[p_owner.PLAYER_ID]
	onready_paths.trail.modulate = color
	onready_paths.sprite.modulate = color
	rotation = Vector2.ZERO.angle_to_point(relative_aim_position)
	_direction = relative_aim_position.normalized()
	_speed *= SPEED_PARRY_MULTIPLIER
	_damage *= DAMAGE_PARRY_MULTIPLIER
	_knockback *= KNOCKBACK_PARRY_MULTIPLIER
	onready_paths.trail.reset()


##### PROTECTED METHODS #####
func _set_params() -> void:
	if PARAMETERS == null:
		GSLogger.error("Error when trying to set the bullet parameters. Exported variable is null")
		return
	_speed = PARAMETERS.SPEED
	_damage = PARAMETERS.DAMAGE
	_knockback = PARAMETERS.KNOCKBACK
	scale = Vector2.ONE * PARAMETERS.SIZE


func _stop_for_duration(time: float) -> void:
	_stopped = true
	var timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.start(time)
	await timer.timeout
	_stopped = false
	timer.queue_free()


##### SIGNAL MANAGEMENT #####
func _on_body_entered(body):
	if GroupUtils.is_player(body) and current_owner != body and body.has_method("hit"):
		body.hit(PlayerHitData.new(_knockback * _direction, _damage, current_owner, _damage, parried, shielded, solid_collision))
	elif GroupUtils.is_static_obstacle(body) or GroupUtils.is_destructible_wall(body):
		solid_collision(body)
