extends Sprite3D
class_name Familiar

@export var position_offset : Vector3 = Vector3(-1.0, 0.0, 0.0)
@export var smoothing : float = 0.1

@export var leader : Node

func _process(delta : float) -> void:
	global_position = lerp(global_position, leader.global_position, smoothing)
