extends Component
class_name ChapterManager

@export var current : Chapter

@export var all : Array[Chapter]
@export var special : Array[Chapter]

func get_map() -> String:
	var n : int = randi_range(0, current.maps.size() - 1)
	var map : String = current.maps[n]
	current.maps.erase(n)
	return "res://maps/" + map + ".map"
