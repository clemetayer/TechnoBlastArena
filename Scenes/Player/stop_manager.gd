extends Node

# manages the player stopping (for hitstops for example)

##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====
var _stopped := false

#==== ONREADY ====
@onready var paths := $"../Paths"
@onready var timer := $"Timer"
@onready var disable_damage_timer := $"DisableDamageTimer"


##### PUBLIC METHODS #####
func stop_for_duration(duration: float) -> void:
	if not _stopped:
		toggle_stop(true)
		timer.start(duration)


func toggle_stop(active: bool) -> void:
	var player = _get_player()
	player.toggle_movement(not active)
	# waits a bit before disabling the damage to allow multiple bullets to connect if needed (example : shotgun)
	if active:
		_start_disable_damage_delay()
	else:
		player.toggle_damage(not active)
	player.toggle_abilities(not active)
	_stopped = active


##### PROTECTED METHODS #####
func _get_player() -> Node2D:
	return paths.player_root


func _start_disable_damage_delay() -> void:
	if disable_damage_timer.is_stopped():
		disable_damage_timer.timeout.connect(
			func():
				_get_player().toggle_damage(not _stopped) # maybe in some cases the hitstop ends before this timeout, so we use _stopped as a failsafe
		)
		disable_damage_timer.start()


##### SIGNAL MANAGEMENT #####
func _on_timer_timeout() -> void:
	toggle_stop(false)
