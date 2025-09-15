extends Node3D
class_name Game

@onready var current_map : Node3D = get_node("Map") 
@onready var special_room : Node3D = get_node("SpecialRoom")
@onready var item_pool : ItemPoolManager = get_node("ItemPoolManager")
@onready var transition : CanvasLayer = get_node("Transition")
@onready var enemies  : Node = get_node("Enemies")
@onready var pause_screen : Node2D = get_node("Pause/Node2D")
@onready var chapter : ChapterManager = get_node("ChapterManager")
@onready var chat : ChatFeed = get_node("ChatFeed")
@onready var debug_light : Node3D = get_node("DebugLight")

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

var in_ether : bool = false
var time_scale : float = 1.0

var leveled_up : bool = false
var in_transition : bool = false
var ending_level : bool = false
var music : bool = false

var all_gates_visible : bool = false
var all_gates_open : bool = false
var pursuer_spawned : bool = false
var enemy_count : int = 0
var enemy_spawner_count : int = 0
var enemy_multiplier : float = 1.0

signal level_changing

func _ready() -> void:
	_G.game = self
	_G.save.can_continue = false
	_G.current_run.kills = 0
	_G.current_run.hits_taken = 0
	_G.current_run.items_collected.common = 0
	_G.current_run.items_collected.uncommon = 0
	_G.current_run.items_collected.rare = 0
	_G.current_run.items_collected.legendary = 0
	_G.current_run.items_collected.mythic = 0
	_G.current_run.times_bought = 0
	_G.current_run.times_looped = 0
	_G.current_run.bosses_slained = 0
	seed(int(Time.get_unix_time_from_system()))
	if _G.starting_level == "":
		change_map("res://level/ether.tscn")
		in_ether = true
		chapter.current = chapter.all[0]
	else:
		chapter.current = chapter.all[1]
		change_map(_G.starting_level)
	$Pause.hide()
	
	
func _process(_delta : float) -> void:
	$WorldEnvironment.environment = chapter.current.environment
	enemy_count = enemies.get_child_count() + enemy_spawner_count
	enemy_multiplier = 1 + snappedf(((actual_stage - 2) / 7.5) + ((_G.player.level_component.level - 1) / 7.5) + _G.current_run.times_looped, 0.05)
	$Label.text = "ENEMY MULT: " + str(enemy_multiplier)
	$Label.visible = _G.debug_mode
	if _G.debug_mode: print(enemy_count)
	if not in_transition:
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
		#if not in_ether: if enemy_count == 0:
			#if not leveled_up and not $PursuerSpawn.spawned:
				#_G.player.level_component.gain_xp(_G.player.level_component.max_xp / 2)
				#chat.add_message("Everybody is dead... ", Color.RED)
				#
	else:  
		$Pause.visible = false

	#$ItemChoose.visible = in_transition
	
	_G.player.can_control = not $Pause.visible and not in_transition and _G.player.essence_component.alive
	$WorldEnvironment.environment.glow_enabled = not _G.config.video.low
	
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
	for i in range(amount / (int(leveled_up) + 1)):
		var res : PackedScene = load("res://prefab/entity/xp_orb.tscn")
		var obj : Node3D = res.instantiate()
		if get_tree() != null:
			await get_tree().create_timer(0.0 + i / 50.0).timeout
		add_child(obj)
		obj.global_position = pos + Vector3(randf_range(-spawn_radius / 2.0, spawn_radius / 2.0), randf_range(-spawn_radius / 2.0, spawn_radius / 2.0), randf_range(-spawn_radius / 2.0, spawn_radius / 2.0))

func end_level(loop : bool = false) -> void:
	if ending_level: return
	#if not loop:
		#if stage == 6:
			#_G.change_scene("res://scene/end_game.tscn")
	ending_level = true
	$Ambience.stop()
	level_changing.emit()
	
	transition.ascend_in()
	stage += 1
	actual_stage += 1
	await get_tree().create_timer(0.75).timeout
	leveled_up = false
	##_G.player.essence_component.essence = _G.player.stat.essence.max\
	#all_gates_open = false
	#all_gates_visible = false
	#_G.player.has_key = false
	for n in enemies.get_children():
		n.queue_free()
	change_map("res://level/chapter1/map_test.tscn")
	chat.add_message("You have beaten this level " + str(stage - 1) + " times.", Color.WHITE)

		
	$Ambience.global_position = Vector3(randf_range(-chapter.current.ambience_position.x, chapter.current.ambience_position.x), 
	randf_range(-chapter.current.ambience_position.y, chapter.current.ambience_position.y), 
	randf_range(-chapter.current.ambience_position.z, chapter.current.ambience_position.z))
	$Ambience.stream = chapter.current.ambience_streams.pick_random()
	$Ambience.play()
	
func save_game() -> void:
	_G.save.can_continue = true
	var s : PackedScene = PackedScene.new()
	s.pack(self)
	ResourceSaver.save(s, "user://last_run.tscn")

func wait(time : float = 0.03) -> void:
	time_scale = 0.01
	await get_tree().create_timer(time, true, false, true).timeout
	time_scale = 1.0

func _notification(what) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		if not _G.debug_mode:
			$Pause.visible = true
			pause_screen.show()
