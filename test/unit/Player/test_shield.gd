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
	# when
	shield.toggle_shielding(shielding)
	# then
	assert_eq(shield._shielding, shielding)


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


var process_hit_shield_params := [
	[500, 200, 300],
	[100, 200, 0],
]


func test_process_hit_shield(params = use_parameters(process_hit_shield_params)):
	# given
	var shield_base_health = params[0]
	var shield_damage = params[1]
	var expected_health_remaining = params[2]
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


func _on_parried(p_owner: Node2D, relative_aim_position: Vector2) -> void:
	parried_times_called += 1
	parried_args.append([p_owner, relative_aim_position])


func _on_shield_process() -> void:
	shield_process_times_called += 1


func _on_hit_process() -> void:
	hit_process_times_called += 1
