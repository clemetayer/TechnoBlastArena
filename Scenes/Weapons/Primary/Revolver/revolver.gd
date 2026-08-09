extends PrimaryWeaponBase

# Basic revolver

##### VARIABLES #####
#---- CONSTANTS -----
const BULLET_PARAMS := preload("res://Scenes/Weapons/Primary/Revolver/revolver_bullet_params.tres")
const PROJECTILE_SCENE_PATH := "res://Scenes/Weapons/Projectiles/Bullet/bullet.tscn"
const LOS_DEFAULT_WIDTH := 8
const FIRE_ANIM_MAX_WIDTH := 20
const FIRE_ANIM_TIME := 0.2

#---- STANDARD -----
#==== PRIVATE ====
var _on_cooldown := false
var _fire_anim_tween: Tween

#==== ONREADY ====
@onready var line_of_sight := $"Line2D"
@onready var shoot_cooldown_timer := $"ShootCooldown"
@onready var sprite := $"Sprite2D"
@onready var gunshot := $"Gunshot"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	_set_los_init_modulate()


##### PUBLIC METHODS #####
func fire() -> void:
	if not _on_cooldown and active:
		_fire_anim()
		_play_gunshot()
		_spawn_projectile(_create_projectile())
		_on_cooldown = true
		shoot_cooldown_timer.start()


func aim(relative_aim_position: Vector2) -> void:
	var analog_angle = Vector2.ZERO.angle_to_point(relative_aim_position)
	rotation = analog_angle
	if abs(rotation) >= PI / 2.0:
		sprite.scale.y = abs(sprite.scale.y) * -1
	else:
		sprite.scale.y = abs(sprite.scale.y)


##### PROTECTED METHODS #####
func _create_projectile() -> Node:
	var projectile = load(PROJECTILE_SCENE_PATH).instantiate()
	projectile.PARAMETERS = BULLET_PARAMS
	projectile.current_owner = projectile_owner
	projectile.init_position = global_position
	projectile.init_rotation = rotation
	projectile.color = owner_color
	return projectile


func _fire_anim() -> void:
	if _fire_anim_tween:
		_fire_anim_tween.kill() # Abort the previous animation.
	_fire_anim_tween = create_tween()
	line_of_sight.modulate = Color.WHITE
	line_of_sight.width = FIRE_ANIM_MAX_WIDTH
	_fire_anim_tween.tween_property(line_of_sight, "modulate", owner_color, FIRE_ANIM_TIME)
	_fire_anim_tween.tween_property(line_of_sight, "width", LOS_DEFAULT_WIDTH, FIRE_ANIM_TIME)


func _play_gunshot() -> void:
	gunshot.play()


func _set_los_init_modulate() -> void:
	line_of_sight.modulate = owner_color


##### SIGNAL MANAGEMENT #####
func _on_shoot_cooldown_timeout():
	_on_cooldown = false
