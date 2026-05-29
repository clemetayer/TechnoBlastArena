extends TileMapLayer

# destructible wall script

##### SIGNALS #####
signal explode_fragments(force: Vector2)

##### VARIABLES #####
#---- CONSTANTS -----
const WALL_BREAK_PARTICLES_SCENE_PATH := "res://Scenes/DestructibleWalls/WallBreakParticles/wall_break_particles.tscn"

#---- EXPORTS -----
@export var BASE_HEALTH := 5000
@export var BOUNCE_BACK_FORCE := 1750
@export var BOUNCE_BACK_DIRECTION := Vector2.RIGHT

#---- STANDARD -----
#==== ONREADY ====
@onready var onready_paths := {
	"health_manager": $"HealthManager",
	"visual_effects_manager": $"VisualEffectsManager",
	"collision_manager": $"CollisionManager",
	"audio_manager": $"AudioManager",
	"respawn_manager": $"RespawnManager",
	"player_interactions_manager": $"PlayerInteractionsManager",
}


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	_init_node()


##### PUBLIC METHODS #####
# mostly for testing purposes
func get_collision_enabled() -> bool:
	return collision_enabled


##### PROTECTED METHODS #####
# mostly for test purposes, since calling _ready resets the onready_paths
func _init_node() -> void:
	_add_particles()
	onready_paths.health_manager.init(BASE_HEALTH)
	onready_paths.collision_manager.init(BOUNCE_BACK_DIRECTION)
	onready_paths.visual_effects_manager.init(BOUNCE_BACK_DIRECTION)
	_toggle_activated(true)
	onready_paths.visual_effects_manager.play_spawn_animation()


func _get_damage(velocity) -> float:
	if BOUNCE_BACK_DIRECTION.x != 0:
		return abs(velocity.x)
	return abs(velocity.y)


func _toggle_activated(active: bool) -> void:
	visible = active
	collision_enabled = active
	onready_paths.collision_manager.set_active(active)


func _add_particles() -> void:
	var particles = load(WALL_BREAK_PARTICLES_SCENE_PATH).instantiate()
	get_parent().call_deferred("add_child", particles)
	particles.init_particles(self)


##### SIGNAL MANAGEMENT #####
func _on_area_entered(area):
	if GroupUtils.is_projectile(area):
		area.queue_free()


func _on_health_manager_health_changed(new_health: float, old_health: float) -> void:
	if new_health > 0:
		onready_paths.visual_effects_manager.update_visuals_tween(new_health, old_health, BASE_HEALTH)


func _on_health_manager_health_empty() -> void:
	onready_paths.audio_manager.play_break()
	onready_paths.respawn_manager.start_respawn_timer()
	onready_paths.visual_effects_manager.play_break_animation()
	emit_signal("explode_fragments", onready_paths.collision_manager.get_latest_hit_velocity())
	_toggle_activated(false)
	onready_paths.respawn_manager.enable_respawn_detection(true)


func _on_collision_manager_player_hit(player: Variant, velocity: Variant) -> void:
	var damage = _get_damage(velocity)
	onready_paths.health_manager.apply_damage(damage)
	if onready_paths.health_manager.is_destroyed():
		onready_paths.player_interactions_manager.kill_player(player)
	else:
		onready_paths.player_interactions_manager.handle_player_hit(player, velocity, BOUNCE_BACK_DIRECTION, BOUNCE_BACK_FORCE)


func _on_respawn_manager_wall_respawned() -> void:
	onready_paths.health_manager.reset_health()
	onready_paths.visual_effects_manager.update_visuals(0.0)
	_toggle_activated(true)
	onready_paths.respawn_manager.enable_respawn_detection(false)
	onready_paths.visual_effects_manager.play_spawn_animation()
