extends Node

# small utilitary class that only contains a reference to specific player nodes

##### VARIABLES #####
#---- EXPORTS -----
@export var PLAYER_ROOT_PATH: NodePath
@export var DAMAGE_LABEL_PATH: NodePath
@export var SHIELD_PATH: NodePath
@export var BOUNCE_AREA_PATH: NodePath
@export var POWERUP_COOLDOWN_PATH: NodePath
@export var INPUT_SYNCHRONIZER_PATH: NodePath
@export var HITSTUN_TIMER_PATH: NodePath
@export var ANIMATION_PLAYER_PATH: NodePath
@export var FLOOR_DETECTOR_PATH: NodePath
@export var SPRITES_PATH: NodePath
@export var ACTION_MANAGER_PATH: NodePath
@export var INIT_PATH: NodePath
@export var HITSTUN_MANAGER: NodePath
@export var STOP_MANAGER: NodePath
@export var CROSSHAIR_PATH: NodePath
@export var AUDIO_MANAGER_PATH: NodePath
@export var DEATH_MANAGER_PATH: NodePath
@export var APPEAR_ELEMENTS: NodePath
@export var PREDICT_BOUNCES_RAY_CAST: NodePath
@export var HIT_PARTICLES: NodePath

#---- STANDARD -----
#==== PUBLIC ====
var primary_weapon
var movement_bonus
var powerup_manager
var action_handler
@onready var player_root := get_node(PLAYER_ROOT_PATH)
@onready var damage_label := get_node(DAMAGE_LABEL_PATH)
@onready var shield := get_node(SHIELD_PATH)
@onready var bounce_area := get_node(BOUNCE_AREA_PATH)
@onready var powerup_cooldown := get_node(POWERUP_COOLDOWN_PATH)
@onready var input_synchronizer := get_node(INPUT_SYNCHRONIZER_PATH)
@onready var hitstun_timer := get_node(HITSTUN_TIMER_PATH)
@onready var animation_player := get_node(ANIMATION_PLAYER_PATH)
@onready var floor_detector := get_node(FLOOR_DETECTOR_PATH)
@onready var sprites := get_node(SPRITES_PATH)
@onready var action_manager := get_node(ACTION_MANAGER_PATH)
@onready var init := get_node(INIT_PATH)
@onready var hitstun_manager := get_node(HITSTUN_MANAGER)
@onready var stop_manager := get_node(STOP_MANAGER)
@onready var crosshair := get_node(CROSSHAIR_PATH)
@onready var audio_manager := get_node(AUDIO_MANAGER_PATH)
@onready var death_manager := get_node(DEATH_MANAGER_PATH)
@onready var appear_elements := get_node(APPEAR_ELEMENTS)
@onready var predict_bounces_ray_cast := get_node(PREDICT_BOUNCES_RAY_CAST)
@onready var hit_particles := get_node(HIT_PARTICLES)
