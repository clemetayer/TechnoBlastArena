extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const TEST_PARRY_TIME_WINDOW = 3.0 / 60.0
const TEST_SHIELD_PASSIVE_REGEN_TIME = 5.0 / 60.0
const MOCK_AUDIO = preload("res://test/unit/Player/test_player/mock_audio.tscn")

#---- VARIABLES -----
var shield: Shield
var parried_times_called := 0
var parried_args := []
var shield_process_times_called := 0
var hit_process_times_called := 0
var hit_process_args := []


##### SETUP #####
func before_each():
	shield = autofree(load("res://Scenes/Player/shield.tscn").instantiate())
	parried_times_called = 0
	parried_args = []
	shield_process_times_called = 0
	hit_process_times_called = 0
	hit_process_args = []

##### TESTS #####
var toggle_shielding_params := [
	[true],
	[false],
]


func test_toggle_shielding(params = use_parameters(toggle_shielding_params)):
	# given
	var shielding = params[0]
	set_real_shield_particles()
	set_real_broken_shield_particles()
	set_real_shield_sound()
	set_real_shield_broken_sound()
	# when
	shield.toggle_shielding(shielding)
	# then
	assert_eq(shield._shielding, shielding)


var toggle_shielding_play_animation_not_broken_params := [
	[true],
	[false],
]


func test_toggle_shielding_play_animation_not_broken(params = use_parameters(toggle_shielding_play_animation_not_broken_params)):
	# given
	var shielding = params[0]
	shield._firing = false
	shield._shielding = false
	shield._parrying = false
	shield._health = 500
	var shield_particles = set_real_shield_particles()
	var broken_shield_particles = set_real_broken_shield_particles()
	var sound = set_real_shield_sound()
	var broken_sound = set_real_shield_broken_sound()
	# when
	shield.toggle_shielding(shielding)
	# then
	assert_eq(shield_particles.emitting, shielding)
	assert_false(broken_shield_particles.emitting)
	assert_eq(sound.playing, shielding)
	assert_false(broken_sound.playing)


func test_toggle_shielding_play_animation_broken():
	# given
	shield._firing = false
	shield._shielding = false
	shield._parrying = false
	shield._health = 0
	var shield_particles = set_real_shield_particles()
	var broken_shield_particles = set_real_broken_shield_particles()
	var sound = set_real_shield_sound()
	var broken_sound = set_real_shield_broken_sound()
	# when
	shield.toggle_shielding(true)
	# then
	assert_true(broken_shield_particles.emitting)
	assert_false(shield_particles.emitting)
	assert_true(broken_sound.playing)
	assert_false(sound.playing)


var toggle_shielding_set_color_params := [
	[Shield.BASE_SHIELD_HEALTH, 0.0],
	[Shield.BASE_SHIELD_HEALTH / 2.0, 0.5],
	[0.0, 1.0],
]


func test_toggle_shielding_set_color(params = use_parameters(toggle_shielding_set_color_params)):
	# given
	var health = params[0]
	var gradient_value = params[1]
	var gradient: Gradient = Shield.DAMAGE_GRADIENT
	shield._health = health
	var shield_particles = set_real_shield_particles()
	set_real_broken_shield_particles()
	set_real_shield_sound()
	set_real_shield_broken_sound()
	# when
	shield.toggle_shielding(true)
	# then
	assert_eq(shield_particles.modulate, gradient.sample(gradient_value))


var activate_parry_params := [
	[true],
	[false],
]


func test_activate_parry(params = use_parameters(activate_parry_params)):
	# given
	var is_broken = params[0]
	shield._health = 0 if is_broken else Shield.BASE_SHIELD_HEALTH
	set_real_parry_time_window()
	var sound = set_real_shield_init_sound()
	# when
	shield.activate_parry()
	# then
	assert_eq(shield._parrying, not is_broken)
	assert_eq(sound.playing, not is_broken)
	await wait_seconds(TEST_PARRY_TIME_WINDOW + 1.0 / 30.0)
	assert_false(shield._parrying)


func test_process_hit_not_shielding():
	# given
	shield._shielding = false
	var player_root = autofree(Node2D.new())
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	paths.player_root = player_root
	shield.paths = paths
	# when
	var hit_result := shield.process_hit(_create_standard_hit_data())
	# then
	assert_eq(hit_result, Shield.HitResult.IGNORED)
	assert_eq(hit_process_times_called, 1)
	assert_eq(hit_process_args, [[player_root]])
	assert_eq(shield_process_times_called, 0)
	assert_eq(parried_times_called, 0)


func test_process_hit_shield():
	# given
	var shield_base_health = 150
	var shield_damage = 30
	var expected_health_remaining = 120
	shield._shielding = true
	shield._health = shield_base_health
	var hit_data := _create_standard_hit_data()
	hit_data.shield_damage = shield_damage
	var sound = set_real_shield_absorbed_sound()
	# when
	var hit_result := shield.process_hit(hit_data)
	# then
	assert_eq(hit_result, Shield.HitResult.SHIELDED)
	assert_eq(hit_process_times_called, 0)
	assert_eq(shield_process_times_called, 1)
	assert_eq(parried_times_called, 0)
	assert_eq(shield._health, expected_health_remaining)
	assert_true(sound.playing)


func test_process_hit_shield_destroyed():
	# given
	shield._health = 0
	shield._shielding = true
	shield._parrying = true
	var player_root = autofree(Node2D.new())
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	paths.player_root = player_root
	shield.paths = paths
	# when
	var hit_result := shield.process_hit(_create_standard_hit_data())
	# then
	assert_eq(hit_result, Shield.HitResult.IGNORED)
	assert_eq(hit_process_times_called, 1)
	assert_eq(hit_process_args, [[player_root]])
	assert_eq(shield_process_times_called, 0)
	assert_eq(parried_times_called, 0)


func test_process_hit_parry():
	# given
	shield._shielding = true
	shield._parrying = true
	var shield_owner = autofree(Node2D.new())
	var input_synchronizer = autofree(load("res://Scenes/Player/input_synchronizer.gd").new())
	var stop_manager = double(load("res://Scenes/Player/stop_manager.gd")).new()
	stub(stop_manager, "stop_for_duration").to_do_nothing()
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	paths.player_root = shield_owner
	paths.input_synchronizer = input_synchronizer
	paths.stop_manager = stop_manager
	input_synchronizer.relative_aim_position = Vector2.ONE
	shield.paths = paths
	var sound = set_real_parry_sound()
	# when
	var hit_result := shield.process_hit(_create_standard_hit_data())
	# then
	assert_eq(hit_result, Shield.HitResult.PARRIED)
	assert_eq(hit_process_times_called, 0)
	assert_eq(shield_process_times_called, 0)
	assert_eq(parried_times_called, 1)
	assert_eq(parried_args, [[shield_owner, Vector2.ONE]])
	assert_called(stop_manager, "stop_for_duration", [Shield.PARRY_STOP_TIME])
	assert_true(sound.playing)


func test_process_hit_ignore_if_firing():
	# given
	shield._firing = true
	shield._shielding = true
	shield._parrying = true
	var player_root = autofree(Node2D.new())
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	paths.player_root = player_root
	shield.paths = paths
	# when
	var hit_result := shield.process_hit(_create_standard_hit_data())
	# then
	assert_eq(hit_result, Shield.HitResult.IGNORED)
	assert_eq(hit_process_times_called, 1)
	assert_eq(hit_process_args, [[player_root]])
	assert_eq(shield_process_times_called, 0)
	assert_eq(parried_times_called, 0)


func test_process_hit_shield_broken():
	# given
	var parent = _create_parent_arborescence()
	parent.add_child(shield)
	shield._firing = false
	shield._shielding = true
	shield._parrying = false
	shield._health = 1
	var regen_bar := set_real_broken_shield_regen_bar()
	var broken_shield_anim_particles := set_real_shield_broken_anim_particles()
	var sound = set_real_shield_regenerated_sound()
	# when
	var hit_result := shield.process_hit(_create_standard_hit_data())
	# then
	assert_eq(hit_result, Shield.HitResult.SHIELDED)
	assert_eq(hit_process_times_called, 0)
	assert_eq(shield_process_times_called, 1)
	assert_eq(parried_times_called, 0)
	assert_true(regen_bar.visible)
	assert_eq(regen_bar.value, 0)
	assert_true(broken_shield_anim_particles.emitting)
	await wait_process_frames(3)
	assert_not_null(shield._regen_tween)
	if not is_instance_valid(shield._regen_tween):
		return
	assert_true(shield._regen_tween.is_running())
	# when
	await wait_seconds(0.1)
	# then
	assert_gt(regen_bar.value, 0)
	# when
	await wait_seconds(shield.SHIELD_BROKEN_REGEN_TIME)
	# then
	assert_eq(shield._health, shield.BASE_SHIELD_HEALTH)
	assert_false(regen_bar.visible)
	assert_true(sound.playing)


var toggle_firing_disable_params := [
	[true],
	[false],
]


func test_toggle_firing_disable(params = use_parameters(toggle_firing_disable_params)):
	# given
	var firing = params[0]
	# when
	shield.toggle_firing_disable(firing)
	# then
	assert_eq(shield._firing, firing)


var shield_passive_regen_params := [
	[90, 90 + Shield.SHIELD_PASSIVE_HEALTH_REGEN_PER_TICK],
	[150, 150],
]


func test_shield_passive_regen(params = use_parameters(shield_passive_regen_params)):
	# given
	var base_health = params[0]
	var expected_health_after_tick = params[1]
	shield._health = base_health
	set_real_shield_passive_regen_timer()
	# when
	await wait_seconds(TEST_SHIELD_PASSIVE_REGEN_TIME + 2.0 / 60.0)
	# then
	assert_eq(shield._health, expected_health_after_tick)


func test_shield_passive_regen_broken_shield():
	# given
	shield._health = 0
	set_real_shield_passive_regen_timer()
	# when
	await wait_seconds(TEST_SHIELD_PASSIVE_REGEN_TIME + 2.0 / 60.0)
	# then
	assert_eq(shield._health, 0)


##### UTILS #####
func _create_standard_hit_data() -> PlayerHitData:
	return PlayerHitData.new(
		Vector2.ONE,
		200,
		autofree(Node2D.new()),
		150,
		_on_parried,
		_on_shield_process,
		_on_hit_process,
	)


func _add_node_on_path(node: Node, variable: String) -> Node:
	add_child_autofree(node)
	shield[variable] = node
	return node


func set_real_shield_particles() -> GPUParticles2D:
	return _add_node_on_path(GPUParticles2D.new(), "shield_particles")


func set_real_broken_shield_particles() -> GPUParticles2D:
	return _add_node_on_path(GPUParticles2D.new(), "broken_shield_particles")


func set_real_broken_shield_regen_bar() -> ProgressBar:
	return _add_node_on_path(ProgressBar.new(), "broken_shield_regen_bar")


func set_real_shield_broken_anim_particles() -> GPUParticles2D:
	return _add_node_on_path(GPUParticles2D.new(), "broken_shield_anim_particles")


func set_real_parry_time_window() -> Timer:
	var timer := Timer.new()
	timer.one_shot = true
	timer.set_wait_time(TEST_PARRY_TIME_WINDOW)
	timer.timeout.connect(shield._on_parry_time_window_timeout)
	return _add_node_on_path(timer, "parry_time_window")


func set_real_shield_passive_regen_timer() -> Timer:
	var timer := Timer.new()
	timer.set_autostart(true)
	timer.set_wait_time(TEST_SHIELD_PASSIVE_REGEN_TIME)
	timer.timeout.connect(shield._on_shield_passive_regen_timeout)
	add_child_autofree(timer)
	return timer


func set_real_shield_sound() -> AudioStreamPlayer2D:
	return _add_node_on_path(MOCK_AUDIO.instantiate(), "shield_sound")


func set_real_shield_absorbed_sound() -> AudioStreamPlayer2D:
	return _add_node_on_path(MOCK_AUDIO.instantiate(), "shield_absorbed_sound")


func set_real_shield_break_sound() -> AudioStreamPlayer2D:
	return _add_node_on_path(MOCK_AUDIO.instantiate(), "shield_break_sound")


func set_real_shield_broken_sound() -> AudioStreamPlayer2D:
	return _add_node_on_path(MOCK_AUDIO.instantiate(), "shield_broken_sound")


func set_real_shield_init_sound() -> AudioStreamPlayer2D:
	return _add_node_on_path(MOCK_AUDIO.instantiate(), "shield_init_sound")


func set_real_shield_regenerated_sound() -> AudioStreamPlayer2D:
	return _add_node_on_path(MOCK_AUDIO.instantiate(), "shield_regenerated_sound")


func set_real_parry_sound() -> AudioStreamPlayer2D:
	return _add_node_on_path(MOCK_AUDIO.instantiate(), "parry_sound")


func _create_parent_arborescence() -> Node2D:
	var parent := Node2D.new()
	var paths = autofree(Node2D.new())
	paths.name = "Paths"
	parent.add_child(paths)
	add_child_autofree(parent)
	return parent


func _on_parried(p_owner: Node2D, relative_aim_position: Vector2) -> void:
	parried_times_called += 1
	parried_args.append([p_owner, relative_aim_position])


func _on_shield_process() -> void:
	shield_process_times_called += 1


func _on_hit_process(with: Node2D) -> void:
	hit_process_times_called += 1
	hit_process_args.append([with])
