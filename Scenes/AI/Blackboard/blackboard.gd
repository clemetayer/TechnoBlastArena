extends Blackboard

class_name CommonBlackboard

# Common blackboard for all AIs to work

##### ENUMS #####
enum DIRECTION { LEFT = -1, NONE = 0, RIGHT = 1 }

##### VARIABLES #####
#---- CONSTANTS -----
const DESIRED_POSITION_KEY := "desired_position"
const FIRE_TRIGGERED_KEY := "fire_triggered"
const JUMP_KEY := "jump"
const LEVEL_BOUNDS_KEY := "level_bounds"
const MOVEMENT_BONUS_TRIGGERED_KEY := "movement_bonus_triggered"
const MOVEMENT_DIRECTION_KEY := "movement_direction"
const OPPONENTS_KEY := "opponents"
const PLAYER_KEY := "player"
const POWERUP_TRIGGERED_KEY := "powerup_triggered"
const PROJECTILES_KEY := "projectiles"
const RELATIVE_AIM_POSITION_KEY := "relative_aim_position"
const TARGET_KEY := "target"
const SHIELD_KEY := "shield"

#==== PUBLIC ====
var get_tree_callable: Callable = get_tree # mostly for test purposes, to stub the get_tree easily


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	_set_level_bounds()


func _process(_delta):
	_set_projectiles()
	_set_opponents()


##### PROTECTED METHODS #####
func _set_projectiles() -> void:
	set_value(PROJECTILES_KEY, get_tree_callable.call().get_nodes_in_group(GroupUtils.PROJECTILE_GROUP_NAME))


func _set_level_bounds() -> void:
	var level_bounds = get_tree_callable.call().get_nodes_in_group(GroupUtils.LEVEL_BOUNDS_GROUP_NAME)
	set_value(LEVEL_BOUNDS_KEY, level_bounds[0].get_bounds())


func _set_opponents() -> void:
	var players = get_tree_callable.call().get_nodes_in_group(GroupUtils.PLAYER_GROUP_NAME)
	var player = get_value(PLAYER_KEY)
	if is_instance_valid(player):
		players.erase(player)
	set_value(OPPONENTS_KEY, players)
