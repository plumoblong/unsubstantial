extends Interaction
class_name UnstableCrystal

var poolpool : Dictionary[String, int] = {
	"res://res/shardpool/0.tres" : 9,
	"res://res/shardpool/1.tres" : 3
}

@export var func_godot_properties : Dictionary = {
	"pool_id" = -1
}

const FALLBACK_POOL = preload("res://res/shardpool/0.tres")

@onready var anim : AnimationPlayer = get_node("Anim")
var pool : StatShardPool

func _func_godot_build_complete() -> void:
	anim.play("idle")
	var chosen_pool = _G.choose_from_chance(poolpool)
	var loaded_pool = load("res://res/shardpool/" + str(func_godot_properties["pool_id"]) + ".tres") \
	if func_godot_properties["pool_id"] != -1 else load(chosen_pool)
	pool = FALLBACK_POOL if loaded_pool == null else loaded_pool
	$Crystal.modulate = pool.pool_crystal_color
	$Light.light_color = pool.pool_crystal_color
	$Crystal.play("new_animation")
	
func on_interacted() -> void:
	anim.play("shatter")
	_G.game.crystal_choose.start_choose(pool)
	return
