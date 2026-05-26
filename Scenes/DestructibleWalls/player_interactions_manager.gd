extends Node

# handles the player interactions with the destructible wall

##### VARIABLES #####
#---- CONSTANTS -----
const WALL_BREAK_KNOCKBACK_STRENGTH := 10000

#---- STANDARD -----
#==== ONREADY ====
@onready var onready_paths := {
	"audio_manager": $"../AudioManager",
	"health_manager": $"../HealthManager",
}


##### PUBLIC METHODS #####
func handle_player_hit(player: Node2D, bounce_direction: Vector2, bounce_force: float) -> void:
	pass


func kill_player(player: Node2D) -> void:
	player.kill()

##### PROTECTED METHODS #####

##### SIGNAL MANAGEMENT #####
