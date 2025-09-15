extends Component
class_name ChaseComponent

var start_position : Vector3

#@export var always_agro : bool = false
@export var agro_distance : float = 20.0
@export var attack_distance : float = 10.0
@export var min_distance : float = 5.0
@export var y_distance : float = 3.0

var target_distance : float
var target_direction : Vector3
var agent_position : Vector3
var y_difference : float
var concious : bool = false


var update_rate : int = 1
var chasing : bool
var attacking : bool

func _ready() -> void:
	start_position = get_parent().global_position
	#update_rate = randi_range(2, 4)
	await get_tree().create_timer(0.5).timeout
	concious = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(target_position : Vector3, movement_component : MovementComponent, agent : NavigationAgent3D) -> void:
	if not enabled: return
	if Engine.get_physics_frames() % update_rate == 0:
		
		target_distance = get_parent().global_position.distance_to(target_position)
		target_direction = get_parent().global_position.direction_to(target_position)
		
		attacking = concious and target_distance < attack_distance
		#get_parent().rotation.y = lerp_angle(get_parent().rotation.y)
		
		if target_distance < agro_distance:
			chasing = true
		
		if chasing:
			if target_distance >= min_distance:
				agent.target_position = target_position
		agent_position  = get_parent().global_position.direction_to(agent.get_next_path_position())
		movement_component.direction = agent_position
		
		
		
		#if Engine.get_physics_frames() % 60 == 0:
			#print(get_parent().name, " time: ", get_parent().time_spawned, " agent position: ", agent.get_next_path_position(), " target position: ", target_position)
