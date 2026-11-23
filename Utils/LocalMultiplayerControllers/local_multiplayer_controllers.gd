extends Object
# Singleton class to setup multiplayer actions for each controlers

##### ENUMS #####
enum Devices {
	KEYBOARD,
	CONTROLLER_1,
	CONTROLLER_2,
	CONTROLLER_3,
	CONTROLLER_4,
}

##### VARIABLES #####
#---- CONSTANTS -----
const DEVICE_ACTION_FORMAT := "%s_%d"
const ACTIONS_TO_MAP := [
	"up",
	"down",
	"left",
	"right",
	"jump",
	"fire",
	"movement_bonus",
	"shield",
	"powerup",
]


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _init():
	_create_devices_actions()


##### PUBLIC METHODS #####
func to_device_action(action: String, device: Devices) -> String:
	if action in ACTIONS_TO_MAP:
		return DEVICE_ACTION_FORMAT % [action, device]
	return action


##### PROTECTED METHODS #####
func _create_devices_actions() -> void:
	for action in ACTIONS_TO_MAP:
		for device in Devices.values():
			var device_action = to_device_action(action, device)
			InputMap.add_action(device_action)
			copy_action_events(action, device_action)


func copy_action_events(source: String, destination: String) -> void:
	var source_events = InputMap.action_get_events(source)
	for source_event in source_events:
		InputMap.action_add_event(destination, source_event)
