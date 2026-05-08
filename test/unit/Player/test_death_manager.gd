extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var death_manager
var killed_times_called := 0
var killed_args := []


##### SETUP #####
func before_each():
	death_manager = load("res://Scenes/Player/death_manager.gd").new()
	killed_times_called = 0
	killed_args = []


##### TEARDOWN #####
func after_each():
	death_manager.free()


##### TESTS #####
func test_set_particles_color():
	# given
	var particles = GPUParticles2D.new()
	death_manager.onready_paths.particles = particles
	# when
	death_manager.set_particles_color(Color.ALICE_BLUE)
	# then
	assert_eq(death_manager.onready_paths.particles.modulate, Color.ALICE_BLUE)
	# cleanup
	particles.free()


func test_kill():
	# given
	var camera_effects = double(load("res://Scenes/Camera/camera_effects.gd")).new()
	stub(camera_effects, "emit_signal_start_camera_impact").to_do_nothing()
	death_manager._camera_effects = camera_effects
	var paths = load("res://Scenes/Player/paths.gd").new()
	death_manager.paths = paths
	var last_hit_owner = load("res://Scenes/Player/player.tscn").instantiate()
	last_hit_owner.PLAYER_ID = 123
	death_manager._last_hit_owner = last_hit_owner
	var particles = GPUParticles2D.new()
	death_manager.onready_paths.particles = particles
	var player_root = partial_double(load("res://Scenes/Player/player.tscn")).instantiate()
	stub(player_root, "toggle_freeze").to_do_nothing()
	stub(player_root, "toggle_truce").to_do_nothing()
	death_manager.paths.player_root = player_root
	var damage_label = double(Control).new()
	stub(damage_label, "hide").to_do_nothing()
	death_manager.paths.damage_label = damage_label
	var sprites = double(Sprite2D).new()
	stub(sprites, "hide").to_do_nothing()
	death_manager.paths.sprites = sprites
	var primary_weapon = double(Node2D).new()
	stub(primary_weapon, "hide").to_do_nothing()
	death_manager.paths.primary_weapon = primary_weapon
	var sound = double(AudioStreamPlayer).new()
	stub(sound, "play").to_do_nothing()
	stub(sound, "is_inside_tree").to_return(true)
	death_manager.onready_paths.sound = sound
	var death_anim_time = double(Timer).new()
	stub(death_anim_time, "start").to_do_nothing()
	stub(death_anim_time, "is_inside_tree").to_return(true)
	death_manager.onready_paths.death_anim_time = death_anim_time
	# when
	death_manager.kill()
	# then
	assert_called(camera_effects, "emit_signal_start_camera_impact", [death_manager.CAMERA_DEATH_IMPACT_TIME * 1.0, CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH, CameraEffects.CAMERA_IMPACT_PRIORITY.HIGH])
	assert_called(player_root, "toggle_freeze", [true])
	assert_eq(player_root.collision_layer, 0)
	assert_eq(player_root.collision_mask, 0)
	assert_called(player_root, "toggle_truce", [true])
	assert_called(damage_label, "hide")
	assert_called(primary_weapon, "hide")
	assert_called(sound, "play")
	assert_called(death_anim_time, "start")
	assert_true(particles.emitting)
	# cleanup
	last_hit_owner.free()
	paths.free()
	particles.free()


func test_get_last_hit_owner_id_valid():
	# given
	var last_hit_owner = load("res://Scenes/Player/player.tscn").instantiate()
	death_manager._last_hit_owner = last_hit_owner
	last_hit_owner.PLAYER_ID = 123
	# when
	var res = death_manager._get_last_hit_owner_id(last_hit_owner)
	# then
	assert_eq(res, 123)
	# cleanup
	last_hit_owner.free()


func test_on_death_anim_time_timeout():
	# given
	var player_root = load("res://Scenes/Player/player.tscn").instantiate()
	var paths = load("res://Scenes/Player/paths.gd").new()
	paths.player_root = player_root
	player_root.connect("killed", _on_killed, 0)
	player_root.PLAYER_ID = 123
	death_manager.paths = paths
	# when
	death_manager._on_death_anim_time_timeout()
	# then
	assert_eq(killed_times_called, 1)
	assert_eq(killed_args, [[123]])
	# cleanup
	player_root.free()
	paths.free()


func test_on_player_last_hit_owner_changed():
	# given
	var hit_owner = Node2D.new()
	# when
	death_manager._on_player_last_hit_owner_changed(hit_owner)
	# then
	assert_eq(death_manager._last_hit_owner, hit_owner)
	# cleanup
	hit_owner.free()


##### UTILS #####
func _on_killed(id: int) -> void:
	killed_times_called += 1
	killed_args.append([id])
