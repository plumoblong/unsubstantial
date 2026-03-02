extends Component
class_name ChapterManager

@export var current : Chapter

@export var all : Array[Chapter]
@export var special : Array[Chapter]

const MAP_PREFIX : String = "res://maps/"
const MAP_SUFFIX : String = ".map"
var available_maps : Array[String] = []

func get_map() -> String:
	if current.maps.is_empty(): return MAP_PREFIX + current.map_fallback + MAP_SUFFIX
	if available_maps.is_empty():
		available_maps = current.maps.duplicate()
	var index : int = randi() % available_maps.size()
	var chosen : String = available_maps[index]
	available_maps.remove_at(index)
	_T.say(MAP_PREFIX + chosen + MAP_SUFFIX)
	return MAP_PREFIX + chosen + MAP_SUFFIX
