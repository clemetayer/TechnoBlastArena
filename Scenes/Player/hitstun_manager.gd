extends Node2D

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
@onready var particles := $"HitstunTrailParticles"


##### PUBLIC METHODS #####
func stop_hitstun() -> void:
	paths.hitstun_timer.stop()
	_on_hitstun_timeout()


func set_trail_color(color: Color) -> void:
	var ligthened_color = color
	ligthened_color.s = 0.5
	particles.modulate = ligthened_color


##### SIGNAL MANAGEMENT #####
func _on_hitstun_timeout() -> void:
	hitstunned = false
	particles.emitting = false
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
	particles.emitting = true
