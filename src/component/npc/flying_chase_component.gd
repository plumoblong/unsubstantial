extends Component
class_name FlyingChaseComponent

signal destination_reached

@export var path_point_margin: float = 0.5

var desired_velocity: Vector3 = Vector3.ZERO

var _map_rid: RID
var _path: PackedVector3Array = []
var _path_index: int = 0

var start_position : Vector3

@export var movehelper : EntMoveHelper
@export var agro_distance : float = 20.0
@export var attack_distance : float = 10.0
@export var min_attack_distance : float = 1.0
@export var min_distance : float = 5.0
@export var y_distance : float = 3.0
@export var update_rate : int = 4
@export var concious_gain_time : float = 0.5
@export var entropy : float = 0.35

var target_distance : float
var target_direction : Vector3
var agent_position : Vector3
var y_difference : float
var concious : bool = false
var attacking : bool

# Cached references
var parent : Node3D

func _ready() -> void:
	await get_tree().physics_frame
	parent = get_parent()
	_setup_entropy()
	_map_rid = get_viewport().find_world_3d().get_navigation_map()
	await get_tree().create_timer(concious_gain_time).timeout
	concious = true
	
func _setup_entropy() -> void:
	min_distance = min_distance * randf_range(1.0, 1.0 + (entropy * 2.0))
	attack_distance = attack_distance * randf_range(1.0, 1.0 + (entropy * 2.0))
	agro_distance = agro_distance * randf_range(1.0, 1.0 + entropy)
	
func set_target(target_position: Vector3) -> void:
	if not _map_rid.is_valid():
		return
	_path = NavigationServer3D.map_get_path(
		_map_rid,
		get_parent().global_position,
		target_position,
		true
	)
	_path_index = 0

func stop() -> void:
	_path = []
	desired_velocity = Vector3.ZERO

func is_moving() -> bool:
	return not _path.is_empty()

func update(movement_component : MovementComponent, target_y : float) -> void:
	if _path.is_empty() or not enabled:
		return
	
	var target_point : Vector3 = _path[_path_index]
	var flat_self : Vector3= Vector3(get_parent().global_position.x, 0.0, get_parent().global_position.z)
	var flat_target : Vector3 = Vector3(target_point.x, 0.0, target_point.z)
	
	var parent_pos : Vector3 = parent.global_position
	target_distance = parent_pos.distance_to(target_point)
	target_direction = parent_pos.direction_to(target_point)
	
	attacking = concious and (target_distance <= attack_distance and target_distance > min_attack_distance)
	
	if flat_self.distance_to(flat_target) <= path_point_margin:
		_path_index += 1
		if _path_index >= _path.size():
			stop()
			destination_reached.emit()
			return
	target_point = _path[_path_index]
	movement_component.direction = parent_pos.direction_to(Vector3(target_point.x, target_y, target_point.z)).normalized()
