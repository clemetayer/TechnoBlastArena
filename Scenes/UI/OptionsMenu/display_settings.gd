extends VBoxContainer

# handles the display types

##### VARIABLES #####
#---- STANDARD -----
#==== ONREADY ====
@onready var display_type_button := $"DisplayType/DisplayTypeButton"
@onready var visual_intensity_button := $"BackgroundIntensity/BackgroundIntensityButton"
@onready var camera_effects_intensity_button := $"CameraEffectsIntensity/CameraEffectsIntensityButton"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	display_type_button.select(0 if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED else 1)
	visual_intensity_button.select(RuntimeConfig.visual_intensity as int)
	camera_effects_intensity_button.select(RuntimeConfig.camera_effects_intensity as int)


##### SIGNAL MANAGEMENT #####
func _on_display_type_button_item_selected(index: int) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if index == 0 else DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_background_intensity_button_item_selected(index: int) -> void:
	RuntimeConfig.visual_intensity = index as RuntimeConfig.VISUAL_INTENSITY


func _on_camera_effects_intensity_button_item_selected(index: int) -> void:
	RuntimeConfig.camera_effects_intensity = index as RuntimeConfig.CAMERA_EFFECTS_INTENSITY
