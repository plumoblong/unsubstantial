extends Label
class_name ValueButton

@export var id : int = 0
@export var id2 : int = 0
@export var unselected_color : Color = Color.WHITE
@export var selected_color : Color = Color.YELLOW

@export_category("value button shit")
@export var value_name : String = "Value"
@export var value : float = 1.0
@export var min_value : float = 0.0
@export var max_value : float = 10.0
@export var step : float = 1.0
@export var percent : bool = false
@export var continuous : bool = false
@export var limit : bool = false

var selected : bool = false
#signal pressed

func update(a : int, b : int) -> void:
	if visible and get_parent().visible:
		if id == a and id2 == b:
			selected = true
		else:
			selected = false
	else:
		selected = false

func _physics_process(_delta : float) -> void:
	if selected:
		modulate = selected_color
		if not continuous:
			if Input.is_action_just_pressed("left"):
				if limit:
					if value > min_value:
						value -= step
				else:
					if value > min_value:
						value -= step
					else:
						value = max_value
			elif Input.is_action_just_pressed("right"):
				if limit:
					if value < max_value:
						value += step
				else:
					if value < max_value:
						value += step
					else:
						value = min_value
		else:
			if Input.is_action_pressed("left"):
				if limit:
					if value > min_value:
						value -= step
				else:
					if value > min_value:
						value -= step
					else:
						value = max_value
			elif Input.is_action_pressed("right"):
				if limit:
					if value < max_value:
						value += step
				else:
					if value <= max_value:
						value += step
					else:
						value = min_value
	else:
		modulate = unselected_color
	if percent:
		text = value_name + ":  < " + str(snappedf(value, 0.01)) + "% >"  
	else:
		text = value_name + ":  < " + str(snappedf(value, 0.01)) + " >"  
