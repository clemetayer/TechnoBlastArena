extends Node


##### PUBLIC METHODS #####
func spawn_projectile(node: Node) -> void:
	add_child(node)


func destroy() -> void:
	for child in get_children():
		child.free()
