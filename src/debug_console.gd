extends CanvasLayer
class_name TUX

# WELCOME TO TERRIBLE USER EXPERIENCE
# - Regards, plumoblong

@onready var input : LineEdit = get_node("ConsolePanel/Input")
@onready var output : RichTextLabel = get_node("ConsolePanel/Output")
@onready var console_panel : Control = get_node("ConsolePanel")  # Assuming you have a parent panel/container

const SLIDE_DURATION : float = 0.25
const SLIDE_OFFSET : float = -400.0  # Adjust based on your console height

var _expression : Expression = Expression.new()
var _tween : Tween

var history : Array[String] = []
var history_index : int = -1

var _is_console_active : bool = false

#console command variables

var _c_print_to_chat : bool = false

func start() -> void:
	# Start with console hidden offscreen
	if console_panel:
		console_panel.position.y = SLIDE_OFFSET
	hide()
	if _G.config.tux:
		say("\nWelcome to TUX!\nType help or help <page> for more information.")
	else:
		say("\nClient's TUX is disabled.")
	var user_args = OS.get_cmdline_args()
	
	say("\nRun Arguments" + str(user_args))
	
	var i = 0
	while i < user_args.size():
		var arg = user_args[i]
		if arg.begins_with("--"):
			var cmd = arg.trim_prefix("--")
			var args = []
			# Collect following values that aren't flags
			while i + 1 < user_args.size() and not user_args[i + 1].begins_with("--"):
				i += 1
				args.append(user_args[i])
			say("Auto-executing: " + cmd + " " + " ".join(args), Color.GRAY)
			execute_command(cmd, args)
		i += 1

func _input(event: InputEvent) -> void:
	if not _G.config.tux: return
	
	if event.is_action_pressed("console"):
		toggle_console()
		get_viewport().set_input_as_handled()
	
	if not _is_console_active or not input.has_focus():
		return
		
	if event.is_action_pressed("tux_prev") and history.size() > 0:
		history_index = clamp(history_index + 1, 0, history.size() - 1)
		input.text = history[history_index]
		input.caret_column = input.text.length()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("tux_next") and history.size() > 0:
		history_index = clamp(history_index - 1, -1, history.size() - 1)
		if history_index == -1:
			input.text = ""
		else:
			input.text = history[history_index]
		input.caret_column = input.text.length()
		get_viewport().set_input_as_handled()

func toggle_console() -> void:
	_is_console_active = not _is_console_active
	
	if _is_console_active:
		show_console()
	else:
		hide_console()

func _process(_delta: float) -> void:
	if not visible: return
	$ConsolePanel/Output.size.x = _R.get_screen_size().x - 4
	$ConsolePanel/Output.size.y = _R.get_screen_size().y - 64
	$ConsolePanel/ColorRect.size.y = _R.get_screen_size().y - 48
	$ConsolePanel/ColorRect.size.x = _R.get_screen_size().x
	$ConsolePanel/Label.position.y = _R.get_screen_size().y - 58
	$ConsolePanel/Input.position.y = _R.get_screen_size().y - 58
	
func show_console() -> void:
	show()
	
	# Kill any existing tween
	if _tween and _tween.is_valid():
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	
	if console_panel:
		_tween.tween_property(console_panel, "position:y", 0.0, SLIDE_DURATION * Engine.time_scale).from(SLIDE_OFFSET)
	
	# Grab focus after animation starts
	await get_tree().create_timer(0.05).timeout
	input.grab_focus()

func hide_console() -> void:
	input.release_focus()
	input.text = ""
	if _tween and _tween.is_valid():
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_CUBIC)
	
	if console_panel:
		_tween.tween_property(console_panel, "position:y", SLIDE_OFFSET, SLIDE_DURATION * Engine.time_scale)
	await _tween.finished
	hide()

func parse_command(text: String) -> Dictionary:
	var result = {
		"command": "",
		"args": []
	}
	
	# Trim whitespace
	text = text.strip_edges()
	if text.is_empty():
		return result
	
	# Split by spaces, respecting quotes
	var parts : Array[String] = []
	var current_part : String = ""
	var in_quotes : bool = false
	
	for i in range(text.length()):
		var c = text[i]
		
		if c == '"':
			in_quotes = not in_quotes
		elif c == ' ' and not in_quotes:
			if not current_part.is_empty():
				parts.append(current_part)
				current_part = ""
		else:
			current_part += c
	
	# Add last part
	if not current_part.is_empty():
		parts.append(current_part)
	
	if parts.size() > 0:
		result.command = parts[0].to_lower()
		result.args = parts.slice(1)
	
	return result

func input_text_submitted(text: String) -> void:
	input.text = ""
	
	if text.strip_edges().is_empty():
		return
	
	history.push_front(text)
	history_index = -1
	
	say(">> " + text)
	
	var parsed = parse_command(text)
	execute_command(parsed.command, parsed.args)

func execute_command(cmd: String, args: Array) -> void:
	match cmd:
		# Global Commands
		"help":
			var page = int(args[0]) if args.size() > 0 else -1
			help(page)
		"debug":
			if not OS.has_feature("debug"):
				say("This is not a debug build!", Color.RED)
			else: 
				_G.debug_mode = not _G.debug_mode
				var state = "enabled" if _G.debug_mode else "disabled"
				say("Debug mode " + state, Color.YELLOW)
		"reload":
			get_tree().reload_current_scene()
			say("Scene Reloaded.", Color.YELLOW)
		"say":
			if args.size() > 0:
				say(" ".join(args))
		"timescale":
			var scale = float(args[0]) if args.size() > 0 else 1.0
			timescale(scale)
		"change_scene":
			var path = args[0] if args.size() > 0 else ""
			scene(path)
		"clear":
			output.text = ""
		
		# Game Commands
		"hitbox":
			hitbox()
		"god":
			god()
		"noclip":
			noclip()
		"fullbright":
			fullbright()
		"moveinf":
			var show_debug = int(args[0]) if args.size() > 0 else 0
			moveinf(show_debug)
		"map":
			var map_name = args[0] if args.size() > 0 else "ether"
			map(map_name)
		"map_custom":
			var map_name = args[0] if args.size() > 0 else "template"
			map_custom(map_name)
		"set_pmvar":
			if args.size() >= 2:
				set_pmvar(args[0], float(args[1]))
			else:
				say("Usage: set_pmvar <property> <value>", Color.RED)
		"dbg_camera":
			dbg_camera()
		"autobhop":
			var enabled = int(args[0]) if args.size() > 0 else -1
			autobhop(enabled)
		"disable_enemies":
			disable_enemies()
		"dark":
			dark()
		"debug_draw":
			var id : int = int(args[0]) if args.size() > 0 else 0
			debug_draw(id)
		"viewscale":
			var scale : float = float(args[0]) if args.size() > 0 else 1.0
			get_tree().root.content_scale_factor = scale
		"spawn_enemy":
			var enemy : String = "res://prefab/entity/enemy/" + str(args[0] + ".tscn")
			
		"print_to_chat":
			_c_print_to_chat = not _c_print_to_chat
		_:
			say("Unknown command: " + cmd, Color.RED)
			say("Type 'help' for a list of commands.")

func say(log : Variant, color : Color = Color.WHITE, debug_only : bool = false) -> void:
	print("TUX: ", log)
	if not _G.debug_mode and debug_only: 
		return
	var hex : String = "#%02x%02x%02x" % [color.r8, color.g8, color.b8]
	output.text = output.text + "[color=" + hex + "]" + str(log) + "[/color]\n"
	if not _validate_game(): return
	if not _c_print_to_chat: return
	_G.game.chat.add_message("TUX: " + str(log))

func set_stat(value, stat : StringName = "actual_atkspd") -> void:
	if not _validate_game(): return
	if not _validate_player(): return
	
	_G.player.stats.set(stat, value)
	
	say("Set stat " + stat + " to " + str(_G.player.get(stat)))

func help(page : int = -1) -> void:
	match page:
		0:
			say("=== Global Commands ===")
			say(" debug - Toggles debug info")
			say(" reload - Reloads the current scene")
			say(" say <text> - Outputs text to console")
			say(" timescale <float> - Sets time scale (default: 1.0)")
			say(" scene <path> - Changes the scene")
		1:
			say("=== Game Commands ===")
			say(" hitbox - Shows/hides hitbox shapes")
			say(" god - Toggles god mode")
			say(" noclip - Toggles noclip flying")
			say(" fullbright - Toggles fullbright")
			say(" autobhop <0|1> - Toggles auto bunnyhopping")
			say(" moveinf [debug] - Toggles movement info")
			say(" map <name> - Loads map from game assets")
			say(" map_custom <name> - Loads map from custom_levels appdata directory")
			say(" set_pmvar <property> <value> - Sets player movement var")
			say(" dbg_camera - Switches to debug camera")
			say(" disable_enemies - Toggles enemy AI")
		2:
			say("=== Other Commands ===")
			say(" debug_draw <id> - Set viewport debug draw mode")
			say(" dark - Toggle dark mode")
		_:
			say("=== TUX Console Help ===")
			say("Type 'help <page>' for command details:")
			say(" help 0 - Global Commands")
			say(" help 1 - Game Commands")
			say(" help 2 - Other Commands")

func reload() -> void:
	get_tree().reload_current_scene()
	say("Scene Reloaded.", Color.YELLOW)

func scene(scene_path : String = "") -> void:
	if scene_path.is_empty():
		say("Usage: scene <path>", Color.RED)
		return
	_G.change_scene(scene_path)
	say("Changed scene to " + scene_path, Color.GREEN)

func timescale(scale : float = 1.0) -> void:
	_G.time_scale[1] = scale
	say("Time scale set to " + str(scale), Color.GREEN)

func debug() -> void:
	if not OS.has_feature("debug"):
		say("This is not a debug build!", Color.RED)
		return
	
	_G.debug_mode = not _G.debug_mode
	var state = "enabled" if _G.debug_mode else "disabled"
	say("Debug mode " + state, Color.YELLOW)

func hitbox() -> void:
	get_tree().debug_collisions_hint = not get_tree().debug_collisions_hint
	var state = "visible" if get_tree().debug_collisions_hint else "hidden"
	say("Hitboxes " + state, Color.YELLOW)
	if get_tree().debug_collisions_hint:
		say("Note: May need to reload scene", Color.GRAY)

func dbg_camera() -> void:
	if not _validate_player():
		return
	_G.player.debug_camera()
	say("Debug camera toggled")

func god() -> void:
	if not _validate_player():
		return
	_G.player.god_mode = not _G.player.god_mode
	var state = "enabled" if _G.player.god_mode else "disabled"
	say("God mode " + state, Color.YELLOW)

func debug_draw(id : int = 0) -> void:
	get_viewport().debug_draw = id
	say("Viewport debug_draw: " + str(get_viewport().get_debug_draw()))

func moveinf(show_debug : int = 0) -> void:
	if not _validate_player():
		return
	
	_G.player.hud.show_movement_info = not _G.player.hud.show_movement_info
	var state = "enabled" if _G.player.hud.show_movement_info else "disabled"
	say("Movement info " + state)
	
	if show_debug == 1:
		_G.player.hud.show_movement_var = true
		say("Movement debug vars enabled")

func fullbright() -> void:
	if not _validate_player():
		return
	# Add your fullbright implementation here
	say("Fullbright toggled", Color.YELLOW)

func map(path : String = "ether") -> void:
	if not _validate_game():
		return
	_G.game.change_map_autobuild("res://maps/" + path + ".map")
	say("Loading map: " + path, Color.GREEN)

func map_custom(path : String = "template") -> void:
	if not _validate_game():
		return
	_G.game.change_map_autobuild("user://custom_maps/" + path + ".map")
	say("Loading custom map: " + path, Color.GREEN)

func disable_enemies() -> void:
	if not _validate_game():
		return
	_G.game.enemies_disabled = not _G.game.enemies_disabled
	var state = "disabled" if _G.game.enemies_disabled else "enabled"
	say("Enemies " + state, Color.YELLOW)

func set_pmvar(property : StringName, value : float = 0.0) -> void:
	if not _validate_player():
		return
	
	if not property in _G.player.movement_component:
		say("Property '" + property + "' not found", Color.RED)
		return
	
	_G.player.movement_component.set(property, value)
	say("Set %s = %s" % [property, str(value)], Color.GREEN)

func autobhop(enabled : int = -1) -> void:
	if not _validate_player():
		return
	
	# Toggle if no arg, otherwise set explicitly
	if enabled == -1:
		_G.player.movement_component.auto_bhop = not _G.player.movement_component.auto_bhop
	else:
		_G.player.movement_component.auto_bhop = (enabled == 1)
	
	var state = "enabled" if _G.player.movement_component.auto_bhop else "disabled"
	say("Auto bunnyhopping " + state, Color.GREEN)
	if _G.player.movement_component.auto_bhop:
		say("Hold jump to keep jumping", Color.GRAY)

func noclip() -> void:
	if not _validate_player():
		return
	
	_G.player.movement_component.noclip = not _G.player.movement_component.noclip
	_G.player.god_mode = _G.player.movement_component.noclip
	
	var state = "enabled" if _G.player.movement_component.noclip else "disabled"
	say("Noclip " + state, Color.GREEN)

func dark() -> void:
	_G.config.ui_dark_mode = not _G.config.ui_dark_mode
	var state = "enabled" if _G.config.ui_dark_mode else "disabled"
	say("Dark mode " + state)

# Helper validation functions
func _validate_player() -> bool:
	if _G.player == null or not _G.player.is_inside_tree():
		say("Player object not found. Must be in game.", Color.RED)
		return false
	return true

func _validate_game() -> bool:
	if _G.game == null or not _G.game.is_inside_tree():
		return false
	return true
