extends Node

# Script that manages the game itself (slightly different from the game manager, which manages the game lobby)

##### SIGNALS #####
signal game_over(players_rank: Array)

##### VARIABLES #####
#---- CONSTANTS -----
const PLAYER_GAME_MESSAGE_DURATION := 1 #s

#---- STANDARD -----
#==== PRIVATE ====
var _full_screen_effects := FullScreenEffects
var _ranks := [] # stores the rank at the end of the game BEFORE the game end animation finishes playing

#==== ONREADY ====
@onready var players := $"Players"
@onready var level := $"Level"
@onready var background := $"Background"
@onready var camera := $"Camera"
@onready var projectiles := $"Projectiles"
@onready var powerups := $"Powerups"
@onready var ui := $"UI"
@onready var animation_player := $"AnimationPlayer"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	camera.enabled = false


##### PUBLIC METHODS #####
func init_level_data(p_level_data: LevelConfig) -> void:
	level.init_level_data(p_level_data)


func init_players_data(p_players_data: Dictionary) -> void:
	players.init_players_data(p_players_data)


func add_game_elements() -> void:
	level.add_level()
	players.init_spawn_positions(level.get_spawn_positions())
	players.add_players()
	camera.PLAYERS_ROOT_PATH = camera.get_path_to(players)
	background.add_background(level.get_background_path())


func init_game_elements(time: int) -> void:
	_full_screen_effects.toggle_active(true)
	ui.init_game_ui(players.get_players_data())
	ui.init_chronometer(time)
	ui.init_screen_game_message()
	camera.enabled = true
	_init_start_game_animation()


func spawn_powerup(powerup: Node) -> void:
	powerup.name = "powerup_%d" % powerups.get_child_count()
	powerups.add_child(powerup, true)


func spawn_projectile(projectile: Node) -> void:
	projectiles.call_deferred("add_child", projectile)


func toggle_players_truce(active: bool) -> void:
	players.toggle_players_truce(active)


func reset() -> void:
	players.reset()
	ui.reset()
	level.reset()
	background.reset()
	_clean_node_tree(projectiles)
	_clean_node_tree(powerups)
	camera.enabled = false
	_ranks = []


##### PROTECTED METHODS #####
func _init_start_game_animation() -> void:
	animation_player.play("start_game")


func _clean_node_tree(root: Node) -> void:
	for child in root.get_children():
		if is_instance_valid(child):
			child.queue_free()


func _end_game() -> void:
	animation_player.play("end_game")
	_ranks = players.get_ranks()


##### SIGNAL MANAGEMENT #####
func _on_ui_time_over() -> void:
	_end_game()


func _on_players_player_won() -> void:
	_end_game()


func _on_players_lives_updated(player_id: int, new_value: int) -> void:
	ui.update_lives(player_id, new_value)


func _on_players_movement_updated(player_id: int, value) -> void:
	ui.update_movement(player_id, value)


func _on_players_powerup_updated(player_id: int, value) -> void:
	ui.update_powerup(player_id, value)


func _on_players_game_message_triggered(message: String) -> void:
	ui.display_message(message, false)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "end_game":
		game_over.emit(_ranks)
