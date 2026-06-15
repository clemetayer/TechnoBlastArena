extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const AI_PRESETS_RESOURCE := preload("res://Resources/AIPresets/ai_profiles.tres")

#---- VARIABLES -----
var presets


##### SETUP #####
func before_each():
	presets = load("res://Scenes/UI/PlayerCustomizationMenu/AISelectionMenu/ai_preset_selection_menu.tscn").instantiate()


##### TESTS #####
func test_presets_initialized_on_ready():
	# given
	# when
	add_child_autofree(presets)
	for preset in presets.presets_root.get_children(): # queue_free does not work well with tests
		preset.free()
	presets._ready()
	# then
	assert_eq(presets.presets_root.get_child_count(), AI_PRESETS_RESOURCE.RESOURCES.size())
	for child in presets.presets_root.get_children():
		print("preset = %s" % child)
		assert_true(child is Button)


func test_presets_selected_emits_signal():
	# given
	var expected_preset = AI_PRESETS_RESOURCE.RESOURCES[0]
	watch_signals(presets)
	# when
	add_child_autofree(presets)
	for preset in presets.presets_root.get_children(): # queue_free does not work well with tests
		preset.free()
	presets._ready()
	presets.presets_root.get_child(0).pressed.emit()
	# then
	assert_signal_emitted_with_parameters(presets.preset_selected, [expected_preset])
