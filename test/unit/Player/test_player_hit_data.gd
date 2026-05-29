extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- CONSTANTS -----
# const CONST := "value"

#---- VARIABLES -----
# var variable := "value"

##### SETUP #####
func before_all():
	pass


func before_each():
	pass


##### TEARDOWN #####
func after_all():
	pass


func after_each():
	pass

##### TESTS #####

var get_hitstop_duration_params := [
	[PlayerHitData.DAMAGE_TRESHOLDS[0] - 1.0, PlayerHitData.KNOCKBACK_TRESHOLDS[0] - 1.0, PlayerHitData.HITSTOP_DURATIONS[0]], # 0 - 0
	[PlayerHitData.DAMAGE_TRESHOLDS[0] + 1.0, PlayerHitData.KNOCKBACK_TRESHOLDS[0] - 1.0, PlayerHitData.HITSTOP_DURATIONS[0]], # 1 - 0
	[PlayerHitData.DAMAGE_TRESHOLDS[0] - 1.0, PlayerHitData.KNOCKBACK_TRESHOLDS[0] + 1.0, PlayerHitData.HITSTOP_DURATIONS[0]], # 0 - 1
	[PlayerHitData.DAMAGE_TRESHOLDS[0] + 1.0, PlayerHitData.KNOCKBACK_TRESHOLDS[0] + 1.0, PlayerHitData.HITSTOP_DURATIONS[1]], # 1 - 1
	[PlayerHitData.DAMAGE_TRESHOLDS[0] - 1.0, PlayerHitData.KNOCKBACK_TRESHOLDS[1] + 1.0, PlayerHitData.HITSTOP_DURATIONS[1]], # 0 - 2
	[PlayerHitData.DAMAGE_TRESHOLDS[1] + 1.0, PlayerHitData.KNOCKBACK_TRESHOLDS[0] - 1.0, PlayerHitData.HITSTOP_DURATIONS[1]], # 2 - 0
	[PlayerHitData.DAMAGE_TRESHOLDS[0] + 1.0, PlayerHitData.KNOCKBACK_TRESHOLDS[1] + 1.0, PlayerHitData.HITSTOP_DURATIONS[2]], # 1 - 2
	[PlayerHitData.DAMAGE_TRESHOLDS[1] + 1.0, PlayerHitData.KNOCKBACK_TRESHOLDS[1] - 1.0, PlayerHitData.HITSTOP_DURATIONS[2]], # 2 - 1
	[PlayerHitData.DAMAGE_TRESHOLDS[1] + 1.0, PlayerHitData.KNOCKBACK_TRESHOLDS[1] + 1.0, PlayerHitData.HITSTOP_DURATIONS[2]], # 2 - 2
]


func test_get_hitstop_duration(params = use_parameters(get_hitstop_duration_params)):
	# given
	var damage = params[0]
	var knockback = params[1]
	var expected_duration = params[2]
	var hit_data = create_default_player_hit_data()
	hit_data.damage = damage
	hit_data.knockback = Vector2.RIGHT * knockback
	# when
	var duration = hit_data.get_hitstop_duration()
	# then
	assert_almost_eq(duration, expected_duration, 0.0001)


##### UTILS #####
func create_default_player_hit_data() -> PlayerHitData:
	return PlayerHitData.new(
		Vector2.ONE * 1.0,
		1.0,
		autofree(Node2D.new()),
		1.0,
	)
