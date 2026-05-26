extends Node

# manages the player stopping (for hitstops for example)

##### SIGNALS #####
# Node signals

##### ENUMS #####
# enumerations

##### VARIABLES #####
#---- CONSTANTS -----
# const constant := 10 # Optionnal comment

#---- EXPORTS -----
# @export var EXPORT_NAME := 10.0 # Optionnal comment

#---- STANDARD -----
#==== PUBLIC ====
# var public_var # Optionnal comment

#==== PRIVATE ====
var _stopped := false

#==== ONREADY ====
@onready var paths := $"../Paths"
@onready var timer := $"Timer"


##### PROCESSING #####
# Called when the object is initialized.
func _init():
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(_delta):
	pass


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
