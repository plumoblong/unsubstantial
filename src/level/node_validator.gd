extends Node
class_name NodeValidator

@export var node : Node
@export var remove : bool = false
@export var check_on_ready : bool = false

@export var delay : float = 0.0

func _ready() -> void:
	if check_on_ready:
		check() 
	else:
		get_parent().dungeon_done_generating.connect(check)

func check() -> void:
	await get_tree().create_timer(delay).timeout
	if remove:
		if is_instance_valid(node) or node == null:
			queue_free()
			return
	else:
		if not is_instance_valid(node) or node == null:
			queue_free()
			return
