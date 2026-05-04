extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var shield
var parried_times_called := 0


##### SETUP #####
func before_each():
	parried_times_called = 0
	shield = load("res://Scenes/Player/shield.gd").new()


##### TEARDOWN #####
func after_each():
	shield.free()

##### TESTS #####
var toggle_parry_enabled_params := [
	[true],
	[false],
]


func test_toggle_parry_enabled(params = use_parameters(toggle_parry_enabled_params)):
	# given
	# when
	shield.toggle_parry_enabled(params[0])
	# then
	assert_eq(shield._enabled, params[0])


var parry_params := [
	[false, false],
	[true, false],
	[true, true],
]


func test_parry(params = use_parameters(parry_params)):
	# given
	var enabled = params[0]
	var can_parry = params[1]
	shield._enabled = enabled
	shield._can_parry = can_parry
	shield._parrying = false
	var parry_timer = double(Timer).new()
	stub(parry_timer, "start").to_do_nothing()
	shield.onready_paths.parry_timer = parry_timer
	var animation_player = double(AnimationPlayer).new()
	stub(animation_player, "play").to_do_nothing()
	shield.onready_paths.animation_player = animation_player
	var parry_active_sound = double(AudioStreamPlayer).new()
	stub(parry_active_sound, "play").to_do_nothing()
	shield.onready_paths.parry_active_sound = parry_active_sound
	var parry_disabled_sound = double(AudioStreamPlayer).new()
	stub(parry_disabled_sound, "play").to_do_nothing()
	shield.onready_paths.parry_disabled_sound = parry_disabled_sound
	# when
	shield.parry()
	# then
	if enabled:
		if can_parry:
			assert_true(shield._parrying)
			assert_called(parry_timer, "start")
			assert_called(animation_player, "play", ["parrying", null, null, null])
			assert_called(parry_active_sound, "play")
			assert_not_called(parry_disabled_sound, "play")
		else:
			assert_false(shield._parrying)
			assert_not_called(parry_timer, "start")
			assert_not_called(animation_player, "play", ["parrying", null, null, null])
			assert_not_called(parry_active_sound, "play")
			assert_called(parry_disabled_sound, "play")
	else:
		assert_false(shield._parrying)
		assert_not_called(parry_timer, "start")
		assert_not_called(animation_player, "play", ["parrying", null, null, null])
		assert_not_called(parry_active_sound, "play")
		assert_not_called(parry_disabled_sound, "play")


var disable_parry_after_firing_params := [
	[true],
	[false],
]


func test_disable_parry_after_firing(params = use_parameters(disable_parry_after_firing_params)):
	# given
	var enabled = params[0]
	shield._enabled = enabled
	var disable_after_fire_timer = double(Timer).new()
	stub(disable_after_fire_timer, "start").to_do_nothing()
	shield.onready_paths.disable_after_fire_timer = disable_after_fire_timer
	var parry_lockout_sprite = Sprite2D.new()
	parry_lockout_sprite.visible = false
	shield.onready_paths.parry_lockout_sprite = parry_lockout_sprite
	shield._can_parry = true
	# when
	shield.disable_parry_after_firing()
	# then
	if enabled:
		assert_called(disable_after_fire_timer, "start")
		assert_false(shield._can_parry)
		assert_true(parry_lockout_sprite.visible)
	else:
		assert_not_called(disable_after_fire_timer, "start")
		assert_true(shield._can_parry)
		assert_false(parry_lockout_sprite.visible)
	# cleanup
	parry_lockout_sprite.free()


var toggle_can_parry_params := [
	[true],
	[false],
]


func test_toggle_can_parry(params = use_parameters(toggle_can_parry_params)):
	# given
	var enabled = params[0]
	var parry_lockout_sprite = Sprite2D.new()
	shield.onready_paths.parry_lockout_sprite = parry_lockout_sprite
	# when
	shield._toggle_can_parry(enabled)
	# then
	assert_eq(shield._can_parry, enabled)
	assert_eq(parry_lockout_sprite.visible, not enabled)
	# cleanup
	parry_lockout_sprite.free()


var on_area_entered_params := [
	[false, false, false],
	[false, true, false],
	[false, false, true],
	[true, true, false],
	[false, true, true],
	[true, true, true],
]


func test_on_area_entered(params = use_parameters(on_area_entered_params)):
	# given
	var is_projectile = params[0]
	var parrying = params[1]
	var can_parry = params[2]
	var is_parry_valid = is_projectile and parrying and can_parry
	var area = partial_double(load("res://Scenes/Weapons/Projectiles/Bullet/bullet.gd")).new()
	if is_projectile:
		area.add_to_group(GroupUtils.PROJECTILE_GROUP_NAME, false)
	shield._parrying = parrying
	shield._can_parry = can_parry
	var parry_owner = Node2D.new()
	shield._owner = parry_owner
	var onready_paths_node = load("res://Scenes/Player/paths.gd").new()
	var input_synchronizer = load("res://Scenes/Player/input_synchronizer.gd").new()
	onready_paths_node.input_synchronizer = input_synchronizer
	shield.onready_paths_node = onready_paths_node
	input_synchronizer.relative_aim_position = Vector2.RIGHT
	var parry_timer = double(Timer).new()
	stub(parry_timer, "stop").to_do_nothing()
	shield.onready_paths.parry_timer = parry_timer
	var animation_player = double(AnimationPlayer).new()
	stub(animation_player, "play").to_do_nothing()
	shield.onready_paths.animation_player = animation_player
	var parry_sound = double(AudioStreamPlayer).new()
	stub(parry_sound, "play").to_do_nothing()
	shield.onready_paths.parry_sound = parry_sound
	var parry_lockout_sprite = Sprite2D.new()
	parry_lockout_sprite.visible = true
	shield.onready_paths.parry_lockout_sprite = parry_lockout_sprite
	stub(area, "parried").to_do_nothing()
	var camera_effects = double(load("res://Scenes/Camera/camera_effects.gd")).new()
	shield._camera_effects = camera_effects
	stub(camera_effects, "emit_signal_start_camera_impact").to_do_nothing()
	var scene_utils = double(load("res://Utils/scene_utils.gd")).new()
	shield._scene_utils = scene_utils
	stub(scene_utils, "freeze_scene_parry").to_do_nothing()
	shield.connect("parried", _on_parried)
	# when
	shield._on_area_entered(area)
	# then
	if is_parry_valid:
		assert_called(animation_player, "play", ["parried", null, null, null])
		assert_called(parry_sound, "play")
		assert_called(parry_timer, "stop")
		assert_false(parry_lockout_sprite.visible)
		assert_true(shield._can_parry)
		assert_false(shield._parrying)
		assert_called(area, "parried", [parry_owner, Vector2.RIGHT])
		assert_called(camera_effects, "emit_signal_start_camera_impact", [shield.PARRY_FREEZE_TIME, CameraEffects.CAMERA_IMPACT_INTENSITY.LIGHT, CameraEffects.CAMERA_IMPACT_PRIORITY.MEDIUM])
		assert_called(scene_utils, "freeze_scene_parry", [shield.PARRY_FREEZE_TIME])
	else:
		assert_not_called(animation_player, "play")
		assert_not_called(parry_sound, "play")
		assert_not_called(parry_timer, "stop")
		assert_true(parry_lockout_sprite.visible)
		assert_eq(shield._can_parry, can_parry)
		assert_eq(shield._parrying, parrying)
		assert_not_called(area, "parried")
		assert_not_called(camera_effects, "emit_signal_start_camera_impact")
		assert_not_called(scene_utils, "freeze_scene_parry")
	# cleanup
	parry_lockout_sprite.free()
	input_synchronizer.free()
	onready_paths_node.free()
	parry_owner.free()


func test_on_lockout_timer_timeout():
	# given
	var parry_lockout_sprite = Sprite2D.new()
	parry_lockout_sprite.visible = true
	shield.onready_paths.parry_lockout_sprite = parry_lockout_sprite
	shield._can_parry = false
	# when
	shield._on_lockout_timer_timeout()
	# then
	assert_true(shield._can_parry)
	assert_false(shield._parrying)
	assert_false(parry_lockout_sprite.visible)
	# cleanup
	parry_lockout_sprite.free()


func test_on_disable_after_fire_timer_timeout():
	# given
	var parry_lockout_sprite = Sprite2D.new()
	parry_lockout_sprite.visible = true
	shield.onready_paths.parry_lockout_sprite = parry_lockout_sprite
	shield._can_parry = false
	# when
	shield._on_disable_after_fire_timer_timeout()
	# then
	assert_true(shield._can_parry)
	assert_false(shield._parrying)
	assert_false(parry_lockout_sprite.visible)
	# cleanup
	parry_lockout_sprite.free()


func test_on_parry_timer_timeout():
	# given
	shield._can_parry = true
	shield._parrying = true
	var parry_lockout_sprite = Sprite2D.new()
	parry_lockout_sprite.visible = false
	shield.onready_paths.parry_lockout_sprite = parry_lockout_sprite
	var lockout_timer = double(Timer).new()
	stub(lockout_timer, "start").to_do_nothing()
	shield.onready_paths.lockout_timer = lockout_timer
	# when
	shield._on_parry_timer_timeout()
	# then
	assert_false(shield._can_parry)
	assert_false(shield._parrying)
	assert_true(parry_lockout_sprite.visible)
	assert_called(lockout_timer, "start")
	# cleanup
	parry_lockout_sprite.free()


func test_on_player_abilities_toggled():
	# given
	var enabled = false
	var parry_lockout_sprite = Sprite2D.new()
	shield.onready_paths.parry_lockout_sprite = parry_lockout_sprite
	# when
	shield._on_player_abilities_toggled(enabled)
	# then
	assert_eq(shield._can_parry, enabled)
	assert_eq(parry_lockout_sprite.visible, not enabled)
	# cleanup
	parry_lockout_sprite.free()


##### UTILS #####
func _on_parried() -> void:
	parried_times_called += 1
