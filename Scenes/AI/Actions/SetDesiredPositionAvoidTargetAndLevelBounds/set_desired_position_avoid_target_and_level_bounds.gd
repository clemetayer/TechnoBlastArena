@tool
extends ActionLeaf

class_name SetDesiredPositionAvoidPlayersAndLevelBounds
# Computes a desired position to avoid players and level bounds

##### PROCESSING #####
func tick(_actor: Node, blackboard: Blackboard) -> int:
	if not blackboard is CommonBlackboard:
		return FAILURE
	var opponents_positions = _nodes_to_position(blackboard.get_value(CommonBlackboard.OPPONENTS_KEY))
	var level_bounds = blackboard.get_value(CommonBlackboard.LEVEL_BOUNDS_KEY)
	if not (_all_positions_valid(opponents_positions) and _all_positions_valid(level_bounds)):
		return FAILURE
	var opponents_center_position := _get_polygon_center(opponents_positions)
	var furthest_corner := _get_furthest_bound_corner_from_point(opponents_center_position, level_bounds)
	blackboard.set_value(CommonBlackboard.DESIRED_POSITION_KEY, (opponents_center_position + furthest_corner) / 2.0)
	return SUCCESS


##### PROTECTED METHODS #####
func _nodes_to_position(nodes: Array) -> Array:
	var positions = []
	for node in nodes:
		if is_instance_valid(node):
			positions.append(node.get_global_position())
	return positions


func _all_positions_valid(positions: Array) -> bool:
	if positions.size() <= 0:
		return false
	for position in positions:
		if position == null:
			return false
	return true


func _get_polygon_center(polygon: Array) -> Vector2:
	var position_sum = Vector2.ZERO
	for point in polygon:
		position_sum += point
	return position_sum / polygon.size()


func _get_furthest_bound_corner_from_point(point: Vector2, bounds: Array) -> Vector2:
	var corners = [
		bounds[0],
		Vector2(bounds[1].x, bounds[0].y),
		bounds[1],
		Vector2(bounds[0].x, bounds[1].y),
	]
	var furthest_corner = corners[0]
	var furthest_distance = point.distance_to(corners[0])
	for corner in corners:
		var distance = point.distance_to(corner)
		if distance > furthest_distance:
			furthest_distance = distance
			furthest_corner = corner
	return furthest_corner
