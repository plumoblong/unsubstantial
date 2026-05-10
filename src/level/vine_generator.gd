extends Node3D
class_name VineGenerator

@export var func_godot_properties : Dictionary[String, Variant] = {
	"radius" = 15.0,
	"flip" = 0
}

const VINE_SCENE : PackedScene = preload("res://prefab/level/prop/vine.tscn")

func _func_godot_build_complete() -> void:
	var num_vines : int= randi_range(2, 5)
	for i in range(num_vines):
		var rand_pos : Vector3 = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized() * randf_range(-func_godot_properties["radius"], func_godot_properties["radius"])
		var v : Vine = VINE_SCENE.instantiate()
		v.flip = bool(func_godot_properties["flip"])
		add_child(v)
		v.global_position = global_position + rand_pos
