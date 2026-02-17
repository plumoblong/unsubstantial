extends Node3D
class_name EntMoveHelper

@onready var back : Node3D = get_node("Back")
@onready var left : Node3D = get_node("Left")
@onready var right : Node3D = get_node("Right")

func get_random_direction() -> Node3D:
	return [left, right].pick_random()
