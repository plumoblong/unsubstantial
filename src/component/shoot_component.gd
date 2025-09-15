extends Component
class_name ShootComponent

@export var shoot_delay : float = 0.0

@export var config : BulletSettings

var can_shoot : bool = true
@export var crit_chance : float = 0.0

signal shooted
signal reseted

func shoot(direction : Vector3 = Vector3.ZERO, origin : Vector3 = get_parent().global_position) -> void:
	if not enabled: return
	if can_shoot:
		
		reset()
		shooted.emit()
		await get_tree().create_timer(shoot_delay).timeout
		var angles : Array = get_bullet_angles(direction, config.spread_angle, config.shots)
		for i : int in range(config.shots):
			# Get angle for this bullet
			
			var bullet : Bullet = config.bullet_scene.instantiate()
			var cc : float = randf_range(0.0, 100.0)
			if cc < crit_chance:
				bullet.crit = true
			else:
				bullet.crit = false
			bullet.config = config
			bullet.global_position = origin
			var spread_dir : Vector3 = angles[i]
			if _G.debug_mode: _T.say(bullet.name + " went towards: " + _G.vector_to_string(spread_dir) + ".\nInput Direction: " + _G.vector_to_string(direction))
			bullet.direction = spread_dir
			# Set bullet direction
			#bullet.direction = final_direction
			
			#print(i)
			await get_tree().create_timer((shoot_delay / config.shots) * float(i) / 2.0, false, true, false).timeout
			get_parent().add_child(bullet)
			# Normalize to keep speed consistent
	else:
		return

func reset() -> void:
	var fire_rate : float = clamp(config.fire_rate * config.fire_rate_mult, 0.2, 10.0)
	can_shoot = false
	#print(get_parent().get_class(), " cantshoot ", fire_rate / 2.0)
	await get_tree().create_timer(fire_rate / 2.0).timeout
	#print(get_parent().get_class(), " reseted ", fire_rate / 2.0)
	reseted.emit()
	await get_tree().create_timer(fire_rate / 2.0).timeout
	#print(get_parent().get_class(), " canshoot ", fire_rate / 2.0)
	can_shoot = true
	
func get_bullet_angles(center_angle: Vector3, spread_angle: float, bullet_count: int) -> Array:
	var directions: Array = []
	
	if bullet_count == 1:
		return [center_angle]  # Just the forward shot

	# Construct a local orientation from center_dir
	var basis = Basis().looking_at(center_angle, Vector3.UP)

	# Fan out bullets across spread_angle (yaw spread around UP)
	for i in range(bullet_count):
		var t: float = i / float(bullet_count - 1)   # Normalized [0, 1]
		var angle: float = -spread_angle / 2 + t * spread_angle

		# Rotate around the local UP axis
		var rotated_basis = basis.rotated(basis.y, deg_to_rad(angle))
		var dir: Vector3 = -rotated_basis.z   # Forward is -Z in Godot
		directions.append(dir.normalized())

	return directions
