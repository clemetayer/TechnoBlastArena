extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var init


##### SETUP #####
func before_each():
	init = load("res://Scenes/Player/init.gd").new()


##### TEARDOWN #####
func after_each():
	init.free()


##### TESTS #####
func test_initialize():
	# given
	var paths = load("res://Scenes/Player/paths.gd").new()
	var input_synchronizer = double(load("res://Scenes/Player/input_synchronizer.gd")).new()
	paths.input_synchronizer = input_synchronizer
	stub(input_synchronizer, "set_action_handler").to_do_nothing()
	var sprites = double(load("res://Scenes/Player/sprites.gd")).new()
	paths.sprites = sprites
	stub(sprites, "load_sprite_preset").to_do_nothing()
	stub(sprites, "set_player_indicator").to_do_nothing()
	var crosshair = double(load("res://Scenes/Weapons/Primary/crosshair.gd")).new()
	paths.crosshair = crosshair
	stub(crosshair, "set_color").to_do_nothing()
	var damage_label = double(load("res://Scenes/Player/damage_text.gd")).new()
	stub(damage_label, "init_damage").to_do_nothing()
	paths.damage_label = damage_label
	var death_manager = double(load("res://Scenes/Player/death_manager.gd")).new()
	stub(death_manager, "set_particles_color").to_do_nothing()
	paths.death_manager = death_manager
	var appear_elements = double(load("res://Scenes/Player/appear_elements.gd")).new()
	stub(appear_elements, "init").to_do_nothing()
	paths.appear_elements = appear_elements
	var player_root = load("res://test/unit/Player/test_init/player_mock.gd").new()
	player_root.PLAYER_ID = 0
	paths.player_root = player_root
	add_child(player_root)
	wait_for_signal(player_root.tree_entered, 0.25)
	var hit_particles = double(load("res://Scenes/Player/hit_particles.gd")).new()
	stub(hit_particles, "init").to_do_nothing()
	paths.hit_particles = hit_particles
	init.paths = paths
	# when
	var config = generate_test_config()
	init.initialize(config)
	# then
	assert_called(sprites, "load_sprite_preset", [config.SPRITE_CUSTOMIZATION])
	assert_called(sprites, "set_player_indicator", [0])
	assert_eq(init.ACTION_HANDLER, config.ACTION_HANDLER)
	assert_eq(init.PRIMARY_WEAPON, config.PRIMARY_WEAPON)
	assert_eq(init.MOVEMENT_BONUS_HANDLER, config.MOVEMENT_BONUS_HANDLER)
	assert_eq(init.POWERUP_HANDLER, config.POWERUP_HANDLER)
	assert_called(crosshair, "set_color", [RuntimeUtils.PLAYER_INDICATOR_COLORS[0]])
	assert_not_null(paths.primary_weapon)
	assert_not_null(paths.movement_bonus)
	assert_not_null(paths.powerup_manager)
	assert_true(player_root.abilities_toggled.is_connected(paths.primary_weapon._on_player_abilities_toggled))
	assert_true(player_root.abilities_toggled.is_connected(paths.movement_bonus._on_player_abilities_toggled))
	assert_true(player_root.abilities_toggled.is_connected(paths.powerup_manager._on_player_abilities_toggled))
	assert_called(input_synchronizer, "set_action_handler", [config.ACTION_HANDLER])
	assert_eq(paths.movement_bonus.player, player_root)
	assert_eq(paths.primary_weapon.projectile_owner, player_root)
	assert_called(damage_label, "init_damage")
	assert_eq(paths.primary_weapon.owner_color, RuntimeUtils.PLAYER_INDICATOR_COLORS[0])
	assert_called(death_manager, "set_particles_color", [Color.ANTIQUE_WHITE])
	assert_called(appear_elements, "init", [Color.REBECCA_PURPLE, Color.ANTIQUE_WHITE])
	assert_eq(player_root.get_child_count(), 3)
	assert_true(paths.movement_bonus.has_connections("value_updated"))
	assert_true(paths.powerup_manager.has_connections("value_updated"))
	assert_called(hit_particles, "init", [Color.ANTIQUE_WHITE])
	# cleanup
	player_root.free()
	paths.free()


##### UTILS #####
func generate_test_config() -> PlayerConfig:
	var config = PlayerConfig.new()
	var sprite_customization = SpriteCustomizationResource.new()
	sprite_customization.BODY_COLOR = Color.REBECCA_PURPLE
	sprite_customization.OUTLINE_COLOR = Color.ANTIQUE_WHITE
	config.ACTION_HANDLER = StaticActionHandler.handlers.INPUT
	config.PRIMARY_WEAPON = StaticPrimaryWeaponHandler.handlers.REVOLVER
	config.MOVEMENT_BONUS_HANDLER = StaticMovementBonusHandler.handlers.DASH
	config.POWERUP_HANDLER = StaticPowerupHandler.handlers.SPLITTER
	config.SPRITE_CUSTOMIZATION = sprite_customization
	config.ELIMINATION_TEXT = "haha"
	return config
