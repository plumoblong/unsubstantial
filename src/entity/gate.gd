extends CSGBox3D
class_name Gate

@export var open_on_ready : bool = false
@export var gate_color : Color = "aa96b5"
var color : Color = "aa96b5"
@export var sprite_frame : int = 0
@export var alert_text : String = "Find the Key..."
@export var done_if_open : bool = false

var alerted : bool = false
var done : bool = false
var opened : bool = false

func _ready() -> void:
	color = gate_color
	$Sprite3D.hide()
	await get_tree().create_timer(1.0)
	if open_on_ready: 
		open()

func open() -> void:
	if not opened:
		if done_if_open:
			done = true
		opened = true
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)

func close() -> void:
	if opened:
		opened = false
		set_collision_layer_value(1, true)
		set_collision_mask_value(1, true)

func _process(delta : float) -> void:
	if sprite_frame != -1:
		$Sprite3D.frame = sprite_frame + int(done) * 4
	if _G.game.all_gates_visible:
		if sprite_frame != -1:
			$Sprite3D.show()
	if _G.game.all_gates_open:
		open()


func area_3d_body_entered(body : Player) -> void:
	if alerted: return
	if body == _G.player:
		if sprite_frame != -1:
			$Sprite3D.show()
		alerted = true
		if alert_text == "0": return
		_G.game.chat.add_message(alert_text)
	
