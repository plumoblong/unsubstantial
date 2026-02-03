extends Node3D

func _ready() -> void:
	
	$"../PalmTree".flip_h = bool(randi_range(0, 1))
	get_parent().rotation_degrees.y = randf_range(0.0, 360.0)
	get_parent().position.y -= randf_range(0.00, 0.35)
	var size : float = randf_range(0.9, 1.4)
	var tc : Color = Color.from_hsv(randf_range(0.00, 1.00), randf_range(0.5, 1.0), 1.0)
	$"../Top".modulate = tc
	$"../Top2".modulate = tc
	$"../Top3".modulate = tc
	$"../Top4".modulate = tc
	$"../Top".frame = randi_range(0, 5)
	$"../Top2".frame = randi_range(0, 5)
	$"../Top3".frame = randi_range(0, 5)
	$"../Top4".frame = randi_range(0, 5)
	$"../Light".light_color = tc
	get_parent().scale = Vector3(size, size, size)
	
	queue_free.call_deferred()
