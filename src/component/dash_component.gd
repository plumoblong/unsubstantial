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

# Cached values
var parent : Node
var tree : SceneTree

func _ready() -> void:
	parent = get_parent()
	tree = get_tree()

func allow_dash(check_if_reset : bool = true) -> void:
	if check_if_reset and not can_reset: return
	can_dash = true
	can_dash_now.emit()
	can_reset = false

func dash(mc : Component, direction : Vector3 = Vector3.ZERO) -> void:
	if not enabled or not can_dash: return
	
	if delay > 0.0:
		await tree.create_timer(delay).timeout
	
	if auto_reset:
		reset()
	
	dashing = true
	just_dashed = true
	dashed.emit()
	
	if mc is MovementComponent:
		_dash_movement_component(mc, direction)
	elif mc is PlayerMoveComponent:
		_dash_player_component(mc)

func _dash_movement_component(mc : MovementComponent, direction : Vector3) -> void:
	mc.friction = mc.floor_friction * 3.0
	var old_speed : float = mc.speed
	mc.speed = dash_speed
	
	if direction == Vector3.ZERO:
		mc.direction = -parent.transform.basis.z
	else:
		mc.direction = direction
	
	if not parent.is_on_floor():
		mc.vel.y = mc.jump_speed * jump_height
	
	await tree.create_timer(dash_time / 10.0).timeout
	just_dashed = false
	mc.speed = old_speed
	await tree.create_timer(dash_time / dash_time_tresh).timeout
	dashing = false

func _dash_player_component(mc : PlayerMoveComponent) -> void:
	var y_speed : float = mc.walk_speed * mc.ground_cap
	var basis : Vector3 = -parent.camera.global_transform.basis.z.normalized()
	
	#if parent.is_on_floor():
		#parent.velocity = Vector3(basis.x * dash_speed, 0.0, basis.z * dash_speed)
	#else:
	parent.velocity = Vector3(basis.x * dash_speed, basis.y * y_speed, basis.z * dash_speed)
	
	just_dashed = false
	await tree.create_timer(dash_time).timeout
	parent.velocity *= end_velocity_multiplier
	dashing = false

func reset() -> void:
	if can_dash:
		can_dash = false
	await tree.create_timer(cooldown).timeout
	can_reset = true
