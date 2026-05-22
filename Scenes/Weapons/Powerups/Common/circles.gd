extends HBoxContainer
# handles the splitter contact counter visuals

##### VARIABLES #####
#---- CONSTANTS -----
const circles_texture := preload("res://Scenes/Weapons/Powerups/Splitter/splitter_circle_texture.tscn")

#---- EXPORTS -----
@export var texture : Texture

##### PUBLIC METHODS #####
func init(amount : int) -> void:
	for circle_idx in range(amount):
		add_child(circles_texture.instantiate(),true)

func remove_circle() -> void:
	if get_child_count() > 0:
		get_child(0).queue_free()
