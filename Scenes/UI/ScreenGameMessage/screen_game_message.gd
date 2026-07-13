extends Control

# Displays a message at the center of the screen. supports bbcode

##### VARIABLES #####
#---- CONSTANTS -----
const ENTER_ANIM_TIME := 0.25
const WAIT_TEXT_END := 0.25
const EXIT_ANIM_TIME := 0.25
const MAX_CHARACTERS_DISPLAY := 16

#---- STANDARD -----
#==== PRIVATE ====
var _display_characters_tween: Tween

#==== ONREADY ====
@onready var label := $"RichTextLabel"
@onready var animation := $"AnimationPlayer"
@onready var mid_screen_timer := $"MidScreenTimer"


##### PUBLIC METHODS #####
func init() -> void:
	label.text = ""


# displays a message on the screen for a specific duration (in seconds). There is also an option to try to display all the characters at once
func display_message(message: String, duration: float, display_all_characters: bool = false) -> void:
	var on_mid_screen_time = max(duration - (ENTER_ANIM_TIME + EXIT_ANIM_TIME), 0.0)
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if _is_message_too_long() else HORIZONTAL_ALIGNMENT_CENTER
	animation.play("enter")
	if display_all_characters:
		label.visible_characters = -1
	else:
		label.visible_ratio = 0
		if _display_characters_tween != null:
			_display_characters_tween.kill()
		_display_characters_tween = create_tween()
		_display_characters_tween.tween_property(label, "visible_ratio", 1.0, duration)
	if on_mid_screen_time > 0:
		mid_screen_timer.wait_time = on_mid_screen_time + WAIT_TEXT_END


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "enter":
		mid_screen_timer.start()


func _on_mid_screen_timer_timeout() -> void:
	animation.play("exit")


func _is_message_too_long() -> bool:
	return label.get_total_character_count() > MAX_CHARACTERS_DISPLAY
