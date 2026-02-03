extends Node2D
class_name ControlMap

var is_any_capturing : bool = false

@onready var page1 : Node2D = $Page1

# Cache children array to avoid repeated get_children() calls
var page1_children : Array

func _ready() -> void:
	page1_children = page1.get_children()

func _process(_delta : float) -> void:
	var process_mode : ProcessMode = Node.PROCESS_MODE_INHERIT if visible else Node.PROCESS_MODE_DISABLED
	
	for child : Node in page1_children:
		child.process_mode = process_mode
