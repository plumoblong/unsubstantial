extends ColorRect
class_name Flare

var start_color : Color = Color.BLACK
var end_color : Color = Color(0,0,0,0)
var time : float = 1.0
var fade_out : float = 0.1
var easing : Tween.EaseType = Tween.EASE_IN_OUT
var transition : Tween.TransitionType = Tween.TRANS_LINEAR

var life_time : float = 0.0

#func _ready() -> void:
	#life_time = time

func fade() -> void:
	show()
	color = start_color
	fade_out = time / 5.0
	await get_tree().create_timer(time + fade_out, false, true, true).timeout
	queue_free()

func _process(delta: float) -> void:
	if color != end_color:
		if life_time <= time:
			life_time += delta * Engine.time_scale
		color.r = lerpf(start_color.r, end_color.r, life_time / time)
		color.g = lerpf(start_color.g, end_color.g, life_time / time)
		color.b = lerpf(start_color.b, end_color.b, life_time / time)
		color.a = lerpf(start_color.a, end_color.a, life_time / time)
	else:
		if life_time <= time + fade_out:
			life_time += delta
		color.a = lerpf(color.a, 0.0, life_time / (time + fade_out))
		
	#print(name, life_time)
