extends Node

# Script that manages the game itself (slightly different from the game manager, which manages the game lobby)

##### SIGNALS #####
signal game_over

##### VARIABLES #####
#---- CONSTANTS -----
const PLAYER_GAME_MESSAGE_DURATION := 1 #s

#---- STANDARD -----
#==== PRIVATE ====
var _full_screen_effects := FullScreenEffects

#==== ONREADY ====
@onready var onready_paths := {
	"players": $"Players",
	"level": $"Level",
	"background": $"Background",
	"camera": $"Camera",
	"projectiles": $"Projectiles",
	"powerups": $"Powerups",
	"ui": $"UI",
	"animation_player": $"AnimationPlayer",
}


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	onready_paths.camera.enabled = false


##### PUBLIC METHODS #####
func init_level_data(p_level_data: LevelConfig) -> void:
	onready_paths.level.init_level_data(p_level_data)


func init_players_data(p_players_data: Dictionary) -> void:
	onready_paths.players.init_players_data(p_players_data)


func add_game_elements() -> void:
	onready_paths.level.add_level()
	onready_paths.players.init_spawn_positions(onready_paths.level.get_spawn_positions())
	onready_paths.players.add_players()
	onready_paths.camera.PLAYERS_ROOT_PATH = onready_paths.camera.get_path_to(onready_paths.players)
	onready_paths.background.add_background(onready_paths.level.get_background_path())


func init_game_elements(time: int) -> void:
	_full_screen_effects.toggle_active(true)
	onready_paths.ui.init_game_ui(onready_paths.players.get_players_data())
	onready_paths.ui.init_chronometer(time)
	onready_paths.ui.init_screen_game_message()
	onready_paths.camera.enabled = true
	_init_start_game_animation()


func spawn_powerup(powerup: Node) -> void:
	powerup.name = "powerup_%d" % onready_paths.powerups.get_child_count()
	onready_paths.powerups.call_deferred("add_child", powerup, true)


func spawn_projectile(projectile: Node) -> void:
	onready_paths.projectiles.call_deferred("add_child", projectile, true)


func toggle_players_truce(active: bool) -> void:
	onready_paths.players.toggle_players_truce(active)


func reset() -> void:
	onready_paths.players.reset()
	onready_paths.ui.reset()
	onready_paths.level.reset()
	onready_paths.background.reset()
	_clean_node_tree(onready_paths.projectiles)
	_clean_node_tree(onready_paths.powerups)
	onready_paths.camera.enabled = false


##### PROTECTED METHODS #####
func _init_start_game_animation() -> void:
	onready_paths.animation_player.play("start_game")


func _clean_node_tree(root: Node) -> void:
	for child in root.get_children():
		if is_instance_valid(child):
			child.queue_free()


func _end_game() -> void:
	onready_paths.animation_player.play("end_game")


##### SIGNAL MANAGEMENT #####
func _on_ui_time_over() -> void:
	_end_game()


func _on_players_player_won() -> void:
	_end_game()


func _on_players_lives_updated(player_id: int, new_value: int) -> void:
	onready_paths.ui.update_lives(player_id, new_value)


func _on_players_movement_updated(player_id: int, value) -> void:
	onready_paths.ui.update_movement(player_id, value)


func _on_players_powerup_updated(player_id: int, value) -> void:
	onready_paths.ui.update_powerup(player_id, value)


func _on_players_game_message_triggered(message: String) -> void:
	onready_paths.ui.display_message(message, false)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "end_game":
		emit_signal("game_over")
