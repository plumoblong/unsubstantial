extends Node2D

var can_reset : bool = false

const MUSIC : AudioStream = preload("res://music/game_over.ogg")

func _ready() -> void:
	#_G.save.can_continue = false
	_S.change_pitch(1.0, 0.75)
	_S.fade_song(1.0, 0.5)
	_S.change_song(MUSIC)
	_G.change_discord_rpc(false, "Game Over", str(_G.current_run.score) + " Score", "", "")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Node2D/Reason.text = _G.current_run.die_reason
	$Node2D/Stats.text = "Enemies killed:   " + str(_G.current_run.kills) + "\nTook damage:   " + str(_G.current_run.hits_taken) + " times\nShards collected:   " + str(_G.current_run.crystals_collected)
	$Node2D/Score.text = "Score: " + str(_G.current_run.score)
	$Node2D/Score2.text = "High Score: " + str(int(_G.save.high_score))
	await get_tree().create_timer(1.0).timeout
	$Node2D/Restart.show()
	$Node2D/Menu.show()
	can_reset = true

func play_again() -> void:
	if not can_reset: return
	_S.fade_song(0.0, 0.5)
	_G.change_scene("res://scene/game.tscn")
	_S.change_pitch(0.0, 0.5)

func _process(_delta : float) -> void:
	$Node2D.position = _R.get_center()
	if Input.is_action_just_pressed("jump"):
		play_again()

func button_pressed() -> void:
	play_again()

func menu_pressed() -> void:
	_G.change_scene("res://scene/menu.tscn")
