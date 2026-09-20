extends PowerupBase

# Manages the spawn of the splitter powerup
##### VARIABLES #####
#---- CONSTANTS -----
const SPLITTER_LOAD := preload("res://Scenes/Weapons/Powerups/Splitter/splitter.tscn")
const MAX_SPLITTERS_ACTIVE := 5
const MAX_ACTIONS := 3
const SPLITTER_GROUP_NAME := "splitter"

#---- STANDARD -----
#==== PRIVATE ====
var _init_ui_done := false # to update the ui on the first frame
var _runtime_utils := RuntimeUtils
var _actions_available := MAX_ACTIONS

#==== ONREADY ====
@onready var cooldown_timer := $"CooldownTimer"


##### PROCESSING #####
# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(_delta):
	if not _init_ui_done:
		value_updated.emit(_actions_available)


##### PUBLIC METHODS #####
func use() -> void:
	if active and _actions_available > 0:
		if _get_total_splitters() >= MAX_SPLITTERS_ACTIVE:
			_remove_last_splitter()
		var powerup = SPLITTER_LOAD.instantiate()
		powerup.global_position = self.global_position
		var game_root = _runtime_utils.get_game_root()
		if game_root != null and game_root.has_method("spawn_powerup"):
			game_root.spawn_powerup(powerup)
		else:
			GSLogger.error("game root is null or does not contain the method %s" % "spawn_powerup")
		cooldown_timer.start()
		_actions_available -= 1
		value_updated.emit(_actions_available)


##### PROTECTED METHODS #####
func _remove_last_splitter() -> void:
	get_tree().get_nodes_in_group(SPLITTER_GROUP_NAME)[0].queue_free()


func _get_total_splitters() -> int:
	return get_tree().get_nodes_in_group(SPLITTER_GROUP_NAME).size()


##### SIGNAL MANAGEMENT #####
func _on_cooldown_timer_timeout() -> void:
	_actions_available = min(_actions_available + 1, MAX_ACTIONS)
	value_updated.emit(_actions_available)
