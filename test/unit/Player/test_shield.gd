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
	shield = load("res://Scenes/Player/shield.gd").new()
	parried_times_called = 0
	parried_args = []
	shield_process_times_called = 0
	hit_process_times_called = 0


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


func test_process_hit_shield():
	# given
	shield._shielding = true
	# when
	var hit_result := shield.process_hit(_create_standard_hit_data())
	# then
	assert_eq(hit_result, Shield.HitResult.SHIELDED)
	assert_eq(hit_process_times_called, 0)
	assert_eq(shield_process_times_called, 1)
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
