extends Button

@onready var shadow : Button = $Shadow

@export var left_handle : String = ""
@export var right_handle : String = ""
@export var handle_text : String = ""

@export var normal_color : Color = Color.WHITE
@export var hover_color : Color = Color.YELLOW
@export var disabled_color : Color = Color.DIM_GRAY

@export var shadow_color : Color = Color.BLACK
@export var shadow_hover_color : Color = Color.BLACK
@export var shadow_disabled_color : Color = Color.BLACK

@export var shadow_distance : Vector2i = Vector2i(1, 1)

var current_shadow_color : Color
var current_color : Color

func _ready() -> void:
	use_parent_material = false
	if handle_text == "":
		handle_text = text
	if not disabled:
		current_shadow_color = shadow_color
		current_color = normal_color
	else:
		current_shadow_color = shadow_disabled_color
		current_color = disabled_color
	shadow.global_position = global_position + Vector2(shadow_distance)
	shadow.size = size
	shadow.alignment = alignment
	shadow.text = text
	#var new_mat = material.duplicate()
	#material = new_mat
	#
func _process(delta: float) -> void:
	if not visible: return
	if disabled: 
		mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
		current_shadow_color = shadow_disabled_color
		current_color = disabled_color
	else: 
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	modulate = current_color
	shadow.modulate = current_shadow_color

func mouse_entered() -> void:
	if not visible: return
	if not disabled:
		text = left_handle + handle_text + right_handle
		#_G.get_node("UIHover").play()
		current_shadow_color = shadow_hover_color
		current_color = hover_color
	else:
		current_shadow_color = shadow_color

func mouse_exited() -> void:
	if not visible: return
	if not disabled:
		text = handle_text
		current_shadow_color = shadow_color
		current_color = normal_color
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	else:
		current_shadow_color = shadow_disabled_color
		current_color = disabled_color
	
func _pressed() -> void:
	if not visible: return
	if not disabled:
		_G.get_node("UIHover").play()
