extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var scene
var helper
var initial_preset_count
var initial_name_count


##### SETUP #####
func before_all():
	helper = load(
		"res://test/integration/PlayerCustomizationMenu/helper_player_customization_menu.gd"
	).new()
	initial_preset_count = helper.count_saved_presets()
	helper.save_std_preset()


func before_each():
	scene = add_child_autofree(
		load("res://Scenes/UI/PlayerCustomizationMenu/player_customization_menu.tscn").instantiate()
	)
	helper.set_customization_menu(scene)


##### TEARDOWN #####
func after_all():
	helper.remove_std_preset()
	await wait_seconds(0.1)
	helper.free()


##### TESTS #####
func test_player_config():
	# given
	var config = load(StaticUtils.DEFAULT_CONFIG_PATH)
	# when / then
	assert_true(helper.is_config_equals_display(config))
	# when
	config = load(helper.INTEGRATION_TEST_PRESET_PATH)
	helper.update_config(config)
	# then
	assert_true(helper.is_config_equals_display(config))


func test_presets():
	# when
	helper.open_presets_menu()
	# then
	await wait_physics_frames(2)
	assert_true(helper.is_preset_menu_visible())
	var integration_test_config = helper.get_integration_test_config()
	var presets = helper.get_presets()
	var total_preset_count = initial_preset_count + 1
	assert_eq(presets.size(), total_preset_count)
	assert_true(helper.preset_buttons_contains_preset(presets, integration_test_config))
	# when
	presets[total_preset_count - 1].button.pressed.emit()
	await wait_process_frames(3)
	# then
	assert_false(helper.is_save_preset_popup_visible())
	# when
	helper.open_save_preset_menu()
	helper.save_preset_with_name_and_description(
		helper.INTEGRATION_TEST_2_PRESET_NAME,
		helper.INTEGRATION_TEST_2_PRESET_DESCRIPTION,
	)
	await wait_seconds(0.5)
	assert_true(helper.saved_preset_exists(helper.INTEGRATION_TEST_2_PRESET_NAME))
	# then
	presets = helper.get_presets()
	assert_eq(presets.size(), initial_preset_count + 2)
	# when
	presets[total_preset_count - 1].button.pressed.emit()
	await wait_process_frames(3)
	helper.save_preset_with_name_and_description(
		helper.INTEGRATION_TEST_2_PRESET_NAME,
		helper.INTEGRATION_TEST_2_PRESET_DESCRIPTION,
	)
	assert_true(helper.is_override_preset_popup_visible())
	helper.override_preset()
	await wait_seconds(0.5)
	assert_eq(presets.size(), initial_preset_count + 2)
	assert_true(helper.saved_preset_exists(helper.INTEGRATION_TEST_2_PRESET_NAME))
	# when
	presets = helper.get_presets()
	presets[total_preset_count].delete_button.pressed.emit()
	await wait_process_frames(4)
	presets = helper.get_presets()
	assert_eq(presets.size(), initial_preset_count + 1)
	assert_false(helper.saved_preset_exists(helper.INTEGRATION_TEST_2_PRESET_NAME))
	# cleanup
	if helper.saved_preset_exists(helper.INTEGRATION_TEST_2_PRESET_NAME):
		helper.remove_preset_with_name(helper.INTEGRATION_TEST_2_PRESET_NAME)


func test_name():
	# then
	assert_eq(helper.get_player_name(), "player")
	assert_eq(helper.get_current_menu_config().PLAYER_NAME, "player")
	# when
	helper.set_player_name("integration")
	await wait_process_frames(3)
	# then
	assert_eq(helper.get_player_name(), "integration")
	assert_eq(helper.get_current_menu_config().PLAYER_NAME, "integration")


func test_elimination_text():
	# when
	helper.open_elimination_text_menu()
	# then
	assert_true(helper.is_elimination_text_menu_visible())
	# when
	var elimination_text = "elimination_text"
	helper.set_elimination_text(elimination_text)
	# then
	assert_eq(helper.get_elimination_text(), elimination_text)
	assert_eq(helper.get_current_menu_config().ELIMINATION_TEXT, elimination_text)


func test_customization():
	# when
	helper.change_main_color(Color.RED)
	# then
	assert_true(helper.is_customization_preview_main_color(Color.RED))
	assert_eq(helper.get_current_menu_config().SPRITE_CUSTOMIZATION.BODY_COLOR, Color.RED)
	# when
	helper.change_secondary_color(Color.BLUE)
	# then
	assert_true(helper.is_customization_preview_secondary_color(Color.BLUE))
	assert_eq(helper.get_current_menu_config().SPRITE_CUSTOMIZATION.OUTLINE_COLOR, Color.BLUE)
	# when
	helper.change_eyes_color(Color.ORANGE)
	# then
	assert_true(helper.is_customization_preview_eyes_color(Color.ORANGE))
	assert_eq(helper.get_current_menu_config().SPRITE_CUSTOMIZATION.EYES_COLOR, Color.ORANGE)
	# when
	helper.change_mouth_color(Color.TEAL)
	# then
	assert_true(helper.is_customization_preview_mouth_color(Color.TEAL))
	assert_eq(helper.get_current_menu_config().SPRITE_CUSTOMIZATION.MOUTH_COLOR, Color.TEAL)
	# when
	helper.change_eyes()
	await wait_process_frames(3)
	# then
	assert_true(helper.is_eyes_selection_menu_visible())
	var eyes = helper.get_eyes_items()
	# when
	helper.select_eyes_item(1)
	# then
	assert_false(helper.is_eyes_selection_menu_visible())
	assert_true(helper.is_eyes_texture_path_equal(eyes[1].resource_path))
	assert_eq(
		helper.get_current_menu_config().SPRITE_CUSTOMIZATION.EYES_TEXTURE_PATH,
		eyes[1].resource_path,
	)
	# when
	helper.change_mouth()
	await wait_process_frames(3)
	# then
	assert_true(helper.is_mouth_selection_menu_visible())
	var mouths = helper.get_mouth_items()
	# when
	helper.select_mouth_item(1)
	# then
	assert_false(helper.is_mouth_selection_menu_visible())
	assert_true(helper.is_mouth_texture_path_equal(mouths[1].resource_path))
	assert_eq(
		helper.get_current_menu_config().SPRITE_CUSTOMIZATION.MOUTH_TEXTURE_PATH,
		mouths[1].resource_path,
	)


func test_primary_weapon_selection():
	# when
	helper.open_primary_weapon_menu()
	# then
	assert_true(helper.is_primary_weapon_menu_visible())
	# when
	helper.select_primary_weapon(0)
	# then
	assert_false(helper.is_primary_weapon_menu_visible())
	assert_eq(
		helper.get_current_menu_config().PRIMARY_WEAPON,
		helper.get_primary_weapon_item_grid_element(0).ITEM_ID,
	)


func test_movement_bonus_selection():
	# when
	helper.open_movement_bonus_menu()
	# then
	assert_true(helper.is_movement_bonus_menu_visible())
	# when
	helper.select_movement_bonus(0)
	# then
	assert_false(helper.is_movement_bonus_menu_visible())
	assert_eq(
		helper.get_current_menu_config().MOVEMENT_BONUS_HANDLER,
		helper.get_movement_bonus_item_grid_element(0).ITEM_ID,
	)


func test_powerup_selection():
	# when
	helper.open_powerup_menu()
	# then
	assert_true(helper.is_powerup_menu_visible())
	# when
	helper.select_powerup(0)
	# then
	assert_false(helper.is_powerup_menu_visible())
	assert_eq(
		helper.get_current_menu_config().POWERUP_HANDLER,
		helper.get_powerup_item_grid_element(0).ITEM_ID,
	)
