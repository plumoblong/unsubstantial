extends Node3D
class_name MapOptions

@export var func_godot_properties : Dictionary = {
	"map_name" : "unnamed",
	"music" : "",
	"chapter_id" : 1,
	"use_map_obstacle" : 1,
	
}

func _func_godot_build_complete() -> void:
	
	_G.game.current_map.set_data(func_godot_properties)
	$Info.text = "map_name: \"" + func_godot_properties["map_name"] + "\"" 
	$Info.text = "chapter_id: " + str(func_godot_properties["chapter_id"])

func _process(_delta: float) -> void:
	visible = _G.show_fps
