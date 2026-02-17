extends Node2D

func _ready() -> void:

	$AnimatedSprite2D.modulate = Color.BLACK
	
	var dir := DirAccess.open("user://")
	dir.make_dir("custom_maps")

	var conffile := FileAccess.open(_G.CONFIG_PATH, FileAccess.READ)
	var savefile := FileAccess.open(_G.SAVE_PATH, FileAccess.READ)
	if not conffile or not savefile:
		_T.say("Conffile or Savefile invalid. Creating...", Color.YELLOW)
	if conffile == null or savefile == null:
		_T.say("Conffile or Savefile returns null.", Color.YELLOW)
	if FileAccess.file_exists(_G.CONFIG_PATH):
		if not conffile.eof_reached():
			_G.config = JSON.parse_string(conffile.get_line())
			_T.say("Config File loaded", Color.GREEN)
			
	if FileAccess.file_exists(_G.SAVE_PATH):
		if not savefile.eof_reached():
			var toset = JSON.parse_string(savefile.get_line())
			if toset != null:
				_G.save = toset
			#print("pre: ", current_line, "post: ", _G.save)
				_T.say("Save File loaded", Color.GREEN)
			#print(typeof(current_line))
	if _G.config.fullscreen:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
	if _G.config.video.v_sync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	set_binds()
	await get_tree().create_timer(0.25).timeout
	start()
	_T.start()

func start() -> void:
	_T.say("[center]unsubstantial Started.[/center]", Color.MAGENTA)
	$AnimatedSprite2D.modulate = Color.WHITE
	$AnimatedSprite2D.play("default")
	$AudioStreamPlayer.play()
	await get_tree().create_timer(3.0).timeout
	_G.tween($AnimatedSprite2D, "modulate", Color.BLACK, 1.25, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	await get_tree().create_timer(2.5).timeout
	_G.change_scene("res://scene/menu.tscn")
	
func set_binds() -> void:
	for i in _G.config.controls.bind:
		InputMap.action_erase_events(i)
		InputMap.action_add_event(i, _G.string_to_input_event(_G.config.controls.bind[i]))
		_T.say("Binds set: " + i + ": " + str(_G.config.controls.bind[i]))
