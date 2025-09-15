extends Node3D
class_name PlacingRandomizer

@export var spherical : bool = false
@export var radius_x : float = 1.0
@export var radius_y : float = 0.0
@export var radius_z : float = 1.0
@export var size_max : float = 1.0
@export var size_min : float = 1.0

func _ready() -> void:
	for i in range(get_child_count()):
		var offset : Vector3
		var size : float = randf_range(size_min, size_max)
		if spherical:
			offset = Vector3(randf_range(-radius_x, radius_x), randf_range(-radius_y, radius_y), randf_range(-radius_z, radius_z)).normalized()
		else:
			offset = Vector3(randf_range(-radius_x, radius_x), randf_range(-radius_y, radius_y), randf_range(-radius_z, radius_z))
		var child : Node = get_child(i)
		if child is Node3D:
			child.global_position += offset
			child.scale = Vector3(size, size, size)
			
