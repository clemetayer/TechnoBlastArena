extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var shield: Shield
var parried_times_called := 0
var parried_args := []
var shield_process_times_called := 0
var hit_process_times_called := 0


##### SETUP #####
func before_each():
	shield = autofree(load("res://Scenes/Player/shield.tscn").instantiate())
	parried_times_called = 0
	parried_args = []
	shield_process_times_called = 0
	hit_process_times_called = 0

##### TESTS #####
var toggle_shielding_params := [
	[true],
	[false],
]


func test_toggle_shielding(params = use_parameters(toggle_shielding_params)):
	# given
	var shielding = params[0]
	stub_shield_particles()
	stub_broken_shield_particles()
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
	var shield_particles = stub_shield_particles()
	var broken_shield_particles = stub_broken_shield_particles()
	# when
	shield.toggle_shielding(shielding)
	# then
	assert_called(shield_particles, "set_emitting", [shielding])
	assert_called(broken_shield_particles, "set_emitting", [false])


func test_toggle_shielding_play_animation_broken():
	# given
	shield._firing = false
	shield._shielding = false
	shield._parrying = false
	shield._health = 0
	var shield_particles = stub_shield_particles()
	var broken_shield_particles = stub_broken_shield_particles()
	# when
	shield.toggle_shielding(true)
	# then
	assert_called(broken_shield_particles, "set_emitting", [true])
	assert_called(shield_particles, "set_emitting", [false])


func test_process_hit_not_shielding():
	# given
	shield._shielding = false
	# when
	var hit_result := shield.process_hit(_create_standard_hit_data())
	# then
	assert_eq(hit_result, Shield.HitResult.IGNORED)
	assert_eq(hit_process_times_called, 1)
	assert_eq(shield_process_times_called, 0)
	assert_eq(parried_times_called, 0)


func test_process_hit_shield():
	# given
	var shield_base_health = 500
	var shield_damage = 200
	var expected_health_remaining = 300
	shield._shielding = true
	shield._health = shield_base_health
	var hit_data := _create_standard_hit_data()
	hit_data.shield_damage = shield_damage
	# when
	var hit_result := shield.process_hit(hit_data)
	# then
	assert_eq(hit_result, Shield.HitResult.SHIELDED)
	assert_eq(hit_process_times_called, 0)
	assert_eq(shield_process_times_called, 1)
	assert_eq(parried_times_called, 0)
	assert_eq(shield._health, expected_health_remaining)


func test_process_hit_shield_destroyed():
	# given
	shield._health = 0
	shield._shielding = true
	shield._parrying = true
	# when
	var hit_result := shield.process_hit(_create_standard_hit_data())
	# then
	assert_eq(hit_result, Shield.HitResult.IGNORED)
	assert_eq(hit_process_times_called, 1)
	assert_eq(shield_process_times_called, 0)
	assert_eq(parried_times_called, 0)


func test_process_hit_parry():
	# given
	shield._shielding = true
	shield._parrying = true
	var shield_owner = autofree(Node2D.new())
	var input_synchronizer = autofree(load("res://Scenes/Player/input_synchronizer.gd").new())
	var paths = autofree(load("res://Scenes/Player/paths.gd").new())
	paths.player_root = shield_owner
	paths.input_synchronizer = input_synchronizer
	input_synchronizer.relative_aim_position = Vector2.ONE
	shield.paths = paths
	# when
	var hit_result := shield.process_hit(_create_standard_hit_data())
	# then
	assert_eq(hit_result, Shield.HitResult.PARRIED)
	assert_eq(hit_process_times_called, 0)
	assert_eq(shield_process_times_called, 0)
	assert_eq(parried_times_called, 1)
	assert_eq(parried_args, [[shield_owner, Vector2.ONE]])


func test_process_hit_ignore_if_firing():
	# given
	shield._firing = true
	shield._shielding = true
	shield._parrying = true
	# when
	var hit_result := shield.process_hit(_create_standard_hit_data())
	# then
	assert_eq(hit_result, Shield.HitResult.IGNORED)
	assert_eq(hit_process_times_called, 1)
	assert_eq(shield_process_times_called, 0)
	assert_eq(parried_times_called, 0)


func test_proccess_hit_shield_broken():
	# given
	var parent = _create_parent_arborescence()
	parent.add_child(shield)
	shield._firing = false
	shield._shielding = true
	shield._parrying = false
	shield._health = 1
	var regen_bar := set_real_broken_shield_regen_bar()
	# when
	var hit_result := shield.process_hit(_create_standard_hit_data())
	# then
	assert_eq(hit_result, Shield.HitResult.SHIELDED)
	assert_eq(hit_process_times_called, 0)
	assert_eq(shield_process_times_called, 1)
	assert_eq(parried_times_called, 0)
	assert_true(regen_bar.visible)
	assert_eq(regen_bar.value, 0)
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
	await wait_seconds(shield.SHIELD_REGEN_TIME)
	# then
	assert_eq(shield._health, shield.BASE_SHIELD_HEALTH)
	assert_false(regen_bar.visible)


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


func stub_shield_particles() -> GPUParticles2D:
	var shield_particles = double(GPUParticles2D).new()
	stub(shield_particles, "set_emitting").to_do_nothing()
	shield.onready_paths.shield_particles = shield_particles
	return shield_particles


func stub_broken_shield_particles() -> GPUParticles2D:
	var broken_shield_particles = double(GPUParticles2D).new()
	stub(broken_shield_particles, "set_emitting").to_do_nothing()
	shield.onready_paths.broken_shield_particles = broken_shield_particles
	return broken_shield_particles


func stub_broken_shield_regen_bar() -> ProgressBar:
	var broken_shield_regen_bar = double(ProgressBar).new()
	stub(broken_shield_regen_bar, "set_value").to_do_nothing()
	stub(broken_shield_regen_bar, "set_visible").to_do_nothing()
	shield.onready_paths.broken_shield_regen_bar = broken_shield_regen_bar
	return broken_shield_regen_bar


func set_real_broken_shield_regen_bar() -> ProgressBar:
	var broken_shield_regen_bar = ProgressBar.new()
	add_child_autofree(broken_shield_regen_bar)
	shield.onready_paths.broken_shield_regen_bar = broken_shield_regen_bar
	return broken_shield_regen_bar


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


func _on_hit_process() -> void:
	hit_process_times_called += 1
