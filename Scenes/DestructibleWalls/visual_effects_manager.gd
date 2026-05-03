extends Node2D
# Handles the visual effects of the destructible wall

##### VARIABLES #####
#---- CONSTANTS -----
const WALL_COLOR_GRADIENT_RES_PATH := "res://Scenes/DestructibleWalls/wall_color_gradient.tres"
const VORONOI_MAX_DESTRUCTION_PERCENTS := 0.5
const DAMAGE_WALL_TRESHOLD_EFFECT := 3000
const UPDATE_VISUALS_ANIMATION_TIME := 1 #s

#---- STANDARD -----
#==== PRIVATE ====
var _bounce_back_direction := Vector2.RIGHT
var _update_visuals_tween : Tween
var _full_screen_effects := FullScreenEffects
var _camera_effects := CameraEffects

#==== ONREADY ====
@onready var wall_gradient := load(WALL_COLOR_GRADIENT_RES_PATH)
@onready var onready_paths := {
	"wall" : get_parent(),
	"cracks" : $"Cracks", 
	"particles": $"Particles",
	"spawn_animation": $"SpawnAnimation"
}

##### PUBLIC METHODS #####
func init(bounce_back_direction : Vector2) -> void:
	_bounce_back_direction = bounce_back_direction
	update_visuals(1.0)

func update_visuals_tween(new_health : float, old_health : float, max_health : float) -> void:
	if _update_visuals_tween:
		_update_visuals_tween.kill() # Abort the previous animation.
	_update_visuals_tween = create_tween()
	_update_visuals_tween.tween_method(update_visuals, old_health / max_health, new_health / max_health, UPDATE_VISUALS_ANIMATION_TIME)

func play_spawn_animation() -> void:
	onready_paths.spawn_animation.play_spawn_animation(_bounce_back_direction)

func play_break_animation(hit_position : Vector2) -> void:
	_full_screen_effects.monochrome(2)
	_full_screen_effects.pincushion(2)
	shake_camera(CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH)

func shake_camera_by_velocity(velocity : float) -> void:
	var camera_shake = _get_shake_type_by_velocity(abs(velocity))
	shake_camera(camera_shake)

func shake_camera(intensity: int) -> void:
	_camera_effects.emit_signal_start_camera_impact(1.0, intensity, CameraEffects.CAMERA_IMPACT_PRIORITY.HIGH)

func update_visuals(health_ratio : float) -> void:
	var new_color = wall_gradient.sample(health_ratio)
	onready_paths.wall.modulate = new_color
	onready_paths.particles.set_color(new_color)
	onready_paths.cracks.material.set_shader_parameter("destruction_amount", (1.0 - health_ratio) * VORONOI_MAX_DESTRUCTION_PERCENTS)

##### PROTECTED METHODS #####
func _get_shake_type_by_velocity(velocity : float) -> CameraEffects.CAMERA_IMPACT_INTENSITY:
	if velocity <= DAMAGE_WALL_TRESHOLD_EFFECT:
		return CameraEffects.CAMERA_IMPACT_INTENSITY.MEDIUM
	else:
		return CameraEffects.CAMERA_IMPACT_INTENSITY.HIGH
