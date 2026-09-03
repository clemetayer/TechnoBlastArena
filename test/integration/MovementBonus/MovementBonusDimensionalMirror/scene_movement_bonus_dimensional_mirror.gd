extends Node2D

##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====
var _player_config: PlayerConfig

#==== ONREADY ====
@onready var player_spawn_position_node := $"PlayerSpawnPosition"

##### PUBLIC METHODS #####
func get_player_spawn_position() -> Vector2:
	return player_spawn_position_node.global_position


func get_player_config(_id: int) -> PlayerConfig:
	return _player_config


func set_player_config(player_config: PlayerConfig) -> void:
	_player_config = player_config


func add_player(player: Node2D) -> void:
	player.global_position = get_player_spawn_position()
	add_child(player)


func disable_truce() -> void:
	for player in get_tree().get_nodes_in_group("player"):
		player.toggle_truce(false)
