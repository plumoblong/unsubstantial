extends Interaction
class_name UnstableCrystal

@export var func_godot_properties : Dictionary[String, Variant] = {
	"pool_id" : -1
}

const FALLBACK_POOL : int = 0

@onready var anim : AnimationPlayer = $Anim

var pool : StatShardPool

func _func_godot_build_complete() -> void:
	anim.play("idle")
	if func_godot_properties["pool_id"] > -1:
		pool = _G.game.shard_picker.pools[func_godot_properties["pool_id"]]
	else:
		var chosen_pool : int = _G.choose_from_chance(_G.game.shard_picker.pool_weights)
		pool = _G.game.shard_picker.pools[chosen_pool]
	$Crystal.modulate  = pool.pool_crystal_color
	$Light.light_color = pool.pool_crystal_color
	$Crystal.play("new_animation")

func on_interacted() -> void:
	anim.play("shatter")
	_G.game.crystal_choose.start_choose(pool)
