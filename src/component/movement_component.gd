extends Component
class_name MovementComponent

@export var speed : float = 10.0
@export var speed_up : float = 6.0
@export var speed_down : float = 9.0
@export var speed_mult_after_jump : float = 1.0

@export var floor_friction : float = 0.1
@export var air_friction : float = 0.05
@export var fall_speed : float = 16.0
@export var jump_speed : float = 6.0

var can_jump : bool = false
var friction : float = 0.0
var direction : Vector3 = Vector3.ZERO

var vel : Vector3
var on_floor : bool = false
var moving : float = 0.0
var actual_speed : float = 0.0

var is_using_force : bool = false

signal jumped

# Cached calculations
var speed_threshold : float
var friction_double : float
var friction_half : float

func _ready() -> void:
	_update_cached_values()

func _update_cached_values() -> void:
	speed_threshold = speed - (speed / 6.0)
	friction_double = floor_friction * 2.0
	friction_half = floor_friction / 2.0

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
			moving = lerpf(moving, 1.0, friction_double)
			if actual_speed < speed_threshold:
				actual_speed += delta * speed_up
			elif actual_speed > speed_threshold:
				actual_speed -= delta * speed_down
		else:
			moving = lerpf(moving, 0.0, friction)
		
		vel.x = lerpf(vel.x, direction.x * actual_speed, friction)
		vel.z = lerpf(vel.z, direction.z * actual_speed, friction)
	else:
		actual_speed -= delta * speed_down
		vel.x = lerpf(vel.x, 0.0, friction)
		vel.z = lerpf(vel.z, 0.0, friction)
		moving = lerpf(moving, 0.0, friction_half)
	
	if on_ceiling:
		vel.y = fall_speed

func update_flying(delta : float) -> void:
	if direction:
		moving = lerpf(moving, 1.0, air_friction)
		vel.x = lerpf(vel.x, direction.x * speed, air_friction)
		vel.z = lerpf(vel.z, direction.z * speed, air_friction)
		vel.y = lerpf(vel.y, direction.y * speed, air_friction)
	else:
		moving = lerpf(moving, 0.0, air_friction)
		vel.x = lerpf(vel.x, 0.0, air_friction)
		vel.z = lerpf(vel.z, 0.0, air_friction)
		vel.y = lerpf(vel.y, 0.0, air_friction)

func jump(amt : float = jump_speed) -> void:
	if not enabled: return
	can_jump = false
	vel.y = amt
	jumped.emit()
