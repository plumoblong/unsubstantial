extends Button
class_name ControlMapButton

@export var action_name : String = "up"
@export var hover_color : Color = Color.YELLOW
@export var action_string : String = "Walk Forward"
@export var default_input : InputEvent

var key_string : String = "???"
var capturing : bool = false

# Cached references
var control_map : Node
var shader_mat : ShaderMaterial

# String constants
const TEXT_PREFIX : String = ": [ "
const TEXT_SUFFIX : String = " ]"
const CAPTURING_TEXT : String = ": [ Input Anything ]"

func _ready() -> void:
	shader_mat = material.duplicate()
	material = shader_mat
	control_map = get_parent().get_parent()

func _pressed() -> void:
	capturing = true
	control_map.is_any_capturing = true

func _process(_delta : float) -> void:
	# Update text and color
	if not capturing:
		text = action_string + TEXT_PREFIX + key_string + TEXT_SUFFIX
		shader_mat.set_shader_parameter("self_modulate", Color.WHITE)
	else:
		text = action_string + CAPTURING_TEXT
		shader_mat.set_shader_parameter("self_modulate", hover_color)
	
	# Update interaction state
	if control_map.is_any_capturing:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		disabled = true
	else:
		mouse_filter = Control.MOUSE_FILTER_STOP
		disabled = false
	
	# Update key string
	key_string = str(InputMap.action_get_events(action_name)[0].as_text())

func _unhandled_input(event : InputEvent) -> void:
	if capturing and event.pressed:
		if event is InputEventKey or event is InputEventMouseButton:
			capturing = false
			control_map.is_any_capturing = false
			InputMap.action_erase_events(action_name)
			
			if Input.is_key_pressed(KEY_ESCAPE):
				InputMap.action_add_event(action_name, default_input)
			else:
				InputMap.action_add_event(action_name, event)
			
			_G.config.controls.bind = _G.return_input_binds_to_dict()
