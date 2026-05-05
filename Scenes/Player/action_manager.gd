extends Node

# Manages the triggers linked to player's actions

##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====
var _frozen: bool
var _action_handler_base = ActionHandlerBase

#==== ONREADY ====
@onready var onready_paths_node := $"../Paths"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	SceneUtils.connect("toggle_scene_freeze", _on_SceneUtils_toggle_scene_freeze)


# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(_delta):
	if not _frozen:
		_handle_actions()


##### PROTECTED METHODS #####
func _handle_actions() -> void:
	_handle_direction()
	_handle_aim()
	_handle_jump()
	_handle_fire()
	_handle_movement_bonus()
	_handle_shield()
	_handle_powerup()


func _handle_direction() -> void:
	var direction = Vector2.ZERO
	if _is_action_active(_action_handler_base.actions.LEFT):
		direction.x -= 1
	if _is_action_active(_action_handler_base.actions.RIGHT):
		direction.x += 1
	if _is_action_active(_action_handler_base.actions.UP):
		direction.y -= 1
	if _is_action_active(_action_handler_base.actions.DOWN):
		direction.y += 1
	onready_paths_node.player_root.direction = direction


func _handle_aim() -> void:
	var relative_aim_position = _get_relative_aim_position()
	onready_paths_node.primary_weapon.aim(relative_aim_position)
	onready_paths_node.sprites.aim(relative_aim_position)
	onready_paths_node.crosshair.position = relative_aim_position


func _handle_jump() -> void:
	onready_paths_node.player_root.jump_triggered = _is_action_active(_action_handler_base.actions.JUMP)


func _handle_fire() -> void:
	if _is_action_active(_action_handler_base.actions.FIRE):
		onready_paths_node.primary_weapon.fire()
		onready_paths_node.shield.disable_shield_after_firing()


func _handle_movement_bonus() -> void:
	if _is_action_just_active(_action_handler_base.actions.MOVEMENT_BONUS):
		onready_paths_node.movement_bonus.activate()


func _handle_shield() -> void:
	onready_paths_node.shield.toggle_shielding(_is_action_active(_action_handler_base.actions.SHIELD))


func _handle_powerup() -> void:
	if _is_action_just_active(_action_handler_base.actions.POWERUP):
		onready_paths_node.powerup_manager.use()


# mostly to improve readability
func _is_action_active(action: ActionHandlerBase.actions) -> bool:
	if onready_paths_node.input_synchronizer.action_states.has(action):
		return _action_handler_base.is_active(onready_paths_node.input_synchronizer.action_states.get(action))
	return false


# mostly to improve readability
func _is_action_just_active(action: ActionHandlerBase.actions) -> bool:
	if onready_paths_node.input_synchronizer.action_states.has(action):
		return _action_handler_base.is_just_active(onready_paths_node.input_synchronizer.action_states.get(action))
	return false


# mostly to improve readability
func _get_relative_aim_position() -> Vector2:
	return onready_paths_node.input_synchronizer.relative_aim_position


##### SIGNAL MANAGEMENT #####
func _on_SceneUtils_toggle_scene_freeze(value: bool) -> void:
	_frozen = value
