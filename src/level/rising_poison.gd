extends Node3D
class_name RisingPoison

@export var func_godot_properties : Dictionary[String, Variant] = {
	"end_y" : 100.0, "speed" : 0.5
}

func _physics_process(delta: float) -> void:
	if global_position.y >= func_godot_properties["end_y"] : return
	global_position.y += delta * func_godot_properties["speed"]
	
