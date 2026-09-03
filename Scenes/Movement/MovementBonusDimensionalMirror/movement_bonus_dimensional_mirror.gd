extends MovementBonusBase

# Makes the player reappear on the opposite wall

##### VARIABLES #####
#---- CONSTANTS -----
const MAX_ACTIONS := 2
const RAYCAST_LENGTH := 10000
const PLAYER_OFFSET := 128.0
const PORTAL_SCENE = preload(
	"res://Scenes/Movement/MovementBonusDimensionalMirror/dimensional_mirror_portal.tscn"
)

#---- EXPORTS -----
@export var ACTIONS_AVAILABLE := MAX_ACTIONS

#---- STANDARD -----
#==== PRIVATE ====
var _init_ui_done := false # just to update the UI once on the first frame
var _ability_active := false

#==== ONREADY ====
@onready var raycast := $"RayCast2D"
@onready var reload_timer := $"ReloadTimer"
@onready var active_timer := $"ActiveTimer"


##### PROCESSING #####
# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(_delta):
	if not _init_ui_done:
		emit_signal("value_updated", ACTIONS_AVAILABLE)
		_init_ui_done = true


func _physics_process(_delta: float) -> void:
	raycast.enabled = _ability_active
	if not _ability_active:
		return
	if not (player.is_on_wall() or player.is_on_floor()):
		return
	_prepare_raycast_for_collision()
	if not raycast.is_colliding():
		return
	_teleport()


##### PUBLIC METHODS #####
func activate() -> void:
	if ACTIONS_AVAILABLE > 0 and active:
		_ability_active = true
		player.can_hit_destructible_wall = false
		active_timer.start()
		ACTIONS_AVAILABLE -= 1
		emit_signal("value_updated", ACTIONS_AVAILABLE)
		if reload_timer.is_stopped():
			reload_timer.start()


##### PROTECTED METHODS #####
func _spawn_portal(is_in: bool, portal_pos: Vector2) -> void:
	var portal = PORTAL_SCENE.instantiate()
	RuntimeUtils.get_game_root().add_child(portal)
	portal.appear(is_in, portal_pos)


func _prepare_raycast_for_collision() -> void:
	raycast.target_position = (
		player.get_wall_normal() if player.is_on_wall() else player.get_floor_normal()
	) * RAYCAST_LENGTH
	raycast.force_raycast_update()


func _teleport() -> void:
	_spawn_portal(true, player.get_global_position())
	_spawn_portal(false, raycast.get_collision_point())
	var player_velocity = player.get_max_velocity_in_buffer()
	player.set_global_position(
		raycast.get_collision_point() + raycast.get_collision_normal() * PLAYER_OFFSET
	)
	player.override_velocity(player_velocity)


##### SIGNAL MANAGEMENT #####
func _on_reload_timer_timeout() -> void:
	ACTIONS_AVAILABLE += 1
	emit_signal("value_updated", ACTIONS_AVAILABLE)
	if ACTIONS_AVAILABLE < MAX_ACTIONS:
		reload_timer.start()


func _on_active_timer_timeout() -> void:
	_ability_active = false
	player.can_hit_destructible_wall = true
