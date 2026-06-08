extends Node2D
class_name InventoryUI

const ICON_SCENE : PackedScene = preload("res://prefab/menus/shard_icon.tscn")
const ICON_SIZE : int = 32
var spacing : Vector2i = Vector2i(12, 6)
var columns : int = 5
var rows : int = 3

@onready var icon_holder : Node2D = $IconHolder
@onready var description : RichTextLabel = $Description
@onready var empty_info : RichTextLabel = $Empty
@onready var rarity : Sprite2D = $Rarity
@onready var arrow_right : TextureButton = $ArrowRight
@onready var arrow_left : TextureButton = $ArrowLeft

var current_description : String = "? ? ?"
var current_page : int = 0
var aviable_pages : int = 0
## Snapshot of added_stats taken when the inventory is opened.
var _known_stats : Array = []

func on_open() -> void:
	_known_stats = _G.player.stats.added_stats.duplicate()
	create_shard_grid()

func on_close() -> void:
	_add_new_shards()

func _add_new_shards() -> void:
	var known_count : int = _known_stats.size()
	var all_stats   : Array = _G.player.stats.added_stats
	if all_stats.size() == known_count:
		return
	
	for i : int in range(known_count, all_stats.size()):
		_create_icon_at(i)
	
	_known_stats = all_stats.duplicate()


func _create_icon_at(i: int) -> void:
	if i < icon_holder.get_child_count():
		return

	var icons_per_page : int = columns * rows
	var grid_width  : int = columns * ICON_SIZE + (columns - 1) * spacing.x
	var grid_height : int = rows    * ICON_SIZE + (rows    - 1) * spacing.y
	var start_x : float = -grid_width  / 2.0 + ICON_SIZE / 2.0
	var start_y : float = -grid_height / 2.0 + ICON_SIZE / 2.0

	var page          : int = i / icons_per_page
	var index_in_page : int = i % icons_per_page
	var col           : int = index_in_page % columns
	var row           : int = index_in_page / columns

	var shard_icon : ShardIcon = ICON_SCENE.instantiate()
	shard_icon.position = Vector2(
		start_x + col * (ICON_SIZE + spacing.x) + page * 480.0,
		start_y + row * (ICON_SIZE + spacing.y)
	)
	icon_holder.add_child(shard_icon)
	var stat : Array = _G.player.stats.added_stats[i]
	shard_icon.initialize(stat[0], stat[1])


func create_shard_grid() -> void:
	if _G.player.stats.added_stats.size() == 0: return
	var grid_width : int = columns * ICON_SIZE + (columns - 1) * spacing.x
	var grid_height : int = rows * ICON_SIZE + (rows - 1) * spacing.y
	var start_x : float = -grid_width / 2.0 + ICON_SIZE / 2.0
	var start_y : float = -grid_height / 2.0 + ICON_SIZE / 2.0
	var icons_per_page : int = columns * rows
	
	for i: int in range(_G.player.stats.added_stats.size()):
		_create_icon_at(i)

func delete_shard_grid() -> void:
	if icon_holder.get_child_count() == 0: return
	for i : ShardIcon in icon_holder.get_children():
		i.queue_free()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		on_close()
		
	if Input.is_action_just_pressed("left"):
		arrow_left_pressed()
	elif Input.is_action_just_pressed("right"):
		arrow_right_pressed()
		
	description.text = current_description
	empty_info.visible = _G.player.stats.added_stats.size() == 0
	description.visible = _G.player.stats.added_stats.size() != 0
	
	aviable_pages =  (icon_holder.get_child_count() / 16)
	arrow_left.visible = current_page != 0
	arrow_right.visible = current_page != aviable_pages
	icon_holder.position.x = lerpf(icon_holder.position.x, _R.get_top_left(true).x - (480.0 * current_page), 0.05)
	icon_holder.position.y = _R.get_top_left(true).y - 24
	$Label.text = str(current_page) + " " + str(aviable_pages)
	
func arrow_right_pressed() -> void:
	if current_page >= aviable_pages: return
	current_page += 1

func arrow_left_pressed() -> void:
	if current_page <= 0: return
	current_page -= 1
