extends AudioStreamPlayer3D
class_name LevelAmbience

@export var random_position_radius : Vector3 = Vector3(100.0, 10.0, 100.0)

func _ready() -> void:
	global_position = Vector3(randf_range(-random_position_radius.x, random_position_radius.x), randf_range(-random_position_radius.y, random_position_radius.y), randf_range(-random_position_radius.z, random_position_radius.z))
	
