extends Control

# Controls and displays the time left of the match (and potentially some other funny things)

##### SIGNALS #####
signal time_over

##### VARIABLES #####
#---- CONSTANTS -----
const END_TEXT := "[wave amp=50.0 freq=5.0 connected=1]END[/wave]"
#---- STANDARD -----
#==== PRIVATE ====
var _start_time
var _end_time

#==== ONREADY ====
@onready var label := $"Label"


##### PROCESSING #####
# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(_delta):
	if _start_time != null and _end_time != null:
		var current_time = _get_current_time()
		if current_time >= _end_time:
			_time_over()
		else:
			_refresh_timer(current_time)


##### PUBLIC METHODS #####
# starts the timer for a specific duration (in seconds)
func start_timer(duration: int) -> void:
	_start_time = _get_current_time()
	_end_time = _start_time + duration * 1000.0


func reset_timer() -> void:
	_start_time = null
	_end_time = null


##### PROTECTED METHODS #####
func _time_over() -> void:
	label.text = END_TEXT
	_start_time = null
	_end_time = null
	emit_signal("time_over")


func _refresh_timer(current_time: int) -> void:
	var time_left = int((_end_time - current_time) / 1000)
	var seconds = time_left % 60
	var minutes = int(time_left / 60.0)
	label.text = "%02d:%02d" % [minutes, seconds]


func _get_current_time() -> int:
	return Time.get_ticks_msec()
