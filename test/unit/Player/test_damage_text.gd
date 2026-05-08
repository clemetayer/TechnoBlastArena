extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var damage_text

##### SETUP #####
func before_each():
	damage_text = partial_double(load("res://Scenes/Player/damage_text.gd")).new()

##### TESTS #####
func test_process():
	# given
	var paths = load("res://Scenes/Player/paths.gd").new()
	var player_root = load("res://Scenes/Player/player.gd").new()
	player_root.DAMAGE = 251
	paths.player_root = player_root
	var damage_text_mock = partial_double(load("res://Scenes/Player/damage_text.gd")).new()
	stub(damage_text_mock, "update_damage").to_do_nothing()
	damage_text_mock.paths = paths
	# when
	damage_text_mock._process(1.0/60.0)
	# then
	assert_called(damage_text_mock, "update_damage", [251.0])
	# cleanup
	player_root.free()
	paths.free()

func test_init_damage():
	# given
	stub(damage_text, "_update_text_color").to_do_nothing()
	# when
	damage_text.init_damage()
	# then
	assert_called(damage_text, "_update_text_color", ["0",0.0])

var test_damage_params := [
	[250.0,205.0,true],
	[250.0,250.0,false]
]
func test_update_damage(params = use_parameters(test_damage_params)):
	# given
	damage_text._current_damage = params[0]
	stub(damage_text, "_update_text_color").to_do_nothing()
	# when
	damage_text.update_damage(params[1])
	# then
	if params[2]:
		assert_called(damage_text, "_update_text_color", ["%d" % params[1], params[1]])
		assert_not_null(damage_text._hit_text_tween)
	else:
		assert_not_called(damage_text, "_update_text_color")
		assert_null(damage_text._hit_text_tween)

func test_update_text_color():
	# given	
	var new_health = damage_text.MAX_DAMAGE_GRADIENT_VALUE / 2.0
	var expected_color = damage_text._damage_text_gradient.sample(0.5) 
	# when
	var res = damage_text._update_text_color("%d" % [new_health], new_health)
	# then
	assert_eq(res, damage_text.DAMAGE_TEXT_COLOR % [expected_color.to_html(), "%d" % new_health])

func test_update_hit_text():
	# given
	# when
	var res = damage_text._update_hit_text("%d" % 125, 0.5, 3, 0.75)
	# then
	assert_eq(res, damage_text.DAMAGE_TEXT_HIT % [0.5, 0.75, 3, "%d" % 125])

func test_set_hit_text_tween():
	# given
	# when
	damage_text._set_hit_text_tween("%d" % 125, 0.5, 3, 0.75)
	# then
	assert_eq(damage_text.text, damage_text.DAMAGE_TEXT_HIT % [0.5, 0.75, 3, "%d" % 125])
