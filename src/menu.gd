extends CanvasLayer

@export var in_game : bool = false

var current_screen : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	global.game_mode = -1
	if not in_game:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Menu.visible = current_screen == 0
	$Options.visible = current_screen == 1
	$Menu/Logo.rotation_degrees = global.sine_movement(2.0, 2.0)
	if Input.is_action_just_pressed("return"):
		current_screen = 0
	if not in_game:
		$"../Camera3D".position.y += global.sine_movement(3, 1.0) * delta
		$"../Camera3D".fov = global.config.fov

func singleplayer_pressed():
	global.game_mode = global.GAME_MODE.SINGLE
	get_tree().change_scene_to_file("res://scenes/e_1s_1.tscn")

func quit_pressed():
	get_tree().quit()

func options_pressed():
	current_screen = 1
