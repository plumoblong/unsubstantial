@tool

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
var spawned : bool = false
var random_factor : float = 0.0

func _ready() -> void:
	random_factor = randf_range(0.00, 1.00)

func spawn() -> void:
	if spawned: return
	#if _G.debug_mode: return
	await get_tree().create_timer(func_godot_properties["spawn_delay"]).timeout
	create_anim()
	var enemy_res : PackedScene = load("res://prefab/entity/enemy/" + func_godot_properties["enemy"] + ".tscn")
	if enemy_res == null:
		_T.say("MAP_ERROR: ent_spawn at position " +  _G.vector_to_string(position, " ", 0.01) + " has an invalid enemy parameter. \n(" + func_godot_properties["enemy"] + " not found in entity/enemy asset directory)\nCheck ent_spawn description in your map editor for valid enemies!", Color.RED)
		spawned = true
		return
	var enemy : Node = enemy_res.instantiate()
	if func_godot_properties["counted_enemy"]: 
		_G.game.enemies.add_child(enemy)
	else:
		_G.game.add_child(enemy)
	if enemy.has_node("ChaseComponent"):
		enemy.get_node("ChaseComponent").start_position = global_position + Vector3(0.0, 0.5, 0.0)
	enemy.global_position = global_position + Vector3(0.0, 0.51, 0.0)
	if func_godot_properties["one_shot"]:
		queue_free()
	else: spawned = true

func _process(_delta : float) -> void:
	if Engine.is_editor_hint(): return
	$Sprite3D.visible = _G.debug_mode
	if func_godot_properties["distance_to_spawn"] >= 0:
		var distance_to_player : float = global_position.distance_to(_G.player.global_position)
		if distance_to_player < func_godot_properties["distance_to_spawn"]:
			spawn()
	if _G.game.ending_level:
		queue_free()

func create_anim() -> void:
	var anim : Node = SPAWN_ANIM.instantiate()
	_G.game.add_child(anim)
	anim.global_position = global_position + Vector3(0.0, 0.55, 0.0)
