extends Interaction
class_name UnstableCrystal

## Maps shard pool resource paths to their selection weights.
## Swap this out or data-drive it per crystal instance as needed.
@export var pool_weights : Dictionary[String, int] = {
	"res://res/shardpool/0.tres" : 5,
	"res://res/shardpool/1.tres" : 1,
}

## When set to a valid pool id (>= 0), always loads that pool and ignores pool_weights.
@export_category("FuncGodot")
@export var func_godot_properties : Dictionary = {
	"pool_id" : -1
}

const FALLBACK_POOL := preload("res://res/shardpool/0.tres")

@onready var anim : AnimationPlayer = $Anim

var pool : StatShardPool

func _func_godot_build_complete() -> void:
	anim.play("idle")
	pool = _resolve_pool()
	$Crystal.modulate  = pool.pool_crystal_color
	$Light.light_color = pool.pool_crystal_color
	$Crystal.play("new_animation")

func on_interacted() -> void:
	anim.play("shatter")
	_G.game.crystal_choose.start_choose(pool)

# ── private ──────────────────────────────────────────────────────────────────

func _resolve_pool() -> StatShardPool:
	var forced_id : int = func_godot_properties.get("pool_id", -1)
	if forced_id >= 0:
		return _load_pool("res://res/shardpool/%d.tres" % forced_id)
	var chosen_path : String = _G.choose_from_chance(pool_weights)
	return _load_pool(chosen_path)

func _load_pool(path: String) -> StatShardPool:
	var loaded = load(path)
	if loaded is StatShardPool:
		return loaded
	push_warning("UnstableCrystal: could not load pool at '%s', using fallback." % path)
	return FALLBACK_POOL
