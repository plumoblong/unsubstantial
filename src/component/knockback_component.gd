extends Component
class_name KnockbackComponent

@export var movement_component : Component
@export var multiplier : float = 2.0

func knock(position : Vector3, strength : float = 10.0) -> void:
	var direction : Vector3 = -get_parent().global_position.direction_to(position) 
	var act_strength : float = strength * multiplier
	if movement_component is MovementComponent or movement_component is PlayerMoveComponent:
		movement_component.apply_knockback(direction, strength * multiplier)
