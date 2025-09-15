extends Node2D
class_name Menu

var screen : int = 0
var selected : int = 0

var all_visible : bool = true
@export var songs : Dictionary[AudioStreamOggVorbis, int]

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_G.get_achievement(_G.achievement.START)
	$Theme.stream = _G.choose_from_chance(songs)
	$Theme.play()
	
func _process(delta : float) -> void:
	if Input.is_action_just_pressed("f2"):
		all_visible = not all_visible
	$Camera3D.rotation_degrees.y += delta * 6.0
	$Main.visible = screen == 0 and all_visible
	$Options.visible = screen == 1 and all_visible
	$Achievements.visible = screen == 2 and all_visible
	$Debug.visible = _G.debug_mode and all_visible
	if Input.is_action_just_pressed("escape"):
		if $Options.screen == 0:
			screen = 0
	$WorldEnvironment.environment.glow_enabled = not _G.config.video.low
	$WorldEnvironment.environment.tonemap_exposure = _G.config.video.exposure * (float(_G.config.video.low) + 1.0)
	if _G.debug_mode:
		if Input.is_action_just_pressed("up"):
			_G.flare_screen()
	
	$Camera3D.fov = _G.config.fov

func _on_start_pressed() -> void:
	_G.starting_level = ""
	_G.change_scene("res://scene/game.tscn")

func exit_pressed() -> void:
	_G.save_files()
	get_tree().quit()

func texture_button_pressed() -> void:
	OS.shell_open("https://discord.gg/t2RjkVAn3Z")

func youtube_pressed() -> void:
	OS.shell_open("https://www.youtube.com/@plumoblong")

func twitter_pressed() -> void:
	OS.shell_open("https://x.com/plumoblong")
	
func options_pressed() -> void:
	screen = 1

func button_pressed() -> void:
	$FileDialog.visible = true

func file_dialog_file_selected(path : String) -> void:
	_G.starting_level = path
	_G.change_scene("res://scene/game.tscn")

func achievements_pressed() -> void:
	screen = 2
