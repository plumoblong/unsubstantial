@icon("res://images/entity/human.png")
extends Node
class_name Component

@export var enabled : bool = true
var updating : bool = false

func _process(_delta : float) -> void:
	if enabled:
		process_mode = ProcessMode.PROCESS_MODE_INHERIT
	else:
		process_mode = ProcessMode.PROCESS_MODE_DISABLED
