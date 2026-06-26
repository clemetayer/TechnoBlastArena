extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var presets


##### SETUP #####
func before_each():
	presets = add_child_autofree(load("res://Scenes/UI/PlayerCustomizationMenu/PresetsMenu/presets.tscn").instantiate())


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


func test_preset_deleted():
	# given
	presets.refresh()
	await wait_process_frames(1)
	for preset in presets.presets_root.get_children():
		assert_true(preset.preset_deleted.is_connected(presets._on_preset_preset_deleted))
	presets = partial_double(load("res://Scenes/UI/PlayerCustomizationMenu/PresetsMenu/presets.gd")).new()
	stub(presets, "refresh").to_do_nothing()
	var preset = autofree(load("res://Scenes/UI/PlayerCustomizationMenu/PresetsMenu/preset.tscn").instantiate())
	preset.preset_deleted.connect(presets._on_preset_preset_deleted)
	# when
	preset.preset_deleted.emit()
	# then
	assert_called(presets, "refresh")
