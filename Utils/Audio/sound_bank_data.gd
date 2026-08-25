extends RefCounted

class_name SoundBankData

const TRIGGER_SEPARATOR := "+"


static func get_trigger_string(triggers: Array) -> String:
	var trigger_string := ""
	if triggers == null or triggers.is_empty():
		return trigger_string
	trigger_string = triggers[0]
	for trigger in triggers.slice(1, triggers.size()):
		if trigger is String:
			trigger_string += "%s%s" % [TRIGGER_SEPARATOR, trigger]
	return trigger_string
