extends Node2D

var screen : int = 0

func _process(_delta : float) -> void:
	if Input.is_action_just_pressed("escape"):
		if $Options.screen == 0:
			screen = 0
	#hide()
	$Main.visible = screen == 0
	$Options.visible = screen == 1
	$Statistics.visible = screen == 2
	$RestartConfirm.visible = screen == 3
	$Main/ChapterInfo.text = "[b][i]- " + _G.game.chapter.current.chapter_name + " -[/i][/b]\n" + _G.game.chapter.current.description + "\n\n" + "[i]CHAPTER " + str(_G.game.chapter.current.id) + " STAGE " + str(_G.game.stage) + "\n\nACTUAL STAGE " + str(_G.game.actual_stage)
	$Main/Restart.disabled = _G.game.in_ether
	
	if screen == 2:
		
		var items : Array[Node] = _G.get_all_children($Statistics/Items)
		for i in items.size():
			items[i].visible = _G.player.items.collected.size() > i
			if _G.player.items.collected.size() > i:
				items[i].item = _G.player.items.collected[i][0]


func continue_pressed() -> void:
	get_parent().hide()

func restart_pressed() -> void:
	screen = 3

func options_pressed() -> void:
	screen = 1
	
func exit_pressed() -> void:
	_G.change_scene("res://scene/menu.tscn")

func statistics_pressed() -> void:
	screen = 2

func rest_yes_pressed() -> void:
	_G.change_scene("res://scene/game.tscn")

func rest_no_pressed() -> void:
	screen = 0
