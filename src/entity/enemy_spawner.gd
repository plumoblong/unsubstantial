extends Node3D
class_name EnemySpawner

@export var func_godot_properties : Dictionary[String, Variant] = {
	"one_shot"                : 1,
	"counted_enemy"           : 1,
	"distance_to_spawn"       : 25.0,
	"enemy"                   : "enemy;",
	"spawn_delay"             : 0.0,
	"override_spawn_condition": 0,
}

const SPAWN_ANIM        : PackedScene = preload("res://prefab/animation/spawning.tscn")
const ENEMY_CAP         : int         = 12


@onready var light   : Node      = $light
@onready var raycast : RayCast3D = $RayCast3D

var spawned           : bool  = false
var distance_to_spawn : float = 30.0
var is_one_shot       : bool
var is_counted_enemy  : bool
var spawn_delay       : float
var enemy_name        : String

#func _parse_enemy_list() -> Array[String]:
	#var result: Array[String] = []
	#for entry : String in func_godot_properties["enemy"].split(";"):
		#var trimmed : String = entry.strip_edges().trim_suffix(":")
		#if not trimmed.is_empty():
			#result.append(ENEMY_PATH_PREFIX + trimmed + ENEMY_PATH_SUFFIX)
	#return result

func _func_godot_build_complete() -> void:
	distance_to_spawn = (
		randf_range(25.0, 35.0)
		if func_godot_properties["distance_to_spawn"] == 30.0
		else func_godot_properties["distance_to_spawn"]
	)

	light.omni_range  = distance_to_spawn
	is_one_shot       = func_godot_properties["one_shot"]
	is_counted_enemy  = func_godot_properties["counted_enemy"]
	spawn_delay       = func_godot_properties["spawn_delay"]
	

func _physics_process(_delta: float) -> void:
	if func_godot_properties["override_spawn_condition"]:
		return

	var distance_to_player : float  = global_position.distance_to(_G.player.global_position)
	var player_pos         : Vector3 = (
		global_position.direction_to(_G.player.global_position)
		* (distance_to_player - 1.0)
		* Vector3(-1.0, 1.0, -1.0)
	)

	if distance_to_player < distance_to_spawn:
		raycast.target_position = player_pos
		_request_spawn()

func _exit_tree() -> void:
	_G.game.spawner.cancel(self)

func can_spawn() -> bool:
	return (
		not spawned
		and _G.game.enemies.get_child_count() < ENEMY_CAP
		and not raycast.is_colliding()
	)

## Performs the actual spawn. Only called by SpawnCoordinator.
func do_spawn() -> void:
	spawned = true
	
	if spawn_delay > 0.0:
		await get_tree().create_timer(spawn_delay).timeout

	_create_anim()
	
	var enemy_res : PackedScene = _G.game.spawner.get_enemy(func_godot_properties["enemy"])

	#if enemy_res == null:
		#_T.say(
			#"MAP_ERROR: ent_spawn at %s has invalid enemy '%s'.\nCheck ent_spawn description in your map editor!" 
			#% [_G.vector_to_string(position, " ", 0.01), enemy_name],
			#Color.RED
		#)
		#return

	var enemy : Node = enemy_res.instantiate()

	if is_counted_enemy:
		_G.game.enemies.add_child(enemy)
	else:
		_G.game.add_child(enemy)

	if enemy.has_node("ChaseComponent"):
		enemy.get_node("ChaseComponent").start_position = global_position + Vector3(0.0, 0.5, 0.0)

	enemy.global_position = global_position + Vector3(0.0, 0.51, 0.0)

	if is_one_shot:
		await get_tree().create_timer(1.0).timeout
		queue_free()

func _request_spawn() -> void:
	if not can_spawn():
		return
	if _G.game.spawner.request(self):
		do_spawn()

func _create_anim() -> void:
	var anim : Node = SPAWN_ANIM.instantiate()
	_G.game.add_child(anim)
	anim.global_position = global_position + Vector3(0.0, 0.55, 0.0)
