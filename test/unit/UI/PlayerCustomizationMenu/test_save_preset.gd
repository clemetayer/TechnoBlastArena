extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var menu


##### SETUP #####
func before_each():
	menu = autofree(load("res://Scenes/UI/PlayerCustomizationMenu/SavePreset/save_preset.gd").new())


##### TESTS #####
func test_on_confirmed_not_existing():
	# given
	var preset_name = autofree(LineEdit.new())
	preset_name.text = "gdunittest"
	menu.preset_name = preset_name
	var preset_description = autofree(TextEdit.new())
	preset_description.text = "description"
	menu.preset_description = preset_description
	watch_signals(menu)
	menu.show()
	# when
	menu._on_confirmed()
	# then
	assert_signal_emitted_with_parameters(menu.save_preset_triggered, ["gdunittest", "description"])
	assert_signal_not_emitted(menu.open_override_popup)


func test_on_confirmed_existing():
	# given
	var preset_to_save = PlayerConfig.new()
	ResourceSaver.save(preset_to_save, StaticUtils.get_preset_save_path("gdunittest"))
	var preset_name = autofree(LineEdit.new())
	preset_name.text = "gdunittest"
	menu.preset_name = preset_name
	var preset_description = autofree(TextEdit.new())
	preset_description.text = "description"
	menu.preset_description = preset_description
	watch_signals(menu)
	menu.show()
	# when
	menu._on_confirmed()
	# then
	assert_signal_not_emitted(menu.save_preset_triggered)
	assert_signal_emitted(menu.open_override_popup)
	# cleanup
	var dir_access = DirAccess.open(StaticUtils.USER_CHARACTER_PRESETS_PATH)
	dir_access.remove(StaticUtils.get_preset_save_path("gdunittest"))
