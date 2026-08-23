extends Control
# handles the victory screen after a multiplayer match

##### SIGNALS #####
signal next

##### VARIABLES #####
#---- STANDARD -----
#==== ONREADY ====
@onready var player_grid := $"MarginContainer/VBoxContainer/PlayerGrid"
@onready var next_button := $"MarginContainer/VBoxContainer/GameConfig/NextButton"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


##### PUBLIC METHODS #####
func show_victory(players: Array) -> void:
	show()
	for player_rank_idx in range(player_grid.get_child_count()):
		var player_rank = player_grid.get_child(player_rank_idx)
		if player_rank_idx < players.size():
			var player: PlayerConfig = players[player_rank_idx]
			player_rank.set_player_data(player.SPRITE_CUSTOMIZATION, player.PLAYER_NAME)
			player_rank.show()
		else:
			player_rank.hide()


func _on_next_button_pressed() -> void:
	next.emit()
