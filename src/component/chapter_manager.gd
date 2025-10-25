extends Component
class_name ChapterManager

@export var current : Chapter

@export var all : Array[Chapter]
@export var special : Array[Chapter]

func get_map() -> String:
	if current.map_fallback.is_empty(): return "res://maps/chapter1/map_1.map"
	if current.maps.is_empty(): return "res://maps/" + current.map_fallback + ".map"
	if not current.remove_maps_from_pool: return "res://maps/" + current.maps.pick_random() + ".map"
	var n : int = randi_range(0, current.maps.size() - 1)
	var map : String = current.maps[n]
	current.maps.remove_at(n)
	return "res://maps/" + map + ".map"
