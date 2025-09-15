extends Component
class_name DashComponent

@export var dash_speed : float = 96.0
@export var dash_time : float = 1.0
@export var cooldown : float = 1.25
@export var jump_height : float = 0.25
@export var dash_time_tresh : float = 4.0
@export var auto_reset : bool = true
@export var delay : float = 0.0

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

func dash(mc : Component) -> void:
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
			mc.speed = dash_speed
			mc.direction = -get_parent().transform.basis.z
			if not mc.on_floor:
				mc.vel.y = mc.jump_speed * jump_height
			await get_tree().create_timer(dash_time / 10.0).timeout
			just_dashed = false
			if mc.on_floor:
				mc.speed = mc.max_speed * 1.1
			else:
				mc.speed = mc.max_speed - (mc.max_speed / 6.0)
			await get_tree().create_timer(dash_time / dash_time_tresh).timeout
			dashing = false
		elif mc is PlayerMoveComponent:
			var speed : float = mc.walk_speed * (mc.ground_cap * 0.67)
			var base_friction : float = mc.ground_friction
			mc.ground_friction = -base_friction
			#get_parent().velocity = Vector3.ZERO\
			var basis : Vector3 = -get_parent().camera.global_transform.basis.z.normalized()
			if get_parent().is_on_floor():
				final_vector = Vector3(basis.x * speed, 0.0, basis.z * speed)
			else:
				final_vector = Vector3(basis.x * speed, basis.y * (speed * 0.45), basis.z * speed)
			get_parent().velocity = final_vector
			just_dashed = false
			await get_tree().create_timer(dash_time).timeout
			dashing = false
			mc.ground_friction = base_friction
	else:
		return

func reset() -> void:
	can_dash = false
	await get_tree().create_timer(cooldown).timeout
	can_reset = true
	return
