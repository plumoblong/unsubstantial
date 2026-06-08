extends Component
class_name ShootComponent

@export var config: BulletSettings
@export var crit_chance: float = 0.0
@export var visual_bullet: VisualBullet

var can_shoot: bool = true
signal shooted
signal reseted
var parent: Node
var tree: SceneTree

func _ready() -> void:
	parent = get_parent()
	tree = get_tree()
	if not visual_bullet: return
	visual_bullet.setup(config)

func shoot(direction: Vector3 = Vector3.ZERO, origin: Vector3 = Vector3.ZERO) -> void:
	if not enabled or not can_shoot: return
	if origin == Vector3.ZERO:
		if visual_bullet:
			origin = visual_bullet.global_position
		else:
			origin = parent.global_position
	
	
	reset()
	shooted.emit()

	var shot_count: int = config.shots
	var angles: Array = get_bullet_angles(direction, config.spread_angle, shot_count)
	var inaccuracy: float = config.inaccuracy

	var first_bullet: Bullet = _G.game.BULLET_SCENE.instantiate()
	first_bullet.crit = randf_range(0.0, 100.0) < crit_chance
	first_bullet.config = config
	
	first_bullet.direction = angles[0] + Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * inaccuracy
	parent.add_child(first_bullet)
	first_bullet.global_position = origin

	for i: int in range(1, shot_count):
		var bullet: Bullet = _G.game.BULLET_SCENE.instantiate()
		bullet.crit = randf_range(0.0, 100.0) < crit_chance
		bullet.config = config
		bullet.direction = angles[i] + Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * inaccuracy
		parent.add_child(bullet)
		bullet.global_position = origin
	
	

func reset() -> void:
	var fire_rate: float = clamp(config.fire_rate * config.fire_rate_mult, 0.2, 10.0)
	can_shoot = false
	await tree.create_timer(fire_rate).timeout
	reseted.emit()
	can_shoot = true

func get_bullet_angles(center_angle: Vector3, spread_angle: float, bullet_count: int) -> Array:
	if bullet_count == 1:
		return [center_angle]

	var directions: Array = []
	directions.resize(bullet_count)
	var basis: Basis = Basis.looking_at(center_angle, Vector3.UP)
	var half_spread: float = spread_angle * 0.5
	var angle_step: float = deg_to_rad(spread_angle) / float(bullet_count - 1)
	var start_angle: float = deg_to_rad(-half_spread)

	for i: int in range(bullet_count):
		var rotated_basis: Basis = basis.rotated(basis.y, start_angle + angle_step * float(i))
		directions[i] = (-rotated_basis.z).normalized()

	return directions
