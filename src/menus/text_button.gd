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

# Cached values
var is_disabled : bool = false
var hover_text : String
var ui_hover_node : Node

func _ready() -> void:
	use_parent_material = false
	
	# Cache handle text
	if handle_text == "":
		handle_text = text
	
	# Pre-build hover text once
	hover_text = left_handle + handle_text + right_handle
	
	# Set initial colors
	is_disabled = disabled
	if is_disabled:
		current_shadow_color = shadow_disabled_color
		current_color = disabled_color
	else:
		current_shadow_color = shadow_color
		current_color = normal_color
	
	# Configure shadow
	shadow.global_position = global_position + Vector2(shadow_distance)
	shadow.size = size
	shadow.alignment = alignment
	shadow.text = text
	
	# Cache UI hover node
	ui_hover_node = _G.get_node("UIHover")

func _process(_delta : float) -> void:
	# Early exit if not visible
	if not visible: return
	
	# Only update if disabled state changed
	var new_disabled : bool = disabled
	if is_disabled != new_disabled:
		is_disabled = new_disabled
		if is_disabled:
			mouse_default_cursor_shape = CURSOR_FORBIDDEN
			current_shadow_color = shadow_disabled_color
			current_color = disabled_color
		else:
			mouse_default_cursor_shape = CURSOR_POINTING_HAND
			current_shadow_color = shadow_color
			current_color = normal_color
	
	# Apply colors (these are lightweight operations)
	modulate = current_color
	shadow.modulate = current_shadow_color

func mouse_entered() -> void:
	if not visible or is_disabled: return
	
	text = hover_text
	current_shadow_color = shadow_hover_color
	current_color = hover_color

func mouse_exited() -> void:
	if not visible: return
	
	if is_disabled:
		current_shadow_color = shadow_disabled_color
		current_color = disabled_color
	else:
		text = handle_text
		current_shadow_color = shadow_color
		current_color = normal_color
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _pressed() -> void:
	if visible and not is_disabled:
		ui_hover_node.play()
