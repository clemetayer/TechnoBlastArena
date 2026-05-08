extends Node

# Manages the histsun

##### VARIABLES #####
#---- CONSTANTS -----
const MAX_HITSTUN_TIME := 3 # s
const MAX_HITSTUN_DAMAGE := 999 # damage points

#---- STANDARD -----
#==== PUBLIC ====
var hitstunned := false

#==== ONREADY ====
@onready var paths := $"../Paths"


##### PUBLIC METHODS #####
func stop_hitstun() -> void:
	if hitstunned:
		paths.hitstun_timer.stop()
		_on_hitstun_timeout()


##### SIGNAL MANAGEMENT #####
func _on_hitstun_timeout() -> void:
	hitstunned = false
	paths.bounce_area.toggle_active(false)
	paths.animation_player.stop()
	paths.animation_player.play("RESET")


func _on_player_damage_received(_old_damage: float, new_damage: float, _knockback: Vector2) -> void:
	var x = min(MAX_HITSTUN_DAMAGE, new_damage) / MAX_HITSTUN_DAMAGE
	var time = StaticUtils.cubic_ease_out(x) * MAX_HITSTUN_TIME
	paths.hitstun_timer.start(time)
	paths.animation_player.play("hitstun")
	paths.bounce_area.toggle_active(true)
	hitstunned = true
