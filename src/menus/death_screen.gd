extends Node2D

var can_reset : bool = false

func _ready() -> void:
	#_G.save.can_continue = false
	if _G.config.ui_dark_mode:
		_G.shader_inverted = true
	else:
		_G.shader_inverted = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Reason.text = _G.current_run.die_reason
	$Stats.text = "Enemies Killed:   " + str(_G.current_run.kills) + "\nTook Damage:   " + str(_G.current_run.hits_taken) + " times\nItems Collected:   " + str(_G.current_run.items_collected.common + _G.current_run.items_collected.uncommon + _G.current_run.items_collected.rare + _G.current_run.items_collected.legendary)
	$Score.text = "Score: " + str(_G.current_run.score)
	$Score2.text = "High Score: " + str(int(_G.save.high_score))
	await get_tree().create_timer(2.0).timeout
	$Restart.show()
	$Menu.show()
	can_reset = true

func play_again() -> void:
	if not can_reset: return
	
	_G.change_scene("res://scene/game.tscn")

func _process(_delta : float) -> void:
	if Input.is_action_just_pressed("jump"):
		play_again()

func button_pressed() -> void:
	play_again()

func menu_pressed() -> void:
	_G.change_scene("res://scene/menu.tscn")
