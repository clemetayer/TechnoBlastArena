extends RefCounted

class_name StaticUtils
# contains various static elements common to the entire game (enums, const, static functions, etc.)

##### VARIABLES #####
#---- CONSTANTS -----
const DEFAULT_CONFIG_PATH := "res://Scenes/Player/PlayerConfigs/default_player_config.tres"
const USER_CHARACTER_PRESETS_PATH := "user://presets/"
const GODOT_RESOURCE_FILE_EXTENSION := ".tres"


##### PUBLIC METHODS #####
# https://easings.net/#easeOutCubic
static func cubic_ease_out(x: float) -> float:
	return min(1.0, abs(1 - pow(1 - x, 3)))


static func map_if_exists(data: Dictionary, key, object, variable_name: String) -> void:
	if data.has(key):
		if variable_name in object:
			object.set(variable_name, data[key])
		else:
			GSLogger.warn("object %s does not contain the variable %s, at %s" % [object, variable_name, get_stack()])
	else:
		GSLogger.warn("%s does not contain the key %s, at %s" % [data, key, get_stack()])


static func create_folder_if_not_exists(folder_path: String) -> void:
	var dir_access = DirAccess.open("user://")
	if not dir_access.dir_exists(folder_path):
		dir_access.make_dir_recursive(folder_path)


static func list_files_in_dir(dir_path: String) -> Array:
	var files = []
	var dir_access = DirAccess.open(dir_path)
	if dir_access:
		dir_access.list_dir_begin()
		var file = dir_access.get_next()
		while file != "":
			if not dir_access.current_is_dir():
				files.append(file)
			file = dir_access.get_next()
	return files


static func partition_array(array: Array, nb_of_elements: int) -> Array:
	var partitionned = []
	var cnt = 0
	var partition = []
	for element in array:
		if cnt < nb_of_elements:
			partition.append(element)
		else:
			partitionned.append(partition)
			partition = [element]
			cnt = 0
		cnt += 1
	if partition.size() > 0:
		partitionned.append(partition)
	return partitionned


static func get_preset_save_path(preset_name: String) -> String:
	return StaticUtils.USER_CHARACTER_PRESETS_PATH + preset_name + StaticUtils.GODOT_RESOURCE_FILE_EXTENSION


static func random_color() -> Color:
	return Color(randf(), randf(), randf())
