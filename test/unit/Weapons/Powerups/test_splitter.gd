extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var splitter
var destroyed_times_called := 0
var destroyed_args := []


##### SETUP #####
func before_each():
	splitter = load("res://Scenes/Weapons/Powerups/Splitter/splitter.gd").new()
	destroyed_times_called = 0
	destroyed_args = []


##### TEARDOWN #####
func after_each():
	splitter.free()


##### TESTS #####
func test_spawn_projectile():
	# given
	var projectile = autofree(Node2D.new())
	var runtime_utils = double(load("res://Utils/runtime_utils.gd")).new()
	splitter._runtime_utils = runtime_utils
	var game_root = double(load("res://Scenes/Game/game.gd"), DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	stub(game_root, "spawn_projectile").to_do_nothing()
	stub(runtime_utils, "get_game_root").to_return(game_root)
	splitter._runtime_utils = runtime_utils
	# when
	splitter._spawn_projectile(projectile)
	# then
	assert_called(game_root, "spawn_projectile", [projectile])


func test_duplicate_projectile_with_angle():
	# given
	var projectile = autofree(load("res://Scenes/Weapons/Projectiles/Bullet/bullet.gd").new())
	var current_owner = autofree(Node2D.new())
	projectile.current_owner = current_owner
	var splitter_mock = partial_double(load("res://Scenes/Weapons/Powerups/Splitter/splitter.gd")).new()
	stub(splitter_mock, "_spawn_projectile").to_do_nothing()
	# when
	splitter_mock._duplicate_projectile_with_angle(projectile, PI / 4.0)
	# then
	assert_called(splitter_mock, "_spawn_projectile")
	assert_eq(splitter_mock._whitelist.size(), 1)
	var duplicated_projectile = splitter_mock._whitelist[0]
	assert_eq(duplicated_projectile.current_owner, current_owner)
	assert_eq(duplicated_projectile.init_rotation, projectile.rotation + PI / 4.0)
	assert_eq(duplicated_projectile.init_position, projectile.global_position)


func test_handle_feedback():
	# given
	var audio = double(AudioStreamPlayer).new()
	stub(audio, "play").to_do_nothing()
	var hit_effect = add_child_autofree(GPUParticles2D.new())
	hit_effect.emitting = false
	splitter.onready_paths.audio = audio
	splitter.onready_paths.hit_effect = hit_effect
	# when
	splitter._handle_feedback()
	# then
	assert_called(audio, "play")
	assert_true(hit_effect.emitting)


func test_prepare_for_deletion():
	# given
	var collision = CollisionShape2D.new()
	var sprite = Sprite2D.new()
	sprite.show()
	var audio = AudioStreamPlayer.new()
	audio.playing = true
	splitter.connect("destroyed", _on_destroyed)
	splitter.onready_paths.collision = collision
	splitter.onready_paths.sprite = sprite
	splitter.onready_paths.audio = audio
	# when
	splitter._prepare_for_deletion()
	# then
	assert_false(sprite.visible)
	assert_eq(destroyed_times_called, 1)
	assert_eq(destroyed_args, [[splitter]])
	# cleanup
	collision.free()
	sprite.free()
	audio.free()


var on_hitbox_area_entered_params := [
	[true, false],
	[false, false],
	[true, true],
]


func test_on_hitbox_area_entered(params = use_parameters(on_hitbox_area_entered_params)):
	# given
	var is_projectile = params[0]
	var whitelist_has_area = params[1]
	var mock_splitter = partial_double(load("res://Scenes/Weapons/Powerups/Splitter/splitter.tscn")).instantiate()
	stub(mock_splitter, "_duplicate_projectile_with_angle").to_do_nothing()
	stub(mock_splitter, "_handle_feedback").to_do_nothing()
	stub(mock_splitter, "_prepare_for_deletion").to_do_nothing()
	add_child_autofree(mock_splitter)
	var area = autofree(Area2D.new())
	if is_projectile:
		area.add_to_group("projectile")
	if whitelist_has_area:
		mock_splitter._whitelist = [area]
	# when
	mock_splitter._on_hitbox_area_entered(area)
	# then
	if is_projectile and not whitelist_has_area:
		for duplicate_idx in range(1, mock_splitter.PROJECTILE_DUPLICATES + 1):
			var dup_angle = (duplicate_idx * ((PI / 2) / (mock_splitter.PROJECTILE_DUPLICATES + 1))) - PI / 4
			assert_called(mock_splitter, "_duplicate_projectile_with_angle", [area, dup_angle])
		if not mock_splitter.PROJECTILE_DUPLICATES % 2 == 0:
			assert_true(mock_splitter._whitelist.has(area))
	else:
		assert_not_called(mock_splitter, "_duplicate_projectile_with_angle")
	# cleanup
	for d_area in mock_splitter._whitelist:
		if is_instance_valid(d_area):
			d_area.free()


var on_hitbox_area_exited_params = [
	[true],
	[true],
	[false],
]


func test_on_hitbox_area_exited(params = use_parameters(on_hitbox_area_exited_params)):
	# given
	var whitelist_has_area = params[0]
	var area = Area2D.new()
	if whitelist_has_area:
		splitter._whitelist.append(area)
	# when
	splitter._on_hitbox_area_exited(area)
	# then
	assert_eq(splitter._whitelist.size(), 0)
	# cleanup
	area.free()


##### UTILS #####
func _on_destroyed(node):
	destroyed_times_called += 1
	destroyed_args.append([node])
