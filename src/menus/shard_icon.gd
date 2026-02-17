extends Node2D
class_name ShardIcon

const COLOR_ARRAY : Array[Color] = [
	Color(0.8, 0.733, 0.0, 1.0),
	Color(0.16, 0.715, 0.8, 1.0),
	Color(0.693, 0.4, 0.8, 1.0),
	Color(0.8, 0.0, 0.347, 1.0)
]

@onready var bg_sprite : Sprite2D = $Background
@onready var stat_sprite : Sprite2D = $Stat
@onready var anim : AnimationPlayer = $Animation
@onready var inventory_node : InventoryUI = get_parent().get_parent()

var mod : Modulate
var description : String = "? ? ?"

func initialize(m : Modulate, texture : Texture) -> void:
	mod = m
	bg_sprite.modulate = COLOR_ARRAY[mod.rarity]
	bg_sprite.frame = mod.rarity
	stat_sprite.texture = texture
	description = "[b]" + mod.get_description() + "[/b]\n"\
	+ str(snappedf(m.pre_append_value, 0.01)) + " -> " + str(snappedf(m.post_append_value, 0.01))

func bound_mouse_entered() -> void:
	inventory_node.current_description = description
	inventory_node.rarity.frame = mod.rarity + 8
	inventory_node.rarity.show()
	anim.speed_scale = 6.0 / Engine.time_scale
	anim.play("in")

func bound_mouse_exited() -> void:
	anim.play("out")
