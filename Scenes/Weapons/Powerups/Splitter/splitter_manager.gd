extends PowerupBase

# Manages the spawn of the splitter powerup

##### VARIABLES #####
#---- CONSTANTS -----
const SPLITTER_PATH := "res://Scenes/Weapons/Powerups/Splitter/splitter.tscn"
const MAX_SPLITTERS_ACTIVE := 2
const COOLDOWN_TIMER := 10.0 #s

#---- STANDARD -----
#==== PRIVATE ====
var _can_use_powerup := true
var _splitters_active := [] # splitters active for the player
var _splitter_cooldown_tween: Tween
var _init_ui_done := false # to update the ui on the first frame
var _runtime_utils := RuntimeUtils

#==== ONREADY ====
@onready var _splitter_load = load(SPLITTER_PATH)
@onready var onready_paths := {
	"cooldown_timer": $"CooldownTimer",
}


##### PROCESSING #####
# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(_delta):
	if not _init_ui_done:
		emit_signal("value_updated", 1.0)


##### PUBLIC METHODS #####
func use() -> void:
	if _can_use_powerup and active:
		if _splitters_active.size() >= MAX_SPLITTERS_ACTIVE:
			_remove_last_splitter()
		var powerup = _splitter_load.instantiate()
		powerup.global_position = self.global_position
		var game_root = _runtime_utils.get_game_root()
		if game_root != null and game_root.has_method("spawn_powerup"):
			powerup.connect("destroyed", _on_splitter_destroyed)
			game_root.spawn_powerup(powerup)
			_splitters_active.push_front(powerup)
		else:
			GSLogger.error("game root is null or does not contain the method %s" % "spawn_powerup")
		_can_use_powerup = false
		onready_paths.cooldown_timer.start(COOLDOWN_TIMER)
		_start_update_value_tween()


##### PROTECTED METHODS #####
func _remove_last_splitter() -> void:
	var splitter = _splitters_active.pop_back()
	splitter.queue_free()


func _start_update_value_tween() -> void:
	if _splitter_cooldown_tween != null:
		_splitter_cooldown_tween.kill()
	_splitter_cooldown_tween = create_tween()
	_splitter_cooldown_tween.tween_method(
		func(value): emit_signal("value_updated", value),
		0.0,
		1.0,
		COOLDOWN_TIMER,
	)


##### SIGNAL MANAGEMENT #####
func _on_cooldown_timer_timeout() -> void:
	_can_use_powerup = true


func _on_splitter_destroyed(splitter: Node2D) -> void:
	_splitters_active.erase(splitter)
