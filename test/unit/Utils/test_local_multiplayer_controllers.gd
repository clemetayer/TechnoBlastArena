extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var controllers


##### SETUP #####
func before_each():
	controllers = load("res://Utils/LocalMultiplayerControllers/local_multiplayer_controllers.gd").new()


##### TEARDOWN #####
func after_each():
	controllers.free()


##### TESTS #####
func test_action_devices_created_on_init():
	# then
	for action in controllers.ACTIONS_TO_MAP:
		for device in controllers.Devices.values():
			assert_true(
				InputMap.has_action(controllers.DEVICE_ACTION_FORMAT % [action, device]),
				"expected %s to be created"
				% [LocalMultiplayerControllers.DEVICE_ACTION_FORMAT % [action, device]],
			)
			assert_eq(
				InputMap.action_get_events(action),
				InputMap.action_get_events(
					LocalMultiplayerControllers.DEVICE_ACTION_FORMAT % [action, device]
				),
			)


var to_device_action_params := [
	[
		"jump",
		LocalMultiplayerControllers.DEVICE_ACTION_FORMAT
		% ["jump", LocalMultiplayerControllers.Devices.CONTROLLER_1],
	],
	["pause", "pause"],
]


func test_to_device_action(params = use_parameters(to_device_action_params)):
	# given
	var device = LocalMultiplayerControllers.Devices.CONTROLLER_1
	var action = params[0]
	var expected = params[1]
	# when
	var result = controllers.to_device_action(action, device)
	# then
	assert_eq(result, expected)
