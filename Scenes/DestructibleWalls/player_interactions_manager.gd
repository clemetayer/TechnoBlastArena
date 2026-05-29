extends Node

# handles the player interactions with the destructible wall

##### VARIABLES #####
#---- CONSTANTS -----
const WALL_HIT_STOP_TIME := 1.0 #s

#---- STANDARD -----
#==== ONREADY ====
@onready var onready_paths := {
	"audio_manager": $"../AudioManager",
	"health_manager": $"../HealthManager",
	"visual_effects_manager": $"../VisualEffectsManager",
	"player_wall_hit_stop_timers": $"PlayerWallHitStopTimers",
}


##### PUBLIC METHODS #####
func handle_player_hit(player: Node2D, hit_velocity: Vector2, bounce_direction: Vector2, bounce_force: float) -> void:
	onready_paths.audio_manager.play_hit()
	onready_paths.audio_manager.play_trebble(onready_paths.health_manager.get_health_ratio())
	onready_paths.visual_effects_manager.shake_camera_by_velocity(hit_velocity.x if bounce_direction.x != 0 else hit_velocity.y)
	player.stop_for_duration(WALL_HIT_STOP_TIME)
	_start_freeze_timeout_timer_for_player(player, bounce_direction, bounce_force)


func kill_player(player: Node2D) -> void:
	player.kill()


##### PROTECTED METHODS #####
func _start_freeze_timeout_timer_for_player(player: Node2D, bounce_direction: Vector2, bounce_force: float) -> void:
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = WALL_HIT_STOP_TIME
	timer.connect("timeout", func(): _on_freeze_player_timer_timeout(timer, player, bounce_direction, bounce_force))
	onready_paths.player_wall_hit_stop_timers.add_child(timer)
	timer.start()


##### SIGNAL MANAGEMENT #####
func _on_freeze_player_timer_timeout(timer_to_free: Timer, player: Node2D, bounce_direction: Vector2, bounce_force: float) -> void:
	onready_paths.audio_manager.stop_trebble()
	if is_instance_valid(player):
		player.override_velocity(bounce_direction * bounce_force)
	timer_to_free.queue_free()
