extends Component
class_name MovementComponent

@export var speed : float = 10.0
@export var speed_up : float = 6.0
@export var speed_down : float = 9.0
@export var speed_mult_after_jump : float = 1.0
@export var floor_friction : float = 0.1
@export var air_friction : float = 0.05
@export var fall_speed : float = 16.0
@export var fall_speed_mult : float = 1.5
@export var jump_speed : float = 8.0
@export var jump_boost : float = 1.0

var can_jump : bool = false
var friction : float = 0.0
var direction : Vector3 = Vector3.ZERO
var vel : Vector3
var moving : float = 0.0
var actual_speed : float = 0.0
var is_using_force : bool = false

# Knockback
var _knockback_velocity : Vector3 = Vector3.ZERO
var _knockback_decay : float = 7.0

signal jumped
signal just_landed

# Cached calculations
var speed_threshold : float
var friction_double : float
var friction_half : float

var _was_on_floor : bool = false

# Cached parent reference
var _parent : CharacterBody3D

func _ready() -> void:
	_update_cached_values()
	_parent = get_parent() as CharacterBody3D
	assert(_parent != null, "MovementComponent parent must be a CharacterBody3D")

func _update_cached_values() -> void:
	speed_threshold = speed - (speed * 0.2)
	friction_double = floor_friction * 2.0
	friction_half = floor_friction * 0.5

func update(delta : float, on_ceiling : bool = false) -> void:
	if not enabled: return
	
	var on_floor := _parent.is_on_floor()
	
	if _knockback_velocity.length_squared() > 0.0001:
		vel += _knockback_velocity
		_knockback_velocity = _knockback_velocity.lerp(Vector3.ZERO, _knockback_decay * delta)
	else:
		_knockback_velocity = Vector3.ZERO
	
	if not on_floor:
		if vel.y > 0.0:
			vel.y -= fall_speed * delta
		else:
			vel.y -= fall_speed * fall_speed_mult * delta
		friction = air_friction
		can_jump = false
	else:
		friction = floor_friction
		can_jump = true
		if not _was_on_floor:
			just_landed.emit()
	
	_was_on_floor = on_floor

	var has_direction : bool = direction.length_squared() > 0.0001 # Optimized check
	if has_direction:
		if _parent.is_on_floor():
			moving = lerpf(moving, 1.0, friction_double)
			# Optimized: Combined threshold checks
			actual_speed = move_toward(actual_speed, speed_threshold, 
				speed_up * delta if actual_speed < speed_threshold else speed_down * delta)
		else:
			moving = lerpf(moving, 0.0, friction)
		
		vel.x = lerpf(vel.x, direction.x * actual_speed, friction)
		vel.z = lerpf(vel.z, direction.z * actual_speed, friction)
	else:
		actual_speed = move_toward(actual_speed, 0.0, speed_down * delta)
		vel.x = lerpf(vel.x, 0.0, friction)
		vel.z = lerpf(vel.z, 0.0, friction)
		moving = lerpf(moving, 0.0, friction_half)
	
	#if on_ceiling:
		#vel.y = fall_speed

func update_flying(delta : float) -> void:
	if not enabled: return
	
	var has_direction : bool = direction.length_squared() > 0.0001
	var target_moving : float = 1.0 if has_direction else 0.0
	
	moving = lerpf(moving, target_moving, air_friction)
	
	if has_direction:
		vel.x = lerpf(vel.x, direction.x * speed, air_friction)
		vel.z = lerpf(vel.z, direction.z * speed, air_friction)
		vel.y = lerpf(vel.y, direction.y * speed, air_friction)
	else:
		vel.x = lerpf(vel.x, 0.0, air_friction)
		vel.z = lerpf(vel.z, 0.0, air_friction)
		vel.y = lerpf(vel.y, 0.0, air_friction)

func jump(amount : float = 0.0) -> void:
	if not enabled or not can_jump: return
	can_jump = false
	var amt : float = jump_speed if amount == 0.0 else amount
	vel.x *= jump_boost
	vel.y += amt
	vel.z *= jump_boost
	jumped.emit()

func apply_knockback(direction: Vector3, power: float, lift_off_ground: bool = true) -> void:
	if not enabled or not _parent: return
	var knockback_dir : Vector3 = direction.normalized()
	const Y_MULT : Vector3 = Vector3(1.0, 0.1, 1.0)
	if _parent.is_on_floor() and lift_off_ground:
		var up_influence : float = 0.5
		knockback_dir = (knockback_dir + Vector3.UP * up_influence).normalized()
	_knockback_velocity = knockback_dir * power * Y_MULT
	can_jump = false
