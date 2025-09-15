extends Node2D

func _process(_delta : float) -> void:
	_G.in_close_menu = true
	if Input.is_action_just_pressed("jump"):
		_G.flare_screen(Color(0, 0, 0, 0), Color.BLACK, 1.0)
		await get_tree().create_timer(1.1).timeout
		get_tree().quit()
