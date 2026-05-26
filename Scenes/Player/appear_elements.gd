extends Node2D

# manages the elements for the spawn animation

##### SIGNALS #####
signal appear_animation_finished

##### VARIABLES #####
#---- CONSTANTS -----
const APPEAR_ANIM_NAME := "appear"

#---- STANDARD -----
#==== ONREADY ====
@onready var paths := $"../Paths"
@onready var onready_paths := {
	"sprite": $"Appear",
	"particles": {
		"main": $"MainColor",
		"secondary": $"SecondaryColor",
	},
}


##### PUBLIC METHODS #####
func init(main_color: Color, secondary_color: Color) -> void:
	var main_color_light = main_color
	main_color_light.h = 50
	var secondary_color_light = secondary_color
	secondary_color_light.h = 50
	onready_paths.sprite.modulate = main_color_light
	onready_paths.particles.main.modulate = main_color_light
	onready_paths.particles.secondary.modulate = secondary_color_light


func play_spawn_animation() -> void:
	paths.animation_player.play("appear")


##### SIGNAL MANAGEMENT #####
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "appear":
		emit_signal("appear_animation_finished")
