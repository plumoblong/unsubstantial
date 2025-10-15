extends CanvasLayer
class_name CrystalChoose

var confirmed_crystal : int = 0

@onready var crystal_piece1 : CrystalPiece = get_node("CrystalPiece1")
@onready var crystal_piece2 : CrystalPiece = get_node("CrystalPiece2")

func start_choose() -> void:
	crystal_piece1.on_start()
	crystal_piece2.on_start()
	
func _process(delta: float) -> void:
	if not visible: return
	if Input.is_action_just_pressed("jump"):
		start_choose()
