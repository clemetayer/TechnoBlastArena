extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var appear_elements
var appear_animation_finished_times_called := 0


##### SETUP #####
func before_each():
	appear_elements = load("res://Scenes/Player/appear_elements.gd").new()
	appear_animation_finished_times_called = 0


##### TEARDOWN #####
func after_each():
	appear_elements.free()


##### TESTS #####
func test_init():
	# given
	var main_color = Color.RED
	var secondary_color = Color.BLUE
	var main_color_light = main_color
	main_color_light.h = 50
	var secondary_color_light = secondary_color
	secondary_color_light.h = 50
	var sprite = Sprite2D.new()
	var particles_main = GPUParticles2D.new()
	var particles_secondary = GPUParticles2D.new()
	appear_elements.onready_paths = {
		"sprite": sprite,
		"particles": {
			"main": particles_main,
			"secondary": particles_secondary,
		},
	}
	# when
	appear_elements.init(main_color, secondary_color)
	# then
	assert_eq(sprite.modulate, main_color_light)
	assert_eq(particles_main.modulate, main_color_light)
	assert_eq(particles_secondary.modulate, secondary_color_light)
	# cleanup
	sprite.free()
	particles_main.free()
	particles_secondary.free()


func test_play_spawn_animation():
	# given
	var paths = load("res://Scenes/Player/paths.gd").new()
	var animation_player = double(AnimationPlayer).new()
	stub(animation_player, "play").to_do_nothing()
	paths.animation_player = animation_player
	appear_elements.paths = paths
	# when
	appear_elements.play_spawn_animation()
	# then
	assert_called(animation_player, "play", ["appear", null, null, null])
	# cleanup
	paths.free()


var on_animation_player_animation_finished_params := [
	["appear", true],
	["not_appear", false],
]


func test_on_animation_player_animation_finished(params = use_parameters(on_animation_player_animation_finished_params)):
	# given
	appear_elements.connect("appear_animation_finished", _on_appear_animation_finished)
	# when
	appear_elements._on_animation_player_animation_finished(params[0])
	# then
	assert_eq(appear_animation_finished_times_called, 1 if params[1] else 0)


##### UTILS #####
func _on_appear_animation_finished() -> void:
	appear_animation_finished_times_called += 1
