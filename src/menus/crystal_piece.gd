extends Node2D
class_name CrystalPiece

@export var linked : CrystalPiece

@onready var sprites : Node2D = get_node("Sprites")
@onready var info : Label = get_node("Info")
@onready var anim : AnimationPlayer = get_node("Anim")

@export var first : bool = false
var enabled : bool = false

var stat_rarities : Dictionary = {}

## Weights for all the stat rarities
## 2 - Common, 3 - Rare, 4 - Epic, 5 - Legendary.
var rarities : Dictionary = {
	"2" : 20, "3" : 10, "4" : 4, "5" : 1
}

## Each entry in this array is 
## [ "Stat Name" , dont_multiply (boolean, if true will add stat), Bonus Common, Bonus Rare, Bonus Epic, Bonus Legendary]
const STAT_INFO : Array = [
	["Damage", true, 10, 15, 20, 35, "The amount of suffering you cause to others."], # 0
	["Attack Speed", false, 0.05, 0.10, 0.20, 0.30, "Your concious' cooldown."], # 1
	["Move Speed", true, 0.5, 1.0, 1.5, 2.5, "How fast can you escape?"], # 2
	["Knockback", false, 0.1, 0.2, 0.4, 0.6, "How much can you seperate?"], # 3
	["Critical Chance", true, 2, 5, 7, 15, "A chance to cause double the pain."], # 4
	["Luck", true, 1, 2, 3, 5, "Better luck. Better crystals."], # 5
	["Max Essence", true, 100, 150, 200, 250, "Your maximum health."], # 6
	["Healing", false, 0.1, 0.25, 0.35, 0.75, "How much can you keep?"], # 7
	["Defense", false, 0.1, 0.2, 0.5, 0.6, "You feel her comfort."], # 8
	["Bullet Count", true, 1, 1, 2, 2, "The amount of bullets you shoot"], # 9
	["Bullet Range", false, 0.15, 0.25, 0.5, 1.0, "How far away you can be?"], # 10
	["Bullet Speed", true, 10.0, 20.0, 30.0, 40.0, "They need to die quicker."] # 11
]
var chosen_dict_stat : int
var chosen_stat : Array = []
var chosen_rarity : int = 2

var hovered : bool = false

func get_stats_dictionary() -> Dictionary:
	return {
		"0" : 11, "1" : 12, "2" : 8, "3" : 7, "4" : 3,
		"5" : 6, "6" : 12, "7" : 9, "8" : 8, "9" : 1,
		"10" : 4, "11" : 2,
	}
	
func get_rarities_dictionary() -> Dictionary:
	return {
	"2" : clampi(35 - _G.player.stats.luck, 5, 40), 
	"3" : clampi(20 - _G.player.stats.luck / 2, 10, 25), 
	"4" : clampi(12  +_G.player.stats.luck, 5, 20), 
	"5" : clampi(3 + _G.player.stats.luck, 2, 15)
	}

func on_start() -> void:
	stat_rarities = get_stats_dictionary()
	
	for i in sprites.get_children():
		i.frame = randi_range(0, 6)
		i.anim_offset = randf_range(0.0, 6.0)
		i.frequency = randf_range(0.75, 1.25)
		i.amplitude = randf_range(4.0, 8.0)
		i.flip_h = bool(randi_range(0, 1))
		i.flip_v = bool(randi_range(0, 1))
		var rscale : float = randf_range(0.25, 0.6)
		i.scale = Vector2(rscale, rscale)
	
	choose_stat()
	await get_tree().create_timer(1.0).timeout
	enabled = true
	
func _process(_delta: float) -> void:
	if not visible: return

	if not enabled:
		hovered = false
		$Bound.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
	else:
		$Bound.mouse_filter = Control.MouseFilter.MOUSE_FILTER_PASS
	
	if chosen_stat.is_empty(): return
	
	$Rarity.frame = (chosen_rarity - 2) + (int(_G.config.ui_dark_mode) * 4)
	
	if hovered:
		if Input.is_action_just_pressed("ui_press"):
			if chosen_stat[1]:
				_G.player.stats.add_stat(chosen_stat[0], chosen_stat[chosen_rarity], 1.0)
			else:
				_G.player.stats.add_stat(chosen_stat[0], 0.0, 1.0 + chosen_stat[chosen_rarity])
			_G.current_run.crystals_collected += 1
			print(_G.current_run.items_collected)
			get_parent().end_choose()

	if chosen_stat[chosen_rarity] > 0.0:
		if chosen_stat[1]:
			info.text = "+" + str(chosen_stat[chosen_rarity]) + " " + chosen_stat[0]
		else:
			info.text = "+" + str(int(chosen_stat[chosen_rarity] * 100)) + "% " + chosen_stat[0]
	else:
		info.text = chosen_stat[0]
	$Info/Shadow.text = info.text
	$Info/Shadow2.text = info.text
	
func choose_stat() -> void:
	
	if stat_rarities.is_empty(): 
		_T.say("CrystalPiece stat rarity dictionary is empty, returning")
		return
		
	
	chosen_rarity = int(_G.choose_from_chance(get_rarities_dictionary()))
	
	if first:
		chosen_dict_stat = int(_G.choose_from_chance(stat_rarities))
		linked.stat_rarities[str(chosen_dict_stat)] = 0
	else:
		stat_rarities[str(linked.chosen_dict_stat)] = 0
		chosen_dict_stat = int(_G.choose_from_chance(stat_rarities))
		
	chosen_stat = STAT_INFO[chosen_dict_stat]
	

func mouse_entered() -> void:
	if enabled:
		hovered = true
		get_parent().description_text = chosen_stat[6]
		anim.play("hover_in")

func mouse_exited() -> void:
	hovered = false
	anim.play("hover_out")
