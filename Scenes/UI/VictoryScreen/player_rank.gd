@tool
extends Panel
# shows the player rank

##### VARIABLES #####
#---- CONSTANTS -----
const RTL_TEXT := "[wave amp=75.0 freq=6 connected=1]#%d[/wave]"
const LABEL_TEXT := "#%d"
const THEME_VARIATION_NAME := "%sPlayerRank%d"

#---- EXPORTS -----
@export var PARAMETERS: PlayerRankParameters = load(
	"res://Scenes/UI/VictoryScreen/RankParameters/rank_1.tres"
)
@export var RANK := 1

#---- STANDARD -----
#==== ONREADY ====
@onready var rank_rtl := $"MarginContainer/VBoxContainer/RankRTL"
@onready var rank_label := $"MarginContainer/VBoxContainer/Rank"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	_load_rank_parameters()
	_set_rank_text()

##### PUBLIC METHODS #####
# Methods that are intended to be "visible" to other nodes or scripts
# func public_method(arg : int) -> void:
#     pass


##### PROTECTED METHODS #####
func _load_rank_parameters() -> void:
	custom_minimum_size = PARAMETERS.SIZE
	set_theme_type_variation(THEME_VARIATION_NAME % ["Panel", RANK])
	rank_rtl.set_theme_type_variation(THEME_VARIATION_NAME % ["RTL", RANK])
	rank_label.set_theme_type_variation(THEME_VARIATION_NAME % ["Label", RANK])
	rank_rtl.visible = PARAMETERS.WAVY_RANK_DISPLAY
	rank_label.visible = not PARAMETERS.WAVY_RANK_DISPLAY


func _set_rank_text() -> void:
	rank_rtl.text = RTL_TEXT % RANK
	rank_label.text = LABEL_TEXT % RANK
