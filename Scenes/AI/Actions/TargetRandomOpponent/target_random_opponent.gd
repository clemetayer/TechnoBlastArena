@tool
class_name ActionTargetRandomOpponent
extends ActionLeaf

# Action to target a random opponent

##### VARIABLES #####
#---- CONSTANTS -----
const REFRESH_TARGET_AFTER_KILL_DELAY := 0.1

#---- EXPORTS -----
@export var SELECT_NEW_TARGET_DELAY := 10.0

#---- STANDARD -----
#==== PRIVATE ====
var _search_new_target := true
var _search_new_target_after_kill := false
var _select_new_target_timer: Timer
var _refresh_target_after_kill_timer: Timer


# Called when the node enters the scene tree for the first time.
##### PROCESSING #####
func _ready():
	_select_new_target_timer = Timer.new()
	_select_new_target_timer.autostart = true
	_select_new_target_timer.wait_time = SELECT_NEW_TARGET_DELAY
	_select_new_target_timer.timeout.connect(_on_search_new_target_timeout)
	add_child(_select_new_target_timer)
	_refresh_target_after_kill_timer = Timer.new()
	_refresh_target_after_kill_timer.one_shot = true
	_refresh_target_after_kill_timer.wait_time = REFRESH_TARGET_AFTER_KILL_DELAY
	_refresh_target_after_kill_timer.timeout.connect(_on_refresh_target_after_kill_timeout)
	add_child(_refresh_target_after_kill_timer)


func tick(_actor: Node, blackboard: Blackboard) -> int:
	if not blackboard is CommonBlackboard:
		return FAILURE
	if _search_new_target:
		_select_target(blackboard)
	elif _search_new_target_after_kill:
		_select_target_after_kill(blackboard)
	return SUCCESS


##### PROTECTED METHODS #####
func _select_target(blackboard: Blackboard) -> void:
	_select_random_target(blackboard)
	_search_new_target = false


func _select_target_after_kill(blackboard: Blackboard) -> void:
	_select_random_target(blackboard)
	_search_new_target_after_kill = false
	if not is_instance_valid(blackboard.get_value(CommonBlackboard.TARGET_KEY)):
		_refresh_target_after_kill_timer.start()


func _select_random_target(blackboard: CommonBlackboard) -> void:
	var target = blackboard.get_value(CommonBlackboard.TARGET_KEY)
	if is_instance_valid(target):
		target.tree_exited.disconnect(_on_current_target_tree_exited)
	var opponents = blackboard.get_value(CommonBlackboard.OPPONENTS_KEY)
	if opponents.is_empty():
		_refresh_target_after_kill_timer.start()
		return
	target = opponents.pick_random()
	if is_instance_valid(target):
		target.tree_exited.connect(_on_current_target_tree_exited)
		blackboard.set_value(CommonBlackboard.TARGET_KEY, target)


##### SIGNAL MANAGEMENT #####
func _on_search_new_target_timeout() -> void:
	_search_new_target = true


func _on_refresh_target_after_kill_timeout() -> void:
	_search_new_target_after_kill = true


func _on_current_target_tree_exited() -> void:
	_refresh_target_after_kill_timer.start()
