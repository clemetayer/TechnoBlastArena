extends CanvasLayer

# Manages the UI within the game

##### SIGNALS #####
signal time_over

##### VARIABLES #####
#---- CONSTANTS -----
const PLAYER_GAME_MESSAGE_DURATION := 1 #s

#---- STANDARD -----
#==== PUBLIC ====
var _pause_enabled := false

#==== ONREADY ====
@onready var game_ui := $"PlayersDataUi"
@onready var chronometer := $"Chronometer"
@onready var screen_message := $"ScreenGameMessage"
@onready var pause_menu := $"PauseMenu"
@onready var options_menu := $"OptionsMenu"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	reset()


# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(_delta):
	if _pause_enabled and (Input.is_action_just_pressed("pause")):
		pause_menu.pause()


##### PUBLIC METHODS #####
func init_game_ui(p_players_data: Dictionary) -> void:
	game_ui.clean()
	_pause_enabled = true
	for player_idx in p_players_data.keys():
		game_ui.add_player(
			player_idx,
			p_players_data[player_idx].config,
			p_players_data[player_idx].lives,
		)
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
	_pause_enabled = false
	game_ui.clean()
	game_ui.hide()
	chronometer.hide()
	chronometer.reset_timer()
	screen_message.hide()


func toggle_pause_enabled(enabled: bool) -> void:
	_pause_enabled = enabled


##### SIGNAL MANAGEMENT #####
func _on_chronometer_time_over() -> void:
	time_over.emit()


func _on_pause_menu_options_triggered() -> void:
	pause_menu.hide()
	options_menu.show()


func _on_options_menu_return_triggered() -> void:
	options_menu.hide()
	pause_menu.show()
