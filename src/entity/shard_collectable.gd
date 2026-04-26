extends Collectable
class_name ShardCollectable

@export var func_godot_properties : Dictionary = {
	"rarity_override" : -1,
	"pool_id" : -1,
	"price_override": -1,
	"free" : 1,
}

var current_pool : StatShardPool
var current_rarity : Modulate.RARITY
var current_stat : StatShard
var current_modulate : Modulate

var current_price : int = 0

@onready var shard_sprite : Sprite3D = get_node("Shard")
@onready var stat_sprite : Sprite3D = get_node("Shard")

const SHARD_MAT : StandardMaterial3D = preload("res://material/shard_material.tres")
const STAT_MAT : StandardMaterial3D = preload("res://material/stat_material.tres")
const COLOR_MULT : Color = Color(0.59, 0.59, 0.59, 1.0)

func _setup_stat() -> void:
	# pool setup
	if func_godot_properties["pool_id"] > -1:
		current_pool = _G.game.shard_picker.pools[func_godot_properties["pool_id"]]
	else:
		var chp : int = _G.choose_from_chance(_G.game.shard_picker.pool_weights)
		current_pool = _G.game.shard_picker.pools[chp]
	
	# rarity setup
	if func_godot_properties["rarity_override"] > -1:
		current_rarity = func_godot_properties["rarity_override"]
	else:
		current_rarity = _G.game.shard_picker.pick_rarity(current_pool, _G.player.stats.luck)
	
	var pool_dict : Dictionary[StatShard, int] = current_pool.build_pool()
	var stat : Array = _G.game.shard_picker.pick(pool_dict, current_rarity)
	
	current_stat = stat[0]
	current_modulate = stat[1]
	
	interaction.interaction_tooltip = current_modulate.get_description()
	interaction.description_tooltip = _G.game.shard_picker.get_stat_change_text(current_modulate, true)

func _setup_visuals() -> void:
	var shard_mat : StandardMaterial3D = SHARD_MAT.duplicate()
	var stat_mat : StandardMaterial3D = STAT_MAT.duplicate()
	
	shard_sprite.frame = current_rarity
	shard_mat.albedo_color = _G.game.shard_picker.RARITY_COLOR[current_rarity] * COLOR_MULT
	shard_sprite.material_override = shard_mat
	
	stat_mat.albedo_texture = current_stat.image
	stat_sprite.material_override = stat_mat

func _func_godot_build_complete() -> void:
	_setup_stat()
	_setup_visuals()
