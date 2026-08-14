extends Node

# manages the music of the game

##### VARIABLES #####
#---- CONSTANTS -----
const DEFAULT_FILTER_IN_OUT_TIME := 1.0
const BUS_IDX := 1
const LOWPASS_FILTER_IDX := 0
const FILTER_IN_CUTOFF := 1000
const FILTER_OUT_CUTOFF := 20000

#---- STANDARD -----
#==== PRIVATE ====
var _filter_tween: Tween

#==== ONREADY ====
@onready var lowpass_filter := AudioServer.get_bus_effect(BUS_IDX, LOWPASS_FILTER_IDX)


##### PUBLIC METHODS #####
func filter_in(duration := DEFAULT_FILTER_IN_OUT_TIME) -> void:
	if _filter_tween:
		_filter_tween.kill()
	_filter_tween = create_tween()
	_filter_tween.tween_property(
		lowpass_filter,
		"cutoff_hz",
		FILTER_IN_CUTOFF,
		duration,
	)
	await _filter_tween.finished
	lowpass_filter.cutoff_hz = FILTER_IN_CUTOFF


func filter_out(duration := DEFAULT_FILTER_IN_OUT_TIME) -> void:
	if _filter_tween:
		_filter_tween.kill()
	_filter_tween = create_tween()
	_filter_tween.tween_property(
		lowpass_filter,
		"cutoff_hz",
		FILTER_OUT_CUTOFF,
		duration,
	)
	await _filter_tween.finished
	lowpass_filter.cutoff_hz = FILTER_OUT_CUTOFF
