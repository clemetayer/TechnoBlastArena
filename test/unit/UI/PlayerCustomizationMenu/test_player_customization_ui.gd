extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
#---- VARIABLES -----
var ui


##### SETUP #####
func before_each():
	ui = add_child_autofree(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerCustomizationUI/player_customization_ui.tscn").instantiate())

##### TESTS #####
var init_params := [
	[true, true],
	[false, true],
	[true, false],
	[false, false],
]


func test_init(params = use_parameters(init_params)):
	# given
	var is_small: bool = params[0]
	var allow_save: bool = params[1]
	ui.IS_SMALL = is_small
	ui.ALLOW_SAVE = allow_save
	var player_config_display = mock_player_config_display()
	stub(player_config_display, "toggle_is_small").to_do_nothing()
	stub(player_config_display, "update_player").to_do_nothing()
	var menus = mock_menus()
	stub(menus, "toggle_is_small").to_do_nothing()
	# when
	ui._init_small()
	ui._init_allow_save()
	ui._init_player_config()
	# then
	assert_called(player_config_display, "toggle_is_small", [is_small])
	assert_called(player_config_display, "update_player", [ui.player_config])
	assert_called(menus, "toggle_is_small", [is_small])
	assert_eq(ui.save_preset_button.visible, allow_save)
	assert_eq(ui.player_config.resource_path, "res://Scenes/Player/PlayerConfigs/default_player_config.tres")


func test_name_changed():
	# given
	# when
	ui.player_config_display.name_changed.emit("test_name")
	# then
	assert_eq(ui.player_config.PLAYER_NAME, "test_name")


func test_primary_weapon_change_triggered():
	# given
	var menus = mock_menus()
	stub(menus, "open_primary_weapon").to_do_nothing()
	# when
	ui.player_config_display.primary_weapon_change_requested.emit()
	# then
	assert_called(menus, "open_primary_weapon")


func test_primary_weapon_changed():
	# given
	var player_config_display = mock_player_config_display()
	stub(player_config_display, "update_player").to_do_nothing()
	# when
	ui.menus.primary_weapon_selected.emit(StaticPrimaryWeaponHandler.handlers.REVOLVER)
	# then
	assert_eq(ui.player_config.PRIMARY_WEAPON, StaticPrimaryWeaponHandler.handlers.REVOLVER)
	assert_called(player_config_display, "update_player")


func test_movement_bonus_change_triggered():
	# given
	var menus = mock_menus()
	stub(menus, "open_movement_bonus").to_do_nothing()
	# when
	ui.player_config_display.movement_bonus_change_requested.emit()
	# then
	assert_called(menus, "open_movement_bonus")


func test_movement_bonus_changed():
	# given
	var player_config_display = mock_player_config_display()
	stub(player_config_display, "update_player").to_do_nothing()
	# when
	ui.menus.movement_bonus_selected.emit(StaticMovementBonusHandler.handlers.DASH)
	# then
	assert_eq(ui.player_config.MOVEMENT_BONUS_HANDLER, StaticMovementBonusHandler.handlers.DASH)
	assert_called(player_config_display, "update_player")


func test_powerup_change_triggered():
	# given
	var menus = mock_menus()
	stub(menus, "open_powerup").to_do_nothing()
	# when
	ui.player_config_display.powerup_change_requested.emit()
	# then
	assert_called(menus, "open_powerup")


func test_powerup_changed():
	# given
	var player_config_display = mock_player_config_display()
	stub(player_config_display, "update_player").to_do_nothing()
	# when
	ui.menus.powerup_selected.emit(StaticPowerupHandler.handlers.SPLITTER)
	# then
	assert_eq(ui.player_config.POWERUP_HANDLER, StaticPowerupHandler.handlers.SPLITTER)
	assert_called(player_config_display, "update_player")


func test_main_color_changed():
	# given
	assert_true(ui.player_config_display.main_color_changed.is_connected(ui._on_player_config_display_main_color_changed))
	var player_config_display = mock_player_config_display()
	stub(player_config_display, "update_player").to_do_nothing()
	ui.player_config_display.main_color_changed.connect(ui._on_player_config_display_main_color_changed)
	# when
	ui.player_config_display.main_color_changed.emit(Color.BLUE)
	# then
	assert_eq(ui.player_config.SPRITE_CUSTOMIZATION.BODY_COLOR, Color.BLUE)
	assert_called(player_config_display, "update_player")


func test_secondary_color_changed():
	# given
	assert_true(ui.player_config_display.secondary_color_changed.is_connected(ui._on_player_config_display_secondary_color_changed))
	var player_config_display = mock_player_config_display()
	stub(player_config_display, "update_player").to_do_nothing()
	ui.player_config_display.secondary_color_changed.connect(ui._on_player_config_display_secondary_color_changed)
	# when
	ui.player_config_display.secondary_color_changed.emit(Color.BLUE)
	# then
	assert_eq(ui.player_config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR, Color.BLUE)
	assert_called(player_config_display, "update_player")


func test_open_eyes_change():
	# given
	var menus = mock_menus()
	stub(menus, "open_eyes_selection").to_do_nothing()
	# when
	ui.player_config_display.eyes_change_triggered.emit()
	# then
	assert_called(menus, "open_eyes_selection")


func test_eyes_selected():
	# given
	var player_config_display = mock_player_config_display()
	stub(player_config_display, "update_player").to_do_nothing()
	# when
	ui.menus.eyes_selected.emit("eyes_sprite_path")
	# then
	assert_eq(ui.player_config.SPRITE_CUSTOMIZATION.EYES_TEXTURE_PATH, "eyes_sprite_path")
	assert_called(player_config_display, "update_player")


func test_open_mouth_change():
	# given
	var menus = mock_menus()
	stub(menus, "open_mouth_selection").to_do_nothing()
	# when
	ui.player_config_display.mouth_change_triggered.emit()
	# then
	assert_called(menus, "open_mouth_selection")


func test_mouth_selected():
	# given
	var player_config_display = mock_player_config_display()
	stub(player_config_display, "update_player").to_do_nothing()
	# when
	ui.menus.mouth_selected.emit("mouth_sprite_path")
	# then
	assert_eq(ui.player_config.SPRITE_CUSTOMIZATION.MOUTH_TEXTURE_PATH, "mouth_sprite_path")
	assert_called(player_config_display, "update_player")


func test_eyes_color_changed():
	# given
	assert_true(ui.player_config_display.eyes_color_changed.is_connected(ui._on_player_config_display_eyes_color_changed))
	var player_config_display = mock_player_config_display()
	stub(player_config_display, "update_player").to_do_nothing()
	player_config_display.eyes_color_changed.connect(ui._on_player_config_display_eyes_color_changed)
	# when
	ui.player_config_display.eyes_color_changed.emit(Color.BLUE)
	# then
	assert_eq(ui.player_config.SPRITE_CUSTOMIZATION.EYES_COLOR, Color.BLUE)
	assert_called(player_config_display, "update_player")


func test_mouth_color_changed():
	# given
	assert_true(ui.player_config_display.mouth_color_changed.is_connected(ui._on_player_config_display_mouth_color_changed))
	var player_config_display = mock_player_config_display()
	stub(player_config_display, "update_player").to_do_nothing()
	player_config_display.mouth_color_changed.connect(ui._on_player_config_display_mouth_color_changed)
	# when
	ui.player_config_display.mouth_color_changed.emit(Color.BLUE)
	# then
	assert_eq(ui.player_config.SPRITE_CUSTOMIZATION.MOUTH_COLOR, Color.BLUE)
	assert_called(player_config_display, "update_player")


func test_elimination_text_change_triggered():
	# given
	var menus = mock_menus()
	stub(menus, "open_elimination_text").to_do_nothing()
	# when
	ui.player_config_display.elimination_text_change_triggered.emit()
	# then
	assert_called(menus, "open_elimination_text")


func test_elimination_text_changed():
	# given
	# when
	ui.menus.elimination_text_updated.emit("elimination text")
	# then
	assert_eq(ui.player_config.ELIMINATION_TEXT, "elimination text")


func test_randomize():
	# given
	assert_true(ui.player_config_display.randomize.is_connected(ui._on_player_config_display_randomize))
	var player_config_display = mock_player_config_display()
	stub(player_config_display, "update_player").to_do_nothing()
	player_config_display.randomize.connect(ui._on_player_config_display_randomize)
	# when
	ui.player_config_display.randomize.emit()
	# then
	assert_ne(ui.player_config.SPRITE_CUSTOMIZATION.BODY_COLOR, Color.ALICE_BLUE)
	assert_ne(ui.player_config.SPRITE_CUSTOMIZATION.OUTLINE_COLOR, Color.AQUAMARINE)
	assert_not_null(ui.player_config.SPRITE_CUSTOMIZATION.EYES_COLOR)
	assert_ne(ui.player_config.SPRITE_CUSTOMIZATION.EYES_COLOR, Color.BLACK)
	assert_not_null(ui.player_config.SPRITE_CUSTOMIZATION.MOUTH_COLOR)
	assert_ne(ui.player_config.SPRITE_CUSTOMIZATION.MOUTH_COLOR, Color.BLACK)
	assert_not_null(ui.player_config.PRIMARY_WEAPON)
	assert_not_null(ui.player_config.MOVEMENT_BONUS_HANDLER)
	assert_not_null(ui.player_config.POWERUP_HANDLER)
	assert_called(player_config_display, "update_player")


func test_open_presets_selection():
	# given
	var menus = mock_menus()
	stub(menus, "open_preset_selection").to_do_nothing()
	# when
	ui.preset_selection_button.pressed.emit()
	# then
	assert_called(menus, "open_preset_selection")


func test_preset_selected():
	# given
	var preset = PlayerConfig.new()
	preset.PLAYER_NAME = "player name"
	preset.DESCRIPTION = "description"
	preset.PRIMARY_WEAPON = StaticPrimaryWeaponHandler.handlers.REVOLVER
	preset.MOVEMENT_BONUS_HANDLER = StaticMovementBonusHandler.handlers.DASH
	preset.POWERUP_HANDLER = StaticPowerupHandler.handlers.SPLITTER
	preset.ELIMINATION_TEXT = "elimination text"
	var sprite = SpriteCustomizationResource.new()
	sprite.BODY_COLOR = Color.BLUE
	sprite.OUTLINE_COLOR = Color.BLUE
	sprite.EYES_TEXTURE_PATH = "res://icon.svg"
	sprite.MOUTH_COLOR = Color.BLUE
	sprite.MOUTH_TEXTURE_PATH = "res://icon.svg"
	preset.SPRITE_CUSTOMIZATION = sprite
	var player_config_display = mock_player_config_display()
	stub(player_config_display, "update_player").to_do_nothing()
	# when
	ui.menus.preset_selected.emit(preset)
	# then
	assert_eq(ui.player_config, preset)
	assert_called(player_config_display, "update_player")


func test_open_save_preset_menu():
	# given
	var menus = mock_menus()
	stub(menus, "open_save_preset_popup")
	# when
	ui.save_preset_button.pressed.emit()
	# then
	assert_called(menus, "open_save_preset_popup")


func test_save_preset():
	# given
	var config = PlayerConfig.new()
	var sprite = SpriteCustomizationResource.new()
	sprite.BODY_COLOR = Color.BLUE
	config.SPRITE_CUSTOMIZATION = sprite
	ui.player_config = config
	# when
	ui.menus.save_preset.emit("gdunittest", "test preset")
	# then
	var preset_path = StaticUtils.get_preset_save_path("gdunittest")
	assert_true(ResourceLoader.exists(preset_path))
	var saved_resource = load(preset_path)
	assert_eq(saved_resource.DESCRIPTION, "test preset")
	assert_eq(saved_resource.SPRITE_CUSTOMIZATION.BODY_COLOR, Color.BLUE)
	# cleanup
	var dir_access = DirAccess.open(StaticUtils.USER_CHARACTER_PRESETS_PATH)
	dir_access.remove(preset_path)


func test_quit():
	# given
	watch_signals(ui)
	# when
	ui.quit_button.pressed.emit()
	# then
	assert_signal_emitted(ui.quit)


##### UTILS #####
func mock_player_config_display():
	var player_config_display = double(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerConfigDisplay/player_config_display.gd")).new()
	ui.player_config_display = player_config_display
	return player_config_display


func mock_menus():
	var menus = double(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerCustomizationMenus/menus.gd")).new()
	ui.menus = menus
	return menus
