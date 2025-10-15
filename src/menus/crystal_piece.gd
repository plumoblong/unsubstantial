extends Area2D
class_name CrystalPiece

@onready var sprites : Node2D = get_node("Sprites")
@onready var info : Label = get_node("Info")

var stats : Dictionary = {
	"Damage" : 7,
	"Attack Speed" : 9,
	"Move Speed" : 6,
	
	"Knockback" : 4,
	
	"Critical Chance" : 1,
	"Luck" : 3,
	
	"Max Essence" : 8,
	"Healing" : 3,
	"Defense" : 7,
	
	"Bullet Count" : 1,
	"Bullet Range" : 8,
	"Bullet Speed" : 5,
}

var chosen_stat_name : String
var chosen_stat_bonus : float = 0.0
var dont_multiply : bool = false
var is_int : bool = false
var chosen_stat

func on_start() -> void:
	for i : Sprite2D in sprites.get_children():
		i.frame = randi_range(0, 7)
		i.flip_h = bool(randi_range(0, 1))
		i.flip_v = bool(randi_range(0, 1))
		var rscale : float = randf_range(0.3, 0.6)
		i.scale = Vector2(rscale, rscale)
	choose_stat()
	if chosen_stat_bonus > 0.0:
		if dont_multiply:
			info.text = "+" + str(int(chosen_stat_bonus)) + " " + chosen_stat_name
		else:
			info.text = "+" + str(int(chosen_stat_bonus * 100)) + "% " + chosen_stat_name
	else:
		info.text = chosen_stat_name
		
func choose_stat() -> void:
	chosen_stat_name = _G.choose_from_chance(stats)
	match chosen_stat_name:
		"Damage":
			chosen_stat_bonus = randf_range(.05, .20)
			dont_multiply = false
		"Attack Speed":
			chosen_stat_bonus = randf_range(.07, .30)
			dont_multiply = false
		"Max Essence":
			chosen_stat_bonus = randf_range(1.0, 4.0) * 50.0
			dont_multiply = true
		_:
			chosen_stat_bonus = 0.0
