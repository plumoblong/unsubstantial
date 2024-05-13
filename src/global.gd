extends CanvasLayer

const GAME_VERSION = "PRE-ALPHA 1 (DEMO)"

var time : float = 0
var debug : bool = false
var total_kills : int = 0


var config = {
	sensivity = 0.5,
	fov = 90.0,
	view_bobbing_amount = 1.0,
	crosshair_enabled = true,
	graphics = {
		shadows = false,
		post_process = true
	}
}

enum GAME_MODE { SINGLE, MULTI, COOP }
var game_mode : int = -1

func _process(delta):
		
	time += delta
	$BuildInfo 
	if Input.is_action_just_pressed("fullscreen"):
		change_fullscreen()
	$BuildInfo.text = GAME_VERSION
	if Input.is_action_just_pressed("debug"):
		debug = not debug
	$Debug.visible = debug
	$Debug/FPS.text = str(Engine.get_frames_per_second())
	

func angle_to_vector(angle_degrees : float):
	var angle_radians = deg_to_rad(angle_degrees)
	var vector2 = Vector2.from_angle(angle_radians)
	return Vector3(vector2.y, 0, vector2.x)

func tween(node, property, value, length, trans):
	var t = get_tree().create_tween()
	t.set_trans(trans)
	t.tween_property(node, property, value, length)
	pass
	
func sine_movement(amp, freq):
	return cos(time*freq) * amp
	
func change_fullscreen():
	if get_window().mode == Window.MODE_WINDOWED:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
