extends Node3D
class_name Game

var current_map : Map
@onready var map_bulder : FuncGodotMap = $Map/Builder
@onready var enemies : Node = $Enemies
@onready var pause_screen : Node2D = $Pause/Node2D
@onready var chapter : ChapterManager = $ChapterManager
@onready var chat : ChatFeed = $ChatFeed
@onready var crystal_choose : CrystalChoose = $CrystalChoose
@onready var pause_node : CanvasLayer = $Pause
@onready var music_player : AudioStreamPlayer = $Music
@onready var ambience_player : AudioStreamPlayer3D = $Ambience
@onready var anim_fix_color : ColorRect = $AnimFix/Color
@onready var difficulty_label : Label = $AnimFix/Label
@onready var world_env : WorldEnvironment = $Environment
@onready var shard_picker : ShardPickerComponent = $ShardPicker
@onready var spawn_timer : Timer = $SpawnTimer
@onready var spawner : SpawnCoordinator = $SpawnCoordinator
@onready var nav_scheduler : NavSchedulerComponent = $NavScheduler

const MAP_SCENE                  : PackedScene = preload("res://prefab/level/map.tscn")
const BULLET_SCENE               : PackedScene = preload("res://prefab/entity/bullet.tscn")
const GHOST_SCENE                : PackedScene = preload("res://prefab/entity/ghost.tscn")
const XPORB_SCENE                : PackedScene = preload("res://prefab/entity/xp_orb.tscn")
const WORLDTEXT_SCENE            : PackedScene = preload("res://prefab/menus/world_text_popup.tscn")
const SHARD_COLLECTABLE_SCENE    : PackedScene = preload("res://prefab/entity/shard_collectible.tscn")
const EXPLOSION_RING_SCENE       : PackedScene = preload("res://prefab/entity/damage_ring.tscn")
const SPAWN_ANIM_SCENE           : PackedScene = preload("res://prefab/animation/spawning.tscn")

var next_level : String
var time_pause : bool = false

var current_level : String = ""
var current_map_path : String = ""
var level_time : float = 0

var actual_stage : int = 0
var chapter_stage : int = 0
## last stage before looping back to the CHAPTER_DEFAULT_STAGE stage
const CHAPTER_MAX_STAGE : int = 5
const CHAPTER_DEFAULT_STAGE : int = 1

var music_volume : float = 1.0
var music : bool = false

var exit_pos : Vector3 = Vector3.ZERO
var enemies_disabled : bool = false
var in_ether : bool = true

var time_scale : float = 1.0

var leveled_up : bool = false

var in_any_menu : bool = false
var ending_level : bool = false

var all_gates_visible : bool = false
var all_gates_open : bool = false

var pursuer_spawned : bool = false
var enemy_count : int = 0
var enemy_spawner_count : int = 0
var enemies_killed : int = 0
var bosses_killed : int = 0

var enemy_multiplier : float = 1.0
var difficulty_bonus : float = 1.0

signal level_changing
signal map_built

var nav_mesh : NavigationMesh

#var spawn_queue : Array[EnemySpawner]

func _ready() -> void:
	_G.game = self
	_G.save.can_continue = false
	_reset_run_stats()
	_initialize_seed()
	
	pause_node.hide()
	_setup_starting_level()

func _reset_run_stats() -> void:
	_G.current_run.kills = 0
	_G.current_run.boss_kills = 0
	_G.current_run.hits_taken = 0
	_G.current_run.crystals_collected = 0
	_G.current_run.times_looped = 0

func _initialize_seed() -> void:
	if _G.run_seed == 0:
		_G.run_seed = int(Time.get_unix_time_from_system())
	seed(_G.run_seed)

func _setup_starting_level() -> void:
	if _G.starting_level == "":
		chapter.current = chapter.all[0]
		_load_next_map()
	else:
		change_map(_G.starting_level)
	_S.fade_song(1.0, 1.5)
	_S.change_pitch(1.0, 1.0)
	
func _process(_delta : float) -> void:
	_update_game_state()
	_handle_input()
	_update_pause_state()
	_update_player_control()
	anim_fix_color.size = _R.get_screen_size()
	

func _update_game_state() -> void:
	enemy_count = enemies.get_child_count() + enemy_spawner_count
	enemy_multiplier = max(1.0, (1.0 + 0.1 * (((bosses_killed * 3) + 1) + actual_stage - 2) ** 1.05) * difficulty_bonus)
	
	difficulty_label.text = "Difficulty: " + str(enemy_multiplier) + "\nEnemy Count: " + str(enemy_count) + " / " + str(EnemySpawner.ENEMY_CAP) + "\nSpawn Cooldown: " + str(spawner.current_cooldown) + "\n\nActual Stage: " + str(actual_stage) + "\n\nCurrent Chapter: " + str(chapter.current) + "\nChapter Base Maps: " +  str(chapter.current.maps) + "\nChapter Aviable Maps: " + str(chapter.available_maps)
	in_ether = chapter.current == chapter.all[0]
	difficulty_label.visible = _T.debug_flags[4]
	$AnimFix/Sprite2D.visible = _T.debug_flags[4]
	$AnimFix/Sprite2D.modulate = get_chapter_color() if Engine.get_physics_frames() % 30 == 0 else $AnimFix/Sprite2D.modulate

func set_env(id : int) -> void:
	world_env.set_environment(chapter.environments[id])

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
			pause_screen.statistics_pressed()
	elif pause_screen.screen == 2:
		if Input.is_action_just_pressed("inventory"):
			pause_screen.show()
			pause_screen.screen = 0
			pause_screen.statistics_screen.on_close()

func _update_pause_state() -> void:
	if pause_node.visible:
		_G.time_scale[0] = 0.01
		enemies.process_mode = Node.PROCESS_MODE_DISABLED
		_G.player.camera.process_mode = Node.PROCESS_MODE_DISABLED
		if Input.is_action_just_pressed("f2"):
			pause_screen.visible = not pause_screen.visible

	else:
		_G.time_scale[0] = 1.0 * time_scale
		enemies.process_mode = Node.PROCESS_MODE_INHERIT
		_G.player.camera.process_mode = Node.PROCESS_MODE_INHERIT
		
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
	if current_map != null: current_map.queue_free()
	
	var map_instance : Map = MAP_SCENE.instantiate()
	map_instance.name = "Map"
	add_child(map_instance)
	map_instance.build(map_file_path)
	
	_reset_player_state()

func mute_music(time : float = 1.0) -> void:
	_G.tween(music_player, "volume_db", linear_to_db(0.001), time, 0, 0)

func unmute_music(time : float = 1.0) -> void:
	_G.tween(music_player, "volume_db", linear_to_db(1.0), time, 0, 0)

# creation scripts

func create_ghost(pos : Vector3, texture : Texture2D, pixel_size : float = 0.03, frames : Array[int] = [0, 1, 1], time : float = 1.5) -> void:
	var ghost : Ghost = GHOST_SCENE.instantiate()
	ghost.lifetime = time
	ghost.global_position = pos
	ghost.sprite = texture
	ghost.frame = frames[0]
	ghost.hframes = frames[1]
	ghost.vframes = frames[2]
	ghost.pixel_size = pixel_size
	add_child.call_deferred(ghost)

func create_decal(pos : Vector3, life_time : float = 10.0, color : Color = Color.WHITE, damage : int = 0) -> void:
	var dres : PackedScene = load("res://prefab/entity/decal.tscn")
	var dec : Decal = dres.instantiate()
	dec.life_time = life_time
	dec.color = color
	dec.global_position = pos
	dec.damage = damage
	add_child.call_deferred(dec)

func create_popup_text(pos : Vector3, text : String = "kupsztal", big : bool = false, bounciness : float = 0.5) -> void:
	var popup : WorldTextPopup = WORLDTEXT_SCENE.instantiate()
	popup.big = big
	popup.bounciness = bounciness
	popup.text = text
	popup.global_position = pos
	add_child(popup)

func create_xporb(pos : Vector3, amount : float = 1.0, spawn_radius : float = 1.0, overheal : bool = true) -> void:
	for i in range(amount):
		if _G.player.essence_component.ratio >= 1.0 and not overheal: break 
		var obj : Node3D = XPORB_SCENE.instantiate()
		if get_tree() != null:
			await get_tree().create_timer(0.025).timeout
		
		current_map.add_child(obj)
		var offset := Vector3(
			randf_range(-spawn_radius * 0.5, spawn_radius * 0.5),
			randf_range(-spawn_radius * 0.5, spawn_radius * 0.5),
			randf_range(-spawn_radius * 0.5, spawn_radius * 0.5)
		)
		obj.global_position = pos + offset

func create_shard_collectable(pos : Vector3, shard : Dictionary = { "rarity_override" : -1, "pool_id" : -1, "price_override" : 0.0, "free" : true, "discount" : false, "random_discount" : true, }) -> ShardCollectable:
	var properties : Dictionary = {
	"rarity_override" : shard["rarity_override"],
	"pool_id"         : shard["pool_id"],
	"price_override"  : shard["price_override"],
	"free"            : shard["free"],
	"discount"        : shard["discount"],
	"random_discount" : shard["random_discount"], }
	
	var sh : ShardCollectable = SHARD_COLLECTABLE_SCENE.instantiate()
	sh.auto_pick = false
	sh.func_godot_properties = properties
	sh.global_position = pos
	
	current_map.add_child(sh)
	sh.setup.call_deferred()
	return sh

func create_spawn_anim(pos : Vector3, use_sound : bool = true, size : float = 1.0) -> void:
	var anim : Node = SPAWN_ANIM_SCENE.instantiate()
	anim.global_position = pos
	anim.use_sound = use_sound
	anim.pixel_size = 0.05 * size
	add_child.call_deferred(anim)

func create_exposilon_ring(pos : Vector3, radius : float = 2.0, speed : float = 1.0) -> void:
	var er : DamageRing = EXPLOSION_RING_SCENE.instantiate()
	er.speed = speed
	er.radius = radius
	er.global_position = pos
	add_child.call_deferred(er)

func end_level(loop : bool = false) -> void:
	if ending_level:
		return
	_S.fade_song(0.0, 0.6)
	ending_level = true
	ambience_player.stop()
	level_changing.emit()
	
	anim_fix_color.color = _G.get_color_darkmode(true, 0.0)
	
	_G.tween(anim_fix_color, "color", _G.get_color_darkmode(true, 1.0), 0.5)
	
	await get_tree().create_timer(0.75).timeout
	_S.fade_song(1.0, 1.4)
	actual_stage += 1
	chapter_stage += 1
	switch_chapters()
	
	_clear_enemies()
	_load_next_map()
	

func _clear_enemies() -> void:
	for n in enemies.get_children():
		n.queue_free()
		
func is_boss_stage() -> bool:
	return chapter.current.boss_stage != chapter.current.stage_start \
		and not chapter.current.boss_maps.is_empty() \
		and chapter_stage == chapter.current.boss_stage

func _load_next_map() -> void:
	var m : String = chapter.get_boss_map() if is_boss_stage() else chapter.get_map()
	change_map_autobuild(m)
	_S.change_song(chapter.current.music)
	var ambience_pos := chapter.current.ambience_position
	ambience_player.global_position = Vector3(
		randf_range(-ambience_pos.x, ambience_pos.x),
		randf_range(-ambience_pos.y, ambience_pos.y),
		randf_range(-ambience_pos.z, ambience_pos.z)
	)
	
	if chapter.current.ambience_streams.is_empty(): return
	ambience_player.stream = chapter.current.ambience_streams.pick_random()
	ambience_player.play()
	

func wait(time : float = 0.05) -> void:
	time_scale = 0.0
	await get_tree().create_timer(time, true, false, true).timeout
	time_scale = 1.0

func map_build_complete() -> void:
	anim_fix_color.show()
	anim_fix_color.color = _G.get_color_darkmode(true, 1.0)
	_G.tween(anim_fix_color, "color", _G.get_color_darkmode(true, 0.0), 0.5)
	ending_level = false

func map_build_failed() -> void:
	anim_fix_color.hide()
	ending_level = false

func timer_timeout() -> void:
	_G.player.camera.screenshot()

func switch_chapters() -> void:
	if chapter_stage > CHAPTER_MAX_STAGE:
		chapter_stage = CHAPTER_DEFAULT_STAGE
	
	var next_chapter : Chapter = chapter.get_chapter_for_stage(chapter_stage)
	if next_chapter != chapter.current:
		chapter.available_maps.clear()
	chapter.current = next_chapter
 
func get_chapter_color(sample_override : float = -1.0) -> Color:
	var color : Color = Color(1.0, 0.0, 1.0, 0.5)
	if not chapter.current.color_ranges == null:
		color = chapter.current.color_ranges.sample(randf_range(0.0, 1.0) if sample_override < 0 else sample_override)
	return color
 
func update_rpc(update_timestamp : bool = false) -> void:
	var rpc_details : String = "Chapter " + str(chapter.current.id) + " Stage " + str(chapter_stage)
	var rpc_state : String = current_map_path
	var rpc_small_img : String = "chapter_icon" + str(chapter.current.id)
	var rpc_small_img_text : String = chapter.current.chapter_name
	_G.change_discord_rpc(update_timestamp, rpc_details, rpc_state, rpc_small_img, rpc_small_img_text)
