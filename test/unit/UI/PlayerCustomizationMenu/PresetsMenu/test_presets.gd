extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var presets


##### SETUP #####
func before_each():
	presets = load("res://Scenes/UI/PlayerCustomizationMenu/PresetsMenu/presets.tscn").instantiate()
	add_child_autofree(presets)
	await wait_for_signal(presets.tree_entered, 0.1)


##### TESTS #####
func test_ready():
	# given
	# when
	presets._ready()
	await wait_process_frames(3)
	# then
	assert_eq(presets.presets_root.get_child_count(), presets._presets.size())

# refresh, _get_preset, _reset_preset_root, _add_preset_button and _add_save_preset_button tested in _ready


func test_on_preset_selected():
	# given
	watch_signals(presets)
	var config = PlayerConfig.new()
	# when
	presets._on_preset_selected(config)
	# then
	assert_signal_emitted_with_parameters(presets.preset_selected, [config])
