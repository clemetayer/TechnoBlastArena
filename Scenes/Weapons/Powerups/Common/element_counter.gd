extends VBoxContainer
# shows dots that can be decreased over time (for instance to show the amount of time a powerup can be triggered)

##### SIGNALS #####
signal empty

##### VARIABLES #####
#---- CONSTANTS -----
const CIRCLE_TEXTURE_LOAD := preload("res://Scenes/Weapons/Powerups/Common/circle_texture.tscn")

#---- EXPORTS -----
@export var BASE_AMOUNT: int


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	_clear()
	for child_idx in range(BASE_AMOUNT):
		add_child(CIRCLE_TEXTURE_LOAD.instantiate())


##### PUBLIC METHODS #####
func decrease() -> void:
	if get_child_count() <= 1:
		empty.emit()
		queue_free()
	get_child(0).queue_free()


##### PROTECTED METHODS #####
func _clear() -> void:
	for child in get_children():
		child.queue_free()
