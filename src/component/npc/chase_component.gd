extends Component
class_name ChaseComponent

var start_position : Vector3

@export var movehelper : EntMoveHelper
@export var agro_distance : float = 20.0
@export var attack_distance : float = 10.0
@export var min_attack_distance : float = 1.0
@export var min_distance : float = 5.0
@export var y_distance : float = 3.0
@export var update_rate : int = 4
@export var concious_gain_time : float = 0.5

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
	await get_tree().create_timer(concious_gain_time).timeout
	concious = true

func update(target_position : Vector3, movement_component : MovementComponent, agent : NavigationAgent3D) -> void:
	if Engine.get_physics_frames() % update_rate == 0 or _G.game.enemies_disabled: return
	var parent_pos : Vector3 = parent.global_position
	target_distance = parent_pos.distance_to(target_position)
	target_direction = parent_pos.direction_to(target_position)
	
	attacking = concious and (target_distance <= attack_distance and target_distance > min_attack_distance)
	
	if movehelper:
		movehelper.look_at(target_position)
		if target_distance <= min_distance:
			agent.target_position = movehelper.back.global_position
		else:
			agent.target_position = target_position
	else:
		agent.target_position = target_position
	
	agent_position = parent_pos.direction_to(agent.get_next_path_position())
	
	movement_component.direction = agent_position if enabled else Vector3.ZERO
	
func jump_to(target_position : Vector3, movement_component : MovementComponent, jump_height : float = 4.0) -> void:
	var from : Vector3 = parent.global_position
	var gravity : float = movement_component.fall_speed

	# Time to reach apex, then fall to target
	var height_diff : float = target_position.y - from.y
	var time_up : float = sqrt(2.0 * jump_height / gravity)
	var time_down : float = sqrt(2.0 * max(jump_height - height_diff, 0.001) / (gravity * movement_component.fall_speed_mult))
	var total_time : float = time_up + time_down

	# Horizontal velocity needed to cover XZ distance in that time
	var horizontal_diff : Vector3 = Vector3(target_position.x - from.x, 0.0, target_position.z - from.z)
	var horizontal_vel : Vector3 = horizontal_diff / total_time

	# Vertical velocity to reach apex
	var vertical_vel : float = gravity * time_up

	movement_component.can_jump = true
	movement_component.vel.x = horizontal_vel.x
	movement_component.vel.z = horizontal_vel.z
	movement_component.jump(vertical_vel)
