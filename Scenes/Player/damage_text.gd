extends RichTextLabel
# Script to handle the damage display

##### VARIABLES #####
#---- CONSTANTS -----
const MAX_DAMAGE_GRADIENT_VALUE := 250 # Damage value where the text will appear at the opposite spot on the gradient
const MAX_DAMAGE_SHAKE_VALUE := MAX_DAMAGE_GRADIENT_VALUE
const MAX_HIT_AMPLITUDE := 75.0
const HIT_TEXT_DURATION := 0.15 #s
const DAMAGE_TEXT_COLOR := "[color=%s]%s[/color]"
const DAMAGE_TEXT_HIT := "[hit amplitude=%d progress=%f seed=%d]%s[/hit]"

#---- STANDARD -----
#==== PRIVATE ====
var _damage_text_gradient = preload("res://Scenes/Player/damage_text_gradient.tres")
var _hit_text_tween : Tween
var _current_damage : float

#==== ONREADY ====
@onready var paths := $"../Paths"

##### PROCESSING #####
# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(_delta):
	update_damage(paths.player_root.DAMAGE)

##### PUBLIC METHODS #####
func init_damage() -> void:
	var damage_label = "%d" % 0
	damage_label = _update_text_color(damage_label,0)

func update_damage(new_val : float) -> void:
	if _current_damage != new_val:
		var damage_label = "%d" % new_val
		damage_label = _update_text_color(damage_label,new_val)
		var amplitude = min(new_val/MAX_DAMAGE_SHAKE_VALUE, 1.0) * MAX_HIT_AMPLITUDE
		var duration = min(new_val/MAX_DAMAGE_SHAKE_VALUE, 1.0) * HIT_TEXT_DURATION
		var damage_seed = randi_range(1,20)
		if _hit_text_tween:
			_hit_text_tween.kill() # stops the previous animation
		_hit_text_tween = create_tween()
		_hit_text_tween.tween_method(
			func(value): _set_hit_text_tween(damage_label,amplitude,damage_seed,value),
			0.0,
			1.0,
			duration
		)
		_current_damage = new_val

##### PROTECTED METHODS #####
func _update_text_color(damage_label : String, new_val : float) -> String:
	var percents = min(new_val/MAX_DAMAGE_GRADIENT_VALUE, 1.0)
	var text_color = _damage_text_gradient.sample(percents)
	return DAMAGE_TEXT_COLOR % [text_color.to_html(), damage_label]

func _update_hit_text(damage_label : String, amplitude : float, damage_seed : int, progression : float) -> String:
	return DAMAGE_TEXT_HIT % [amplitude, progression, damage_seed, damage_label]

func _set_hit_text_tween(damage_label : String, amplitude : float, damage_seed : int, progression : float) -> void:
	text = _update_hit_text(damage_label, amplitude, damage_seed, progression)
