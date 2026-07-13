extends PanelContainer

# handles the player sprite display for the UI menu

##### VARIABLES #####
#---- STANDARD -----
#==== ONREADY ====
@onready var body := $"MarginContainer/Body"
@onready var outline := $"Outline"
@onready var eyes := $"Eyes"
@onready var mouth := $"Mouth"


##### PUBLIC METHODS #####
func update_sprite(sprite_config: SpriteCustomizationResource) -> void:
	body.modulate = sprite_config.BODY_COLOR
	outline.modulate = sprite_config.OUTLINE_COLOR
	eyes.texture = load(sprite_config.EYES_TEXTURE_PATH)
	eyes.modulate = sprite_config.EYES_COLOR
	mouth.texture = load(sprite_config.MOUTH_TEXTURE_PATH)
	mouth.modulate = sprite_config.MOUTH_COLOR
