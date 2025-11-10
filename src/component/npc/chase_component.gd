extends Component
class_name ChaseComponent

var start_position : Vector3
@export var movebackhelper : Node3D
#@export var always_agro : bool = false
@export var agro_distance : float = 20.0
@export var attack_distance : float = 10.0
@export var min_distance : float = 5.0
@export var y_distance : float = 3.0

#@export var jump_if_lower : bool = true
#@export var jump_check_margin : float = 1.0
#@export var distance_to_jump : float = 6.0

var target_distance : float
var target_direction : Vector3
var agent_position : Vector3
var y_difference : float
var concious : bool = false

#var jump : bool = false
var update_rate : int = 1
#var chasing : bool
var attacking : bool

func _ready() -> void:
	start_position = get_parent().global_position
	#update_rate = randi_range(2, 4)
	await get_tree().create_timer(0.5).timeout
	concious = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(target_position : Vector3, movement_component : MovementComponent, agent : NavigationAgent3D) -> void:
	target_distance = get_parent().global_position.distance_to(target_position)
	target_direction = get_parent().global_position.direction_to(target_position)
	movebackhelper.look_at(target_position)
	attacking = concious and target_distance < attack_distance
	#var seperate_check : bool = target_position.y + 1.0 < get_parent().global_position.y
	if not target_position.y + 1.0 < get_parent().global_position.y:
		if target_distance > min_distance:
			agent.target_position = target_position
		else: 
			agent.target_position = movebackhelper.get_child(0).global_position
	else:
		agent.target_position = start_position
	agent_position  = get_parent().global_position.direction_to(agent.get_next_path_position())
	movement_component.direction = agent_position
