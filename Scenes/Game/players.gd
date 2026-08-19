extends CanvasLayer

# handles the communication between the player and the game root

##### SIGNALS #####
signal lives_updated(player_idx: int, new_value: int)
signal player_won
signal powerup_updated(player_idx: int, new_value)
signal movement_updated(player_idx: int, new_value)
signal game_message_triggered(message: String)

##### VARIABLES #####
#---- CONSTANTS -----
const PLAYER_SCENE_PATH := "res://Scenes/Player/player.tscn"
const RESPAWN_TIME := 1 # seconds

#---- STANDARD -----
#==== PRIVATE ====
var _players_data := { }
var _spawn_positions: Array
var _current_spawn_idx := 0
var _game_ending := false
var _players_game_over_idx := []

#==== ONREADY ====
@onready var root = $".."
@onready var tree = get_tree()


##### PUBLIC METHODS #####
func init_players_data(p_players_data: Dictionary) -> void:
	for player_idx in p_players_data.keys():
		var player_config = p_players_data[player_idx].config
		_players_data[player_idx] = {
			"config": player_config,
			"lives": p_players_data[player_idx].lives,
		}


func init_spawn_positions(spawn_positions: Array) -> void:
	_spawn_positions = spawn_positions
	_current_spawn_idx = 0


func toggle_players_truce(active: bool) -> void:
	for player_idx in _players_data.keys():
		get_player_instance(player_idx).toggle_truce(active)


func reset() -> void:
	_players_data = { }
	_players_game_over_idx = []
	clean_players()
	_game_ending = false


func clean_players() -> void:
	for player in get_children():
		player.queue_free()


func add_players() -> void:
	clean_players()
	for player_idx in _players_data.keys():
		_spawn_player(player_idx, _get_spawn_position_and_go_next())


func get_player_instance(idx: int) -> Node2D:
	return get_node("player_%d" % idx)


func get_player_config(idx: int) -> PlayerConfig:
	return _players_data[idx].config


func get_players_data() -> Dictionary:
	return _players_data


func get_ranks() -> Array:
	var ranks := []
	var players_data_array := _map_players_data_to_array()
	var remaining_players := players_data_array.filter(
		func(data):
			return data.lives > 0,
	)
	remaining_players = _handle_draws(remaining_players)
	remaining_players.sort_custom(
		func(a, b):
			return a.lives > b.lives,
	)
	ranks.append_array(
		remaining_players.map(
			func(data):
				return data.config,
		)
	)
	ranks.append_array(
		_players_game_over_idx.map(
			func(idx):
				return _players_data[idx].config,
		)
	)
	return ranks


##### PROTECTED METHODS #####
# converts the player data to an array, to make it easier to filter and sort
func _map_players_data_to_array() -> Array:
	var ret_array := []
	for player_idx in _players_data:
		ret_array.append(
			{
				"idx": player_idx,
				"config": _players_data[player_idx].config,
				"lives": _players_data[player_idx].lives,
			}
		)
	return ret_array


# TODO : for now sorts by player id for each draw, which is not great
func _handle_draws(remaining_players: Array) -> Array:
	var lives_dict := { }
	var ret_array := []
	for player_data in remaining_players:
		if lives_dict.has(player_data.lives):
			lives_dict[player_data.lives].append(player_data)
		else:
			lives_dict[player_data.lives] = [player_data]
	for lives_keys in lives_dict:
		lives_dict[lives_keys].sort_custom(
			func(a, b):
				return a.idx < b.idx,
		)
		ret_array.append_array(lives_dict[lives_keys])
	return ret_array


func _spawn_player(player_idx: int, spawn_position: Vector2) -> void:
	var player_instance = load(PLAYER_SCENE_PATH).instantiate()
	player_instance.PLAYER_ID = player_idx
	player_instance.name = "player_%d" % player_idx
	add_child(player_instance)
	player_instance.global_position = spawn_position
	player_instance.connect("killed", _on_player_killed)
	player_instance.connect("movement_updated", _on_player_movement_updated)
	player_instance.connect("powerup_updated", _on_player_powerup_updated)
	player_instance.connect("game_message_triggered", _on_player_game_message_triggered)


func _get_spawn_position_and_go_next() -> Vector2:
	var spawn_position = _spawn_positions[_current_spawn_idx]
	_current_spawn_idx = (_current_spawn_idx + 1) % _spawn_positions.size()
	return spawn_position


func _is_only_one_player_alive() -> bool:
	var players_alive := 0
	for player_idx in _players_data.keys():
		if _players_data[player_idx].lives > 0:
			players_alive += 1
	return players_alive <= 1


##### SIGNAL MANAGEMENT #####
func _on_player_killed(idx: int) -> void:
	if not _game_ending:
		_players_data[idx].lives -= 1
		emit_signal("lives_updated", idx, _players_data[idx].lives)
		if _players_data[idx].lives > 0:
			await tree.create_timer(RESPAWN_TIME).timeout
			_spawn_player(idx, _get_spawn_position_and_go_next())
		else:
			_players_game_over_idx.push_front(idx)
		if _is_only_one_player_alive():
			emit_signal("player_won")


func _on_player_movement_updated(player_id: int, value) -> void:
	emit_signal("movement_updated", player_id, value)


func _on_player_powerup_updated(player_id: int, value) -> void:
	emit_signal("powerup_updated", player_id, value)


func _on_player_game_message_triggered(id: int) -> void:
	if _players_data.has(id):
		emit_signal("game_message_triggered", _players_data[id].config.ELIMINATION_TEXT)
		return
	GSLogger.error("Error when triggering game message : %s" % [get_stack()])
