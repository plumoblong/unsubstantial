extends Node3D
class_name Game

@onready var current_map : Node3D = get_node("Map") 
@onready var item_pool : ItemPoolManager = get_node("ItemPoolManager")
@onready var enemies  : Node = get_node("Enemies")
@onready var pause_screen : Node2D = get_node("Pause/Node2D")
@onready var chapter : ChapterManager = get_node("ChapterManager")
@onready var chat : ChatFeed = get_node("ChatFeed")
@onready var crystal_choose : CrystalChoose = get_node("CrystalChoose")

const MAP_SCENE : PackedScene = preload("res://prefab/level/map.tscn")

var next_level : String

var time_pause : bool = false

var current_level : String = ""
var level_time : float = 0
var stage : int = 0
var actual_stage : int = 0

var music_volume : float = 1.0

#var in_special : bool = false
#var special_aviable : bool = false
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
var enemies_killed : int = 0

signal level_changing

func _ready() -> void:
	_G.game = self
	_G.save.can_continue = false
	_G.current_run.kills = 0
	_G.current_run.hits_taken = 0
	_G.current_run.crystals_collected = 0
	_G.current_run.times_bought = 0
	_G.current_run.times_looped = 0
	_G.current_run.bosses_slained = 0
	seed(int(Time.get_unix_time_from_system()))
	if _G.starting_level == "":
		change_map_autobuild("res://maps/ether.map")
	else:
		chapter.current = chapter.all[1]
		change_map(_G.starting_level)
	$Pause.hide()
	
func _process(_delta : float) -> void:
	
	enemy_count = enemies.get_child_count() + enemy_spawner_count
	enemy_multiplier = 1 + sqrt(float(actual_stage - 1.0) * 0.13) * float(actual_stage)
	$Label.text = "Difficulty: " + str(enemy_multiplier)
	$Label.visible = _G.debug_mode
	in_ether = chapter.current == chapter.all[0]

	if _G.debug_mode: print(enemy_count)
	if not ending_level or not in_any_menu:
		if pause_screen.screen == 0:
			if Input.is_action_just_pressed("escape"):
				$Pause.visible = not $Pause.visible
				pause_screen.show()
			elif Input.is_action_just_pressed("inventory"):
				$Pause.visible = true
				pause_screen.show()
				pause_screen.screen = 2
		elif pause_screen.screen == 2:
			if Input.is_action_just_pressed("inventory"):
				#$Pause.visible = not $Pause.visible
				pause_screen.show()
				pause_screen.screen = 0
		if $Pause.visible:
			_G.time_scale[0] = 0.01
			enemies.process_mode = Node.PROCESS_MODE_DISABLED
			if Input.is_action_just_pressed("f2"):
				pause_screen.visible = not pause_screen.visible
		else:
			_G.time_scale[0] = 1.0 * time_scale
			enemies.process_mode = Node.PROCESS_MODE_INHERIT
	else:  
		$Pause.visible = false
		pause_screen.screen = 0
		_G.time_scale[0] = 1.0 * time_scale
	_G.player.can_control = not $Pause.visible and not ending_level and _G.player.essence_component.alive and not in_any_menu
	
func change_map(map_file_path : String) -> void:
	var map_file : PackedScene = load(map_file_path)
	if map_file != null:
		if current_map != null:
			current_map.queue_free()
		_G.player.global_position = Vector3.ZERO
		_G.player.global_rotation = Vector3.ZERO
		_G.player.velocity = Vector3.ZERO
		#_G.player.movement_component.speed = _G.player.movement_component.default_speed
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
	else:
		_T.say("File " + map_file_path + " doesn't exist.", Color.RED)

func change_map_autobuild(map_file_path : String) -> void:
	if map_file_path == '': return
	enemies_killed = 0
	current_map.queue_free()
	var map_instance : Map = MAP_SCENE.instantiate()
	map_instance.name = "Map"
	current_map = map_instance
	add_child(current_map)
	current_map.build(map_file_path)
	#if chapter.current != chapter.all[0]:
		#in_ether = false
	chapter.current = chapter.all[current_map.chapter_id]
	
	_G.player.global_position = Vector3.ZERO
	_G.player.global_rotation = Vector3.ZERO
	_G.player.velocity = Vector3.ZERO
	
func mute_music(time : float = 1.0) -> void:
	_G.tween($Music, "volume_db", linear_to_db(0.001), time, 0, 0)
	
func unmute_music(time : float = 1.0) -> void:
	_G.tween($Music, "volume_db", linear_to_db(1.0), time, 0, 0)

func create_ghost(pos : Vector3, texture : Texture2D, pixel_size : float = 0.03) -> void:
	var gres : PackedScene = load("res://prefab/entity/ghost.tscn")
	var ghost : Ghost = gres.instantiate()
	
	ghost.global_position = pos
	ghost.sprite = texture
	ghost.pixel_size = pixel_size
	add_child(ghost)

func create_decal(pos : Vector3, life_time : float = 10.0 , color : Color = Color.WHITE, damage : int = 0) -> void:
	var dres : PackedScene = load("res://prefab/entity/decal.tscn")
	var dec : Decal = dres.instantiate()
	add_child(dec)
	dec.life_time = life_time
	dec.color = color
	dec.global_position = pos
	dec.damage = damage
	
func create_popup_text(pos : Vector3, text : String = "kupsztal", color : Color = Color.WHITE, crit : bool = false) -> void:
	return
	var cres : PackedScene = load("res://prefab/entity/crit_text.tscn")
	var pp : Node3D = cres.instantiate()
	add_child(pp)
	pp.global_position = pos
	pp.color = color
	pp.text = text
	pp.big = crit
	
func create_xporb(pos : Vector3, amount : float = 1.0, spawn_radius : float = 1.0) -> void:
	for i in range(amount):
		var res : PackedScene = load("res://prefab/entity/xp_orb.tscn")
		var obj : Node3D = res.instantiate()
		if get_tree() != null:
			await get_tree().create_timer(0.0 + i / 50.0).timeout
		add_child(obj)
		obj.global_position = pos + Vector3(randf_range(-spawn_radius / 2.0, spawn_radius / 2.0), randf_range(-spawn_radius / 2.0, spawn_radius / 2.0), randf_range(-spawn_radius / 2.0, spawn_radius / 2.0))
		
func end_level(loop : bool = false) -> void:
	if ending_level: return
	ending_level = true
	$Ambience.stop()
	level_changing.emit()
	$AnimFix/Color.color = _G.get_color_darkmode(true, 0.0)
	_G.tween($AnimFix/Color, "color", _G.get_color_darkmode(true, 1.0), 0.5)
	stage += 1
	actual_stage += 1
	await get_tree().create_timer(0.75).timeout
	
	for n in enemies.get_children():
		n.queue_free()
	var m : String = chapter.get_map()
	change_map_autobuild(m)
	$Ambience.global_position = Vector3(randf_range(-chapter.current.ambience_position.x, chapter.current.ambience_position.x), 
	randf_range(-chapter.current.ambience_position.y, chapter.current.ambience_position.y), 
	randf_range(-chapter.current.ambience_position.z, chapter.current.ambience_position.z))
	$Ambience.stream = chapter.current.ambience_streams.pick_random()
	$Ambience.play()

func wait(time : float = 0.07) -> void:
	time_scale = 0.0
	await get_tree().create_timer(time, true, false, true).timeout
	time_scale = 1.0
			
func map_build_complete() -> void:
	$AnimFix/Color.color = _G.get_color_darkmode(true, 1.0)
	_G.tween($AnimFix/Color, "color", _G.get_color_darkmode(true, 0.0), 0.5)
	ending_level = false
	#$WorldEnvironment.set_env

func map_build_failed() -> void:
	$AnimFix/Color.hide()
	ending_level = false
