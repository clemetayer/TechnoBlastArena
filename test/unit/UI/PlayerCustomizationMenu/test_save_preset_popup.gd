extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var popup


##### SETUP #####
func before_each():
	popup = autofree(load("res://Scenes/UI/PlayerCustomizationMenu/save_preset_popup.gd").new())


##### TESTS #####
func test_on_confirmed_not_existing():
	# given
	var preset_name = autofree(LineEdit.new())
	preset_name.text = "gdunittest"
	popup.preset_name = preset_name
	var preset_description = autofree(TextEdit.new())
	preset_description.text = "description"
	popup.preset_description = preset_description
	watch_signals(popup)
	popup.show()
	# when
	popup._on_confirmed()
	# then
	assert_signal_emitted_with_parameters(popup.save_preset, ["gdunittest", "description"])


func test_on_confirmed_existing():
	# given
	var preset_to_save = PlayerConfig.new()
	ResourceSaver.save(preset_to_save, StaticUtils.get_preset_save_path("gdunittest"))
	var preset_name = autofree(LineEdit.new())
	preset_name.text = "gdunittest"
	popup.preset_name = preset_name
	var preset_description = autofree(TextEdit.new())
	preset_description.text = "description"
	popup.preset_description = preset_description
	var override_preset_popup = add_child_autofree(ConfirmationDialog.new())
	popup.override_preset_popup = override_preset_popup
	watch_signals(popup)
	popup.show()
	# when
	popup._on_confirmed()
	# then
	assert_signal_not_emitted(popup.save_preset)
	assert_true(override_preset_popup.visible)
	# cleanup
	var dir_access = DirAccess.open(StaticUtils.USER_CHARACTER_PRESETS_PATH)
	dir_access.remove(StaticUtils.get_preset_save_path("gdunittest"))


func test_on_override_preset_popup_confirmed():
	# given
	var preset_name = autofree(LineEdit.new())
	preset_name.text = "gdunittest"
	popup.preset_name = preset_name
	var preset_description = autofree(TextEdit.new())
	preset_description.text = "description"
	popup.preset_description = preset_description
	watch_signals(popup)
	# when
	popup._on_override_preset_popup_confirmed()
	# then
	assert_signal_emitted_with_parameters(popup.save_preset, ["gdunittest", "description"])
