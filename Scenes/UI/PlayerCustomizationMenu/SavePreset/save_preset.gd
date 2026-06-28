extends MarginContainer

# Popup to handle the saving of a preset

##### SIGNALS #####
signal save_preset_triggered(preset_name: String, preset_description: String)
signal open_override_popup

##### VARIABLES #####
#---- STANDARD -----
#==== ONREADY ====
@onready var preset_name := $"VBoxContainer/Name"
@onready var preset_description := $"VBoxContainer/Description"
@onready var ok_button := $"VBoxContainer/OkButton"


##### PROTECTED METHODS #####
func save_preset() -> void:
	save_preset_triggered.emit(preset_name.text, preset_description.text)


##### SIGNAL MANAGEMENT #####
func _on_confirmed() -> void:
	if preset_name.text.length() > 0:
		if ResourceLoader.exists(StaticUtils.get_preset_save_path(preset_name.text)):
			open_override_popup.emit()
		else:
			save_preset()
