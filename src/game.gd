extends Node3D
class_name Game

@onready var current_map : Node3D = $Map
@onready var enemies : Node = $Enemies
@onready var pause_screen : Node2D = $Pause/Node2D
@onready var chapter : ChapterManager = $ChapterManager
@onready var chat : ChatFeed = $ChatFeed
@onready var crystal_choose : CrystalChoose = $CrystalChoose
@onready var pause_node : CanvasLayer = $Pause
@onready var music_player : AudioStreamPlayer = $Music
@onready var ambience_player : AudioStreamPlayer3D = $Ambience
@onready var anim_fix_color : ColorRect = $AnimFix/Color
@onready var difficulty_label : Label = $Label

const MAP_SCENE : PackedScene = preload("res://prefab/level/map.tscn")

var next_level : String
var time_pause : bool = false
var current_level : String = ""
var level_time : float = 0
var stage : int = 0
var actual_stage : int = 0
var music_volume : float = 1.0
var exit_pos : Vector3 = Vector3.ZERO
var enemies_disabled : bool = false
var in_ether : bool = true
var time_scale : float = 1.0
var leveled_up : bool = false
var in_any_menu : bool = false
var ending_level : bool = false
var music : bool = false
var all_gates_visible : bool = false
var all_gates_open : bool = false
var pursuer_spawned : bool = false
var enemy_count : int = 0
var enemy_spawner_count : int = 0
var enemy_multiplier : float = 1.0
var difficulty_bonus : float = 1.0
var enemies_killed : int = 0

signal level_changing

func _ready() -> void:
	_G.game = self
	_G.save.can_continue = false
	_reset_run_stats()
	_initialize_seed()
	_setup_starting_level()
	pause_node.hide()

func _reset_run_stats() -> void:
	_G.current_run.kills = 0
	_G.current_run.hits_taken = 0
	_G.current_run.crystals_collected = 0
	_G.current_run.times_bought = 0
	_G.current_run.times_looped = 0
	_G.current_run.bosses_slained = 0

func _initialize_seed() -> void:
	if _G.run_seed == 0:
		_G.run_seed = int(Time.get_unix_time_from_system())
	seed(_G.run_seed)

func _setup_starting_level() -> void:
	if _G.starting_level == "":
		change_map_autobuild("res://maps/ether.map")
	else:
		chapter.current = chapter.all[1]
		change_map(_G.starting_level)

func _process(_delta : float) -> void:
	_update_game_state()
	_handle_input()
	_update_pause_state()
	_update_player_control()

func _update_game_state() -> void:
	enemy_count = enemies.get_child_count() + enemy_spawner_count
	enemy_multiplier = (1.0 + 0.1 * (actual_stage - 1) ** 1.4) * difficulty_bonus
	difficulty_label.text = "Difficulty: " + str(enemy_multiplier)
	difficulty_label.visible = _G.show_fps
	in_ether = chapter.current == chapter.all[0]
	
	if _G.debug_mode:
		print(enemy_count)

func _handle_input() -> void:
	if ending_level or in_any_menu:
		pause_node.visible = false
		pause_screen.screen = 0
		_G.time_scale[0] = 1.0 * time_scale
		return
	
	if pause_screen.screen == 0:
		if Input.is_action_just_pressed("escape"):
			pause_node.visible = not pause_node.visible
			pause_screen.show()
		elif Input.is_action_just_pressed("inventory"):
			pause_node.visible = true
			pause_screen.show()
			pause_screen.screen = 2
	elif pause_screen.screen == 2:
		if Input.is_action_just_pressed("inventory"):
			pause_screen.show()
			pause_screen.screen = 0

func _update_pause_state() -> void:
	if pause_node.visible:
		_G.time_scale[0] = 0.01
		enemies.process_mode = Node.PROCESS_MODE_DISABLED
		if Input.is_action_just_pressed("f2"):
			pause_screen.visible = not pause_screen.visible
	else:
		_G.time_scale[0] = 1.0 * time_scale
		enemies.process_mode = Node.PROCESS_MODE_INHERIT

func _update_player_control() -> void:
	_G.player.can_control = not pause_node.visible and not ending_level and _G.player.essence_component.alive and not in_any_menu

func change_map(map_file_path : String) -> void:
	var map_file : PackedScene = load(map_file_path)
	if map_file == null:
		_T.say("File " + map_file_path + " doesn't exist.", Color.RED)
		return
	
	if current_map != null:
		current_map.queue_free()
	
	_reset_player_state()
	
	if in_ether:
		in_ether = false
		chapter.current = chapter.all[1]
	
	var map_instance : Node = map_file.instantiate()
	map_instance.name = "Map"
	current_level = map_file_path
	current_map = map_instance
	add_child(current_map)
	ending_level = false
	_T.say("Changed map to " + map_file_path, Color.GREEN)

func _reset_player_state() -> void:
	_G.player.global_position = Vector3.ZERO
	_G.player.global_rotation = Vector3.ZERO
	_G.player.velocity = Vector3.ZERO

func change_map_autobuild(map_file_path : String) -> void:
	if map_file_path == '':
		return
	
	enemies_killed = 0
	current_map.queue_free()
	
	var map_instance : Map = MAP_SCENE.instantiate()
	map_instance.name = "Map"
	current_map = map_instance
	add_child(current_map)
	current_map.build(map_file_path)
	
	_reset_player_state()

func mute_music(time : float = 1.0) -> void:
	_G.tween(music_player, "volume_db", linear_to_db(0.001), time, 0, 0)

func unmute_music(time : float = 1.0) -> void:
	_G.tween(music_player, "volume_db", linear_to_db(1.0), time, 0, 0)

func create_ghost(pos : Vector3, texture : Texture2D, pixel_size : float = 0.03) -> void:
	var gres : PackedScene = load("res://prefab/entity/ghost.tscn")
	var ghost : Ghost = gres.instantiate()
	ghost.global_position = pos
	ghost.sprite = texture
	ghost.pixel_size = pixel_size
	add_child(ghost)

func create_decal(pos : Vector3, life_time : float = 10.0, color : Color = Color.WHITE, damage : int = 0) -> void:
	var dres : PackedScene = load("res://prefab/entity/decal.tscn")
	var dec : Decal = dres.instantiate()
	dec.life_time = life_time
	dec.color = color
	dec.global_position = pos
	dec.damage = damage
	add_child(dec)

func create_popup_text(pos : Vector3, text : String = "kupsztal", color : Color = Color.WHITE, crit : bool = false) -> void:
	return

func create_xporb(pos : Vector3, amount : float = 1.0, spawn_radius : float = 1.0) -> void:
	var res : PackedScene = load("res://prefab/entity/xp_orb.tscn")
	
	for i in range(amount):
		var obj : Node3D = res.instantiate()
		if get_tree() != null:
			await get_tree().create_timer(0.0 + i / 50.0).timeout
		
		add_child(obj)
		var offset := Vector3(
			randf_range(-spawn_radius * 0.5, spawn_radius * 0.5),
			randf_range(-spawn_radius * 0.5, spawn_radius * 0.5),
			randf_range(-spawn_radius * 0.5, spawn_radius * 0.5)
		)
		obj.global_position = pos + offset

func end_level(loop : bool = false) -> void:
	if ending_level:
		return
	
	ending_level = true
	ambience_player.stop()
	level_changing.emit()
	
	anim_fix_color.color = _G.get_color_darkmode(true, 0.0)
	_G.tween(anim_fix_color, "color", _G.get_color_darkmode(true, 1.0), 0.5)
	
	switch_chapters()
	stage += 1
	actual_stage += 1
	
	await get_tree().create_timer(0.75).timeout
	
	_clear_enemies()
	_load_next_map()

func _clear_enemies() -> void:
	for n in enemies.get_children():
		n.queue_free()

func _load_next_map() -> void:
	var m : String = chapter.get_map()
	change_map_autobuild(m)
	
	var ambience_pos := chapter.current.ambience_position
	ambience_player.global_position = Vector3(
		randf_range(-ambience_pos.x, ambience_pos.x),
		randf_range(-ambience_pos.y, ambience_pos.y),
		randf_range(-ambience_pos.z, ambience_pos.z)
	)
	ambience_player.stream = chapter.current.ambience_streams.pick_random()
	ambience_player.play()

func wait(time : float = 0.07) -> void:
	time_scale = 0.0
	await get_tree().create_timer(time, true, false, true).timeout
	time_scale = 1.0

func map_build_complete() -> void:
	anim_fix_color.color = _G.get_color_darkmode(true, 1.0)
	_G.tween(anim_fix_color, "color", _G.get_color_darkmode(true, 0.0), 0.5)
	ending_level = false

func map_build_failed() -> void:
	anim_fix_color.hide()
	ending_level = false

func timer_timeout() -> void:
	_G.player.camera.screenshot()

func switch_chapters() -> void:
	match actual_stage:
		0:
			chapter.current = chapter.all[1]
