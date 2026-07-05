extends CanvasLayer

# Manages the UI within the game

##### SIGNALS #####
signal time_over

##### VARIABLES #####
#---- CONSTANTS -----
const PLAYER_GAME_MESSAGE_DURATION := 1 #s

#---- STANDARD -----
#==== ONREADY ====
@onready var game_ui := $"PlayersDataUi"
@onready var chronometer := $"Chronometer"
@onready var screen_message := $"ScreenGameMessage"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	game_ui.hide()
	chronometer.hide()
	screen_message.hide()


##### PUBLIC METHODS #####
func init_game_ui(p_players_data: Dictionary) -> void:
	game_ui.clean()
	for player_idx in p_players_data.keys():
		game_ui.add_player(player_idx, p_players_data[player_idx].config, p_players_data[player_idx].lives)
		game_ui.update_lives(player_idx, p_players_data[player_idx].lives)
	game_ui.show()


func init_chronometer(game_time: float) -> void:
	chronometer.start_timer(game_time)
	chronometer.show()


func init_screen_game_message() -> void:
	screen_message.init()
	screen_message.show()


func update_movement(player_id: int, value) -> void:
	game_ui.update_movement(player_id, value)


func update_powerup(player_id: int, value) -> void:
	game_ui.update_powerup(player_id, value)


func update_lives(idx: int, lives: int) -> void:
	game_ui.update_lives(idx, lives)


func display_message(message: String, display_all_characters: bool = false) -> void:
	screen_message.display_message(message, PLAYER_GAME_MESSAGE_DURATION, display_all_characters)


func reset() -> void:
	game_ui.clean()
	game_ui.hide()
	chronometer.hide()
	screen_message.hide()


##### SIGNAL MANAGEMENT #####
func _on_chronometer_time_over() -> void:
	time_over.emit()
