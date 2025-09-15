extends Component
class_name MovementComponent



@export var max_speed : float = 20.0
@export var default_speed : float = 10.0
@export var speed_up : float = 6.0
@export var speed_down : float = 9.0
@export var speed_mult_after_jump : float = 1.0

@export var floor_friction : float = 0.1
@export var air_friction : float = 0.001
@export var fall_speed : float = 15.0
@export var jump_speed : float = 6.0

var can_jump : bool = false
var speed : float = 0.0
var friction : float = 0.0
var direction : Vector3 = Vector3.ZERO

var vel : Vector3
var on_floor : bool = false
var moving : float = 0.0

var is_using_force : bool = false

signal jumped

func update(delta : float, on_ceiling : bool = false) -> void:
	if not enabled: return
	if not on_floor:
		vel.y -= fall_speed * delta
		friction = air_friction
	else:
		friction = floor_friction
		if not is_using_force:
			vel.y = 0.0
		can_jump = true
	
	if direction:
		if on_floor:
			moving = lerpf(moving, 1.0, friction * 2.0)
			if speed < max_speed - (max_speed / 6.0):
				speed += delta * speed_up
			elif speed > max_speed - (max_speed / 6.0):
				speed -= delta * speed_down
		else:
			moving = lerpf(moving, 0.0, friction)
			if vel.y >= 0.0:
				if speed < max_speed:
					speed += delta * speed_up * 0.75
		if speed > max_speed:
			speed -= delta * speed_down * 2.0
		vel.x = lerpf(vel.x, direction.x * speed, friction)	
		vel.z = lerpf(vel.z, direction.z * speed, friction)
	else:
		speed -= delta * speed_down
		vel.x = lerpf(vel.x, 0.0, friction)
		vel.z = lerpf(vel.z, 0.0, friction)
		moving = lerpf(moving, 0.0, friction / 2.0)
	
	speed = clamp(speed, default_speed, 256.0)
	if on_ceiling:
		vel.y = 0.0
	
func update_flying(delta : float) -> void:
	if direction:
		moving = lerpf(moving, 1.0, air_friction)
		if speed < max_speed - (max_speed / 7.5):
			speed += (delta * speed_up)
		vel.x = lerpf(vel.x, direction.x * speed, air_friction)
		vel.z = lerpf(vel.z, direction.z * speed, air_friction)
		vel.y = lerpf(vel.y, direction.y * speed, air_friction)
	else:
		moving = lerpf(moving, 0.0, air_friction)
		speed -= delta * speed_down
		vel.x = lerpf(vel.x, 0.0, air_friction)
		vel.z = lerpf(vel.z, 0.0, air_friction)
		vel.y = lerpf(vel.y, 0.0, air_friction)

func jump(amt : float = jump_speed) -> void:
	if not enabled: return
	can_jump = false
	
	vel.y = amt
	jumped.emit()
