@abstract
class_name PowerupBase
extends Node2D

# Base class for the powerups

##### SIGNALS #####
@warning_ignore("UNUSED_SIGNAL")
signal value_updated(value)

##### VARIABLES #####
#---- STANDARD -----
#==== PUBLIC ====
var active := false
var player_paths: Node


##### PUBLIC METHODS #####
# to be overrided by children classes
@abstract func use() -> void


##### SIGNAL MANAGEMENT #####
func _on_player_abilities_toggled(p_active: bool) -> void:
	active = p_active
