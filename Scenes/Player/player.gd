extends CharacterBody2D

# player script

##### SIGNALS #####
@warning_ignore("unused_signal")
signal killed(id: int)
@warning_ignore("unused_signal")
signal movement_updated(id: int, value)
@warning_ignore("unused_signal")
signal powerup_updated(id: int, value)
@warning_ignore("unused_signal")
signal game_message_triggered(id: int)
signal damage_received(old_damage: float, new_damage: float, knockback: Vector2)
signal last_hit_owner_changed(hit_owner: Node2D)
signal abilities_toggled(active: bool)

##### VARIABLES #####
#---- CONSTANTS -----
const TARGET_SPEED := 1000.0 # px/s
const JUMP_VELOCITY := -1200.0
const MAX_FLOOR_ANGLE := PI / 4
const NORMAL_BOUNCE := 0.05
const HITSTUN_BOUNCE := 1.0
const FLOOR_ACCELERATION := 9000.0
const AIR_ACCELERATION := FLOOR_ACCELERATION / 2.0
const MAX_DAMAGE := 999
const WEIGHT := 2.5 # multiplier for the gravity

#---- EXPORTS -----
@export var DAMAGE := 0.0
@export var GAME_PROXY_PATH := ".."
@export var PLAYER_ID := 1

#---- STANDARD -----
#==== PUBLIC ====
var direction := Vector2.ZERO
var jump_triggered := false

#==== PRIVATE ====
var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") * WEIGHT
var _frozen := false
var _velocity_override := Vector2.ZERO
var _additional_vector := Vector2.ZERO # external forces that can have an effect on the player and needs to be added to the velocity on the next physics frame
var _freeze_buffer_velocity := Vector2.ZERO
var _damage_enabled := true
var _truce_active := false # allows for players to move freely but can't shoot or use abilities. Usefull during the start countdown of the game
var _velocity_buffer := [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO] # 3 frame buffer for the velocity. Usefull to keep track of the velocity when elements are going too fast
var _scene_utils := SceneUtils

#==== ONREADY ====
@onready var paths := $"Paths"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	paths.init.initialize(get_node(GAME_PROXY_PATH).get_player_config(PLAYER_ID))
	_appear()
	_scene_utils.connect("toggle_scene_freeze", _on_SceneUtils_toggle_scene_freeze)


func _physics_process(delta: float) -> void:
	if not _frozen:
		if not _is_on_floor():
			velocity.y += _gravity * delta
		elif velocity.y > 0 and _is_on_floor(): # to bounce back on horizontal destroyable walls
			velocity.y = 0

		if _freeze_buffer_velocity != Vector2.ZERO:
			velocity = _freeze_buffer_velocity
			_freeze_buffer_velocity = Vector2.ZERO
		if _velocity_override != Vector2.ZERO:
			velocity = _velocity_override
			_velocity_override = Vector2.ZERO

		if jump_triggered and _is_on_floor():
			velocity.y = JUMP_VELOCITY

		velocity += _additional_vector
		_additional_vector = Vector2.ZERO

		var acceleration = FLOOR_ACCELERATION if _is_on_floor() else AIR_ACCELERATION
		velocity.x = move_toward(velocity.x, direction.x * TARGET_SPEED, acceleration * delta)

		if paths.hitstun_manager.hitstunned:
			_predict_bounces()
			var collision_normal = _get_collisions_normal()
			if collision_normal != Vector2.ZERO:
				velocity.bounce(collision_normal)

		move_and_slide()

		_buffer_velocity(velocity)


##### PUBLIC METHODS #####
func hit(hit_data: PlayerHitData) -> void:
	if not _damage_enabled:
		return
	var shield_hit_result: Shield.HitResult = paths.shield.process_hit(hit_data)
	if shield_hit_result != Shield.HitResult.IGNORED:
		return
	var old_damage = DAMAGE
	DAMAGE = min(DAMAGE + hit_data.damage, MAX_DAMAGE)
	var knockback_velocity = hit_data.knockback * DAMAGE
	_additional_vector += knockback_velocity
	damage_received.emit(old_damage, DAMAGE, knockback_velocity)
	last_hit_owner_changed.emit(hit_data.owner)


func kill() -> void:
	paths.death_manager.kill()


func override_velocity(velocity_override: Vector2) -> void:
	_velocity_override += velocity_override


func toggle_movement(_active: bool) -> void:
	pass # TODO : implement this + maybe remove the toggle_freeze below


func toggle_freeze(active: bool) -> void:
	_freeze_buffer_velocity = velocity
	set_deferred("freeze", active)
	set_deferred("sleeping", active)
	toggle_abilities(not active)
	toggle_damage(not active)
	_frozen = active


# Activates the player's abilities (fire, powerup, movement). Especially usefull waiting for the game startup screen to end
func toggle_abilities(active: bool) -> void:
	if not _truce_active:
		abilities_toggled.emit(active)


func toggle_damage(active: bool) -> void:
	_damage_enabled = active


func toggle_truce(active: bool) -> void:
	# Note : calls the toggle abilities twice to make sure it is updated
	toggle_abilities(not active)
	_truce_active = active
	toggle_abilities(not active)


func get_config() -> PlayerConfig:
	return get_node(GAME_PROXY_PATH).get_player_config(PLAYER_ID)


func get_velocity_buffer() -> Array:
	return _velocity_buffer


func get_direction() -> Vector2:
	return direction


##### PROTECTED METHODS #####
func _appear() -> void:
	toggle_freeze(true)
	toggle_abilities(false)
	toggle_damage(false)
	paths.appear_elements.play_spawn_animation()


func _buffer_velocity(vel_to_buffer: Vector2) -> void:
	_velocity_buffer.pop_back()
	_velocity_buffer.push_front(vel_to_buffer)


func _get_collisions_normal() -> Vector2:
	var collision_normal_sum = Vector2.ZERO
	for col_idx in get_slide_collision_count():
		collision_normal_sum = get_slide_collision(col_idx).get_normal()
	if collision_normal_sum == Vector2.ZERO:
		return collision_normal_sum
	return (collision_normal_sum / get_slide_collision_count()).normalized()


# mostly for test purposes because _process is really important to test here
func _is_on_floor() -> bool:
	return is_on_floor()


# also mostly for test purposes to avoid mocking the predict bounces node every time
func _predict_bounces() -> void:
	paths.predict_bounces_ray_cast.predict_bounces()


##### SIGNAL MANAGEMENT #####
func _on_SceneUtils_toggle_scene_freeze(value: bool) -> void:
	toggle_freeze(value)


func _on_appear_elements_appear_animation_finished() -> void:
	toggle_freeze(false)
	toggle_abilities(true)
	toggle_damage(true)
