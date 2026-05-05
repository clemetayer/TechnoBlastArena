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
var toggle_shielding_params := [
	[true],
	[false],
]


func test_toggle_shielding(params = use_parameters(toggle_shielding_params)):
	# given
	# when
	shield.toggle_shielding(params[0])
	# then
	assert_eq(shield._shielding, params[0])


var parry_params := [
	[false, false],
	[true, false],
	[true, true],
]


func test_parry(params = use_parameters(parry_params)):
	# given
	var shielding = params[0]
	var can_parry = params[1]
	shield._shielding = shielding
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
	shield.shield()
	# then
	if shielding:
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


var disable_shield_after_firing_params := [
	[true],
	[false],
]


func test_disable_shield_after_firing(params = use_parameters(disable_shield_after_firing_params)):
	# given
	var shielding = params[0]
	shield._shielding = shielding
	var disable_after_fire_timer = double(Timer).new()
	stub(disable_after_fire_timer, "start").to_do_nothing()
	shield.onready_paths.disable_after_fire_timer = disable_after_fire_timer
	var parry_lockout_sprite = Sprite2D.new()
	parry_lockout_sprite.visible = false
	shield.onready_paths.parry_lockout_sprite = parry_lockout_sprite
	shield._can_parry = true
	# when
	shield.disable_shield_after_firing()
	# then
	if shielding:
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
