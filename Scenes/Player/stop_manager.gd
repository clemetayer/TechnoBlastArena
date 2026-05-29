extends Node

# manages the player stopping (for hitstops for example)

##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====
var _stopped := false

#==== ONREADY ====
@onready var paths := $"../Paths"
@onready var timer := $"Timer"


##### PUBLIC METHODS #####
func stop_for_duration(duration: float) -> void:
	if not _stopped:
		toggle_stop(true)
		timer.start(duration)


func toggle_stop(active: bool) -> void:
	var player = _get_player()
	player.toggle_movement(not active)
	player.toggle_damage(not active)
	player.toggle_abilities(not active)
	_stopped = active


##### PROTECTED METHODS #####
func _get_player() -> Node2D:
	return paths.player_root


##### SIGNAL MANAGEMENT #####
func _on_timer_timeout() -> void:
	toggle_stop(false)
