extends Component
class_name DashComponent

@export var dash_speed : float = 96.0
@export var dash_time : float = 1.0
@export var cooldown : float = 1.25
@export var jump_height : float = 0.25
@export var dash_time_tresh : float = 4.0
@export var auto_reset : bool = true
@export var delay : float = 0.0
@export var end_velocity_multiplier : float = 0.4

var can_dash : bool = true
var dashing : bool = false
var can_reset : bool = false
var just_dashed : bool = false

signal dashed
signal can_dash_now

var final_vector : Vector3 = Vector3.ZERO

func update() -> void:
	if not enabled: return
	if can_reset and get_parent().is_on_floor():
		can_dash = true
		can_dash_now.emit()
		can_reset = false

func dash(mc : Component, direction : Vector3 = Vector3.ZERO) -> void:
	if not enabled: return
	await get_tree().create_timer(delay).timeout
	if can_dash:
		if auto_reset:
			reset()
		dashing = true
		just_dashed = true
		dashed.emit()
		
		if mc is MovementComponent:
			mc.friction = mc.floor_friction * 3.0
			var old_speed : float = mc.speed
			mc.speed = dash_speed
			if direction == Vector3.ZERO:
				mc.direction = -get_parent().transform.basis.z
			else:
				mc.direction = direction
			if not mc.on_floor:
				mc.vel.y = mc.jump_speed * jump_height
			await get_tree().create_timer(dash_time / 10.0).timeout
			just_dashed = false
			mc.speed = old_speed
			await get_tree().create_timer(dash_time / dash_time_tresh).timeout
			dashing = false
		elif mc is PlayerMoveComponent:
			var speed : float = mc.walk_speed * (mc.ground_cap)
			
			#get_parent().velocity = Vector3.ZERO\
			var basis : Vector3 = -get_parent().camera.global_transform.basis.z.normalized()
			if get_parent().is_on_floor():
				get_parent().velocity = Vector3(basis.x * dash_speed, 0.0, basis.z * dash_speed)
				#just_dashed = false
				#await get_tree().create_timer(dash_time).timeout
				#dashing = false
				#mc.ground_friction = base_friction
			else:
				get_parent().velocity = Vector3(basis.x * dash_speed, basis.y * speed, basis.z * dash_speed)
			just_dashed = false
			await get_tree().create_timer(dash_time).timeout
			get_parent().velocity *= end_velocity_multiplier
			dashing = false
			#get_parent().velocity = final_vector

	else:
		return

func reset() -> void:
	if can_dash: can_dash = false
	await get_tree().create_timer(cooldown).timeout
	can_reset = true
	return
