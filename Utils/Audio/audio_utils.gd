extends RefCounted

class_name AudioUtils

# helper for various audio stuff


# just adds a node2D child to work with the EventAudio plugin. Mostly to avoid changing the type of some node scripts
static func add_event_audio_emitter_2D(node: Node) -> Node2D:
	var emitter = Node2D.new()
	node.add_child(emitter)
	return emitter
