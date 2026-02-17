extends Node
class_name Global

const VERSION : String = "0.96 indev 8"
const CONFIG_VERSION : int = 1

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
		bind = {
		}
	},
	sound = {
		master = 0.75,
		sfx = 1.0,
		music = 0.5,
	},
	video = {
		exposure = 1.0,
		low = false,
		v_sync = false,
		motion_blur = false,
	},
}

var run_seed : int = 0

var current_run : Dictionary = {
	die_reason = "You got shot.",
	score = 0,
	kills = 0,
	hits_taken = 0,
	crystals_collected = 0,
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

var CONFIG_PATH : String = "user://config_v" + str(CONFIG_VERSION) + ".json" 
var SAVE_PATH : String = "user://save.json" 

var in_close_menu : bool = false

const FLARE_FILE : PackedScene = preload("res://prefab/flare.tscn")
const UIPOP_FILE : PackedScene = preload("res://prefab/menus/ui_pop_up.tscn")

var lowpass_enabled : bool = false
var time_scale : Array[float] = [1.0, 1.0]

@onready var version_label: Label = $Version
@onready var fps_label: Label = $FPS
@onready var debug_node: Node2D = $Debug
@onready var shader_rect: ColorRect = $Shader
@onready var flare_rect: ColorRect = $Flare
@onready var flares_container: Node = $Flares

var _cached_window: Window
var _cached_viewport: Viewport
var _cached_shader_material: ShaderMaterial
var _last_fullscreen_state: bool = true
var _last_low_quality: bool = false

func _ready() -> void:
	_cached_window = get_window()
	_cached_viewport = get_viewport()
	_cached_shader_material = shader_rect.material
	
	if config.fullscreen:
		_cached_window.mode = Window.MODE_FULLSCREEN
	else:
		_cached_window.mode = Window.MODE_WINDOWED
	
	seed(int(Time.get_unix_time_from_system()))
	version_label.text = VERSION.to_upper()
	
	_setup_discord_rpc()

func _setup_discord_rpc() -> void:
	if OS.has_feature("web"): return
	DiscordRPC.app_id = 1316162745384702043
	
func _setup_audio_buses() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(config.sound.master))
	AudioServer.set_bus_volume_db(1, linear_to_db(config.sound.music))
	AudioServer.set_bus_volume_db(2, linear_to_db(config.sound.sfx))
	AudioServer.set_bus_volume_db(3, linear_to_db(config.sound.sfx))
	
func change_discord_rpc(update_timestamp : bool = true, details : String = "Chapter 1 Stage 2", state = "5 Shards", small_image : String = "chapter_icon0", small_image_text : String = "The Ether", large_image : String = "poison", large_image_text : String = "plumoblong.github.io", ) -> void:
	if OS.has_feature("web"): return
	DiscordRPC.details = details
	DiscordRPC.state = state
	DiscordRPC.large_image = large_image
	DiscordRPC.large_image_text = large_image_text
	DiscordRPC.small_image = small_image
	DiscordRPC.small_image_text = small_image_text
	if update_timestamp: DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	DiscordRPC.refresh()
	
func _process(delta : float) -> void:
	time += delta
	
	if _last_low_quality != config.video.low:
		_cached_viewport.scaling_3d_scale = 0.5 if config.video.low else 1.0
		_last_low_quality = config.video.low
	
	_cached_shader_material.set_shader_parameter("gamma", config.video.exposure)
	
	_handle_input()
	_update_ui(delta)
	_update_window_size()
	_setup_audio_buses()
	
	Engine.time_scale = time_scale[0] * time_scale[1]

func _handle_input() -> void:
	if Input.is_action_just_pressed("f11"):
		change_fullscreen()
	if Input.is_action_just_pressed("f1"):
		show_fps = not show_fps
	if Input.is_action_just_pressed("toggle_fb"):
		_cached_viewport.debug_draw = int(not bool(_cached_viewport.debug_draw))

func _update_ui(delta : float = 0.0) -> void:
	fps_label.visible = show_fps
	debug_node.visible = debug_mode
	
	if show_fps:
		if Engine.get_physics_frames() % 30 == 0:
			fps_label.text = str(int(1/delta) * Engine.time_scale) + " FPS\n" + str(float(delta * 1000.0)) + "ms"
		
func _update_window_size() -> void:
	if not config.fullscreen:
		var screen_size := DisplayServer.screen_get_size(0)
		var clean_res := Vector2i(snappedi(screen_size.x, 480), snappedi(screen_size.x, 270))
		var min_size := Vector2i(480, 270)
		var new_size := clamp(min_size * int(config.resolution), min_size, clean_res)
		
		if _cached_window.size != new_size:
			_cached_window.size = new_size
			_cached_window.move_to_center()
		
		config.resolution = clampi(config.resolution, 1, clean_res.x / 480.0)

func get_resolution() -> float:
	if not config.fullscreen: 
		return config.resolution
	else:
		return DisplayServer.screen_get_size(DisplayServer.window_get_current_screen()).x / 432.0

func flare_screen(start_color : Color = Color.WHITE, end_color : Color = Color.TRANSPARENT, length : float = 1.0) -> void:
	var flare : Flare = FLARE_FILE.instantiate()
	flares_container.add_child(flare)
	flare.start_color = start_color
	flare.end_color = end_color
	flare.time = length
	flare.fade()

func angle_to_vector(angle_degrees : float, y : float = 0.0) -> Vector3:
	var angle_radians : float = deg_to_rad(angle_degrees)
	var vector2 : Vector2 = Vector2.from_angle(angle_radians)
	return Vector3(vector2.y, y, vector2.x)

func vector_to_angle(vec : Vector3) -> float:
	return rad_to_deg(Vector2(vec.z, vec.x).angle())

func angle3d_to_vector3(angle : Vector3) -> Vector3:
	return Vector3(sin(angle.y) * cos(angle.x), -sin(angle.x), cos(angle.y) * cos(angle.x)).normalized()

func vector_to_angle3d(vec : Vector3) -> Vector3:
	return Vector3(asin(-vec.y), atan2(vec.x, vec.z), 0.0)

func sine_movement(freq : float, amplitude : float, delta : float, offset : float = 0.0) -> float:
	return sin((offset + time) * freq) * (amplitude * delta)

func change_window_size(size : int) -> void:
	size = clampi(size, -1, (DisplayServer.screen_get_size(DisplayServer.window_get_current_screen()).x / 432.0)) + 1
	_cached_window.size = Vector2i(432, 243) * size
	_cached_window.move_to_center()

@warning_ignore("untyped_declaration")
func tween(node : Object, property : String, value, length : float = 1.0, trans : int = Tween.TRANS_LINEAR, easing : int = Tween.EASE_IN_OUT) -> Tween:
	var t := get_tree().create_tween()
	t.set_trans(trans)
	t.set_ease(easing)
	t.tween_property(node, property, value, length)
	return t

func change_fullscreen() -> void:
	if _cached_window.mode == Window.MODE_WINDOWED:
		_cached_window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		config.fullscreen = true
	else:
		_cached_window.mode = Window.MODE_WINDOWED
		config.fullscreen = false

func _notification(what : int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_files()
		await get_tree().create_timer(0.1).timeout
		get_tree().quit()

func change_scene(file : String, color : Color = Color.BLACK, trans_in : float = 0.5, trans_out : float = 0.5, bypass : bool = false) -> void:
	if not bypass and flare_rect.color.a != 0:
		return
	
	tween(flare_rect, "color", color, trans_in, 0, 0)
	await get_tree().create_timer(trans_in, true, false, true).timeout
	get_tree().change_scene_to_file(file)
	tween(flare_rect, "color", Color(color.r, color.g, color.b, 0.0), trans_out, 0, 0)
	await get_tree().create_timer(trans_out, true, false, true).timeout
	time_scale[0] = 1.0
	time_scale[1] = 1.0

func change_scene_packed(packed_scene : PackedScene, color : Color = Color.BLACK, trans_in : float = 0.5, trans_out : float = 0.5, bypass : bool = false) -> void:
	if not bypass and flare_rect.color.a != 0:
		return
	
	var transparent_color := Color(color.r, color.g, color.b, 0.0)
	flare_screen(transparent_color, color, trans_in)
	await get_tree().create_timer(trans_in, true, false, true).timeout
	get_tree().change_scene_to_packed(packed_scene)
	await get_tree().create_timer(0.015).timeout
	flare_screen(color, transparent_color, trans_out)
	await get_tree().create_timer(trans_out, true, false, true).timeout
	time_scale[0] = 1.0
	time_scale[1] = 1.0

func get_all_children(node : Node) -> Array[Node]:
	var nodes : Array[Node] = []
	var stack : Array[Node] = [node]
	
	while stack.size() > 0:
		var current := stack.pop_back()
		for child in current.get_children():
			nodes.append(child)
			if child.get_child_count() > 0:
				stack.append(child)
	
	return nodes

@warning_ignore("untyped_declaration")	
func values_match(values : Array, expected_value) -> bool:
	for value in values:
		if value == expected_value:
			return true
	return false

func choose_from_chance(values : Dictionary):
	var weighted_list : Array = []
	for key in values.keys():
		var weight := maxi(values[key], 1)
		for i in weight:
			weighted_list.append(key)
	return weighted_list.pick_random()

func get_achievement(a : achievement, count_to_save : bool = true) -> void:
	if save.achieved.has(a):
		return
	
	if count_to_save:
		save.achieved.append(a)

func save_files() -> void:
	var configfile := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	configfile.store_line(JSON.stringify(config))
	configfile.close()
	
	var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	save_file.store_line(JSON.stringify(save))
	save_file.close()
	
	print("saved")

func get_last_n_elements(array: Array, count: int) -> Array:
	var start_index: int = maxi(array.size() - count, 0)
	return array.slice(start_index, array.size())

func get_first_n_elements(array: Array, count: int) -> Array:
	return array.slice(0, mini(count, array.size()))

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
		print(dest[key], "  ", src[key])

func vector_to_string(vec, seperator : String = "   ", snap : float = 0.01) -> String:
	if vec is Vector2:
		return str(snappedf(vec.x, snap)) + seperator + str(snappedf(vec.y, snap))
	elif vec is Vector3:
		return str(snappedf(vec.x, snap)) + seperator + str(snappedf(vec.y, snap)) + seperator + str(snappedf(vec.z, snap))
	elif vec is Vector4:
		return str(snappedf(vec.x, snap)) + seperator + str(snappedf(vec.y, snap)) + seperator + str(snappedf(vec.z, snap)) + seperator + str(snappedf(vec.w, snap))
	else:
		return str(vec)

func create_ui_popup(text : String = "HI.", position : Vector2 = Vector2.ZERO, velocity : Vector2 = Vector2.UP, color : Color = Color.GREEN, length : float = 10.0, invert : float = 0.6) -> void:
	var d = UIPOP_FILE.instantiate()
	d.text = text
	d.position = position
	d.velocity = velocity
	d.color = color
	d.invert_amount = invert
	add_child(d)

func set_shaderparam_once(material : ShaderMaterial, parameter : StringName, value : Variant) -> void:
	material.set_shader_parameter(parameter, value)

func get_color_darkmode(white : bool = true, alpha : float = 1.0) -> Color:
	var base_color := Color.WHITE if (white == config.ui_dark_mode) else Color.BLACK
	return base_color * Color(1, 1, 1, alpha)

func return_input_binds_to_dict() -> Dictionary:
	#TODO: Loop through are supported bindable InputMap actions and return their input values to a Dictionary.
	#      Meant to be used for saving the input binds into config.json
	return {
		"up" = InputMap.action_get_events("up")[0],
		"down" = InputMap.action_get_events("down")[0],
		"left" = InputMap.action_get_events("left")[0],
		"right" = InputMap.action_get_events("right")[0],
		"jump" = InputMap.action_get_events("jump")[0],
		"dash" = InputMap.action_get_events("dash")[0],
		"shoot" = InputMap.action_get_events("shoot")[0],
		"interact" = InputMap.action_get_events("interact")[0],
	}
	
func string_to_input_event(text: String) -> InputEvent:
	if "InputEventMouseButton" in text:
		var event = InputEventMouseButton.new()
		event.button_index = _get_int(text, "button_index")
		event.pressed = "pressed=true" in text
		event.position = _get_vector2(text, "position")
		event.button_mask = _get_int(text, "button_mask")
		event.double_click = "double_click=false" in text
		return event
	
	if "InputEventKey" in text:
		var event = InputEventKey.new()
		event.keycode = _get_int(text, "keycode")
		event.pressed = "pressed=true" in text
		event.echo = "echo=true" in text
		event.physical_keycode = "physical=true" in text
		return event
	
	return null

func _get_int(text: String, key: String) -> int:
	var start = text.find(key + "=")
	if start == -1:
		return 0
	start += key.length() + 1
	var end = text.find(",", start)
	if end == -1:
		end = text.length()
	var value = text.substr(start, end - start).strip_edges()
	return int(value.split(" ")[0])

func _get_vector2(text: String, key: String) -> Vector2:
	var start = text.find(key + "=")
	if start == -1:
		return Vector2.ZERO
	start += key.length() + 1
	var end = text.find(")", start) + 1
	var vec_str = text.substr(start, end - start)
	vec_str = vec_str.replace("(", "").replace(")", "")
	var parts = vec_str.split(",")
	return Vector2(float(parts[0]), float(parts[1]))
