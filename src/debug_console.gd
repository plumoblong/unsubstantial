extends CanvasLayer
class_name TUX

@onready var input : LineEdit = get_node("Input")
@onready var output : RichTextLabel = get_node("Output")

var _expression : Expression = Expression.new()

var history : Array[String] = []
var history_index : int = -1

func _ready() -> void:
	hide()
	input.grab_focus()
	say("[center]Welcome to TUX!\nType help(page : int) for more information.[/center]")

func _process(_delta: float) -> void:
	if not _G.show_fps: return
	$Shadow.text = output.text
	if Input.is_action_just_pressed("console"):
		if visible:
			input.release_focus()
			input.text = ""
			visible = false
		else:
			input.grab_focus()
			visible = true
	if history.size() != 0:
		if Input.is_action_just_pressed("tux_prev"):
			history_index = clamp(history_index + 1, 0, history.size() - 1)
			input.text = history[history_index]
			input.caret_column = 102
		elif Input.is_action_just_pressed("tux_next"):
			history_index = clamp(history_index + 1, 0, history.size() - 1)
			input.text = history[history_index]
			input.caret_column = 102
			
func input_text_submitted(command: String) -> void:
	input.text = ""
	say(">> " + command + "\n")
	history.push_front(command)
	history_index = -1
	var error : Error = _expression.parse(command)
	if error != OK:
		say("ERROR " + str(error) + ": " + _expression.get_error_text())
		return
	
	var result : Variant = _expression.execute([], self)
	if not _expression.has_execute_failed():
		if result != null:
			say(result)
func say(log : Variant, color : Color = Color.WHITE, debug_only : bool = false) -> void:
	print("TUX: ", log)
	if not _G.debug_mode and debug_only: return
	var hex : String = "#%02x%02x%02x" % [color.r8, color.g8, color.b8]
	output.text = "[color=" + hex + "]"+ output.text + "\n" + str(log) + "[/color]"
	
	
func help(page : int = -1) -> void:
	match page:
		0:
			say("Global Commands")
			say(" debug() - Toggles debug info.")
			say(" reload() - Reloads the current loaded scene.")
			say(" say(log) - Outputs an expression to the console.")
			say(" timescale(float) - Sets the time scale. Useful for previewing animations.")
		1:
			say("In Game Commands")
			say(" hitbox() - Shows/Hides hitbox shapes.")
			say(" god() - Toggles god mode for the player.")
			say(" noclip() - Toggles noclip flying for the player. Useful for mapping")
			say(" fullbright() - Toggles fullbright.")
			say(" moveinf(show_debug : int) - Toggles movement info for player.")
			say(" map(name : Text) - Changes the game map. Gets map file from game files.")
			say(" map_custom(name : Text) - Changes the game map. Gets map file from custom_levels folder.\n                                       This can crash if the custom map isn't using unsubstantial assets.")
			say(" set_pmvar(property : Text, value) - Sets a value of specified property in PlayerMovement.")
			say(" dbg_camera() - Switches between the debug camera and the FPS camera.")
			say(" add_item(name : Text) - Adds an item to the inventory. Use snake case for item names. For example \"Some Mage's Hat\" -> \"some_mages_hat\"")
		2:
			say("set_lp(enabled : bool, cutoff : float) - Configure the LowPassFilter on master audio bus.")
		_:
			say("Page 0 - Global Commands")
			say("Page 1 - Game Commands")
			say("Page 2 - Other... Commands")
			
func reload() -> void:
	get_tree().reload_current_scene()
	say("Scene Reloaded.", Color.YELLOW)

func scene(scene_path : String = ""):
	if scene_path == null:
		say("Scene Path can't be empty.")
		return
	_G.change_scene(scene_path)
	say("Changed Scene to " + scene_path, Color.GREEN)

func set_lp(enabled : bool = true, cutoff : float = 0.2) -> void:
	_G.lowpass_cutoff = cutoff
	_G.lowpass_enabled = enabled
	say("LowPass enabled: " + str(enabled) + "\nLowPass cutoff: " + str(int(cutoff * 20500)) + " hz. (" + str(cutoff) + ")", Color.YELLOW)
	
func timescale(scale : float = 1.0) -> void:
	_G.time_scale[1] = scale
	say("Set time scale to " + str(scale), Color.GREEN)

func debug() -> void:
	if OS.has_feature("debug"):
		if _G.debug_mode:
			_G.debug_mode = false
			say("Debug mode is now disabled.", Color.YELLOW)
		else:
			_G.debug_mode = true
			say("Debug mode is now enabled.", Color.YELLOW)
		input.release_focus()
		visible = false
	else:
		say("This is not a debug build!", Color.RED)
		return

func hitbox() -> void:
	if get_tree().debug_collisions_hint:
		get_tree().debug_collisions_hint = false
		say("Hitboxes hidden.")
	else:
		get_tree().debug_collisions_hint = true
		say("Hitboxes visible. You might need to reload the scene.", Color.YELLOW)
	input.release_focus()
	visible = false

func dbg_camera() -> void:
	if _G.player == null or not _G.player.is_inside_tree(): 
		say("Couldn't find player object. Make sure you are in Game.", Color.RED)
		return
	_G.player.debug_camera()
	say("Debug Camera changed")
	
func god() -> void:
	if _G.player == null or not _G.player.is_inside_tree(): 
		say("Couldn't find player object. Make sure you are in Game.", Color.RED)
		return
	if _G.player.god_mode:
		_G.player.god_mode = false
		say("God mode disabled.")
	else:
		_G.player.god_mode = true
		say("God mode enabled.")
	input.release_focus()
	visible = false

func fullbright() -> void:
	if _G.player == null or not _G.player.is_inside_tree(): 
		say("Couldn't find player object. Make sure you are in Game.", Color.RED)
		return
	_G.player.fullbright = not _G.player.fullbright
	input.release_focus()
	visible = false

func moveinf(show_debug : int = 0) -> void:
	if _G.player == null or not _G.player.is_inside_tree(): 
		say("Couldn't find player object. Make sure you are in Game.", Color.RED)
		return
	if _G.player.hud.show_movement_info:
		_G.player.hud.show_movement_info = false
		say("Movement info disabled.")
	else:
		_G.player.hud.show_movement_info = true
		say("Movement info enabled.")
	if show_debug == 1:
		_G.player.hud.show_movement_var = true
		say("Movement debug variables enabled.")
	input.release_focus()
	visible = false

func map(path : String = "ether") -> void:
	if _G.game == null or not _G.game.is_inside_tree(): 
		say("Couldn't find game object. Make sure you are in Game.", Color.RED)
		return
	_G.game.change_map("res://level/" + path + ".tscn")
	input.release_focus()
	visible = false
	
func map_custom(path : String = "template") -> void:
	if _G.game == null or not _G.game.is_inside_tree(): 
		say("Couldn't find game object. Make sure you are in Game.", Color.RED)
		return
	_G.game.change_map("user://custom_levels/" + path + ".tscn")
	input.release_focus()
	visible = false

func set_pmvar(property : StringName, value : float = 0.0) -> void:
	if _G.player == null or not _G.player.is_inside_tree(): 
		say("Couldn't find player object. Make sure you are in Game.", Color.RED)
		return
	_G.player.movement_component.set(property, value)
	say("Set movement_componenty property " + property + " to: " + str(value), Color.WHITE)

func autobhop() -> void:
	if _G.player == null or not _G.player.is_inside_tree(): 
		say("Couldn't find player object. Make sure you are in Game.", Color.RED)
		return
	if _G.player.movement_component.auto_bhop:
		_G.player.movement_component.auto_bhop = false
		say("Auto Bunnying disabled.")
	else:
		_G.player.movement_component.auto_bhop = true
		say("Auto Bunnying enabled. Hold the jump button to keep jumping")

func noclip() -> void:
	if _G.player == null or not _G.player.is_inside_tree(): 
		say("Couldn't find player object. Make sure you are in Game.", Color.RED)
		return
	if _G.player.movement_component.noclip:
		_G.player.god_mode = false
		_G.player.movement_component.noclip = false
		say("Noclip disabled.")
	else:
		_G.player.movement_component.noclip = true
		_G.player.god_mode = true
		say("Noclip enabled.")

func add_item(path : String) -> void:
	if _G.player == null or not _G.player.is_inside_tree(): 
		say("Couldn't find player object. Make sure you are in Game.", Color.RED)
		return
	var x : Item = load("res://item/" + path + ".tres")
	_G.player.items.append(x)
