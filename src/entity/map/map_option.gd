extends Node3D
class_name MapOptions

@export var func_godot_properties : Dictionary = {
	"map_name" : "unnamed",
	"music" : "",
	"chapter_id" : 1,
	"bake_navmesh" : 1,
	"use_map_obstacle" : 1,
	
}

func _func_godot_build_complete() -> void:
	_G.game.current_map.map_name = func_godot_properties["map_name"]
	_G.game.current_map.chapter_id = func_godot_properties["chapter_id"]
	_G.game.current_map.bake_navmesh = bool(func_godot_properties["bake_navmesh"])
	$Info.text = "map_name: " + func_godot_properties["map_name"] + "\nchapter_id: " + str(func_godot_properties["chapter_id"]) + "\nbake_navmesh: " + str(func_godot_properties["bake_navmesh"])

func _process(_delta: float) -> void:
	visible = _G.debug_mode
	
