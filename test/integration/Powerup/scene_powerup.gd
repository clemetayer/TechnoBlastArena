extends Node2D

##### VARIABLES #####
#---- STANDARD -----
#==== ONREADY ====
@onready var fire_position_node := $"FirePosition"
@onready var powerup_position_node := $"PowerupPosition"


##### PUBLIC METHODS #####
func get_fire_position_node():
	return fire_position_node


func get_powerup_position() -> Vector2:
	return powerup_position_node.global_position


func get_powerup_position_node():
	return powerup_position_node


func get_projectiles():
	return fire_position_node.get_children()


func get_powerups():
	return powerup_position_node.get_children()


func fire_projectile(projectile_scene) -> void:
	fire_position_node.call_deferred("add_child", projectile_scene)


func spawn_powerup(powerup) -> void:
	powerup_position_node.call_deferred("add_child", powerup)


func clean_projectiles():
	for projectile in fire_position_node.get_children():
		projectile.queue_free()


func clean_powerups():
	for powerup in powerup_position_node.get_children():
		powerup.queue_free()


func spawn_projectile(projectile):
	fire_projectile(projectile)
