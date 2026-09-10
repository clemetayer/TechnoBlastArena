extends PowerupBase
# manages the chain elements

##### VARIABLES #####
#---- CONSTANTS -----
const MAX_ELEMENTS := 6
const CHAIN_ELEMENT_GROUP_NAME := "chain_element"
const CHAIN_ELEMENT_SCENE := preload("res://Scenes/Weapons/Powerups/Chain/chain_element.tscn")
const MAX_ACTIONS := 3

#---- STANDARD -----
#==== PRIVATE ====
var _actions_left := MAX_ACTIONS
var _init_ui_done := false # to update the ui on the first frame

#==== ONREADY ====
@onready var reload_timer := $"ReloadTimer"


##### PROCESSING #####
# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(_delta):
	if not _init_ui_done:
		value_updated.emit(_actions_left)
		_init_ui_done = true


##### PUBLIC METHODS #####
func use() -> void:
	if active and _actions_left > 0:
		_actions_left -= 1
		reload_timer.start()
		value_updated.emit(_actions_left)
		var last_idx = _get_last_chain_element_idx()
		if last_idx + 2 >= MAX_ELEMENTS:
			_remove_first_chain_element()
		_spawn_chain_element(last_idx)
		_reorder()


##### PROTECTED METHODS #####
func _get_chain_elements() -> Array:
	return get_tree().get_nodes_in_group(CHAIN_ELEMENT_GROUP_NAME)


func _get_chain_elements_sorted() -> Array:
	var elements_sorted = _get_chain_elements()
	elements_sorted.sort_custom(
		func(a, b):
			return a.idx < b.idx,
	)
	return elements_sorted


func _get_last_chain_element_idx() -> int:
	return _get_chain_elements().size() - 1


func _remove_first_chain_element() -> void:
	_get_chain_elements_sorted()[0].free()


func _reorder() -> void:
	var elements = _get_chain_elements_sorted()
	for element_idx in range(elements.size()):
		var element = elements[element_idx]
		if element_idx > 0:
			var previous_element = elements[element_idx - 1]
			previous_element.change_direction(
				element.global_position - previous_element.global_position
			)
		element.idx = element_idx


func _spawn_chain_element(idx: int) -> void:
	var aim_direction = player_paths.input_synchronizer.relative_aim_position.normalized()
	var chain_element = CHAIN_ELEMENT_SCENE.instantiate()
	chain_element.spawn(aim_direction, global_position, idx)
	chain_element.destroyed.connect(_on_chain_element_destroyed)


##### SIGNAL MANAGEMENT #####
func _on_chain_element_destroyed(idx: int) -> void:
	_get_chain_elements().filter(
		func(element):
			return element.idx == idx,
	)[0].queue_free()
	await get_tree().process_frame # awaits the next process frame to ensure the element is deleted and will not be present when reordering
	_reorder()


func _on_reload_timer_timeout() -> void:
	_actions_left = min(_actions_left + 1, MAX_ACTIONS)
	value_updated.emit(_actions_left)
	if _actions_left < MAX_ACTIONS:
		reload_timer.start()
