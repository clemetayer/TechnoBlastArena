extends ConditionLeaf

class_name ConditionHasCloseProjectile

# success if the player has a projectile nearby that can be parried

##### VARIABLES #####
#---- CONSTANTS -----
const SHIELD_DISTANCE := 75.0 # Distance from the projectile where the AI should consider that this is a good idea to parry


##### PROCESSING #####
func tick(_actor: Node, blackboard: Blackboard) -> int:
	if not blackboard is CommonBlackboard:
		return FAILURE
	var player = blackboard.get_value(CommonBlackboard.PLAYER_KEY)
	var projectiles = blackboard.get_value(CommonBlackboard.PROJECTILES_KEY)
	var has_close_projectile = _get_min_distance_to_projectile(player, projectiles) <= SHIELD_DISTANCE
	return SUCCESS if has_close_projectile else FAILURE


##### PROTECTED METHODS #####
func _get_min_distance_to_projectile(player: Node2D, projectiles: Array) -> float:
	if not (is_instance_valid(player) and projectiles.size() > 0):
		return INF
	var player_pos = player.get_global_position()
	var projectile_pos = Vector2.ONE * INF
	var min_distance = player_pos.distance_to(projectile_pos)
	for projectile in projectiles:
		if is_instance_valid(projectile):
			projectile_pos = projectile.get_global_position()
			var distance = player_pos.distance_to(projectile_pos)
			if distance < min_distance:
				min_distance = distance
	return min_distance
