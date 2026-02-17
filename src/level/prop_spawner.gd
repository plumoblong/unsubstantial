extends Node3D
class_name PropSpawner

@export var func_godot_properties : Dictionary = {
	"scale" = Vector3(1,1,1), "prop_name" = ""
}



func _func_godot_build_complete() -> void:
	var prop_file = load("res://prefab/level/prop/" + func_godot_properties["prop_name"] + ".tscn")
	var prop_obj = prop_file.instantiate()
	var pre_scale = prop_obj.scale
	_G.game.current_map.add_child(prop_obj)
	prop_obj.scale = pre_scale * func_godot_properties["scale"]
	prop_obj.global_position = global_position
	
