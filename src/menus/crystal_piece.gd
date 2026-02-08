extends Node2D
class_name CrystalPiece

@onready var sprite : Sprite2D = get_node("Sprite")
@onready var stat_icon : Sprite2D = get_node("Icon")
@onready var info : Label = get_node("Info")
@onready var anim : AnimationPlayer = get_node("Anim")

@export var first : bool = false
var enabled : bool = false

var chosen_stat : StatShard
var chosen_modulate : Modulate

var hovered : bool = false

func on_start(pool : Dictionary[StatShard, int]) -> void:
	if pool.is_empty(): 
		_T.say("StatShardPool final_pool dictionary is empty, returning")
		return
	chosen_stat = _G.choose_from_chance(pool)
	if chosen_stat.image != null:
		stat_icon.texture = chosen_stat.image
	chosen_modulate = _G.choose_from_chance(chosen_stat.get_modulates(_G.player.stats.luck))
	
	enabled = true
	
func _process(_delta: float) -> void:
	
	if not enabled:
		hovered = false
		$Bound.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
	else:
		$Bound.mouse_filter = Control.MouseFilter.MOUSE_FILTER_PASS

	if chosen_stat == null: return
	
	$Rarity.frame = chosen_modulate.rarity + (int(_G.config.ui_dark_mode) * 4)
	info.text = chosen_modulate.get_description(chosen_stat.stat_name)
	stat_icon.use_parent_material = _G.config.ui_dark_mode
	if hovered:
		if Input.is_action_just_pressed("ui_press"):
			_G.player.stats.add_stat(chosen_modulate)
			_G.current_run.crystals_collected += 1
			print(_G.current_run.items_collected)
			_G.game.crystal_choose.end_choose()
	
	$Info/Shadow.text = info.text
	$Info/Shadow2.text = info.text

func mouse_entered() -> void:
	if enabled:
		hovered = true
		#get_parent().description_text = chosen_modulate.get_description()
		anim.play("hover_in")

func mouse_exited() -> void:
	hovered = false
	anim.play("hover_out")
