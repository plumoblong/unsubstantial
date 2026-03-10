extends CanvasLayer
class_name CrystalChoose

const CRYSTAL_PIECE_SCENE : PackedScene = preload("res://prefab/menus/crystal_piece.tscn")

var margin : float = 64.0

@onready var crystals : Node2D = get_node("Crystals")

var description_text : String = ". . ."

var last_pool : Dictionary[StatShard, int] = {}

func create_crystals(amount: int = 2) -> void:
	var crystal_spacing: float = 0.0
	var crystal_width : float = 128.0  * _R.get_aspect_coefficient()
	if amount > 1:
		var total_crystal_width: float = amount * crystal_width
		var total_gap_space: float = (_R.get_screen_size().x - (margin * 2.0)) - total_crystal_width
		crystal_spacing = total_gap_space / (amount - 1)
	var total_width: float = (amount * crystal_width) + ((amount - 1) * crystal_spacing)
	var start_x: float = -(total_width / 2.0) + (crystal_width / 2.0)
	for i: int in range(amount):
		var crystal: CrystalPiece = CRYSTAL_PIECE_SCENE.instantiate()
		crystals.add_child(crystal)
		crystal.name = "CrystalPiece" + str(i)
		crystal.position = Vector2(start_x + i * (crystal_width + crystal_spacing), 0.0)

func start_choose(pool : StatShardPool) -> void:
	_G.game.in_any_menu = true
	description_text = ". . ."
	
	last_pool = pool.init_pool()
	create_crystals(_G.player.stats.choices)

	for i : CrystalPiece in crystals.get_children():
		i.on_start(last_pool)
		last_pool[i.chosen_stat] = 0
	await get_tree().create_timer(0.5).timeout
	_G.flare_screen(Color(1,1,1,1), Color(1,1,1,0), 0.75)
	show()
	return

func end_choose() -> void:
	for i : CrystalPiece in crystals.get_children():
		i.queue_free()
	hide()
	_G.flare_screen(Color(1,1,1,1), Color(1,1,1,0), 0.5)
	await get_tree().create_timer(0.25).timeout
	_G.game.in_any_menu = false
	
func _process(_delta: float) -> void:
	if not _G.game.in_any_menu: return
	$Text2.text = description_text
	$Text2/Shadow.text = description_text
	$Text2/Shadow2.text = description_text
	_update_positions()

func _update_positions() -> void:
	$Text.size.x = _R.get_screen_size().x
	$Text.size.y = _R.get_screen_size().y / 4.0
	$Text/Shadow.size = $Text.size
	$Text/Shadow2.size = $Text.size
	$Crystals.position = _R.get_center()
