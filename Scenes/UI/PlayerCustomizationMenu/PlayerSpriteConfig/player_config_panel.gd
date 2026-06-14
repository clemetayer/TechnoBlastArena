extends VBoxContainer

# handles the panel to configure some character elements (color, cosmetics, etc.)

##### SIGNALS #####
signal main_color_changed(color: Color)
signal secondary_color_changed(color: Color)
signal eyes_change_triggered
signal eyes_color_changed(color: Color)
signal mouth_change_triggered
signal mouth_color_changed(color: Color)
signal elimination_text_change_triggered
signal randomize

##### ENUMS #####
# enumerations

##### VARIABLES #####
#---- CONSTANTS -----
const FONT_SIZE_SMALL := 10
const FONT_SIZE_BIG := 25
const H_SEPARATION_SMALL := 4
const H_SEPARATION_BIG := 20

#---- STANDARD -----
#==== ONREADY ====
@onready var main_color := $"MainColor/MainColorPicker"
@onready var secondary_color := $"SecondaryColor/SecondaryColorPicker"
@onready var eyes_color := $"Eyes/Eyes/EyesColorPickerButton"
@onready var eyes_edit = $"Eyes/Eyes/EyesEditButton"
@onready var mouth_color := $"Mouth/Mouth/MouthColorPickerButton"
@onready var mouth_edit := $"Mouth/Mouth/MouthEditButton"
@onready var elimination_text_edit := $"EliminationText/EliminationtextButton"
@onready var randomize_button := $"RandomizeButton"
@onready var font_sizes_to_change := [
	$"MainColor/MainColorLabel",
	$"SecondaryColor/SecondaryColorLabel",
	$"Eyes/EyesLabel",
	$"Mouth/MouthLabel",
	$"EliminationText/EliminationText",
	$"RandomizeButton",
]


##### PUBLIC METHODS #####
func set_player_config(sprite_config: SpriteCustomizationResource):
	main_color.color = sprite_config.BODY_COLOR
	secondary_color.color = sprite_config.OUTLINE_COLOR
	eyes_color.color = sprite_config.EYES_COLOR
	mouth_color.color = sprite_config.MOUTH_COLOR


func toggle_is_small(is_small: bool) -> void:
	add_theme_constant_override("separation", H_SEPARATION_SMALL if is_small else H_SEPARATION_BIG)
	for element in font_sizes_to_change:
		element.add_theme_font_size_override("font_size", FONT_SIZE_SMALL if is_small else FONT_SIZE_BIG)


##### SIGNAL MANAGEMENT #####
func _on_main_color_picker_color_changed(color: Color) -> void:
	main_color_changed.emit(color)


func _on_secondary_color_picker_color_changed(color: Color) -> void:
	secondary_color_changed.emit(color)


func _on_eyes_edit_button_pressed() -> void:
	eyes_change_triggered.emit()


func _on_eyes_color_picker_button_color_changed(color: Color) -> void:
	eyes_color_changed.emit(color)


func _on_mouth_edit_button_pressed() -> void:
	mouth_change_triggered.emit()


func _on_mouth_color_picker_button_color_changed(color: Color) -> void:
	mouth_color_changed.emit(color)


func _on_eliminationtext_button_pressed() -> void:
	elimination_text_change_triggered.emit()


func _on_randomize_button_pressed() -> void:
	randomize.emit()
