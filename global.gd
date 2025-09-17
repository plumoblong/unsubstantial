extends Node
class_name Global

const VERSION : String = "0.96 indev5.1"

enum achievement {
	START, BEAT, DIE, LUCK, LOOP
}

var show_fps : bool = false
var debug_mode : bool = false
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var config : Dictionary = {
	fov = 90.0,
	fullscreen = true,
	resolution = 2,
	ui_dark_mode = false,
	tux = false,
	view_bob = true,
	controls = {
		sensitivity = 0.5,
		bind = {}
	},
	sound = {
		master = 0.75,
		sfx = 1.0,
		music = 0.5,
	},
	video = {
		post_process = true,
		exposure = 1.0,
		low = false, ## disables glow and reduces render distance
		v_sync = false,
		motion_blur = true,
	},
}

var current_run : Dictionary = {
	
	die_reason = "You got shot.",
	score = 0,

	kills = 0,
	hits_taken = 0,
	items_collected = {
		common = 0,
		uncommon = 0,
		rare = 0,
		legendary = 0,
		mythic = 0,
		times_bought = 0,
	},
	times_looped = 0,
	bosses_slained = 0,
}

var save : Dictionary = {
	achieved = [],
	ichor = 0,
	high_score = 0,
	runs_lost = 0,
	runs_won = 0,
	win_streak = 0,
}



var player : Player
var game : Game

var time : float = 0.0
var starting_level : String = "res://level/test/dengeon_test.tscn"

var CONFIG_PATH : String = "user://config" + VERSION.to_snake_case() + ".dat" 
var SAVE_PATH : String = "user://save.dat" 

var in_close_menu : bool = false

const FLARE_FILE : PackedScene = preload("res://prefab/flare.tscn")
const UIPOP_FILE : PackedScene = preload("res://prefab/menus/ui_pop_up.tscn")

var shader_inverted : bool = false

var lowpass_cutoff : float = 1.0  # n * 20500 hz (why so low? idk ask godot devs)
var lowpass_enabled : bool = true

var low_pass : AudioEffectLowPassFilter = AudioServer.get_bus_effect(0, 1)

var time_scale : Array[float] = [1.0, 1.0]

func _ready() -> void:
	if config.fullscreen:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
	seed(int(Time.get_unix_time_from_system()))

func _process(delta : float) -> void:
	time += delta
	$Version.text = VERSION.to_upper()
	
	$Shader.material.set_shader_parameter("gamma", config.video.exposure)
	$Shader.material.set_shader_parameter("enable_filter", config.video.post_process)
	$Shader.material.set_shader_parameter("inverted", shader_inverted)
	if Input.is_action_just_pressed("f11"):
		change_fullscreen()
	if Input.is_action_just_pressed("f1"):
		show_fps = not show_fps
	$FPS.text = str(Engine.get_frames_per_second()) + " FPS"
	$Debug.visible = debug_mode
	$FPS.visible = show_fps
	AudioServer.set_bus_volume_db(0, linear_to_db(config.sound.master))
	AudioServer.set_bus_volume_db(2, linear_to_db(config.sound.sfx))
	AudioServer.set_bus_volume_db(3, linear_to_db(config.sound.sfx))
	AudioServer.set_bus_volume_db(1, linear_to_db(config.sound.music))
	
	
	low_pass.cutoff_hz = 20500 * lowpass_cutoff
	AudioServer.set_bus_effect_enabled(0, 1, lowpass_enabled)
	
	Engine.time_scale = time_scale[0] * time_scale[1]
	
	
	if not _G.config.fullscreen:
		var clean_res : Vector2i = Vector2i(snappedi(DisplayServer.screen_get_size(0).x, 480), snappedi(DisplayServer.screen_get_size(0).x, 270))
		get_window().size = clamp(Vector2i(480, 270) * int(config.resolution), Vector2i(480, 270), clean_res)
		config.resolution = clampi(config.resolution, 1, clean_res.x / 480.0)
		get_window().move_to_center()
	
func get_resolution() -> float:
	if not _G.config.fullscreen: 
		return _G.config.resolution
	else:
		return DisplayServer.screen_get_size(DisplayServer.window_get_current_screen()).x / 432.0
func flare_screen(start_color : Color = Color.WHITE, end_color : Color = Color.TRANSPARENT, length : float = 1.0) -> void:
	var flare : Flare = FLARE_FILE.instantiate()
	$Flares.add_child(flare)
	flare.start_color = start_color
	flare.end_color = end_color
	flare.time = length
	#flare.transition = transition
	flare.fade()
	
func angle_to_vector(angle_degrees : float, y : float = 0.0) -> Vector3:
	var angle_radians : float = deg_to_rad(angle_degrees)
	var vector2 : Vector2 = Vector2.from_angle(angle_radians)
	return Vector3(vector2.y, y, vector2.x)
	
func vector_to_angle(vec : Vector3) -> float:
	
	var angle : float = rad_to_deg(Vector2(vec.z, vec.x).angle())
	return angle

func angle3d_to_vector3(angle :Vector3) -> Vector3:
	return Vector3(sin(angle.y) * cos(angle.x), -sin(angle.x), cos(angle.y) * cos(angle.x)).normalized()

func vector_to_angle3d(vec : Vector3) -> Vector3:
	var yaw = atan2(vec.x, vec.z)
	var pitch = asin(-vec.y)
	return Vector3(pitch, yaw, 0.0)

func sine_movement(freq : float, amplitude : float, offset : float = 0.0) -> float:
	return sin(offset + time *freq)*(amplitude * 0.01)

func change_window_size(size : int) -> void:
	size = clampi(size, -1, (DisplayServer.screen_get_size(DisplayServer.window_get_current_screen()).x / 432.0)) + 1
	var viewport_size : Vector2i = Vector2i(432, 243)
	get_window().size = viewport_size * size
	get_window().move_to_center()
	
@warning_ignore("untyped_declaration")
func tween(node : Object, property : String, value, length : float = 1.0, trans : int = Tween.TRANS_LINEAR, easing : int = Tween.EASE_IN_OUT) -> void:
	#pass
	var t := get_tree().create_tween()
	t.set_trans(trans)
	t.set_ease(easing)
	t.tween_property(node, property, value, length)
	return
	
func change_fullscreen() -> void:
	if get_window().mode == Window.MODE_WINDOWED:
		get_window().mode = Window.MODE_FULLSCREEN
		config.fullscreen = true
	else:
		get_window().mode = Window.MODE_WINDOWED
		config.fullscreen = false
		
func _notification(what : int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_files()
		await get_tree().create_timer(0.1).timeout
		get_tree().quit() # default behavior
			
func change_scene(file : String, color : Color = Color.BLACK, trans_in : float = 0.5, trans_out : float = 0.5, bypass : bool = false) -> void:
	if not bypass: if $Flare.color.a != 0: return
	tween($Flare, "color", color, trans_in, 0, 0)
	await get_tree().create_timer(trans_in, true, false, true).timeout
	get_tree().change_scene_to_file(file)
	_G.shader_inverted = false
	tween($Flare, "color", Color(color.r, color.g, color.b, 0.0), trans_out, 0, 0)
	await get_tree().create_timer(trans_out, true, false, true).timeout
	time_scale[0] = 1.0
	time_scale[1] = 1.0
	
func change_scene_packed(packed_scene : PackedScene, color : Color = Color.BLACK, trans_in : float = 0.5, trans_out : float = 0.5, bypass : bool = false) -> void:
	if not bypass: if $Flare.color.a != 0: return
	flare_screen(Color(color.r, color.g, color.b, 0.0), color, trans_in)
	await get_tree().create_timer(trans_in, true, false, true).timeout
	get_tree().change_scene_to_packed(packed_scene)
	await get_tree().create_timer(0.015).timeout
	flare_screen(color, Color(color.r, color.g, color.b, 0.0), trans_out)
	await get_tree().create_timer(trans_out, true, false, true).timeout
	time_scale[0] = 1.0
	time_scale[1] = 1.0
	
func hsv_to_rgb(h : float, s : float, v : float, a : float = 1.0) -> Color:
	#based on code at
	#http://stackoverflow.com/questions/51203917/math-behind-hsv-to-rgb-conversion-of-colors
	var r : float
	var g : float
	var b : float

	var i : int = floor(h * 6)
	var f : float = h * 6 - i
	var p : float = v * (1 - s)
	var q : float = v * (1 - f * s)
	var t : float = v * (1 - (1 - f) * s)

	match (int(i) % 6):
		0:
			r = v
			g = t
			b = p
		1:
			r = q
			g = v
			b = p
		2:
			r = p
			g = v
			b = t
		3:
			r = p
			g = q
			b = v
		4:
			r = t
			g = p
			b = v
		5:
			r = v
			g = p
			b = q
	return Color(r, g, b, a)

func get_all_children(node : Node) -> Array[Node]:
	var nodes : Array[Node] = []

	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(get_all_children(N))
		else:

			nodes.append(N)

	return nodes
	
#func change_discord_rpc(details : String = "poison", state : String = "", count_time : bool = false, large_image : Array[String] = ["poison", "test"]) -> void:
	#DiscordRPC.details = details
	#if state != "":
		#DiscordRPC.state = state
	#DiscordRPC.large_image = large_image[0]
	#DiscordRPC.large_image_text = large_image[1]
	##DiscordRPC.small_image = small_image[0]
	##DiscordRPC.small_image_text = small_image[1]
	#if count_time:
		#DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system()) # "02:46 elapsed"
	#DiscordRPC.refresh()
	
@warning_ignore("untyped_declaration")	
func values_match(values : Array, expected_value):
	@warning_ignore("untyped_declaration")
	return values.any(func(value): return value == expected_value)
#func create_object(file_path : String, parent : Node) -> Node:
	#var res : PackedScene = load(file_path)
	#var obj : Node = res.instantiate()
	#parent.add_child(obj)
	#obj.position = Vector3(0.0, 1.0, 0.0)
	#return obj
	
func choose_from_chance(values : Dictionary):
	var weighted_list : Array = []
	for key in values.keys():
		for i in values[key]:
			weighted_list.append(key)
	if not weighted_list.is_empty():
		return weighted_list.pick_random() 

func get_achievement(a : achievement) -> void:
	if save.achieved.has(a): return
	else:
		save.achieved.append(a)
		
func save_files() -> void:
	var configfile := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	var conf_js = JSON.stringify(config)
	configfile.store_line(conf_js)
	configfile.close()
	var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var save_js = JSON.stringify(save)
	save_file.store_line(save_js)
	save_file.close()
	print("saved")
	
func get_last_n_elements(array: Array, count: int) -> Array:
	var start_index: int = max(array.size() - count, 0)
	return array.slice(start_index, array.size() - start_index)

func get_first_n_elements(array: Array, count: int) -> Array:
	var length: int = min(count, array.size())
	return array.slice(0, length)

func enable_bit(mask: int, index: int) -> int:
	return mask | (1 << index)

func disable_bit(mask: int, index: int) -> int:
	return mask & ~(1 << index)

func merge_no_overwrite(src, dest : Dictionary) -> void:
	if src == null or dest == null: 
		_T.say("merge_no_overwrite Error: one of the dictionaries dont exist. Pushing on stack.", Color.RED) 
		return
	for key in src:
		dest[key] = src[key]
		print(dest[key],"  ", src[key])

func vector_to_string(vec, seperator : String = "   ", snap : float = 0.01) -> String:
	if vec is Vector2:
		return str(snappedf(vec.x, snap)) + seperator +  str(snappedf(vec.y, snap))
	elif vec is Vector3:
		return str(snappedf(vec.x, snap)) + seperator +  str(snappedf(vec.y, snap)) + seperator +  str(snappedf(vec.z, snap))
	elif vec is Vector4:
		return str(snappedf(vec.x, snap)) + seperator +  str(snappedf(vec.y, snap)) + seperator +  str(snappedf(vec.z, snap)) + seperator + str(snappedf(vec.w, snap))
	else:
		return str(vec)

func create_ui_popup(text : String = "HI.", position : Vector2 = Vector2.ZERO, velocity : Vector2 = Vector2.UP, color : Color = Color.GREEN, length : float = 10.0, invert : float = 0.6):
	var d = UIPOP_FILE.instantiate()
	d.text = text
	d.position = position
	d.velocity = velocity
	d.color = color
	d.invert_amount = invert
	add_child(d)
