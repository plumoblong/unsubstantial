extends Label
class_name TextButton

@export var id : int = 0
@export var id2 : int = 0
@export var unselected_color : Color = Color.WHITE
@export var selected_color : Color = Color.YELLOW

var selected : bool = false
signal pressed

func update(a : int, b : int) -> void:
	if visible and get_parent().visible:
		if id == a and id2 == b:
			selected = true
		else:
			selected = false
	else:
		selected = false

func _process(_delta : float) -> void:
	if selected:
		modulate = selected_color
		if Input.is_action_just_pressed("ui_accept"):
			pressed.emit()
	else:
		modulate = unselected_color
