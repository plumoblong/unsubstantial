extends Component
class_name ChaseComponent

var start_position : Vector3

@export var movehelper : EntMoveHelper
@export var agro_distance : float = 20.0
@export var attack_distance : float = 10.0
@export var min_distance : float = 5.0
@export var y_distance : float = 3.0
@export var update_rate : int = 4

var target_distance : float
var target_direction : Vector3
var agent_position : Vector3
var y_difference : float
var concious : bool = false
var attacking : bool

# Cached references
var parent : Node3D

func _ready() -> void:
	parent = get_parent()
	start_position = parent.global_position
	await get_tree().create_timer(0.5).timeout
	concious = true

func update(delta, target_position : Vector3, movement_component : MovementComponent, agent : NavigationAgent3D) -> void:
	if Engine.get_physics_frames() % update_rate == 0: return
	var parent_pos : Vector3 = parent.global_position
	target_distance = parent_pos.distance_to(target_position)
	target_direction = parent_pos.direction_to(target_position)
	
	attacking = concious and target_distance < attack_distance
	
	if movehelper:
		movehelper.look_at(target_position)
		if target_distance <= min_distance:
			agent.target_position = movehelper.back.global_position
		else:
			agent.target_position = target_position
	else:
		agent.target_position = target_position
	
	agent_position = parent_pos.direction_to(agent.get_next_path_position())
	
	movement_component.direction = agent_position
