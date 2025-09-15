extends Node3D

var color : Color = Color.WHITE
var text : String = "?"
var big : bool = false

func _ready() -> void:

	$Sprite.position = Vector3(randf_range(-0.5, 0.5), 0.0, randf_range(-0.5, 0.5)).normalized()
	print("crit")
	_G.tween($Sprite, "position", Vector3($Sprite.position.x, $Sprite.position.y + 0.75, $Sprite.position.z), 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN) 
	_G.tween($Sprite, "modulate", Color(color.r, color.g, color.b, 0.0), 1.5, Tween.TRANS_LINEAR, Tween.EASE_OUT) 
	await get_tree().create_timer(1.5).timeout
	queue_free.call_deferred()

func _process(_delta : float) -> void:
	if big:
		$Sprite.pixel_size = 0.0035
		color *= Color.YELLOW
	else:
		$Sprite.pixel_size = 0.0025
		color *= Color.WHITE
	$Sprite.modulate = color
	$Sprite.text = text
