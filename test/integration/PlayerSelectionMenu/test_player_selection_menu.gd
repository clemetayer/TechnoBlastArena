extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var scene
var helper
var initial_preset_count


##### SETUP #####
func before_all():
	helper = load("res://test/integration/PlayerSelectionMenu/helper_player_selection_menu.gd").new()
	initial_preset_count = helper.count_saved_presets()
	helper.save_std_preset()


func before_each():
	scene = add_child_autofree(load("res://Scenes/UI/PlayerCustomizationMenu/player_selection_menu.tscn").instantiate())
	helper.set_selection_menu(scene)


##### TEARDOWN #####
func after_all():
	helper.remove_std_preset()
	await wait_seconds(0.1)
	helper.free()


##### TESTS #####
func test_add_remove_players():
	# given
	var items = helper.get_player_selection_items()
	# then
	for item in items:
		assert_true(helper.is_empty_menu_visible(item))
	for item in items:
		# when
		helper.add_player_on_item(item)
		await wait_process_frames(3)
		# then
		assert_false(helper.is_empty_menu_visible(item))
		assert_true(helper.is_user_menu_visible(item))
	for item in items:
		# when
		helper.remove_player_on_item(item)
		await wait_process_frames(3)
		# then
		assert_true(helper.is_empty_menu_visible(item))
		assert_false(helper.is_user_menu_visible(item))


func test_add_remove_ai_players():
	# given
	var items = helper.get_player_selection_items()
	# then
	for item in items:
		assert_true(helper.is_empty_menu_visible(item))
	for item in items:
		# when
		helper.add_ai_player_on_item(item)
		await wait_process_frames(3)
		# then
		assert_false(helper.is_empty_menu_visible(item))
		assert_true(helper.is_ai_preset_menu_visible(item))
		helper.select_first_ai_preset(item)
		var ai_config: PlayerConfig = helper.get_ai_preset_configuration(item)
		assert_true(helper.is_ai_visualisation_menu_visible(item))
		assert_false(helper.is_ai_preset_menu_visible(item))
		assert_eq(helper.get_ai_player_name(item), ai_config.PLAYER_NAME)
		assert_eq(helper.get_ai_primary_weapon_image_path(item), StaticPrimaryWeaponHandler.get_icon_path(ai_config.PRIMARY_WEAPON))
		assert_eq(helper.get_ai_movement_bonus_image_path(item), StaticMovementBonusHandler.get_icon_path(ai_config.MOVEMENT_BONUS_HANDLER))
		assert_eq(helper.get_ai_powerup_image_path(item), StaticPowerupHandler.get_icon_path(ai_config.POWERUP_HANDLER))
	for item in items:
		# when
		helper.remove_ai_player_on_item(item)
		await wait_process_frames(3)
		# then
		assert_true(helper.is_empty_menu_visible(item))
		assert_false(helper.is_ai_preset_menu_visible(item))


func test_user_menu() -> void:
	# given
	var items = helper.get_player_selection_items()
	var item = items[0]
	var config = load(StaticUtils.DEFAULT_CONFIG_PATH)
	helper.add_player_on_item(item)
	# then
	assert_true(helper.is_user_menu_visible(item))
	assert_true(helper.is_config_equals_display(config, item))


func test_presets() -> void:
	# given
	await wait_process_frames(2)
	var items = helper.get_player_selection_items()
	var item = items[0]
	# when
	helper.add_player_on_item(item)
	helper.select_presets_menu(item)
	var integration_test_config = helper.get_integration_test_config()
	var presets = helper.get_presets(item)
	var configs = helper.get_presets_configs(item)
	var total_preset_count = initial_preset_count + 1
	# then
	assert_true(helper.is_preset_menu_visible(item))
	assert_eq(presets.size(), total_preset_count)
	assert_true(helper.preset_buttons_contains_preset(presets, integration_test_config))
	# when
	helper.select_preset(presets[0])
	# then
	assert_false(helper.is_preset_menu_visible(item))
	assert_true(helper.is_user_menu_visible(item))
	assert_true(helper.is_config_equals_display(configs[configs.keys()[0]], item))


func test_primary_weapons() -> void:
	# given
	var items = helper.get_player_selection_items()
	var item = items[0]
	# when
	helper.add_player_on_item(item)
	helper.select_primary_weapon_menu(item)
	await wait_process_frames(3)
	# then
	assert_true(helper.is_primary_weapon_menu_visible(item))
	# when
	helper.select_primary_weapon(0, item)
	# then
	assert_true(helper.is_primary_weapon_selected(StaticPrimaryWeaponHandler.handlers.REVOLVER, item))
	assert_true(helper.is_user_menu_visible(item))
	assert_false(helper.is_primary_weapon_menu_visible(item))


func test_movement_bonus() -> void:
	# given
	var items = helper.get_player_selection_items()
	var item = items[0]
	# when
	helper.add_player_on_item(item)
	helper.select_movement_bonus_menu(item)
	await wait_process_frames(3)
	# then
	assert_true(helper.is_movement_bonus_menu_visible(item))
	# when
	helper.select_movement_bonus(0, item)
	# then
	assert_true(helper.is_movement_bonus_selected(StaticMovementBonusHandler.handlers.DASH, item))
	assert_true(helper.is_user_menu_visible(item))
	assert_false(helper.is_movement_bonus_menu_visible(item))


func test_powerup() -> void:
	# given
	var items = helper.get_player_selection_items()
	var item = items[0]
	# when
	helper.add_player_on_item(item)
	helper.select_powerup_menu(item)
	await wait_process_frames(3)
	# then
	assert_true(helper.is_powerup_menu_visible(item))
	# when
	helper.select_powerup(0, item)
	# then
	assert_true(helper.is_powerup_selected(StaticPowerupHandler.handlers.SPLITTER, item))
	assert_true(helper.is_user_menu_visible(item))
	assert_false(helper.is_powerup_menu_visible(item))


func test_start_game():
	# given
	watch_signals(scene)
	var items = helper.get_player_selection_items()
	# when
	helper.add_player_on_item(items[0])
	helper.add_player_on_item(items[1])
	helper.set_lives(5)
	helper.set_game_time(2, 15)
	helper.press_start()
	# then
	assert_signal_emitted_with_parameters(scene.game_ready, [[items[0].get_config(), items[1].get_config()], 5, 135])
