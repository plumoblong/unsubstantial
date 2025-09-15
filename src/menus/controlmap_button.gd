extends Button
class_name ControlMapButton

@export var action_name : String = "up"

@export var action_string : String = "Walk Forward"
@export var default_input : InputEvent

var key_string : String = "???"

var capturing : bool = false

func _ready() -> void:
	var new_mat = material.duplicate()
	material = new_mat

func _pressed() -> void:
	capturing = true
	get_parent().is_any_capturing = true

func _process(delta: float) -> void:
	if not capturing:
		text = action_string + ": [ " + key_string + " ]"
		material.set_shader_parameter("self_modulate", Color.WHITE)
	else:
		text = action_string + ": [ ... ]"
		material.set_shader_parameter("self_modulate", Color.HOT_PINK)

	if get_parent().is_any_capturing:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		disabled = true
	else:
		mouse_filter = Control.MOUSE_FILTER_STOP
		disabled = false

	key_string = str(InputMap.action_get_events(action_name)[0].as_text())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		if capturing and event.pressed:
			if Input.is_key_pressed(KEY_ESCAPE):
				capturing = false
				get_parent().is_any_capturing = false
				InputMap.action_erase_events(action_name)
				InputMap.action_add_event(action_name, default_input)
			else:
				capturing = false
				get_parent().is_any_capturing = false
				InputMap.action_erase_events(action_name)
				InputMap.action_add_event(action_name, event)
