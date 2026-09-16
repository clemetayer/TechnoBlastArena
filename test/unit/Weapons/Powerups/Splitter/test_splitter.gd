extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var splitter


##### SETUP #####
func before_each():
	splitter = add_child_autofree(
		load("res://Scenes/Weapons/Powerups/Splitter/splitter.tscn").instantiate()
	)


##### TESTS #####
func test_projectile_entered():
	# given
	var projectile = autofree(
		load("res://test/unit/Weapons/Powerups/Common/projectile_mock.tscn").instantiate()
	)
	var game_root = add_child_autofree(
		load("res://test/unit/Weapons/Powerups/Splitter/mock_game_root.tscn").instantiate()
	)
	game_root.add_child(projectile)
	var runtime_utils = _mock_runtime_utils()
	stub(runtime_utils, "get_game_root").to_return(game_root)
	var init_damage = 150
	var init_knockback = 15
	var expected_damage = (init_damage / splitter.PROJECTILE_DUPLICATES) * splitter.PROJECTILE_DUP_DAMAGE_BONUS_MULTIPLIER
	var expected_knockback = (init_knockback / splitter.PROJECTILE_DUPLICATES) * splitter.PROJECTILE_DUP_KNOCKBACK_BONUS_MULTIPLIER
	projectile.PARAMETERS.DAMAGE = init_damage
	projectile.damage = init_damage
	projectile.PARAMETERS.KNOCKBACK = init_knockback
	projectile.knockback = init_knockback
	# when
	splitter.hitbox.area_entered.emit(projectile)
	await wait_process_frames(1)
	# then
	assert_eq(game_root.get_child_count(), splitter.PROJECTILE_DUPLICATES)
	var expected_angles := []
	for angle_idx in range(1, splitter.PROJECTILE_DUPLICATES + 1):
		expected_angles.append(
			(angle_idx * ((PI / 2) / (splitter.PROJECTILE_DUPLICATES + 1))) - PI / 4
		)
	var seen_angles := []
	for split_proj in game_root.get_children():
		assert_eq(split_proj.damage, expected_damage)
		assert_eq(split_proj.knockback, expected_knockback)
		if (
			_is_almost_in_array(split_proj.rotation, expected_angles)
			and not _is_almost_in_array(split_proj.rotation, seen_angles)
		):
			seen_angles.append(split_proj.rotation)
			expected_angles.erase(split_proj.rotation)
		else:
			fail_test("projectile with angle %s has an invalid rotation" % split_proj.rotation)


##### UTILS #####
func _mock_runtime_utils():
	var runtime_utils = double(load("res://Utils/runtime_utils.gd")).new()
	splitter._runtime_utils = runtime_utils
	return runtime_utils


func _is_almost_in_array(value: float, array: Array) -> bool:
	for element in array:
		if FunctionUtils.in_between(value, element - 0.001, element + 0.001):
			return true
	return false
