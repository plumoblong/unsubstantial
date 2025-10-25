extends CanvasLayer
class_name CrystalChoose

var confirmed_crystal : int = 0

@onready var crystal_piece1 : CrystalPiece = get_node("CrystalPiece1")
@onready var crystal_piece2 : CrystalPiece = get_node("CrystalPiece2")

var description_text : String = ". . ."

func _ready() -> void:
	if _G.config.ui_dark_mode:
		_G.shader_inverted = true
	else:
		_G.shader_inverted = false

func start_choose() -> void:
	_G.game.in_any_menu = true
	description_text = ". . ."
	await get_tree().create_timer(0.25).timeout
	_G.flare_screen(Color(1,1,1,1), Color(1,1,1,0), 0.75)
	show()
	crystal_piece1.on_start()
	crystal_piece2.on_start()
	return
	
func end_choose() -> void:
	crystal_piece1.enabled = false
	crystal_piece2.enabled = false
	hide()
	_G.flare_screen(Color(1,1,1,1), Color(1,1,1,0), 0.5)
	await get_tree().create_timer(0.25).timeout
	_G.game.in_any_menu = false
	
func _process(_delta: float) -> void:
	$Text2.text = description_text
	$Text2/Shadow.text = description_text
	$Text2/Shadow2.text = description_text
