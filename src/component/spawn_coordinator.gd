@icon("res://images/entity/human.png")
extends Component
class_name SpawnCoordinator

## Global cooldown between any two spawns across all spawners.
const SPAWN_COOLDOWN : float = 0.5

var _queue       : Array[EnemySpawner] = []
var _on_cooldown : bool = false

const ENEMY_FALLBACK : PackedScene = preload("res://prefab/debug/sprite_placeholder.tscn")
const ENEMY_PATH_PREFIX : String      = "res://prefab/entity/enemy/"
const ENEMY_PATH_SUFFIX : String      = ".tscn"

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

func get_enemy(list : String = "") -> PackedScene:
	var enemies : Array[String] = _parse_enemy_list(list)
	var enemy : int = randi() % enemies.size()
	var res : PackedScene = load(enemies[enemy])
	if res == null:
		_T.say("Couldnt find enemy: " + enemies[enemy] + " in list: " + list + " " + str(res), Color.RED)
		return ENEMY_FALLBACK
	return res
	
func _parse_enemy_list(list : String) -> Array[String]:
	var result: Array[String] = []
	for entry : String in list.split(";"):
		var trimmed : String = entry.strip_edges().trim_suffix(":")
		if not trimmed.is_empty():
			result.append(ENEMY_PATH_PREFIX + trimmed + ENEMY_PATH_SUFFIX)
	return result
