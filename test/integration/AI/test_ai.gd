extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
const PLAYER_SCENE_PATH := preload("res://Scenes/Player/player.tscn")
const FIGHT_TIME := 10 #s
const LIVES := 99

#---- VARIABLES -----
var scene


##### SETUP #####
func before_each():
	scene = load("res://test/integration/AI/ai_scene.tscn").instantiate()
	add_child_autofree(scene)
	await wait_process_frames(1)


##### TESTS #####
func test_all_ai():
	# given
	var ai_profiles = load("res://Resources/AIPresets/ai_profiles.tres").RESOURCES
	var partitionned_profiles = StaticUtils.partition_array(ai_profiles, 4)
	print("ai_profiles = %s, partitions = %s" % [ai_profiles, partitionned_profiles])
	# when
	for partition in partitionned_profiles:
		_generate_ai_fight(partition)
		await wait_seconds(FIGHT_TIME)
	# then
	assert_true(true) # success, no ai crashed.


##### UTILS #####
func _generate_ai_fight(config_partition: Array):
	var data = { }
	if config_partition.size() == 1:
		data = {
			0: {
				"config": config_partition[0],
				"lives": LIVES,
			},
			1: {
				"config": config_partition[0],
				"lives": LIVES,
			},
		}
	else:
		for config_idx in range(config_partition.size()):
			data[config_idx] = {
				"config": config_partition[config_idx],
				"lives": LIVES,
			}
	scene.init_players_data(data)
	scene.add_game_elements()
