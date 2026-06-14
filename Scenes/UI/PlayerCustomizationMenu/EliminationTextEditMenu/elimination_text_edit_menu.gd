extends MarginContainer

# menu to edit the elimination text_edit for a player

##### SIGNALS #####
signal elimination_text_updated(new_text: String)

##### VARIABLES #####
#---- STANDARD -----
#==== ONREADY ====
@onready var text_edit := $"VBoxContainer/MarginContainer/TextEdit"


##### PUBLIC METHODS #####
func get_elimination_text() -> String:
	return text_edit.text


func set_elimination_text(text: String) -> void:
	text_edit.text = text


##### SIGNAL MANAGEMENT #####
func _on_line_edit_text_changed(new_text: String) -> void:
	elimination_text_updated.emit(new_text)
