extends Node3D
class_name PlayerTarget

@export var target_distance : float = 1.0
@export var smoothing : float = 0.25

var offset : Vector3 = Vector3.ZERO

func _process(delta: float) -> void:
	visible = get_parent().hud.show_movement_var
	offset = lerp(offset, get_parent().velocity * target_distance, smoothing)
	global_position = get_parent().global_position + Vector3(0.0, 1.0, 0.0 ) + offset

func get_pos_multiplied(multiplier : float = 1.0) -> Vector3:
	return get_parent().global_position + Vector3(0.0, 1.0, 0.0) + (offset * multiplier)
