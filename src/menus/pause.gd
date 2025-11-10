extends Node2D

var screen : int = 0

func _process(_delta : float) -> void:
	if not visible: return
	if Input.is_action_just_pressed("escape"):
		if $Options.screen == 0:
			screen = 0
	
	$Main.visible = screen == 0
	$Options.visible = screen == 1
	$Statistics.visible = screen == 2
	$RestartConfirm.visible = screen == 3
	
	if _G.game.in_ether:
		$Main/ChapterInfo.text = "[b][i]- " + _G.game.chapter.current.chapter_name + " -[/i][/b]\n" + _G.game.chapter.current.description + "\n\n" + "[i]ANOTHER BEGINNING"
	else:
		$Main/ChapterInfo.text = "[b][i]- " + _G.game.chapter.current.chapter_name + " -[/i][/b]\n" + _G.game.chapter.current.description + "\n\n" + "[i]CHAPTER " + str(_G.game.chapter.current.id) + " STAGE " + str(_G.game.stage)
	$Main/Restart.disabled = _G.game.in_ether
	
	if screen == 2:
		$Statistics/Stats.text = "Crystals Shards Collected: " + str(_G.player.stats.added_stats.size()) + \
		"\n\nDamage: " + str(_G.player.stats.actual_damage) + \
		" ESC\nAttack Speed: " + str(int(_G.player.stats.actual_atkspd * 100.0)) + \
		"%\nMove Speed: " + str(snappedf(_G.player.stats.speed, 0.1)) + \
		"m/s\n\nMax Essence: " + str(_G.player.stats.esc_max) + \
		" ESC\nEssence Healing: " + str(int(10.0 * _G.player.essence_component.heal_multiplier)) + \
		" ESC\nDefense: " + str(snappedf(_G.player.stats.defense, 0.1)) + \
		"\n\nKnockback: " + str(int(_G.player.stats.knockback * 100.0)) + \
		"%\nCritical Chance: " + str(int(_G.player.stats.crit_chance)) + \
		"%\nLuck: " + str(_G.player.stats.luck)
		

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
