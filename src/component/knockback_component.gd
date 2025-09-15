extends Component
class_name KnockbackComponent

@export var movement_component : Component
@export var multiplier : float = 1.0
@export var y_multiplier : float = 0.34

func knock(position : Vector3, strength : float = 10.0, y_strength : float = 1.0) -> void:
	var hit_position : Vector3 = get_parent().global_position.direction_to(position) 
	if movement_component is MovementComponent:
		movement_component.vel += -hit_position * Vector3(multiplier, y_multiplier * y_strength, multiplier) * (strength)
	else:
		get_parent().global_position.y += 0.25
		get_parent().velocity -= hit_position * Vector3(multiplier, y_multiplier * y_strength, multiplier) * (strength)
