extends Sprite2D
# dimensional mirror visual effect

##### VARIABLES #####
#---- CONSTANTS -----
const ROTATION_SPEED := 6 * PI # rad/s
const APPEAR_IN_ANIMATION := "In"
const APPEAR_OUT_ANIMATION := "Out"

#---- STANDARD -----
#==== ONREADY ====
@onready var animation_player := $"AnimationPlayer"


##### PROCESSING #####
# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(delta):
	rotation = fmod(rotation + ROTATION_SPEED * delta, 2 * PI)


##### PUBLIC METHODS #####
func appear(is_in: bool, appear_position: Vector2) -> void:
	global_position = appear_position
	animation_player.play(APPEAR_IN_ANIMATION if is_in else APPEAR_OUT_ANIMATION)
	await animation_player.animation_finished
	queue_free()
