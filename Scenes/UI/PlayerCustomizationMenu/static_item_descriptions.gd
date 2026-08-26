extends RefCounted

class_name StaticItemDescriptions
# utils class, mostly for the UI, to get the items descriptions fairly easily

##### VARIABLES #####
#---- CONSTANTS -----
const PRIMARY_WEAPONS := {
	StaticPrimaryWeaponHandler.handlers.REVOLVER: {
		"name": "Revolver",
		"description": "The revolver is a polyvalent weapon that shoots bullets in a straight line. A great choice if you want an all-rounder.",
	},
	StaticPrimaryWeaponHandler.handlers.SHOTGUN: {
		"name": "Shotgun",
		"description": "The shotgun shoots a multiple small bullet spread. Deals a lot of damage if you are close and every bullet hits, but not so much from far away.",
	},
}

const MOVEMENT_BONUS := {
	StaticMovementBonusHandler.handlers.DASH: {
		"name": "Dash",
		"description": "Makes you dash up to three times before recharging. Usefull to reposition yourself quickly.",
	},
	StaticMovementBonusHandler.handlers.DIMENSIONAL_MIRROR: {
		"name": "Dimensional mirror",
		"description": "Makes you reappear on the opposite wall. Makes you appear at unexpected places.",
	},
}

const POWERUPS := {
	StaticPowerupHandler.handlers.SPLITTER: {
		"name": "Splitter",
		"description": "When hit by a projectile, the splitter will split it and send it in various directions. It has limited uses. Usefull to cover a large area with your projectiles.",
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
