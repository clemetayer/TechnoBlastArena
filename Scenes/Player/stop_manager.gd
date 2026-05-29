extends Node

# manages the player stopping (for hitstops for example)

##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====
var _stopped := false

#==== ONREADY ====
@onready var paths := $"../Paths"
@onready var timer := $"Timer"
@onready var shaker := $"ShakerComponent2D"


##### PUBLIC METHODS #####
func stop_for_duration(duration: float, with_shake := false) -> void:
	if not _stopped:
		toggle_stop(true, with_shake)
		timer.start(duration)
		await timer.timeout
		toggle_stop(false, with_shake)


func toggle_stop(active: bool, with_shake := false) -> void:
	var player = _get_player()
	player.toggle_movement(not active)
	player.toggle_damage(not active)
	player.toggle_abilities(not active)
	_stopped = active
	if not (with_shake and is_instance_valid(shaker)):
		return
	if active:
		shaker.play_shake()
		return
	shaker.stop_shake()


##### PROTECTED METHODS #####
func _get_player() -> Node2D:
	return paths.player_root
