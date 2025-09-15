extends Node2D
class_name ItemButton
# Called every frame. 'delta' is the elapsed time since the previous frame.

var item : Item = null
@export var time_offset : float = 0.0
var init_pos : float
var is_hovered : bool = false

signal item_chosen

var shattered : bool = false
var elemental : float = 0.0

var elemental_alpha : float = 0.0
var crystal_alpha : float = 1.0

func _ready() -> void:
	$Query.position = position + Vector2(-34.0, -49.0)
	init_pos = position.y
	modulate = Color.GRAY
	$Item.modulate = Color(1,1,1,0)
	await get_tree().create_timer(0.15).timeout


func shatter() -> void:
	elemental = randi_range(0, 15)
	
	if elemental == 8:
		shattered = true
	else:
		shattered = false
		_G.game.item_pool.pick_an_item()

func _process(_delta : float) -> void:
	visible = not shattered
	$Query.modulate = Color(1, 1, 1, float(_G.debug_mode) * 0.5)
	$Item/Elemental.frame = elemental
	$Item/Elemental.material.set_shader_parameter("modulate", Color(1, 1, 1, elemental_alpha * 0.7 + _G.sine_movement(1.5, 0.4, time_offset)))
	$Crystal.modulate.a = 0.9 + _G.sine_movement(1.0, 0.1, time_offset + 1.0)
	#$Elemental.modulate.a = _G.sine_movement(0.5, 1.0, time_offset)
	if item != null:
		#mouse_filter = 0
		$Item/ItemImage.texture = item.image
		$Item/Itemname.text = item.item_name
		$Item/ItemDesc.text = item.item_description
		match item.quality:
			0:
				$Item/Itemname/Sprite2D.modulate = Color.WHITE
				$Item/ItemImage/Sprite2D.modulate = Color.WHITE
			1:
				$Item/Itemname/Sprite2D.modulate = Color.GREEN
				$Item/ItemImage/Sprite2D.modulate = Color.GREEN
			2:
				$Item/Itemname/Sprite2D.modulate = Color.PURPLE
				$Item/ItemImage/Sprite2D.modulate = Color.PURPLE
			3:
				$Item/Itemname/Sprite2D.modulate = Color.GOLD
				$Item/ItemImage/Sprite2D.modulate = Color.GOLD
func mouse_entered() -> void:
	if get_parent().in_transition: return
	hovered()
func mouse_exited() -> void:
	if get_parent().in_transition: return
	unhovered()
func pressed() -> void:
	_G.player.items.append(item)
	item_chosen.emit()
	if item.item_script != null:
		var scr : RefCounted = load(item.item_script.resource_path).new()
		if scr.has_method("pickup"):
			scr.pickup()
		else:
			print(item.id, " ", item.item_name, " no pickup()")
	#
func hovered() -> void:
	if not is_hovered:
		is_hovered = true
		_G.tween(self, "modulate", Color.WHITE, 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)
		_G.tween($Item, "modulate", Color.WHITE, 0.15, Tween.TRANS_SINE, Tween.EASE_OUT)
		_G.tween(self, "elemental_alpha", 1.0, 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)
		_G.tween(self, "position", Vector2(position.x, init_pos - 16), 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)

func unhovered() -> void:
	if is_hovered:
		is_hovered = false
		_G.tween($Item, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
		_G.tween(self, "modulate", Color.GRAY, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
		_G.tween(self, "elemental_alpha", 0.0, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
		_G.tween(self, "position", Vector2(position.x, init_pos), 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)

#func get_item() -> void:
	#var i : int
	#i = randi_range(0, _G.game.item_pool.size() - 1)
	#if _G.game.item_pool[i] == false:
		#i = randi_range(0, _G.game.item_pool.size() - 1)
		#if _G.game.item_pool[i] == false:
			#i = randi_range(0, _G.game.item_pool.size() - 1)
			#if shattered != true:
				#shattered = true
				#print(name, " shattered ", i)
				#return
		#
	#print(name, " infused ", i)
	#print(i)
	#item = load("res://res/item/" + str(i) + ".tres")
	#if item.remove_from_pool:
		#_G.game.item_pool[i] = false
