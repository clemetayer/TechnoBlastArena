extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var action_manager
var action_handler


##### SETUP #####
func before_each():
	action_manager = partial_double(load("res://Scenes/Player/action_manager.gd")).new()
	action_handler = StaticActionHandler.get_handler(StaticActionHandler.handlers.RECORD)
	action_manager._action_handler_base = action_handler


##### TEARDOWN #####
func after_each():
	action_handler.free()


##### TESTS #####
func test_handle_actions():
	# given
	stub(action_manager, "_handle_direction").to_do_nothing()
	stub(action_manager, "_handle_aim").to_do_nothing()
	stub(action_manager, "_handle_jump").to_do_nothing()
	stub(action_manager, "_handle_fire").to_do_nothing()
	stub(action_manager, "_handle_movement_bonus").to_do_nothing()
	stub(action_manager, "_handle_shield").to_do_nothing()
	stub(action_manager, "_handle_powerup").to_do_nothing()
	# when
	action_manager._handle_actions()
	# then
	assert_called(action_manager, "_handle_direction")
	assert_called(action_manager, "_handle_aim")
	assert_called(action_manager, "_handle_jump")
	assert_called(action_manager, "_handle_fire")
	assert_called(action_manager, "_handle_movement_bonus")
	assert_called(action_manager, "_handle_shield")
	assert_called(action_manager, "_handle_powerup")


var handle_direction_params := [
	[ActionHandlerBase.actions.LEFT, Vector2(-1, 0)],
	[ActionHandlerBase.actions.RIGHT, Vector2(1, 0)],
	[ActionHandlerBase.actions.UP, Vector2(0, -1)],
	[ActionHandlerBase.actions.DOWN, Vector2(0, 1)],
]


func test_handle_direction(params = use_parameters(handle_direction_params)):
	# given
	stub(action_manager, "_is_action_active").to_return(false)
	stub(action_manager, "_is_action_active").when_passed(params[0]).to_return(true)
	var player_root = load("res://Scenes/Player/player.gd").new()
	var paths = load("res://Scenes/Player/paths.gd").new()
	paths.player_root = player_root
	action_manager.paths = paths
	# when
	action_manager._handle_direction()
	# then
	assert_eq(player_root.direction, params[1])
	# cleanup
	player_root.free()
	paths.free()


func test_handle_aim():
	# given
	var primary_weapon = double(load("res://Scenes/Weapons/Primary/Revolver/revolver.gd")).new()
	stub(primary_weapon, "aim").to_do_nothing()
	var sprites = double(load("res://Scenes/Player/sprites.gd")).new()
	stub(sprites, "aim").to_do_nothing()
	var crosshair = load("res://Scenes/Weapons/Primary/crosshair.gd").new()
	var paths = load("res://Scenes/Player/paths.gd").new()
	paths.crosshair = crosshair
	paths.primary_weapon = primary_weapon
	paths.sprites = sprites
	action_manager.paths = paths
	stub(action_manager, "_get_relative_aim_position").to_return(Vector2.RIGHT)
	# when
	action_manager._handle_aim()
	# then
	assert_called(primary_weapon, "aim", [Vector2.RIGHT])
	assert_called(sprites, "aim", [Vector2.RIGHT])
	assert_eq(crosshair.position, Vector2.RIGHT)
	# cleanup
	crosshair.free()
	paths.free()


var handle_jump_params := [
	[true],
	[false],
]


func test_handle_jump(params = use_parameters(handle_jump_params)):
	# given
	var player_root = load("res://Scenes/Player/player.gd").new()
	var paths = load("res://Scenes/Player/paths.gd").new()
	paths.player_root = player_root
	action_manager.paths = paths
	stub(action_manager, "_is_action_active").to_return(params[0])
	# when
	action_manager._handle_jump()
	# then
	assert_eq(player_root.jump_triggered, params[0])
	# cleanup
	player_root.free()
	paths.free()


var handle_fire_params := [
	[true],
	[false],
]


func test_handle_fire(params = use_parameters(handle_fire_params)):
	# given
	stub(action_manager, "_is_action_active").to_return(params[0])
	var primary_weapon = double(load("res://Scenes/Weapons/Primary/Revolver/revolver.gd")).new()
	stub(primary_weapon, "fire").to_do_nothing()
	var shield = double(load("res://Scenes/Player/shield.gd")).new()
	stub(shield, "toggle_firing_disable").to_do_nothing()
	var paths = load("res://Scenes/Player/paths.gd").new()
	paths.primary_weapon = primary_weapon
	paths.shield = shield
	action_manager.paths = paths
	# when
	action_manager._handle_fire()
	# then
	assert_called(shield, "toggle_firing_disable", [params[0]])
	if params[0]:
		assert_called(primary_weapon, "fire")
	else:
		assert_not_called(primary_weapon, "fire")
	# cleanup
	paths.free()


var handle_movement_params := [
	[true],
	[false],
]


func test_handle_movement_bonus(params = use_parameters(handle_movement_params)):
	# given
	stub(action_manager, "_is_action_just_active").to_return(params[0])
	var movement_bonus = double(load("res://Scenes/Movement/MovementBonusDash/movement_bonus_dash.gd")).new()
	stub(movement_bonus, "activate").to_do_nothing()
	var paths = load("res://Scenes/Player/paths.gd").new()
	paths.movement_bonus = movement_bonus
	action_manager.paths = paths
	# when
	action_manager._handle_movement_bonus()
	# then
	if params[0]:
		assert_called(movement_bonus, "activate")
	else:
		assert_not_called(movement_bonus, "activate")
	# cleanup
	paths.free()


var handle_shield_params := [
	[true],
	[false],
]


func test_handle_shield(params = use_parameters(handle_shield_params)):
	# given
	stub(action_manager, "_is_action_active").to_return(params[0])
	stub(action_manager, "_is_action_just_active").to_return(false)
	var shield = double(load("res://Scenes/Player/shield.gd")).new()
	stub(shield, "toggle_shielding").to_do_nothing()
	stub(shield, "activate_parry").to_do_nothing()
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	paths.shield = shield
	action_manager.paths = paths
	# when
	action_manager._handle_shield()
	# then
	assert_called(shield, "toggle_shielding", [params[0]])
	assert_not_called(shield, "activate_parry")


func test_handle_parry():
	# given
	stub(action_manager, "_is_action_active").to_return(true)
	stub(action_manager, "_is_action_just_active").to_return(true)
	var shield = double(load("res://Scenes/Player/shield.gd")).new()
	stub(shield, "toggle_shielding").to_do_nothing()
	stub(shield, "activate_parry").to_do_nothing()
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	paths.shield = shield
	action_manager.paths = paths
	# when
	action_manager._handle_shield()
	# then
	assert_called(shield, "toggle_shielding", [true])
	assert_called(shield, "activate_parry")


var handle_powerup_params := [
	[true],
	[false],
]


func test_handle_powerup(params = use_parameters(handle_powerup_params)):
	# given
	stub(action_manager, "_is_action_just_active").to_return(params[0])
	var powerup_manager = double(load("res://Scenes/Weapons/Powerups/Splitter/splitter_manager.gd")).new()
	stub(powerup_manager, "use").to_do_nothing()
	var paths = load("res://Scenes/Player/paths.gd").new()
	paths.powerup_manager = powerup_manager
	action_manager.paths = paths
	# when
	action_manager._handle_powerup()
	# then
	if params[0]:
		assert_called(powerup_manager, "use")
	else:
		assert_not_called(powerup_manager, "use")
	# cleanup
	paths.free()


var is_action_active_params = [
	[true],
	[false],
]


func test_is_action_active(params = use_parameters(is_action_active_params)):
	# given
	var paths = load("res://Scenes/Player/paths.gd").new()
	var input_synchronizer = load("res://Scenes/Player/input_synchronizer.gd").new()
	var action_states = {
		ActionHandlerBase.actions.JUMP: ActionHandlerBase.states.ACTIVE if params[0] else ActionHandlerBase.states.INACTIVE,
	}
	input_synchronizer.action_states = action_states
	paths.input_synchronizer = input_synchronizer
	action_manager.paths = paths
	# when
	var res = action_manager._is_action_active(ActionHandlerBase.actions.JUMP)
	# then
	assert_eq(res, params[0])
	# cleanup
	input_synchronizer.free()
	paths.free()


var is_action_just_active_params = [
	[true],
	[false],
]


func test_is_action_just_active(params = use_parameters(is_action_just_active_params)):
	# given
	var paths = load("res://Scenes/Player/paths.gd").new()
	var input_synchronizer = load("res://Scenes/Player/input_synchronizer.gd").new()
	var action_states = {
		ActionHandlerBase.actions.JUMP: ActionHandlerBase.states.JUST_ACTIVE if params[0] else ActionHandlerBase.states.INACTIVE,
	}
	input_synchronizer.action_states = action_states
	paths.input_synchronizer = input_synchronizer
	action_manager.paths = paths
	# when
	var res = action_manager._is_action_active(ActionHandlerBase.actions.JUMP)
	# then
	assert_eq(res, params[0])
	# cleanup
	input_synchronizer.free()
	paths.free()


func test_get_relative_aim_position():
	# given
	var paths = load("res://Scenes/Player/paths.gd").new()
	var input_synchronizer = load("res://Scenes/Player/input_synchronizer.gd").new()
	input_synchronizer.relative_aim_position = Vector2.UP
	paths.input_synchronizer = input_synchronizer
	action_manager.paths = paths
	# when
	var res = action_manager._get_relative_aim_position()
	# then
	assert_eq(res, Vector2.UP)
	# cleanup
	input_synchronizer.free()
	paths.free()
