extends Node
# Handles UI sounds

##### VARIABLES #####
#---- CONSTANTS -----
const UI_CLICK := "ui_click"
const UI_CLOSE := "ui_close"
const UI_CONFIRM := "ui_confirm"
const UI_HOVER := "ui_hover"
const UI_OPEN := "ui_open"
const UI_TICK := "ui_tick"


#---- EXPORTS -----
@export var EVENT_AUDIO_LOGS_ENABLED := true

#---- STANDARD -----
#==== PUBLIC ====
var event_audio := EventAudio

#==== ONREADY ====
@onready var _audio_emitter := AudioUtils.add_event_audio_emitter_2D(self)


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	_connect_ui_sounds()
	_toggle_event_audio_logs(EVENT_AUDIO_LOGS_ENABLED)
	EventAudio.process_mode = Node.PROCESS_MODE_ALWAYS # Required in order to play sounds in the dialog or pause menu
	if not get_tree().node_added.is_connected(_on_SceneTree_node_added):
		get_tree().node_added.connect(_on_SceneTree_node_added)


##### PUBLIC METHODS #####
func play_click() -> void:
	_play_sound([UISoundBankData.UI_CLICK])


func play_close() -> void:
	_play_sound([UISoundBankData.UI_CLOSE])


func play_confirm(_value = 0.0) -> void:
	_play_sound([UISoundBankData.UI_CONFIRM])


func play_hover() -> void:
	_play_sound([UISoundBankData.UI_HOVER])


func play_open() -> void:
	_play_sound([UISoundBankData.UI_OPEN])


func play_tick(_value = 0.0) -> void:
	_play_sound([UISoundBankData.UI_TICK])


##### PROTECTED METHODS #####
func _play_sound(triggers: Array) -> void:
	event_audio.play_2d(SoundBankData.get_trigger_string(triggers), _audio_emitter)


func _toggle_event_audio_logs(enabled: bool) -> void:
	EventAudio.log_lookups = enabled
	EventAudio.log_deaths = enabled
	EventAudio.log_registrations = enabled


##### SIGNAL MANAGEMENT #####
func _connect_ui_sounds() -> void:
	_connect_ui_sound_node_recur(get_tree().root)


func _connect_ui_sound_node_recur(root: Node) -> void:
	for node in root.get_children():
		_connect_ui_sound(node)
		if node.get_child_count() > 0:
			_connect_ui_sound_node_recur(node)


func _on_SceneTree_node_added(node: Node) -> void:
	_connect_ui_sound(node)


func _connect_ui_sound(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	if node.is_in_group(UI_CLICK):
		if node is Button and not node.is_connected("pressed", play_click):
			node.connect("pressed", play_click)
		elif node is ItemList and not node.is_connected("item_selected", play_confirm):
			node.connect("item_selected", play_confirm)
	if node.is_in_group(UI_CLOSE):
		if node is Button and not node.is_connected("pressed", play_close):
			node.connect("pressed", play_close)
		if node is Window and not node.is_connected("close_requested", play_close):
			node.connect("close_requested", play_close)
	if node.is_in_group(UI_CONFIRM):
		if node is Button and not node.is_connected("pressed", play_confirm):
			node.connect("pressed", play_confirm)
		elif node is ItemList and not node.is_connected("item_selected", play_confirm):
			node.connect("item_selected", play_confirm)
	if node.is_in_group(UI_HOVER):
		if node is Control and not node.is_connected("focus_entered", play_hover):
			node.connect("focus_entered", play_hover)
	if node.is_in_group(UI_OPEN):
		if node is Button and not node.is_connected("pressed", play_open):
			node.connect("pressed", play_open)
	if node.is_in_group(UI_TICK):
		if node is Range and not node.is_connected("value_changed", play_tick):
			node.connect("value_changed", play_tick)
