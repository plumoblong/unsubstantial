extends Component
class_name ChapterManager

@export var current : Chapter

## All chapters, in any order — sorted automatically by stage_start at runtime.
## To add a new chapter just create the resource, set its stage_start, and drop
## it anywhere in this array.  No duplicates, no gaps to fill.
@export var all : Array[Chapter]
@export var environments : Array[Environment]

const MAP_PREFIX : String = "res://maps/"
const MAP_SUFFIX : String = ".map"
var available_maps : Array[String] = []

## Sorted copy built once in get_chapter_for_stage() — don't edit directly.
var _sorted : Array[Chapter] = []

func get_map() -> String:
	if current.maps.is_empty():
		return MAP_PREFIX + current.map_fallback + MAP_SUFFIX
	if available_maps.is_empty():
		available_maps = current.maps.duplicate()
	var index : int = randi() % available_maps.size()
	var chosen : String = available_maps[index]
	available_maps.remove_at(index)
	_T.say(MAP_PREFIX + chosen + MAP_SUFFIX)
	return MAP_PREFIX + chosen + MAP_SUFFIX

## Returns the chapter whose stage_start is the highest value still <= stage.
## Example setup (stage_start → chapter):
##   0 → Ether   (always first)
##   1 → Forest
##   4 → Caves
##   8 → Volcano
## Insert a new chapter between Forest and Caves? Just add one with stage_start = 2 or 3.
func get_chapter_for_stage(stage: int) -> Chapter:
	if _sorted.is_empty():
		_sorted = all.duplicate()
		_sorted.sort_custom(func(a: Chapter, b: Chapter) -> bool:
			return a.stage_start < b.stage_start)

	var result : Chapter = _sorted[0]
	for ch in _sorted:
		if ch.stage_start <= stage:
			result = ch
		else:
			break
	return result
