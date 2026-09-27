extends RefCounted

class_name StaticItemDescriptions
# utils class, mostly for the UI, to get the items descriptions fairly easily

##### VARIABLES #####
#---- CONSTANTS -----
const PRIMARY_WEAPONS := {
	StaticPrimaryWeaponHandler.handlers.REVOLVER: {
		"name": "Revolver",
		"description": "It's a gun. It's basic. It shoots bullets in a straight line. It's an all rounder.",
	},
	StaticPrimaryWeaponHandler.handlers.SHOTGUN: {
		"name": "Shotgun",
		"description": "Fires a spread of small bullets. Deals a lot of damage at close range.",
	},
}

const MOVEMENT_BONUS := {
	StaticMovementBonusHandler.handlers.DASH: {
		"name": "Dash",
		"description": "Makes you dash where you want to reposition yourself quickly",
	},
	StaticMovementBonusHandler.handlers.DIMENSIONAL_MIRROR: {
		"name": "Dimensional mirror",
		"description": "Phase through surfaces to teleport and appear in unexpected places",
	},
}

const POWERUPS := {
	StaticPowerupHandler.handlers.SPLITTER: {
		"name": "Splitter",
		"description": "Splits a projectile in a spread of smaller variant. Usefull to cover a large area.",
	},
	StaticPowerupHandler.handlers.CHAIN: {
		"name": "Chain",
		"description": "Redirects a projectile when interacting with it, either to the last aim direction or to the next chain element",
	},
}


##### PUBLIC METHODS #####
static func get_primary_weapons_descriptions() -> Array:
	return _get_descriptions_generic(PRIMARY_WEAPONS, StaticPrimaryWeaponHandler)


static func get_movement_bonus_descriptions() -> Array:
	return _get_descriptions_generic(MOVEMENT_BONUS, StaticMovementBonusHandler)


static func get_powerups_descriptions() -> Array:
	return _get_descriptions_generic(POWERUPS, StaticPowerupHandler)


##### PROTECTED METHODS #####
static func _get_descriptions_generic(data: Dictionary, weapon_class) -> Array:
	var items = []
	for id in weapon_class.handlers.values():
		var item = ItemGridMenuElement.new(
			id,
			weapon_class.get_icon_path(id),
			data[id].name,
			data[id].description,
		)
		items.append(item)
	return items
