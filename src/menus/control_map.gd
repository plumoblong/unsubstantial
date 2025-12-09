extends Node2D
class_name ControlMap

var is_any_capturing : bool = false
@onready var page1 : Node2D = get_node("Page1")

func _process(_delta: float) -> void:
	if visible:
		for i in page1.get_children():
			i.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		for i in page1.get_children():
			i.process_mode = Node.PROCESS_MODE_DISABLED
