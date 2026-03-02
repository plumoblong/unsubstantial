extends Node3D
class_name EnemySpawner

@export var func_godot_properties : Dictionary = {
	"one_shot" = 1,
	"counted_enemy" = 1,
	"distance_to_spawn" = 25.0,
	"enemy" = "enemy",
	"spawn_delay" = 0.0,
}

const SPAWN_ANIM : PackedScene = preload("res://prefab/animation/spawning.tscn")
const ENEMY_CAP : int = 6
const ENEMY_PATH_PREFIX : String = "res://prefab/entity/enemy/"
const ENEMY_PATH_SUFFIX : String = ".tscn"

@onready var light : Node = $light
@onready var raycast : RayCast3D = $RayCast3D

var spawned : bool = false
var distance_to_spawn : float = 30.0
var enemy_res : PackedScene
var is_one_shot : bool
var is_counted_enemy : bool
var spawn_delay : float
var enemy_name : String

func _func_godot_build_complete() -> void:
	if func_godot_properties["distance_to_spawn"] == 30.0:
		distance_to_spawn = randf_range(25.0, 35.0)
	else:
		distance_to_spawn = func_godot_properties["distance_to_spawn"]
	
	light.omni_range = distance_to_spawn
	
	# Cache properties
	is_one_shot = func_godot_properties["one_shot"]
	is_counted_enemy = func_godot_properties["counted_enemy"]
	spawn_delay = func_godot_properties["spawn_delay"]
	enemy_name = func_godot_properties["enemy"]
	
	# Preload enemy resource
	enemy_res = load(ENEMY_PATH_PREFIX + enemy_name + ENEMY_PATH_SUFFIX)

func spawn() -> void:
	if _G.game.enemies_disabled or spawned: return
	if _G.game.enemies.get_child_count() >= ENEMY_CAP: return
	if raycast.is_colliding(): return
	
	if spawn_delay > 0.0:
		await get_tree().create_timer(spawn_delay).timeout
	
	create_anim()
	
	if enemy_res == null:
		_T.say("MAP_ERROR: ent_spawn at position " + _G.vector_to_string(position, " ", 0.01) + 
			" has an invalid enemy parameter. \n(" + enemy_name + 
			" not found in entity/enemy asset directory)\nCheck ent_spawn description in your map editor for valid enemies!", Color.RED)
		spawned = true
		return
	
	var enemy : Node = enemy_res.instantiate()
	
	if is_counted_enemy:
		_G.game.enemies.add_child(enemy)
	else:
		_G.game.add_child(enemy)
	
	if enemy.has_node("ChaseComponent"):
		enemy.get_node("ChaseComponent").start_position = global_position + Vector3(0.0, 0.5, 0.0)
	
	enemy.global_position = global_position + Vector3(0.0, 0.51, 0.0)
	
	if is_one_shot:
		queue_free()
	else:
		spawned = true

func _physics_process(_delta : float) -> void:
	var distance_to_player : float = global_position.distance_to(_G.player.global_position)
	
	if distance_to_player < distance_to_spawn:
		raycast.target_position = global_position.direction_to(_G.player.global_position) * (distance_to_player - 1.0) * Vector3(-1.0, 1.0, -1.0)
		spawn()

func create_anim() -> void:
	var anim : Node = SPAWN_ANIM.instantiate()
	_G.game.add_child(anim)
	anim.global_position = global_position + Vector3(0.0, 0.55, 0.0)
