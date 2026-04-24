extends NavigationRegion3D
class_name SpecialRoom

var builder : FuncGodotMap

@export var func_godot_properties : Dictionary[String, String] = {
	"maps" : "treasure1;treasure2;"
}

var _can_build : bool = false

func _parse_map_list() -> Array[String]:
	var result: Array[String] = []
	for entry : String in func_godot_properties["maps"].split(";"):
		var trimmed : String = entry.strip_edges().trim_suffix(":")
		if not trimmed.is_empty():
			result.append("res://maps/special/%s.map" % trimmed)
	return result
	
func _pick_map() -> void:
	builder.map_settings = _G.MAP_SETTINGS
	builder.local_map_file = _parse_map_list().pick_random()
	
func _func_godot_build_complete() -> void:
	_pick_map()
	_T.say(builder.local_map_file)
	if _can_build:
		builder.build() 
		bake_navigation_mesh()
		
func builder_ready() -> void:
	builder = $Builder
	
	_can_build = true
