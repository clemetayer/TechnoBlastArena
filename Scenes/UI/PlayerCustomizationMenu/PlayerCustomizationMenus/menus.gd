extends Control

# handles the menus to edit some player elements

##### SIGNALS #####
signal preset_selected(preset: PlayerConfig)
signal primary_weapon_selected(handler: StaticPrimaryWeaponHandler.handlers)
signal movement_bonus_selected(handler: StaticMovementBonusHandler.handlers)
signal powerup_selected(handler: StaticPowerupHandler.handlers)
signal elimination_text_updated(elimination_text: String)
signal save_preset(preset_name: String, preset_description: String)
signal eyes_selected(sprite_path: String)
signal mouth_selected(sprite_path: String)
signal menu_closed

##### VARIABLES #####
#---- STANDARD -----
#==== PRIVATE ====
var _is_small

#==== ONREADY ====
@onready var save_preset_popup := $"SavePresetPopup"

@onready var full_menus_close_buttons := {
	"preset_selection": $"PresetSelectionFull/PresetSelectionCloseButton",
	"primary_weapon": $"PrimaryWeaponGridFull/PrimaryWeaponCloseButton",
	"movement_bonus": $"MovementBonusGridFull/MovementBonusCloseButton",
	"powerup": $"PowerupGridFull/PowerupCloseButton",
	"elimination_text": $"EliminationTextEditFull/EliminationTextCloseButton",
	"eyes_selection": $"EyesSelectionFull/EyesSelectionCloseButton",
	"mouth_selection": $"MouthSelectionFull/MouthSelectionCloseButton",
}

@onready var full_menus := {
	"preset_selection": $"PresetSelectionFull",
	"primary_weapon": $"PrimaryWeaponGridFull",
	"movement_bonus": $"MovementBonusGridFull",
	"powerup": $"PowerupGridFull",
	"elimination_text": $"EliminationTextEditFull",
	"eyes_selection": $"EyesSelectionFull",
	"mouth_selection": $"MouthSelectionFull",
}

@onready var menus_in_popups := {
	"preset_selection": $"PresetSelectionPopup/PresetSelection",
	"primary_weapon": $"PrimaryWeaponGridPopup/PrimaryWeaponGrid",
	"movement_bonus": $"MovementBonusGridPopup/MovementBonusGrid",
	"powerup": $"PowerupGridPopup/PowerupGrid",
	"elimination_text": $"EliminationTextEditPopup/EliminationTextEdit",
	"eyes_selection": $"EyesSelectionPopup/EyesSelection",
	"mouth_selection": $"MouthSelectionPopup/MouthSelection",
}

@onready var popup_menus_root := {
	"preset_selection": $"PresetSelectionPopup",
	"primary_weapon": $"PrimaryWeaponGridPopup",
	"movement_bonus": $"MovementBonusGridPopup",
	"powerup": $"PowerupGridPopup",
	"elimination_text": $"EliminationTextEditPopup",
	"eyes_selection": $"EyesSelectionPopup",
	"mouth_selection": $"MouthSelectionPopup",
}

@onready var popup_background := $"BackgroundPopup"


##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	_set_primary_weapon_data()
	_set_movement_bonus_data()
	_set_powerup_data()


##### PUBLIC METHODS #####
func toggle_is_small(is_small: bool) -> void:
	_is_small = is_small


func refresh_presets() -> void:
	full_menus.preset_selection.refresh()
	menus_in_popups.preset_selection.refresh()


func open_preset_selection() -> void:
	_common_open_menu("preset_selection")


func open_primary_weapon() -> void:
	_common_open_menu("primary_weapon")


func open_movement_bonus() -> void:
	_common_open_menu("movement_bonus")


func open_powerup() -> void:
	_common_open_menu("powerup")


func open_elimination_text() -> void:
	_common_open_menu("elimination_text")


func open_eyes_selection() -> void:
	_common_open_menu("eyes_selection")


func open_mouth_selection() -> void:
	_common_open_menu("mouth_selection")


func open_save_preset_popup() -> void:
	show()
	save_preset_popup.show()
	popup_background.visible = not _is_small


##### PROTECTED METHODS #####
func _set_primary_weapon_data() -> void:
	var data = StaticItemDescriptions.get_primary_weapons_descriptions()
	full_menus.primary_weapon.set_items(data)
	menus_in_popups.primary_weapon.set_items(data)


func _set_movement_bonus_data() -> void:
	var data = StaticItemDescriptions.get_movement_bonus_descriptions()
	full_menus.movement_bonus.set_items(data)
	menus_in_popups.movement_bonus.set_items(data)


func _set_powerup_data() -> void:
	var data = StaticItemDescriptions.get_powerups_descriptions()
	full_menus.powerup.set_items(data)
	menus_in_popups.powerup.set_items(data)


func _common_open_menu(menu_name: String) -> void:
	show()
	if _is_small:
		full_menus[menu_name].show()
		return
	popup_background.show()
	popup_menus_root[menu_name].show()


func _common_close_menu(menu_name: String) -> void:
	hide()
	popup_background.hide()
	popup_menus_root[menu_name].hide()
	full_menus[menu_name].hide()
	menu_closed.emit()


##### SIGNAL MANAGEMENT #####
func _on_preset_selection_preset_selected(preset: PlayerConfig) -> void:
	preset_selected.emit(preset)
	_common_close_menu("preset_selection")


func _on_preset_selection_close_button_pressed() -> void:
	_common_close_menu("preset_selection")


func _on_primary_weapon_grid_item_selected(item: ItemGridMenuElement) -> void:
	primary_weapon_selected.emit(item.ITEM_ID)
	_common_close_menu("primary_weapon")


func _on_primary_weapon_close_button_pressed() -> void:
	_common_close_menu("primary_weapon")


func _on_powerup_grid_item_selected(item: ItemGridMenuElement) -> void:
	powerup_selected.emit(item.ITEM_ID)
	_common_close_menu("powerup")


func _on_powerup_close_button_pressed() -> void:
	_common_close_menu("powerup")


func _on_movement_bonus_grid_item_selected(item: ItemGridMenuElement) -> void:
	movement_bonus_selected.emit(item.ITEM_ID)
	_common_close_menu("movement_bonus")


func _on_movement_bonus_close_button_pressed() -> void:
	_common_close_menu("movement_bonus")


func _on_elimination_text_edit_elimination_text_updated(new_text: String) -> void:
	elimination_text_updated.emit(new_text)
	_common_close_menu("elimination_text")


func _on_elimination_text_close_button_pressed() -> void:
	_common_close_menu("elimination_text")


func _on_eyes_selection_sprite_selected(sprite_path: String) -> void:
	eyes_selected.emit(sprite_path)
	_common_close_menu("eyes_selection")


func _on_eyes_selection_close_button_pressed() -> void:
	_common_close_menu("eyes_selection")


func _on_mouth_selection_sprite_selected(sprite_path: String) -> void:
	mouth_selected.emit(sprite_path)
	_common_close_menu("mouth_selection")


func _on_mouth_selection_close_button_pressed() -> void:
	_common_close_menu("mouth_selection")


func _on_save_preset_popup_canceled() -> void:
	popup_background.hide()
	hide()


func _on_save_preset_popup_save_preset(preset_name: String, preset_description: String) -> void:
	save_preset.emit(preset_name, preset_description)
	hide()
	popup_background.hide()
	save_preset_popup.hide()
