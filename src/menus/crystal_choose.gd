extends CanvasLayer
class_name CrystalChoose

const CRYSTAL_PIECE_SCENE : PackedScene = preload("res://prefab/menus/crystal_piece.tscn")

@onready var crystals : Node2D = $Crystals

var description_text : String = ". . ."
var margin           : float  = 64.0


func start_choose(pool: StatShardPool) -> void:
	_G.game.in_any_menu = true
	description_text    = ". . ."

	_spawn_crystals(_G.player.stats.choices, pool.build_pool(), pool)

	await get_tree().create_timer(0.5).timeout
	_G.flare_screen(Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.75)
	show()


func end_choose() -> void:
	for piece in crystals.get_children():
		piece.queue_free()
	hide()
	_G.flare_screen(Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5)
	await get_tree().create_timer(0.25).timeout
	_G.game.in_any_menu = false


func _process(_delta: float) -> void:
	if not _G.game.in_any_menu:
		return
	$Description/Text2.text         = description_text
	$Description/Text2/Shadow.text  = description_text
	$Description/Text2/Shadow2.text = description_text
	_update_positions()


# ── private ──────────────────────────────────────────────────────────────────

func _spawn_crystals(amount: int, weighted_pool: Dictionary[StatShard, int], stat_pool : StatShardPool) -> void:
	var crystal_width   := 128.0 * _R.get_aspect_coefficient()
	var crystal_spacing := _calculate_spacing(amount, crystal_width)
	var total_width     := amount * crystal_width + (amount - 1) * crystal_spacing
	var start_x         := -(total_width / 2.0) + (crystal_width / 2.0)
	
	var rarity : Modulate.RARITY = _G.game.shard_picker.pick_rarity(stat_pool, _G.player.stats.actual_luck)
	
	for i in amount:
		var piece  : CrystalPiece = CRYSTAL_PIECE_SCENE.instantiate()

		var result : Array = _G.game.shard_picker.pick(weighted_pool, rarity)
		
		
		crystals.add_child(piece)
		piece.setup(result[0], result[1])
		piece.name     = "CrystalPiece%d" % i
		piece.position = Vector2(start_x + i * (crystal_width + crystal_spacing), 0.0)


func _calculate_spacing(amount: int, crystal_width: float) -> float:
	if amount <= 1:
		return 0.0
	var usable_width := _R.get_screen_size().x - (margin * 2.0)
	return (usable_width - (amount * crystal_width)) / (amount - 1)


func _update_positions() -> void:
	var screen := _R.get_screen_size()
	$Header.global_position = _R.get_top_center()
	$Description.global_position = _R.get_bottom_center()
	$Crystals.position = _R.get_center()
