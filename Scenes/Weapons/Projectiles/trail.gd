extends Line2D

# traces a bullet path line

##### VARIABLES #####
#---- CONSTANTS -----
const SIZE := 10

#---- STANDARD -----
#==== ONREADY ====
@onready var add_point_timer := $AddPointTimer


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	reset()
	add_point_timer.start() # Weirdly, autostart does not work if the trail comes from a duplication (splitter), so it needs to be triggered manually


# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(_delta):
	# reset to origin since line2D uses the local coordinates
	global_position = Vector2.ZERO
	global_rotation = 0


##### PUBLIC METHODS #####
func reset() -> void:
	points = []


##### SIGNAL MANAGEMENT #####
func _on_add_point_timer_timeout() -> void:
	if get_point_count() >= SIZE:
		remove_point(0)
	add_point(get_parent().global_position)
