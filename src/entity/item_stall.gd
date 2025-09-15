@tool
extends Node3D
class_name ItemStall

@export var func_godot_properties : Dictionary = {
	"item" = "random",
	"blind_chance" = 15.0,
	"blind_type" = 0
}

var item : Item = null
var blind : bool = false

var random_pool : ItemPoolManager.Pool
var item_name : String = "Unknown"
var item_desc : String = "Unknown"
var collected : bool = false

@export var item_override : Item # pusta zmienna -  bierze z item poolki
@export var free : bool = true
@export var blind_chance : float = 15.0
@export var blind_type : bool = false
@export var link_to_stall : NodePath
@export var link_to_gate : NodePath

@onready var sprite : Sprite3D = get_node("Item")

var linked_stall : ItemStall
var linked_gate : Gate
var reroll : bool = false

func get_item_from_tb() -> void:

	if func_godot_properties["blind_chance"] != null:
		blind_chance = bool(func_godot_properties["blind_chance"])
	if func_godot_properties["blind_type"] != null:
		blind_type = func_godot_properties["blind_chance"]
	if func_godot_properties["item"] == "random" or func_godot_properties["item"] == "":
		return
	else:
		var item_res = load("res://res/item/" + func_godot_properties["item"] + ".tres")
		if item_res != null:
			item = item_res
func _ready() -> void:
	if Engine.is_editor_hint(): return
	get_item_from_tb()
	if link_to_stall != NodePath(""):
		linked_stall = get_node(link_to_stall)	
	if link_to_gate != NodePath(""):
		linked_gate = get_node(link_to_gate)
	if item_override == null:
		item = _G.game.item_pool.pick_an_item(random_pool)
	else:
		item = item_override
	var c : float = randf_range(0.0, 100.0)
	if c <= blind_chance:
		blind = true
	else:
		blind = false
	if not blind_type:
		$Blind.frame = item.type
	else:
		$Blind.frame = 0
	$Blind.visible = blind
	$Item.visible = not blind
	#$Ambient.play()

func _process(_delta : float) -> void:
	#if reroll: use_reroll()
	if Engine.is_editor_hint(): return
	if item.type > 0:
		$GPUParticles3D.amount = item.type
	else:
		$GPUParticles3D.hide()
	#$OmniLight3D.omni_range = float(item.type) + 1.0
	if not blind_type:
		match item.type:
			Item.TYPE.UNCOMMON:
				$OmniLight3D.light_color = Color.CYAN
			Item.TYPE.RARE:
				$OmniLight3D.light_color = Color.MAGENTA
			Item.TYPE.LEGENDARY:
				$OmniLight3D.light_color = Color.GOLD
			Item.TYPE.BOSS:
				$OmniLight3D.light_color = Color.RED
			_:
				$OmniLight3D.light_color = Color.WHITE
	else:
		$OmniLight3D.light_color = Color.WHITE

	sprite.texture = item.image
	$ID.text = str(item.item_name)
	$ID.visible = _G.debug_mode
	
	if linked_stall != null:
		if linked_stall is ItemStall:
			if linked_stall.collected:
				destroy()
				linked_stall.destroy()
	
	if linked_gate != null:
		if linked_gate is Gate:
			if collected:
				if linked_gate.done == false: 
					linked_gate.done = true
			
	$Interaction.enabled = not collected

	if $Interaction.can_interact:
		if not blind:
			if free:
				_G.player.interact_tooltip = "Get [wave]" + item.item_name.to_upper()
			else:
				_G.player.interact_tooltip = "Get [wave]" + item.item_name.to_upper()+ "[/wave] for " + str(item.shop_cost) + "esc"
			_G.player.interact_description = item.item_description
		else:
			if free:
				_G.player.interact_tooltip = "Get [wave]???" 
			else:
				_G.player.interact_tooltip = "Get [wave]???[/wave] for " + str(item.shop_cost) + "esc"
			_G.player.interact_description = "???"

	
func interaction_interacted() -> void:
	destroy()
	_G.player.items.append(item)
	if not free: _G.player.essence_component.fracture(item.shop_cost)

func destroy() -> void:
	if collected: return
	collected = true
	$AnimationPlayer.play("take")
	$SFX.play()
