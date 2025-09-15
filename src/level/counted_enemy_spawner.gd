extends Node3D

@export var distance_to_spawn : float = 30.0
@export var enemies : Dictionary[PackedScene, int] = {}
@export var max_amount : int = 1
@export var min_amount : int = 1
@export var radius : float = 0.5
@export var radius_y : float = 0.0
@export var delay : float = 0.35 
@export_category("conditionals")
@export var chance_to_spawn : int = 35
@export var chance_each_level : int = 0
@export var chance_each_stage : int = 0
@export var chance_each_actual_stage : int = 10
@export var min_stage : int = 0
@export var min_actual_stage : int = 0
@export var after_key : bool = false
@export var before_key : bool = false

const SPAWNER_FILE : PackedScene = preload("res://prefab/entity/level/enemy_spawner.tscn")

func _ready() -> void:
	_G.game.dungeon_generator.connect("done_generating", add)

func add() -> void:
	$Sprite2D.hide()
	var amt : int = randi_range(min_amount, max_amount)
	var c : float = randf_range(0.0, 100.0)
	var chance_coefficient : float = (chance_each_level * (_G.player.level_component.level - 1)) + chance_each_stage * (_G.game.stage - min_stage) + chance_each_actual_stage * (_G.game.actual_stage - min_actual_stage)
	var chance : float = clampf(chance_to_spawn + chance_coefficient, 0.0, 100.0)
	if chance > c:
		
		
		var enemy : PackedScene = _G.choose_from_chance(enemies)
		var rand_pos : Vector3
		for i in range(amt):
			var s : EnemySpawner = SPAWNER_FILE.instantiate()
			
			rand_pos = Vector3(randf_range(-radius, radius),0.0, randf_range(-radius, radius)).normalized() + Vector3(0.0, randf_range(-radius_y, radius_y), 0.0).normalized()
			s.global_position = global_position + rand_pos
			s.distance_to_spawn = distance_to_spawn
			s.after_key = after_key
			s.before_key = before_key
			s.min_actual_stage = min_actual_stage
			s.min_stage = min_stage
			s.enemies.clear()
			s.enemies.assign({enemy : 1})
			s.spawn_delay = delay * i
			_G.game.enemies.add_child(s)
		queue_free()
