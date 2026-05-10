extends Node3D
class_name CollectableTable

@export var func_godot_properties : Dictionary[String, Variant] = {
	"collectables"      : 2,
	"choices_bonus"     : true,
	"only_one"          : false,
	"free"              : true,
	"distance_to_spawn" : 15.0,
	"spawn_width"       : 1.0,
	"spawn_curvature"   : 0.0,
	"use_physics"     : true,
	"allow_discount"    : false,
	"rarity_override"   : -1,
	"pool_id"           : -1,
	"random_rarities"   : false,
}

var current_pool : StatShardPool
var current_rarity : Modulate.RARITY

const DISTANCE_BETWEEN_COLLECTABLE : float = 2.5
const CURVATURE_DISTANCE_MULT : float = 3.0

@onready var ray : RayCast3D = get_node("Raycast")

var spawned : bool = false

func _spawn() -> void: 
	if ray.is_colliding() and not spawned: return
	var shard_config : Dictionary = { "rarity_override" : -1, 
	"pool_id" : -1, 
	"price_override" : 0.0, 
	"free" : func_godot_properties["pool_id"], 
	"use_physics" : func_godot_properties["use_physics"], 
	"discount" : false, 
	"random_discount" : func_godot_properties["allow_discount"], }
	
	if func_godot_properties["pool_id"] > -1:
		current_pool = _G.game.shard_picker.pools[func_godot_properties["pool_id"]]
	else:
		var chp : int = _G.choose_from_chance(_G.game.shard_picker.pool_weights)
		current_pool = _G.game.shard_picker.pools[chp]
		
	if func_godot_properties["rarity_override"] > -1:
		current_rarity = func_godot_properties["rarity_override"]
	else:
		current_rarity = _G.game.shard_picker.pick_rarity(current_pool, _G.player.stats.luck)
	
	for i in range(func_godot_properties["collectables"]):
		var pos : Vector3 = _get_collectable_position(i)
		var shard : ShardCollectable = _G.game.create_shard_collectable(pos, shard_config)
		
		shard.setup_stat(current_pool.build_pool(), current_rarity)
		shard.setup_visuals(shard.current_stat, current_rarity)
	spawned = true

func _physics_process(_delta: float) -> void:
	if spawned: return
	var distance_to_player : float  = global_position.distance_to(_G.player.global_position)
	var player_pos         : Vector3 = (
		global_position.direction_to(_G.player.global_position)
		* (distance_to_player - 1.0)
		* Vector3(-1.0, 1.0, -1.0)
	)

	if distance_to_player < func_godot_properties["distance_to_spawn"]:
		ray.target_position = player_pos
		_spawn()

func _get_collectable_position(index: int) -> Vector3:
	var count: int = func_godot_properties["collectables"]
	var curvature: float = func_godot_properties["spawn_curvature"]
	var offset: float = (index - (count - 1) * 0.5) * (DISTANCE_BETWEEN_COLLECTABLE * func_godot_properties["spawn_width"])
	
	if curvature <= 0.0:
		return global_position + global_transform.basis.x * offset
	
	# Radius that makes the arc's chord spacing equal DISTANCE_BETWEEN_COLLECTABLE
	var total_spread: float = (count - 1) * (DISTANCE_BETWEEN_COLLECTABLE * CURVATURE_DISTANCE_MULT)
	var radius: float = total_spread / (2.0 * PI * curvature) if curvature > 0.0 else INF
	
	# At curvature=1.0 items are evenly spread around a full circle,
	# at curvature<1.0 they occupy that fraction of the circle arc.
	var total_angle: float = 2.0 * PI * curvature
	var angle_step: float  = total_angle / maxf(count - 1, 1)
	var start_angle: float = -total_angle * 0.5
	var angle: float       = start_angle + index * angle_step
	
	# Blend between straight row (curvature=0) and arc (curvature>0)
	var row_pos: Vector3 = global_transform.basis.x * offset
	var arc_pos: Vector3 = Vector3(sin(angle), 0.0, -(cos(angle) - cos(start_angle))) * radius
	
	return global_position + row_pos.lerp(arc_pos, curvature)
