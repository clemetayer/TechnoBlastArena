extends ConfirmationDialog

# Popup to handle the saving of a preset

##### SIGNALS #####
signal save_preset(preset_name: String, preset_description: String)

##### VARIABLES #####
#==== ONREADY ====
@onready var preset_name := $"MarginContainer/VBoxContainer/Name"
@onready var preset_description := $"MarginContainer/VBoxContainer/Description"
@onready var override_preset_popup := $"../OverridePresetPopup"


##### PROTECTED METHODS #####
func _save_preset() -> void:
	save_preset.emit(preset_name.text, preset_description.text)


##### SIGNAL MANAGEMENT #####
func _on_confirmed() -> void:
	if preset_name.text.length() > 0:
		if ResourceLoader.exists(StaticUtils.get_preset_save_path(preset_name.text)):
			override_preset_popup.show()
		else:
			_save_preset()
		hide()


func _on_override_preset_popup_confirmed() -> void:
	_save_preset()
