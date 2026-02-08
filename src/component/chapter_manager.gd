extends Component
class_name ChapterManager

@export var current : Chapter

@export var all : Array[Chapter]
@export var special : Array[Chapter]

const MAP_PREFIX : String = "res://maps/"
const MAP_SUFFIX : String = ".map"

var last_map : int = -1

func get_map() -> String:
	if current.maps.is_empty(): return MAP_PREFIX + current.map_fallback + MAP_SUFFIX
	var maps : Array[String] = compile_map_array()
	var chosen : String = MAP_PREFIX + maps[randi() % maps.size()] + MAP_SUFFIX
	_T.say(chosen)
	return chosen
		
func compile_map_array() -> Array[String]:
	var maps : Array[String] = current.maps
	if last_map >= 0 and last_map < maps.size():
		maps.remove_at(last_map)
	_T.say(maps)
	return maps
