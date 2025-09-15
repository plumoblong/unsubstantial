extends Node2D

func _ready() -> void:
	$Stats.text = "[center]	KILLS:  " + str(_G.current_run.kills) + "\n\n" + "HITS TAKEN:  " + str(_G.current_run.hits_taken) + "\n\n" + "ITEMS COLLECTED:  " + str(_G.current_run.items_collected.common + _G.current_run.items_collected.uncommon + _G.current_run.items_collected.rare + _G.current_run.items_collected.legendary)
	$Score.text = "SCORE: " + str(_G.current_run.score)
	$Score2.text = "HIGH SCORE: " + str(_G.save.high_score)
	await get_tree().create_timer(1.0).timeout

func menu_pressed():
	_G.change_scene("res://scene/menu.tscn")
