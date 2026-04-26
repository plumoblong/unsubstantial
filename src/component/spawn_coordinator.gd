@icon("res://images/entity/human.png")
extends Component
class_name SpawnCoordinator

## Global cooldown between any two spawns across all spawners.
const SPAWN_COOLDOWN : float = 0.5

var _queue       : Array[EnemySpawner] = []
var _on_cooldown : bool = false


## Called by a spawner when it wants to spawn.
## Returns true if the spawner should proceed immediately, false if queued.
func request(spawner: EnemySpawner) -> bool:
	if _on_cooldown:
		if spawner not in _queue:
			_queue.append(spawner)
		return false

	_start_cooldown()
	return true


## Called by a spawner when it is freed, so it can be removed from the queue.
func cancel(spawner: EnemySpawner) -> void:
	_queue.erase(spawner)


# ── private ──────────────────────────────────────────────────────────────────

func _start_cooldown() -> void:
	_on_cooldown = true
	get_tree().create_timer(SPAWN_COOLDOWN).timeout.connect(_on_cooldown_expired)


func _on_cooldown_expired() -> void:
	_on_cooldown = false
	_flush_queue()


func _flush_queue() -> void:
	while not _queue.is_empty():
		var next : EnemySpawner = _queue.pop_front()

		if not is_instance_valid(next) or next.spawned:
			continue

		if next.can_spawn():
			_start_cooldown()
			next.do_spawn()
			return
