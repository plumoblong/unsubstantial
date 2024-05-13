extends CanvasLayer

@export var in_game : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	global.game_mode = -1
	if not in_game:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ColorRect.visible = in_game
	$ColorRect.size = get_viewport().get_size()
	$Menu/Logo.rotation_degrees = global.sine_movement(2, 2)

func singleplayer_pressed():
	global.game_mode = global.GAME_MODE.SINGLE
	get_tree().change_scene_to_file("res://scenes/e_1s_1.tscn")

func quit_pressed():
	get_tree().quit()
