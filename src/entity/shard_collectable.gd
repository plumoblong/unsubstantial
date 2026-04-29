extends Collectable
class_name ShardCollectable

@export var func_godot_properties : Dictionary = {
	"rarity_override" : -1,
	"pool_id"         : -1,
	"price_override"  : 0.0,
	"free"            : true,
}

var current_pool : StatShardPool
var current_rarity : Modulate.RARITY
var current_stat : StatShard
var current_modulate : Modulate

var current_price : int = 0

@onready var shard_sprite : Sprite3D = get_node("Shard")
@onready var stat_sprite : Sprite3D = get_node("Stat")
@onready var anim : AnimationPlayer = get_node("AnimationPlayer")

@onready var price : Node2D = get_node("Price")
@onready var price_label : Label = get_node("Price/Text")
@onready var soul_icon : AnimatedSprite2D = get_node("Price/SoulIcon")

const SHARD_MAT : StandardMaterial3D = preload("res://material/shard_material.tres")
const STAT_MAT : StandardMaterial3D = preload("res://material/stat_material.tres")

@export var shard_color : Color = Color(0.502, 0.502, 0.502, 1.0)
@export var stat_color : Color = Color(0.788, 0.788, 0.788, 1.0)

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
	current_price = func_godot_properties["price_override"] if func_godot_properties["price_override"] != 0.0 else (0.0 if func_godot_properties["free"] else stat[0].get_price(current_rarity))
	
	interaction.interaction_tooltip = "Buy " + current_modulate.get_description() + " for " + str(current_price) + " soul" if current_price > 0.0 else "Get " + current_modulate.get_description()
	
	price.visible = current_price > 0.0
	price_label.text = str(current_price)

func _setup_visuals() -> void:
	var shard_mat : StandardMaterial3D = SHARD_MAT.duplicate()
	var stat_mat : StandardMaterial3D = STAT_MAT.duplicate()
	
	shard_sprite.frame = current_rarity
	
	shard_sprite.material_override = shard_mat
	
	stat_mat.albedo_texture = current_stat.image
	#stat_mat.albedo_color = COLOR_MULT
	stat_sprite.material_override = stat_mat 
	soul_icon.play("default")

func _func_godot_build_complete() -> void:
	_setup_stat()
	_setup_visuals()
	
func _process(_delta: float) -> void:
	shard_sprite.material_override.albedo_color = _G.game.shard_picker.RARITY_COLOR[current_rarity] * shard_color
	stat_sprite.material_override.albedo_color = stat_color
	interaction.description_tooltip = _G.game.shard_picker.get_stat_preview_text(current_modulate)

func hooked() -> void:
	anim.play("in")

func unhooked() -> void:
	anim.play("out")

func interacted() -> void:
	if current_price > 0.0 and not _T.debug_flags[5]:
		if _G.player.money > current_price:
			_G.player.money -= float(current_price)
			_G.player.stats.add_stat(current_modulate, current_stat.image)
			anim.play("disapear")
			interaction.enabled = false
			price.active = false
			_G.player.hud.interact_tooltip = ""
			_G.player.hud.interact_description = ""
		else:
			return
	else:
		_G.player.stats.add_stat(current_modulate, current_stat.image)
		anim.play("disapear")
		interaction.enabled = false
		_G.player.hud.interact_tooltip = ""
		_G.player.hud.interact_description = ""

func _cooldown() -> void:
	interaction.enabled = false
	_G.player.hud.interact_tooltip = ""
	_G.player.hud.interact_description = ""
	await get_tree().create_timer(0.5).timeout
	interaction.enabled = true
