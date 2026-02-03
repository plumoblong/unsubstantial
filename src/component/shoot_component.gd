extends Component
class_name ShootComponent

@export var shoot_delay : float = 0.0
@export var config : BulletSettings
@export var crit_chance : float = 0.0

var can_shoot : bool = true

signal shooted
signal reseted

# Cached values
var parent : Node
var tree : SceneTree

func _ready() -> void:
	parent = get_parent()
	tree = get_tree()

func shoot(direction : Vector3 = Vector3.ZERO, origin : Vector3 = Vector3.ZERO) -> void:
	if not enabled or not can_shoot: return
	
	if origin == Vector3.ZERO:
		origin = parent.global_position
	
	reset()
	shooted.emit()
	
	if shoot_delay > 0.0:
		await tree.create_timer(shoot_delay).timeout
	
	var angles : Array = get_bullet_angles(direction, config.spread_angle, config.shots)
	var shot_count : int = config.shots
	var shot_delay : float = (shoot_delay / float(shot_count)) * 0.5
	
	for i : int in range(shot_count):
		var bullet : Bullet = config.bullet_scene.instantiate()
		
		# Determine crit status
		bullet.crit = randf_range(0.0, 100.0) < crit_chance
		
		bullet.config = config
		bullet.global_position = origin
		bullet.direction = angles[i]
		
		if _G.debug_mode:
			_T.say(bullet.name + " went towards: " + _G.vector_to_string(angles[i]) + ".\nInput Direction: " + _G.vector_to_string(direction))
		
		if i > 0 and shot_delay > 0.0:
			await tree.create_timer(shot_delay * float(i), false, true, false).timeout
		
		parent.add_child(bullet)

func reset() -> void:
	var fire_rate : float = clamp(config.fire_rate * config.fire_rate_mult, 0.2, 10.0)
	var half_rate : float = fire_rate * 0.5
	
	can_shoot = false
	await tree.create_timer(half_rate).timeout
	reseted.emit()
	await tree.create_timer(half_rate).timeout
	can_shoot = true

func get_bullet_angles(center_angle : Vector3, spread_angle : float, bullet_count : int) -> Array:
	if bullet_count == 1:
		return [center_angle]
	
	var directions : Array = []
	var basis : Basis = Basis().looking_at(center_angle, Vector3.UP)
	var half_spread : float = spread_angle * 0.5
	var bullet_count_float : float = float(bullet_count - 1)
	
	for i : int in range(bullet_count):
		var t : float = float(i) / bullet_count_float
		var angle : float = -half_spread + t * spread_angle
		var rotated_basis : Basis = basis.rotated(basis.y, deg_to_rad(angle))
		directions.append((-rotated_basis.z).normalized())
	
	return directions
