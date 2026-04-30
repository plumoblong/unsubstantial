extends Component
class_name NavSchedulerComponent

## How many agents get a path query dispatched per physics frame.
@export var agents_per_frame: int = 4

var _queue: Array[Dictionary] = []
var _index: int = 0

func register(agent: NavigationAgent3D, chase: ChaseComponent, movement: MovementComponent) -> void:
	_queue.append({ "agent": agent, "chase": chase, "movement": movement })

func unregister(agent: NavigationAgent3D) -> void:
	_queue = _queue.filter(func(e): return e["agent"] != agent)

func _physics_process(_delta: float) -> void:
	if not enabled or _queue.is_empty() or _G.game.enemies_disabled: return
	var count: int = mini(agents_per_frame, _queue.size())
	for i in count:
		_dispatch(_queue[_index % _queue.size()])
		_index = (_index + 1) % _queue.size()

func _dispatch(entry: Dictionary) -> void:
	var agent    : NavigationAgent3D = entry["agent"]
	var chase    : ChaseComponent    = entry["chase"]
	var movement : MovementComponent = entry["movement"]

	if not is_instance_valid(agent) or not is_instance_valid(chase): return
	if not chase.concious or not chase.enabled: return

	var parent_pos: Vector3 = agent.get_parent().global_position

	var params := NavigationPathQueryParameters3D.new()
	params.map             = NavigationServer3D.get_maps()[0]
	params.start_position      = parent_pos
	params.target_position     = agent.target_position
	params.pathfinding_algorithm = NavigationPathQueryParameters3D.PATHFINDING_ALGORITHM_ASTAR

	var result := NavigationPathQueryResult3D.new()
	NavigationServer3D.query_path(params, result)

	if result.path.size() < 2: return
	movement.direction = parent_pos.direction_to(result.path[1]) if chase.enabled else Vector3.ZERO
