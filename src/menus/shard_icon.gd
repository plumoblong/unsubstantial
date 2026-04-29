extends Node2D
class_name ShardIcon

@onready var bg_sprite : Sprite2D = $Background
@onready var stat_sprite : Sprite2D = $Stat
@onready var anim : AnimationPlayer = $Animation
@onready var inventory_node : InventoryUI = get_parent().get_parent()

var mod : Modulate
var description : String = "? ? ?"

func initialize(m : Modulate, texture : Texture) -> void:
	mod = m
	bg_sprite.modulate = _G.game.shard_picker.RARITY_COLOR[mod.rarity]
	bg_sprite.frame = mod.rarity
	stat_sprite.texture = texture
	description = "[b]" + mod.get_description() + "[/b]\n"\
	+ _G.game.shard_picker.get_stat_snapshot_text(mod)

func bound_mouse_entered() -> void:
	inventory_node.current_description = description
	inventory_node.rarity.frame = mod.rarity + 10
	inventory_node.rarity.show()
	anim.speed_scale = 6.0 / Engine.time_scale
	anim.play("in")

func bound_mouse_exited() -> void:
	anim.play("out")
