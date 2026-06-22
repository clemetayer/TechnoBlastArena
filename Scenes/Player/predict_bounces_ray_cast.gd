extends Node2D

# Raycast that predicts bounces for the player

##### VARIABLES #####
#---- CONSTANTS -----
const MAX_BOUNCE_PREDICTIONS := 10
const PREDICT_BOUNCE_OFFSET := 64.0
const BOUNCE_DAMPING := 0.85
const BODY_SIZE_SIDE_HALF := 42.24
const PREDICT_BOUNCE_RAY_MASK := 1
const MIN_VELOCITY_TO_ALLOW_PREDICT := 0.5

#---- STANDARD -----
#==== ONREADY ====
@onready var paths := $"../Paths"


##### PUBLIC METHODS #####
func predict_bounces() -> void:
	var root = paths.player_root
	if root.velocity.length() <= MIN_VELOCITY_TO_ALLOW_PREDICT:
		return
	var travel_distance_next_frame = root.velocity * 1.0 / Engine.get_physics_ticks_per_second()
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + travel_distance_next_frame + _get_additional_body_size_point(root.velocity.normalized()), PREDICT_BOUNCE_RAY_MASK)
	query.collide_with_bodies = true
	var intersection = space_state.intersect_ray(query)
	var predict_bounce_cnt = 0
	while intersection and predict_bounce_cnt < MAX_BOUNCE_PREDICTIONS:
		global_position = intersection.position + intersection.normal * PREDICT_BOUNCE_OFFSET # slight position correction to avoid repositionning in the wall
		if GroupUtils.is_destructible_wall(intersection.collider): # breakable wall, should not bounce
			return
		elif not paths.hitstun_manager.hitstunned: # if hitstunned just stopped, reset the velocity if it collides with a wall to avoid going through at high velocities
			root.velocity = Vector2.ZERO
			return
		else:
			var distance_traveled = global_position - intersection.position
			root.velocity = root.velocity.bounce(intersection.normal) * BOUNCE_DAMPING
			if travel_distance_next_frame.length() - distance_traveled.length() <= 0:
				return
			travel_distance_next_frame = root.velocity.normalized() * (travel_distance_next_frame - distance_traveled).length()
			query = PhysicsRayQueryParameters2D.create(position, position + travel_distance_next_frame, 1)
			intersection = space_state.intersect_ray(query)
		predict_bounce_cnt += 1


##### PROTECTED METHODS #####
func _get_additional_body_size_point(direction: Vector2) -> Vector2:
	var dir = direction.normalized()
	var mult = 1.0 / max(abs(dir.x), abs(dir.y))
	dir *= mult
	return dir * BODY_SIZE_SIDE_HALF
