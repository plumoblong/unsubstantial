extends Node3D

func _ready() -> void:
	$PalmTree.flip_h = bool(randi_range(0, 1))
	rotation_degrees.y = randf_range(0.0, 360.0)
	position.y -= randf_range(0.00, 0.35)
	var size : float = randf_range(0.9, 1.4)
	var tc : Color = _G.hsv_to_rgb(randf_range(0.00, 1.00), randf_range(0.3, 0.7), 1.0)
	$Top.modulate = tc
	$Top2.modulate = tc
	$Top3.modulate = tc
	$Top4.modulate = tc
	$Top.frame = randi_range(0, 5)
	$Top2.frame = randi_range(0, 5)
	$Top3.frame = randi_range(0, 5)
	$Top4.frame = randi_range(0, 5)
	$Light.light_color = tc
	scale = Vector3(size, size, size)
