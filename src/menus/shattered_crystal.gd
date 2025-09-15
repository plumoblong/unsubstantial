extends Node2D

@export var time_offset : float = 0.0
var hovering : bool = true
var essence : int = 500

signal pressed

func _ready() -> void:
	$Sprite2D.modulate = Color.DARK_GRAY
	$Sprite2D2.modulate = Color.DARK_GRAY
	set_essence() 

func set_essence() -> void:
	essence = randi_range(50, 100) * 10

func _process(_delta : float) -> void:
	$Sprite2D.position.y = _G.sine_movement(1.5, 12.0, time_offset + 1.5)
	$Sprite2D2.position.y = _G.sine_movement(1.25, 12.0, time_offset + 0.0)
	$Text/Essence.text = str(essence)
	#if visible:
		#$Button.mouse_filter = 2
	#else:
		#$Button.mouse_filter = 0

func hovered() -> void:
	_G.tween($Sprite2D, "modulate", Color.WHITE, 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)
	_G.tween($Sprite2D2, "modulate", Color.WHITE, 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)
	_G.tween($Text, "modulate", Color.WHITE, 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)
#
func unhovered() -> void:
	_G.tween($Sprite2D, "modulate", Color.DARK_GRAY, 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)
	_G.tween($Sprite2D2, "modulate", Color.DARK_GRAY, 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)
	_G.tween($Text, "modulate", Color(1, 1, 1, 0), 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)
	
func button_mouse_entered() -> void:
	hovered() 

func button_mouse_exited() -> void:
	unhovered()

func button_pressed() -> void:
	_G.player.essence_component.essence += essence
	pressed.emit()
