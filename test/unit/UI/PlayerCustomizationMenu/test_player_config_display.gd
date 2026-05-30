extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var display
var primary_weapon_change_requested_times_called := 0
var powerup_change_requested_times_called := 0
var movement_bonus_change_requested_times_called := 0
var name_changed_times_called := 0
var name_changed_args := []


##### SETUP #####
func before_each():
	display = load("res://Scenes/UI/PlayerCustomizationMenu/PlayerConfigDisplay/player_config_display.tscn").instantiate()
	add_child_autofree(display)
	await wait_for_signal(display.tree_entered, 0.1)
	primary_weapon_change_requested_times_called = 0
	powerup_change_requested_times_called = 0
	movement_bonus_change_requested_times_called = 0
	name_changed_times_called = 0
	name_changed_args = []


##### TESTS #####
func test_update_player():
	# given
	var player_sprite = double(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerSprite/player_sprite.gd")).new()
	stub(player_sprite, "update_sprite").to_do_nothing()
	display.onready_paths.player_sprite = player_sprite
	var player_config = PlayerConfig.new()
	player_config.PLAYER_NAME = "name"
	var sprite_customization = SpriteCustomizationResource.new()
	player_config.SPRITE_CUSTOMIZATION = sprite_customization
	player_config.PRIMARY_WEAPON = StaticPrimaryWeaponHandler.handlers.REVOLVER
	player_config.POWERUP_HANDLER = StaticPowerupHandler.handlers.SPLITTER
	player_config.MOVEMENT_BONUS_HANDLER = StaticMovementBonusHandler.handlers.DASH
	# when
	display.update_player(player_config)
	# then
	assert_called(player_sprite, "update_sprite")
	assert_eq(display.onready_paths.name.text, "name")
	assert_not_null(display.onready_paths.weapons.primary.icon)
	assert_not_null(display.onready_paths.weapons.powerup.icon)
	assert_not_null(display.onready_paths.weapons.movement_bonus.icon)


func test_update_body():
	# given
	var player_sprite = double(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerSprite/player_sprite.gd")).new()
	stub(player_sprite, "update_body").to_do_nothing()
	display.onready_paths.player_sprite = player_sprite
	# when
	display.update_body(Color.SADDLE_BROWN)
	# then
	assert_called(player_sprite, "update_body", [Color.SADDLE_BROWN])


func test_update_outline():
	# given
	var player_sprite = double(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerSprite/player_sprite.gd")).new()
	stub(player_sprite, "update_outline").to_do_nothing()
	display.onready_paths.player_sprite = player_sprite
	# when
	display.update_outline(Color.SADDLE_BROWN)
	# then
	assert_called(player_sprite, "update_outline", [Color.SADDLE_BROWN])


func test_update_eyes():
	# given
	var player_sprite = double(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerSprite/player_sprite.gd")).new()
	stub(player_sprite, "update_eyes").to_do_nothing()
	display.onready_paths.player_sprite = player_sprite
	# when
	display.update_eyes(load("res://icon.svg"))
	# then
	assert_called(player_sprite, "update_eyes")


func test_update_eyes_color():
	# given
	var player_sprite = double(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerSprite/player_sprite.gd")).new()
	stub(player_sprite, "update_eyes_color").to_do_nothing()
	display.onready_paths.player_sprite = player_sprite
	# when
	display.update_eyes_color(Color.SADDLE_BROWN)
	# then
	assert_called(player_sprite, "update_eyes_color", [Color.SADDLE_BROWN])


func test_update_mouth():
	# given
	var player_sprite = double(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerSprite/player_sprite.gd")).new()
	stub(player_sprite, "update_mouth").to_do_nothing()
	display.onready_paths.player_sprite = player_sprite
	# when
	display.update_mouth(load("res://icon.svg"))
	# then
	assert_called(player_sprite, "update_mouth")


func test_update_mouth_color():
	# given
	var player_sprite = double(load("res://Scenes/UI/PlayerCustomizationMenu/PlayerSprite/player_sprite.gd")).new()
	stub(player_sprite, "update_mouth_color").to_do_nothing()
	display.onready_paths.player_sprite = player_sprite
	# when
	display.update_mouth_color(Color.SADDLE_BROWN)
	# then
	assert_called(player_sprite, "update_mouth_color", [Color.SADDLE_BROWN])


func test_press_primary_weapon_sends_signal():
	# given
	display.primary_weapon_change_requested.connect(_on_primary_weapon_change_requested)
	# when
	display.onready_paths.weapons.primary.pressed.emit()
	# then
	assert_eq(primary_weapon_change_requested_times_called, 1)


func test_press_powerup_sends_signal():
	# given
	display.powerup_change_requested.connect(_on_powerup_change_requested)
	# when
	display.onready_paths.weapons.powerup.pressed.emit()
	# then
	assert_eq(powerup_change_requested_times_called, 1)


func test_press_movement_bonus_sends_signal():
	# given
	display.movement_bonus_change_requested.connect(_on_movement_bonus_change_requested)
	# when
	display.onready_paths.weapons.movement_bonus.pressed.emit()
	# then
	assert_eq(movement_bonus_change_requested_times_called, 1)


func test_change_name_sends_signal():
	# given
	display.name_changed.connect(_on_name_changed)
	# when
	display.onready_paths.name.text_changed.emit("test")
	# then
	assert_eq(name_changed_times_called, 1)
	assert_eq(name_changed_args, [["test"]])


##### UTILS #####
func _on_primary_weapon_change_requested() -> void:
	primary_weapon_change_requested_times_called += 1


func _on_powerup_change_requested() -> void:
	powerup_change_requested_times_called += 1


func _on_movement_bonus_change_requested() -> void:
	movement_bonus_change_requested_times_called += 1


func _on_name_changed(new_name: String) -> void:
	name_changed_times_called += 1
	name_changed_args.append([new_name])

